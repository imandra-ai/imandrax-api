(** Conformance test of a twine decoder against imandrakit's encoder.

    Environment:
    - [TWINE_CONFORMANCE_DECODER]: shell command that starts the adapter
      (required)
    - [TWINE_CONFORMANCE_NAME]: the decoder's name in the output (default: the
      command)
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

let dump bytes = String.trim (Imandrakit_twine.Dump.dump_string bytes)

let print_value v =
  Printf.sprintf "value:   %s\nencoded:\n%s" (Value.show v)
    (dump (Value.encode v))

let show_reply (r : Sexp.reply) =
  match r with
  | Value v -> Value.show v
  | Rational (n, d) -> Printf.sprintf "%s/%s" (Z.to_string n) (Z.to_string d)
  | Decode_error msg -> "decode error: " ^ msg
  | Unsupported ty -> "type not supported: " ^ ty

module P = Decoder_client

(** The reference decoder in its own process, so that a crash on corrupted input
    cannot take the harness down: see [Ocaml_adapter.serve] *)
let reference_command = Filename.quote Sys.executable_name ^ " serve-ocaml"

(** Check that [outcome], a decoder's answer, is the reply [expected]. *)
let check_reply ~(expected : Sexp.reply) (outcome : P.outcome) : bool =
  match outcome with
  | Reply (Ok r) when Sexp.equal_reply r expected -> true
  | Reply (Ok r) ->
    T.fail_reportf "expected: %s@\ngot:      %s" (show_reply expected)
      (show_reply r)
  | Reply (Error msg) -> T.fail_reportf "unparseable reply: %s" msg
  | Died msg -> T.fail_reportf "%s" msg

(* Shrinking
   ========= *)

(** Calls of a property allowed after its first failure, while shrinking. A
    decoder that fails only on some runs (one that reads memory outside the
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
      check_reply ~expected:(Value (Value.widen v)) (P.request dec bytes))

let bigints (dec : P.t) =
  make ~name:"decoder reads big integers"
    ~print:(fun z ->
      Printf.sprintf "value:   %s\nencoded:\n%s" (Z.to_string z)
        (dump (Value.encode_bigint z)))
    Value.gen_bigint
    (fun z ->
      let bytes = Value.encode_bigint z in
      check_reply ~expected:(Value (Int z)) (P.request ~ty:"int" dec bytes))

let rationals (dec : P.t) =
  make ~name:"decoder reads rationals"
    ~print:(fun q ->
      Printf.sprintf "value:   %s\nencoded:\n%s" (Q.to_string q)
        (dump (Value.encode_q q)))
    Value.gen_q
    (fun q ->
      let bytes = Value.encode_q q in
      check_reply
        ~expected:(Rational (Q.num q, Q.den q))
        (P.request ~ty:"q" dec bytes))

let sharing (dec : P.t) =
  make ~name:"sharing does not change the decoded value"
    ~print:(fun v ->
      Printf.sprintf "value:   %s\nshared encoding:\n%s" (Value.show v)
        (dump (Value.encode ~share:true v)))
    Value.gen
    (fun v ->
      let bytes = Value.encode ~share:true v in
      check_reply ~expected:(Value (Value.widen v)) (P.request dec bytes))

(* Corrupted input
   ---------------

    Valid encodings, truncated or with a byte overwritten. Twine does not say
    which of them are malformed: the reference decides. *)

type corrupted = {
  from: string;
  bytes: string;
}
(** A corrupted input, and how it was made *)

(** Inputs on which a decoder or the reference once failed. They are tried
    first, before the random ones. *)
let regressions : corrupted list =
  List.map
    (fun (from, hex) -> { from; bytes = Sexp.string_of_hex hex })
    [
      "[], truncated to 0 bytes", "";
      (* the entry point is at offset -97 *)
      "[], truncated to 1 byte", "60";
      (* the reference read outside the buffer, a different value each run *)
      "[], then byte 1 set to 0x50", "6050";
      (* a varint longer than 10 bytes *)
      ( "{tag 128(0) => 0; [tag 128(144115188075855841)] => -9}, then byte 14 \
         set to 0xfc",
        "8f71108f711fd2fffffffffffffffc61fc72ff0210f52805" );
      (* a string that is not UTF-8 *)
      "\"fg\", then byte 1 set to 0x80", "42806702";
    ]

type corruption =
  | Truncate of int
  | Set_byte of int * char

let show_corruption = function
  | Truncate 1 -> "truncated to 1 byte"
  | Truncate n -> Printf.sprintf "truncated to %d bytes" n
  | Set_byte (i, c) -> Printf.sprintf "byte %d set to 0x%02x" i (Char.code c)

let apply_corruption bytes = function
  | Truncate n -> String.sub bytes 0 n
  | Set_byte (i, c) ->
    let b = Bytes.of_string bytes in
    Bytes.set b i c;
    Bytes.to_string b

(** The [regressions], then random cases. A new generator for each property,
    since it remembers which regressions it has given. *)
let gen_corrupted () : corrupted G.t =
  G.(
    graft_corners
      ( Value.gen >>= fun v ->
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
        map
          (fun c ->
            {
              from =
                Printf.sprintf "%s, then %s" (Value.show v) (show_corruption c);
              bytes = apply_corruption bytes c;
            })
          corruption )
      regressions ())

let print_corrupted { from; bytes } =
  Printf.sprintf "bytes:     %s\nfrom:      %s"
    (if bytes = "" then
       "(none)"
     else
       Sexp.hex_of_string bytes)
    from

let never_crashes (dec : P.t) =
  make ~name:"decoder never crashes on corrupted input" ~print:print_corrupted
    (gen_corrupted ()) (fun { bytes; _ } ->
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
    ~print:print_corrupted (gen_corrupted ()) (fun { bytes; _ } ->
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

(* Running
   ======= *)

let test_name (T.Test cell) = T.get_name cell

let indent (s : string) : string =
  String.split_on_char '\n' s
  |> List.map (fun l ->
         if l = "" then
           l
         else
           "      " ^ l)
  |> String.concat "\n"

(** Run one property and print one line for it, followed by the failing case if
    it fails. Returns whether it passed. *)
let run_property rand (test : T.t) : bool =
  match test with
  | T.Test cell ->
    let name = T.get_name cell in
    let case (c : _ QCheck2.TestResult.counter_ex) =
      let input =
        match T.get_print_opt cell with
        | Some print -> print c.instance
        | None -> "(no printer)"
      in
      String.concat "\n" (input :: c.msg_l)
    in
    let fail detail =
      Printf.printf "  \u{2717} %s\n%s\n%!" name (indent detail);
      false
    in
    (match QCheck2.TestResult.get_state (T.check_cell ~rand cell) with
    | Success ->
      Printf.printf "  \u{2713} %s\n%!" name;
      true
    | Failed { instances = c :: _ } -> fail (case c)
    | Failed { instances = [] } -> fail "failed"
    | Failed_other { msg } -> fail msg
    | Error { instance; exn; backtrace = _ } ->
      fail (case instance ^ "\nexception: " ^ Printexc.to_string exn))

(* Main
   ==== *)

(** Whether the adapter implements type [ty]. An adapter replies [unsupported]
    before looking at the bytes, so empty bytes are enough to ask. *)
let supports (dec : P.t) (ty : string) : bool =
  match P.request ~ty dec "" with
  | Reply (Ok (Unsupported _)) -> false
  | _ -> true

(** Every property, with the type it needs other than ["any"], which every
    adapter must implement. A property is skipped if the adapter does not
    support its type. *)
let properties ~(reference : P.t) (dec : P.t) : (string option * T.t) list =
  [
    None, round_trip dec;
    Some "int", bigints dec;
    Some "q", rationals dec;
    None, sharing dec;
    None, never_crashes dec;
    None, same_as_reference ~reference dec;
  ]

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
  let name =
    match Sys.getenv_opt "TWINE_CONFORMANCE_NAME" with
    | Some n when String.trim n <> "" -> n
    | _ -> command
  in
  Printf.printf "twine conformance, %s decoder (seed %d)\n%!" name seed;
  let dec = P.start command in
  let reference = P.start reference_command in
  at_exit (fun () ->
      P.stop dec;
      P.stop reference);
  let rand = Random.State.make [| seed |] in
  let outcomes =
    List.map
      (fun (ty, test) ->
        match ty with
        | Some ty when not (supports dec ty) ->
          Printf.printf
            "  - %s (skipped: the adapter does not support type %s)\n%!"
            (test_name test) ty;
          `Skipped
        | _ ->
          if run_property rand test then
            `Passed
          else
            `Failed)
      (properties ~reference dec)
  in
  let count o = List.length (List.filter (( = ) o) outcomes) in
  let failed = count `Failed in
  let skipped =
    match count `Skipped with
    | 0 -> ""
    | n -> Printf.sprintf ", %d skipped" n
  in
  if failed = 0 then
    Printf.printf "all properties passed%s\n" skipped
  else
    Printf.printf
      "%d of %d properties failed%s (set QCHECK_SEED=%d to reproduce)\n" failed
      (List.length outcomes) skipped seed;
  exit
    (if failed = 0 then
       0
     else
       1)
