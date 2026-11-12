(** The reference decoder: imandrakit's [Decode], run in-process. It answers the
    same requests as a decoder program, and its reply goes through the same
    printer and parser, so it also checks the harness itself. *)

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
  | String _ -> Str (Dec.string dec off)
  | Blob _ -> Blob (Dec.blob dec off)
  | Array c -> Array (Dec.Array_cursor.to_list_of value c)
  | Dict c -> Dict (Dec.Dict_cursor.to_list_of (fun k v -> value k, value v) c)
  | Tag (n, x) -> Tag (Z.of_int n, value x)
  | Cstor0 i -> Cstor (Z.of_int i, [])
  | CstorN (i, c) -> Cstor (Z.of_int i, Dec.Array_cursor.to_list_of value c)
  | Ref p -> Ref (value p)
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
