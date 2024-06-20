(** Storing artifacts in Protobuf *)

type msg = Artmsg.art [@@deriving show]

let to_msg (self : Artifact.t) : msg =
  let (Artifact (kind, _)) = self in
  let data = Imandrakit_twine.Encode.encode_to_string Artifact.to_twine self in
  Artmsg.make_art
    ~kind:(Artifact.kind_to_string kind)
    ~data:(Bytes.unsafe_of_string data)
    ~api_version:Versioning.version ()

let to_msg_str ?(enc = Pbrt.Encoder.create ()) (self : Artifact.t) : string =
  Pbrt.Encoder.clear enc;
  Artmsg.encode_pb_art (to_msg self) enc;
  Pbrt.Encoder.to_string enc

let of_msg (msg : msg) : Artifact.t Error.result =
  let@ () = Error.guards "Decoding artifact encoded in protobuf form" in
  let@ () = Error.try_catch ~kind:Error_kinds.deserializationError () in
  let (Any_kind kind) =
    match Artifact.kind_of_string msg.kind with
    | Ok k -> k
    | Error msg ->
      Error.failf ~kind:Error_kinds.deserializationError
        "Unknown artifact kind: %s" msg
  in

  (* check version compat *)
  if msg.api_version <> Versioning.version then
    Error.failf ~kind:Error_kinds.versionMismatchError
      "ImandraX API types version is %S, but data has version %S."
      Versioning.version msg.api_version;

  let res =
    let@ () = Error.guards "Reading data from protobuf" in
    Imandrakit_twine.Decode.decode_string (Artifact.of_twine kind)
      (Bytes.unsafe_to_string msg.data)
  in
  Artifact.make ~kind res

let of_msg_str (str : string) : Artifact.t Error.result =
  Format.eprintf "proto.of-msg %S@." str;
  let@ () = Error.guards "Decoding artifact encoded in protobuf form" in
  let@ () = Error.try_catch ~kind:Error_kinds.deserializationError () in
  let msg =
    let dec = Pbrt.Decoder.of_string str in
    Artmsg.decode_pb_art dec
  in
  of_msg msg |> Error.unwrap
