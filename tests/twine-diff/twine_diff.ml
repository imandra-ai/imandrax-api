(** Differential test of a twine decoder against imandrakit's encoder.

    Environment:
    - [TWINE_DIFF_DECODER]: shell command that starts the adapter (required)
    - [TWINE_DIFF_COUNT]: cases per property (default 1000)
    - [QCHECK_SEED]: random seed (default: random, printed) *)

module G = QCheck2.Gen
module T = QCheck2.Test

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

(* Reporting
   ========= *)

let dump bytes = Imandrakit_twine.Dump.dump_string bytes

let print_value v =
  Printf.sprintf "%s\nencoded:\n%s" (Value.show v) (dump (Value.encode v))

let show_reply (r : Sexp.reply) =
  match r with
  | Value v -> Value.show v
  | Decode_error msg -> "decode error: " ^ msg

module P = Decoder_client

(** The reference decoder in its own process, since it can segfault on corrupted
    input: see [Ocaml_adapter.serve] *)
let reference_command = Filename.quote Sys.executable_name ^ " serve-reference"

(** Check that [outcome], a decoder's answer, is the value [expected]. *)
let check_reply ~(expected : Value.t) ~(bytes : string) (outcome : P.outcome) :
    bool =
  let expected = Value.widen expected in
  match outcome with
  | Reply (Ok (Value v)) when Value.equal v expected -> true
  | Reply (Ok r) ->
    T.fail_reportf "expected:@ %s@ got:@ %s@ bytes:@ %s" (Value.show expected)
      (show_reply r) (dump bytes)
  | Reply (Error msg) -> T.fail_reportf "unparseable reply: %s" msg
  | Died msg -> T.fail_reportf "%s" msg

(* Properties
   ========== *)

let self_check =
  T.make ~count ~name:"reference decoder round-trips" ~print:print_value
    Value.gen (fun v ->
      let bytes = Value.encode v in
      check_reply ~expected:v ~bytes
        (Reply (Sexp.parse_reply (Ocaml_adapter.request 'v' bytes))))

let agreement (dec : P.t) =
  T.make ~count ~name:"decoder agrees with the reference encoder"
    ~print:print_value Value.gen (fun v ->
      let bytes = Value.encode v in
      check_reply ~expected:v ~bytes (P.request dec bytes))

let bigints (dec : P.t) =
  T.make ~count ~name:"decoder reads big integers"
    ~print:(fun z ->
      Printf.sprintf "%s\nencoded:\n%s" (Z.to_string z)
        (dump (Value.encode_bigint z)))
    Value.gen_bigint
    (fun z ->
      let bytes = Value.encode_bigint z in
      check_reply ~expected:(Int z) ~bytes (P.request ~mode:'i' dec bytes))

let sharing (dec : P.t) =
  T.make ~count ~name:"sharing does not change the decoded value"
    ~print:(fun v ->
      Printf.sprintf "%s\nshared encoding:\n%s" (Value.show v)
        (dump (Value.encode ~share:true v)))
    Value.gen
    (fun v ->
      let bytes = Value.encode ~share:true v in
      check_reply ~expected:v ~bytes (P.request dec bytes))

(* Corrupted input
   ---------------

    Valid encodings, truncated or with a byte overwritten. Whether the decoder
    accepts or rejects them is not checked: twine does not say which inputs
    must be rejected, and the reference is lenient. *)

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
    Value.gen >>= fun v ->
    let bytes = Value.encode v in
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

let print_corrupted (v, c, bytes) =
  Printf.sprintf "from: %s\n%s\nbytes: %s" (Value.show v) (show_corruption c)
    (Sexp.hex_of_string bytes)

let never_crashes (dec : P.t) =
  T.make ~count ~name:"decoder never crashes on corrupted input"
    ~print:print_corrupted gen_corrupted (fun (_, _, bytes) ->
      match P.request dec bytes with
      | Reply (Ok (Value _ | Decode_error _)) -> true
      | Reply (Error msg) -> T.fail_reportf "unparseable reply: %s" msg
      | Died msg -> T.fail_reportf "%s" msg)

let same_values_as_reference ~(reference : P.t) (dec : P.t) =
  T.make ~count ~name:"decoded values on corrupted input match the reference"
    ~print:print_corrupted gen_corrupted (fun (_, _, bytes) ->
      match P.request dec bytes with
      | Reply (Ok (Value ours)) ->
        (match P.request reference bytes with
        | Reply (Ok (Value theirs)) when not (Value.equal ours theirs) ->
          T.fail_reportf "decoder:@ %s@ reference:@ %s" (Value.show ours)
            (Value.show theirs)
        | _ -> true)
      (* crashes are [never_crashes]'s job; a rejection is not compared *)
      | _ -> true)

(* Main
   ==== *)

let () =
  if Array.length Sys.argv > 1 && Sys.argv.(1) = "serve-reference" then (
    Ocaml_adapter.serve ();
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
  let dec = P.start command in
  let reference = P.start reference_command in
  at_exit (fun () ->
      P.stop dec;
      P.stop reference);
  let rand = Random.State.make [| seed |] in
  let code =
    QCheck_base_runner.run_tests ~colors:false ~verbose:true ~rand
      [
        self_check;
        agreement dec;
        bigints dec;
        sharing dec;
        never_crashes dec;
        same_values_as_reference ~reference dec;
      ]
  in
  if code <> 0 then
    Printf.printf "\nfailed with seed %d (set QCHECK_SEED=%d to reproduce)\n"
      seed seed;
  exit code
