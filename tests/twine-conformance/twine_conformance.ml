(** Conformance test of a twine decoder against imandrakit's encoder.

    Environment:
    - [TWINE_CONFORMANCE_DECODER]: shell command that starts the adapter
      (required)
    - [TWINE_CONFORMANCE_COUNT]: cases per property (default 1000)
    - [QCHECK_SEED]: random seed (default: random, printed) *)

module G = QCheck2.Gen
module T = QCheck2.Test

let count =
  match
    Option.bind (Sys.getenv_opt "TWINE_CONFORMANCE_COUNT") int_of_string_opt
  with
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
  | Rational (n, d) -> Printf.sprintf "%s/%s" (Z.to_string n) (Z.to_string d)
  | Decode_error msg -> "decode error: " ^ msg
  | Unsupported ty -> "type not supported: " ^ ty

module P = Decoder_client

(** The reference decoder in its own process, since it can segfault on corrupted
    input: see [Ocaml_adapter.serve] *)
let reference_command = Filename.quote Sys.executable_name ^ " serve-ocaml"

(** Check that [outcome], a decoder's answer, is the reply [expected]. *)
let check_reply ~(expected : Sexp.reply) ~(bytes : string) (outcome : P.outcome)
    : bool =
  match outcome with
  | Reply (Ok r) when Sexp.equal_reply r expected -> true
  | Reply (Ok r) ->
    T.fail_reportf "expected:@ %s@ got:@ %s@ bytes:@ %s" (show_reply expected)
      (show_reply r) (dump bytes)
  | Reply (Error msg) -> T.fail_reportf "unparseable reply: %s" msg
  | Died msg -> T.fail_reportf "%s" msg

(* Shrinking
   ========= *)

(** Calls of a property allowed after its first failure, while shrinking. A
    decoder that fails only on some runs (the OCaml one reads memory outside the
    buffer) keeps finding smaller failing cases, so shrinking would not end in
    reasonable time. Once the budget is spent, the remaining candidates pass,
    and QCheck reports the smallest failure found so far. *)
let shrink_budget = 500

let make ~name ~print gen (law : 'a -> bool) : T.t =
  let calls_since_failure = ref None in
  let failed () =
    if Option.is_none !calls_since_failure then calls_since_failure := Some 0
  in
  let law x =
    match !calls_since_failure with
    | Some n when n >= shrink_budget -> true
    | n ->
      Option.iter (fun n -> calls_since_failure := Some (n + 1)) n;
      (match law x with
      | true -> true
      | false ->
        failed ();
        false
      | exception e ->
        failed ();
        raise e)
  in
  T.make ~count ~name ~print gen law

(* Properties
   ========== *)

let round_trip (dec : P.t) =
  make ~name:"decoder reads back what the reference encoded" ~print:print_value
    Value.gen (fun v ->
      let bytes = Value.encode v in
      check_reply ~expected:(Value (Value.widen v)) ~bytes (P.request dec bytes))

let bigints (dec : P.t) =
  make ~name:"decoder reads big integers"
    ~print:(fun z ->
      Printf.sprintf "%s\nencoded:\n%s" (Z.to_string z)
        (dump (Value.encode_bigint z)))
    Value.gen_bigint
    (fun z ->
      let bytes = Value.encode_bigint z in
      check_reply ~expected:(Value (Int z)) ~bytes
        (P.request ~ty:"int" dec bytes))

let rationals (dec : P.t) =
  make ~name:"decoder reads rationals"
    ~print:(fun q ->
      Printf.sprintf "%s\nencoded:\n%s" (Q.to_string q)
        (dump (Value.encode_q q)))
    Value.gen_q
    (fun q ->
      let bytes = Value.encode_q q in
      check_reply
        ~expected:(Rational (Q.num q, Q.den q))
        ~bytes
        (P.request ~ty:"q" dec bytes))

let sharing (dec : P.t) =
  make ~name:"sharing does not change the decoded value"
    ~print:(fun v ->
      Printf.sprintf "%s\nshared encoding:\n%s" (Value.show v)
        (dump (Value.encode ~share:true v)))
    Value.gen
    (fun v ->
      let bytes = Value.encode ~share:true v in
      check_reply ~expected:(Value (Value.widen v)) ~bytes (P.request dec bytes))

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
  make ~name:"decoder never crashes on corrupted input" ~print:print_corrupted
    gen_corrupted (fun (_, _, bytes) ->
      match P.request dec bytes with
      | Reply (Ok (Value _ | Decode_error _)) -> true
      | Reply (Ok (Rational _)) -> T.fail_reportf "a rational for type any"
      | Reply (Ok (Unsupported ty)) ->
        T.fail_reportf "type not supported: %s" ty
      | Reply (Error msg) -> T.fail_reportf "unparseable reply: %s" msg
      | Died msg -> T.fail_reportf "%s" msg)

(** Verdicts are compared, and values when both accept. Error messages are not:
    both rejecting is agreement. *)
let same_as_reference ~(reference : P.t) (dec : P.t) =
  make ~name:"decoder gives the reference's verdict on corrupted input"
    ~print:print_corrupted gen_corrupted (fun (_, _, bytes) ->
      match P.request dec bytes, P.request reference bytes with
      | Reply (Ok (Decode_error _)), Reply (Ok (Decode_error _)) -> true
      | ( Reply (Ok ((Value _ | Decode_error _) as ours)),
          Reply (Ok ((Value _ | Decode_error _) as theirs)) ) ->
        Sexp.equal_reply ours theirs
        || T.fail_reportf "decoder:   %s@\nreference: %s" (show_reply ours)
             (show_reply theirs)
      (* The decoder crashed, which is [never_crashes]'s job, or the reference
         did: there is no verdict to compare, and the OCaml decoder's own run
         reports it. *)
      | _ -> true)

(* Main
   ==== *)

(** Whether the adapter implements type [ty]. An adapter replies [unsupported]
    before looking at the bytes, so empty bytes are enough to ask. *)
let supports (dec : P.t) (ty : string) : bool =
  match P.request ~ty dec "" with
  | Reply (Ok (Unsupported _)) -> false
  | _ -> true

(** Properties that need a type other than ["any"], which every adapter must
    implement. *)
let optional_properties (dec : P.t) : (string * T.t) list =
  [ "int", bigints dec; "q", rationals dec ]

let () =
  if Array.length Sys.argv > 1 && Sys.argv.(1) = "serve-ocaml" then (
    Ocaml_adapter.serve ();
    exit 0
  );
  let command =
    match Sys.getenv_opt "TWINE_CONFORMANCE_DECODER" with
    | Some c when String.trim c <> "" -> c
    | _ ->
      prerr_endline
        "TWINE_CONFORMANCE_DECODER is not set: it is the command that starts \
         the decoder under test.";
      exit 2
  in
  Printf.printf "decoder: %s\nseed: %d (set QCHECK_SEED to reproduce)\n%!"
    command seed;
  let dec = P.start command in
  let reference = P.start reference_command in
  at_exit (fun () ->
      P.stop dec;
      P.stop reference);
  let optional =
    List.filter_map
      (fun (ty, test) ->
        if supports dec ty then
          Some test
        else (
          Printf.printf "skipped: the adapter does not support type %s\n%!" ty;
          None
        ))
      (optional_properties dec)
  in
  let rand = Random.State.make [| seed |] in
  let code =
    QCheck_base_runner.run_tests ~colors:false ~verbose:true ~rand
      ([ round_trip dec ]
      @ optional
      @ [ sharing dec; never_crashes dec; same_as_reference ~reference dec ])
  in
  if code <> 0 then
    Printf.printf "\nfailed with seed %d (set QCHECK_SEED=%d to reproduce)\n"
      seed seed;
  exit code
