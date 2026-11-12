(** The reference decoder: imandrakit's [Decode], run in-process. It answers the
    same requests as a decoder program, and its reply goes through the same
    printer and parser, so it also checks the harness itself. *)

module Dec = Imandrakit_twine.Decode

let rec value (dec : Dec.t) (off : int) : Value.t =
  match Dec.read dec off with
  | Null -> Null
  | True -> Bool true
  | False -> Bool false
  | Int i -> Int (Z.of_int64 i)
  | Float f -> F64 f
  | String _ -> Str (Dec.string dec off)
  | Blob _ -> Blob (Dec.blob dec off)
  | Array c -> Array (Dec.Array_cursor.to_list_of (value dec) c)
  | Dict c ->
    Dict (Dec.Dict_cursor.to_list_of (fun k v -> value dec k, value dec v) c)
  | Tag (n, x) -> Tag (n, value dec x)
  | Cstor0 i -> Cstor (i, [])
  | CstorN (i, c) -> Cstor (i, Dec.Array_cursor.to_list_of (value dec) c)
  | Ref p -> Ref (value dec p)
  | Pointer _ -> Imandrakit_twine.Error "pointer after dereferencing" |> raise

let reply (mode : char) (bytes : string) : Sexp.reply =
  try
    let dec = Dec.of_string bytes in
    let entry = Dec.get_entrypoint dec in
    match mode with
    | 'v' -> Value (value dec entry)
    | 'i' -> Value (Int (Imandrax_api.Util_twine.Z.of_twine dec entry))
    | c -> Crash (Printf.sprintf "unknown mode %C" c)
  with
  | Imandrakit_twine.Error msg -> Decode_error msg
  | e -> Crash (Printexc.to_string e)

(** Same as a decoder program's reply line *)
let request (mode : char) (bytes : string) : string =
  Sexp.to_string (Sexp.of_reply (reply mode bytes))

(** Serve the protocol on stdin/stdout, like a decoder program. Used for
    corrupted input: [Decode] does not bounds-check every read, so it can
    segfault, and that must not take the harness down. *)
let serve () : unit =
  set_binary_mode_in stdin true;
  let rec loop () =
    match In_channel.really_input_string stdin 5 with
    | None -> ()
    | Some head ->
      let n = Int32.to_int (String.get_int32_be head 1) in
      (match In_channel.really_input_string stdin n with
      | None -> exit 1
      | Some bytes ->
        print_endline (request head.[0] bytes);
        loop ())
  in
  loop ()
