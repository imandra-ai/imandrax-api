(** Storing artifacts in Zip files *)

open Imandrax_api_artifact
open Imandrakit_zip
module Json = Yojson.Safe

module Manifest = struct
  type metadata = { creation_time: Timestamp.t option [@key "creation_time"] }
  [@@deriving show { with_path = false }, yojson, make]
  (** Metadata *)

  type t = {
    kind: string; [@key "kind"]
    api_version: string; [@key "version"]  (** API types versions *)
    metadata: metadata option; [@key "metadata"]
  }
  [@@deriving show { with_path = false }, yojson, make]
end

let write_zip ?(metadata = true) (zip : Util_zip.out_file) (self : Artifact.t) :
    unit =
  let (Artifact (kind, _)) = self in
  let data = Imandrakit_twine.Encode.encode_to_string Artifact.to_twine self in

  Util_zip.add_entry data zip "data.twine";

  let manifest : Manifest.t =
    let kind = Artifact.kind_to_string kind in
    let api_version = Versioning.version in
    let metadata =
      if metadata then (
        let creation_time = Timestamp.now () in
        let m = Manifest.make_metadata ~creation_time () in
        Some m
      ) else
        None
    in
    Manifest.make ?metadata ~kind ~api_version ()
  in
  Util_zip.add_entry
    (Json.to_string @@ Manifest.to_yojson manifest)
    zip "manifest.json";
  ()

let write_zip_file ?metadata (filename : string) (self : Artifact.t) : unit =
  let@ zip = Util_zip.with_open_out filename in
  write_zip ?metadata zip self

let read_zip (zip : Util_zip.in_file) : (Manifest.t * Artifact.t) Error.result =
  let@ () = Error.try_catch ~kind:Error_kinds.deserializationError () in

  (* read manifest *)
  let manifest : Manifest.t =
    let@ () = Error.guards "Reading manifest.json" in
    let e =
      let@ () = Error.guards "Finding entry in zip" in
      Util_zip.find_entry zip "manifest.json"
    in
    let m = Util_zip.read_entry zip e in
    let manifest_j =
      let@ () = Error.guards "Parsing JSON" in
      Json.from_string ~fname:"manifest.json" m
    in
    match Manifest.of_yojson manifest_j with
    | Ok m -> m
    | Error err ->
      Error.failf ~kind:Error_kinds.deserializationError "Invalid manifest: %s"
        err
  in

  (* check version compat *)
  if manifest.api_version <> Versioning.version then
    Error.failf ~kind:Error_kinds.versionMismatchError
      "ImandraX API types version is %S, but data has version %S."
      Versioning.version manifest.api_version;

  let (Any_kind kind) =
    match Artifact.kind_of_string manifest.kind with
    | Error msg ->
      Error.failf ~kind:Error_kinds.deserializationError
        "Invalid artifact kind in manifest: %s" msg
    | Ok k -> k
  in

  let res =
    let@ () = Error.guards "Reading data from twine" in
    let entry =
      let@ () = Error.guards "Finding 'data.twine' entry…" in
      Util_zip.find_entry zip "data.twine"
    in
    let data = Util_zip.read_entry zip entry in
    Imandrakit_twine.Decode.decode_string (Artifact.of_twine kind) data
  in

  let a : Artifact.t = Artifact.Artifact (kind, res) in
  manifest, a

let read_zip_file (filename : string) : _ Error.result =
  let@ zip = Util_zip.with_open_in filename in
  read_zip zip
