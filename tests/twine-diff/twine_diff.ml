(** Differential test of a twine decoder against imandrakit's encoder.

    Environment:
    - [TWINE_DIFF_DECODER]: shell command that starts the decoder program
      (required)
    - [TWINE_DIFF_COUNT]: cases per property (default 1000)
    - [QCHECK_SEED]: random seed (default: random, printed)
    - [TWINE_DIFF_REF=1]: also generate explicit references (kind 14)
    - [TWINE_DIFF_CORRUPT=1]: also run the corrupted-input report *)

module G = QCheck2.Gen
module T = QCheck2.Test

let env_flag name =
  match Sys.getenv_opt name with
  | Some ("1" | "true" | "yes") -> true
  | _ -> false

let count =
  match Option.bind (Sys.getenv_opt "TWINE_DIFF_COUNT") int_of_string_opt with
  | Some n -> n
  | None -> 1000

let seed =
  match Option.bind (Sys.getenv_opt "QCHECK_SEED") int_of_string_opt with
  | Some s -> s
  | None ->
    Random.self_init ();
    Random.int (1 lsl 29)

let refs = env_flag "TWINE_DIFF_REF"

(* Reporting
   ========= *)

let dump bytes = Imandrakit_twine.Dump.dump_string bytes

let print_value v =
  Printf.sprintf "%s\nencoded:\n%s" (Value.show v) (dump (Encode_v.encode v))

let show_reply (r : Sexp.reply) =
  match r with
  | Value v -> Value.show v
  | Decode_error msg -> "decode error: " ^ msg
  | Crash msg -> "crash: " ^ msg

(** Check that [line], a decoder's reply, is the value [expected]. *)
let check_reply ~(expected : Value.t) ~(bytes : string) (line : string) : bool =
  let expected = Value.widen expected in
  match Sexp.parse_reply line with
  | Ok (Value v) when Value.equal v expected -> true
  | Ok r ->
    T.fail_reportf "expected:@ %s@ got:@ %s@ reply:@ %s@ bytes:@ %s"
      (Value.show expected) (show_reply r) line (dump bytes)
  | Error msg -> T.fail_reportf "unparseable reply: %s" msg

(* Properties
   ========== *)

let gen_value = Value.gen ~refs

let self_check =
  T.make ~count ~name:"reference decoder round-trips" ~print:print_value
    gen_value (fun v ->
      let bytes = Encode_v.encode v in
      check_reply ~expected:v ~bytes (Ocaml_decoder.request 'v' bytes))

let agreement dec =
  T.make ~count ~name:"decoder agrees with the reference encoder"
    ~print:print_value gen_value (fun v ->
      let bytes = Encode_v.encode v in
      check_reply ~expected:v ~bytes (Decoder_process.request dec 'v' bytes))

let bigints dec =
  T.make ~count ~name:"decoder reads big integers"
    ~print:(fun z ->
      Printf.sprintf "%s\nencoded:\n%s" (Z.to_string z)
        (dump (Encode_v.encode_bigint z)))
    Value.gen_bigint
    (fun z ->
      let bytes = Encode_v.encode_bigint z in
      check_reply ~expected:(Int z) ~bytes
        (Decoder_process.request dec 'i' bytes))

let sharing dec =
  T.make ~count ~name:"sharing does not change the decoded value"
    ~print:(fun v ->
      Printf.sprintf "%s\nshared encoding:\n%s" (Value.show v)
        (dump (Encode_v.encode ~share:true v)))
    gen_value
    (fun v ->
      let bytes = Encode_v.encode ~share:true v in
      check_reply ~expected:v ~bytes (Decoder_process.request dec 'v' bytes))

(* Corrupted input (report only)
   =============================

    Corrupt valid encodings and check two things, without failing the run:
    - the decoder replies with a value or a decode error, never a crash;
    - its verdict (value or error) matches the reference decoder's. *)

type corruption =
  | Truncate of int
  | Set_byte of int * char

let show_corruption = function
  | Truncate n -> Printf.sprintf "truncate to %d bytes" n
  | Set_byte (i, c) -> Printf.sprintf "set byte %d to 0x%02x" i (Char.code c)

let apply_corruption bytes = function
  | Truncate n -> String.sub bytes 0 n
  | Set_byte (i, c) ->
    let b = Bytes.of_string bytes in
    Bytes.set b i c;
    Bytes.to_string b

let gen_corrupted : (Value.t * corruption * string) G.t =
  G.(
    gen_value >>= fun v ->
    let bytes = Encode_v.encode v in
    let n = String.length bytes in
    let corruption =
      oneof_weighted
        [
          1, map (fun k -> Truncate k) (int_range 0 (n - 1));
          3, map2 (fun i c -> Set_byte (i, c)) (int_range 0 (n - 1)) char;
          (* the last byte locates the entry point *)
          1, map (fun c -> Set_byte (n - 1, c)) char;
        ]
    in
    map (fun c -> v, c, apply_corruption bytes c) corruption)

type verdict_reply =
  | Reply of (Sexp.reply, string) result
  | Died of string

let verdict = function
  | Reply (Ok (Value _)) -> "value"
  | Reply (Ok (Decode_error _)) -> "decode error"
  | Reply (Ok (Crash _)) -> "crash"
  | Reply (Error _) -> "unparseable reply"
  | Died _ -> "died"

type restartable = {
  command: string;
  mutable proc: Decoder_process.t;
}
(** A decoder process that is restarted when it dies, since corrupted input may
    kill it *)

let restartable command = { command; proc = Decoder_process.start command }

let request_or_die (r : restartable) bytes : verdict_reply =
  match Decoder_process.request ~timeout:10. r.proc 'v' bytes with
  | line -> Reply (Sexp.parse_reply line)
  | exception Decoder_process.Died msg ->
    Decoder_process.stop r.proc;
    r.proc <- Decoder_process.start r.command;
    Died msg

let corrupted_report ~command rand =
  (* the reference decoder runs in its own process too: see
     [Ocaml_decoder.serve] *)
  let reference =
    restartable (Filename.quote Sys.executable_name ^ " serve-reference")
  in
  let dec = restartable command in
  let crashes = ref [] in
  let reference_deaths = ref [] in
  let verdicts = Hashtbl.create 8 in
  let cases = G.generate ~rand ~n:count gen_corrupted in
  List.iter
    (fun (v, c, bytes) ->
      let ours = request_or_die dec bytes in
      let reference = request_or_die reference bytes in
      (match ours with
      | Reply (Ok (Crash msg) | Error msg) | Died msg ->
        crashes := (String.length bytes, v, c, bytes, msg) :: !crashes
      | Reply (Ok _) -> ());
      (match reference with
      | Died msg ->
        reference_deaths :=
          (String.length bytes, v, c, bytes, msg) :: !reference_deaths
      | Reply _ -> ());
      let key =
        match ours, reference with
        | Reply (Ok (Value a)), Reply (Ok (Value b)) when not (Value.equal a b)
          ->
          "value", "different value"
        | _ -> verdict ours, verdict reference
      in
      Hashtbl.replace verdicts key
        (1 + Option.value ~default:0 (Hashtbl.find_opt verdicts key)))
    cases;
  Printf.printf "\ncorrupted input (report only, %d cases)\n" count;
  Printf.printf "verdicts, decoder vs reference:\n";
  Hashtbl.to_seq verdicts |> List.of_seq |> List.sort compare
  |> List.iter (fun ((a, b), n) ->
         Printf.printf "  %-18s %-18s %d%s\n" a b n
           (if a = b then
              ""
            else
              "  <- disagree"));
  let print_cases title cases =
    let cases = List.sort compare cases in
    Printf.printf "%s: %d\n" title (List.length cases);
    List.iteri
      (fun i (_, v, c, bytes, msg) ->
        if i < 3 then
          Printf.printf "\n- %s\n  from: %s\n  %s\n  bytes: %s\n" msg
            (Value.show v) (show_corruption c) (Sexp.hex_of_string bytes))
      cases
  in
  print_cases "decoder crashes" !crashes;
  print_cases "reference decoder deaths" !reference_deaths;
  Decoder_process.stop dec.proc;
  Decoder_process.stop reference.proc

(* Main
   ==== *)

let () =
  if Array.length Sys.argv > 1 && Sys.argv.(1) = "serve-reference" then (
    Ocaml_decoder.serve ();
    exit 0
  );
  let command =
    match Sys.getenv_opt "TWINE_DIFF_DECODER" with
    | Some c when String.trim c <> "" -> c
    | _ ->
      prerr_endline
        "TWINE_DIFF_DECODER is not set: it is the command that starts the \
         decoder under test.";
      exit 2
  in
  Printf.printf "decoder: %s\nseed: %d (set QCHECK_SEED to reproduce)\n%!"
    command seed;
  let dec = Decoder_process.start command in
  at_exit (fun () -> Decoder_process.stop dec);
  let rand = Random.State.make [| seed |] in
  let code =
    QCheck_base_runner.run_tests ~colors:false ~verbose:true ~rand
      [ self_check; agreement dec; bigints dec; sharing dec ]
  in
  if env_flag "TWINE_DIFF_CORRUPT" then
    corrupted_report ~command (Random.State.make [| seed |]);
  if code <> 0 then
    Printf.printf "\nfailed with seed %d (set QCHECK_SEED=%d to reproduce)\n"
      seed seed;
  exit code
