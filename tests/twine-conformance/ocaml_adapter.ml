(** The OCaml adapter, on imandrakit's [Decode], started by
    [twine_conformance.exe serve-ocaml]. It is tested like any other adapter,
    and is also the reference that the corrupted-input property compares
    against. *)

module Dec = Imandrakit_twine.Decode
module Int_set = Set.Make (Int)

(** [path] holds the offsets of the values enclosing [off]. Malformed input can
    be cyclic (a tag, container or ref that leads back to itself); reaching an
    offset already on the path is a cycle. Shared values are fine: a value can
    be reached many times, but never from inside itself. *)
let rec value ?(path = Int_set.empty) (dec : Dec.t) (off : int) : Value.t =
  let off = Dec.deref_rec dec off in
  if Int_set.mem off path then
    Imandrakit_twine.Error (Printf.sprintf "cyclic value at offset 0x%x" off)
    |> raise;
  let value = value ~path:(Int_set.add off path) dec in
  match Dec.read dec off with
  | Null -> Null
  | True -> Bool true
  | False -> Bool false
  | Int i -> Int (Z.of_int64 i)
  | Float f -> F64 f
  | String _ ->
    (* imandrakit returns any bytes; a twine string is UTF-8 text, and the
       other decoders reject it otherwise *)
    let s = Dec.string dec off in
    if not (String.is_valid_utf_8 s) then
      Imandrakit_twine.Error
        (Printf.sprintf "invalid UTF-8 in string at offset 0x%x" off)
      |> raise;
    Str s
  | Blob _ -> Blob (Dec.blob dec off)
  | Array c -> Array (Dec.Array_cursor.to_list_of value c)
  | Dict c -> Dict (Dec.Dict_cursor.to_list_of (fun k v -> value k, value v) c)
  | Tag (n, x) -> Tag (Z.of_int n, value x)
  | Cstor0 i -> Cstor (Z.of_int i, [])
  | CstorN (i, c) -> Cstor (Z.of_int i, Dec.Array_cursor.to_list_of value c)
  | Ref p -> Ref (value p)
  | Pointer _ -> Imandrakit_twine.Error "pointer after dereferencing" |> raise

(** How to read the entry point, by the type the bytes represent. Any exception
    other than a decode error escapes: in [serve] it ends the process, which is
    how an adapter reports a crash. *)
let decoders : (string * (Dec.t -> int -> Sexp.reply)) list =
  [
    ("any", fun dec off -> Value (value dec off));
    ( "int",
      fun dec off -> Value (Int (Imandrax_api.Util_twine.Z.of_twine dec off)) );
    ( "q",
      fun dec off ->
        let q = Imandrax_api.Util_twine.Q.of_twine dec off in
        Rational (Q.num q, Q.den q) );
  ]

let reply (ty : string) (bytes : string) : Sexp.reply =
  match List.assoc_opt ty decoders with
  | None -> Unsupported ty
  | Some decode ->
    (try
       let dec = Dec.of_string bytes in
       decode dec (Dec.get_entrypoint dec)
     with Imandrakit_twine.Error msg -> Decode_error msg)

(** Same as an adapter's reply line *)
let request (ty : string) (bytes : string) : string =
  Sexp.reply_to_string (reply ty bytes)

(** Serve the protocol on stdin/stdout, like any adapter. It always runs as a
    child process: if [Decode] crashes on corrupted input, that must not take
    the harness down. *)
let serve () : unit =
  let rec loop () =
    match In_channel.input_line stdin with
    | None -> ()
    | Some line ->
      (match String.index_opt line ' ' with
      | None -> failwith "malformed request: no space after the type"
      | Some i ->
        let ty = String.sub line 0 i in
        let hex = String.sub line (i + 1) (String.length line - i - 1) in
        print_endline (request ty (Sexp.string_of_hex hex));
        loop ())
  in
  loop ()
