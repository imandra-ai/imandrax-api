open Lwt.Syntax
open Imandrakit
open Imandrax_api

(** {2 Re-exports} *)

module Cir = Imandrax_api_cir
module Ty = Cir.Type
module T = Cir.Term
module Artifact = Imandrax_api_artifact.Artifact
module Artifact_zip = Imandrax_api_artifact_zip

(** Access the content of the future *)
let poll_exn fut =
  match Lwt.poll fut with
  | None -> failwith "not ready"
  | Some r -> r

(** {2 Client} *)

module Client = Imandrax_api_client_cohttp

(* TODO: use a state thing, and in toplevel make it global *)

let connect ?(tls = false) ?(host = "127.0.0.1") ?encoding ~port () : Client.t =
  Client.create ~verbose:true ~tls ~host ~port ?encoding ~auth_token:None ()

let disconnect = Client.disconnect

module Session = struct
  type t = Client.Session.t

  let create ?timeout_s client : t Lwt.t =
    Client.Session.create ?timeout_s client

  let open_ ?timeout_s client sesh : unit Lwt.t =
    Client.Session.open_ ?timeout_s client sesh
end

module System = struct
  let gc_stats client : Client.API.gc_stats Lwt.t =
    Client.System.gc_stats client

  let release_memory client : Client.API.gc_stats Lwt.t =
    Client.System.release_memory client

  let version client : string Lwt.t =
    let+ v = Client.System.version client in
    v.version

  let git_version client : string option Lwt.t =
    let+ v = Client.System.version client in
    v.git_version
end

type task_id = Client.API.task_id [@@deriving show { with_path = false }]

type task = {
  id: task_id;
  kind: Client.API.task_kind;
}
[@@deriving show { with_path = false }]

module Eval = struct
  type res = {
    is_ok: bool;
    duration_s: float;
    tasks: task list;
    errors: Client.API.error list;
  }
  [@@deriving show { with_path = false }]

  let eval ?timeout_s client ~session (code : string) : res Lwt.t =
    let* r = Client.Eval.eval_code ?timeout_s client ~session ~code () in
    let is_ok =
      match r.res with
      | Client.API.Eval_ok -> true
      | Client.API.Eval_errors -> false
    in

    (* unwrap tasks *)
    let tasks =
      List.map
        (function
          | { Client.API.id = Some id; kind } -> { id; kind }
          | _ ->
            Error.fail ~kind:Error_kinds.rpcError "task does not have an ID")
        r.tasks
    in
    Lwt.return { is_ok; tasks; duration_s = r.duration_s; errors = r.errors }

  let get_artifact ?timeout_s client (task : task_id) ~(kind : _ Artifact.kind)
      : 'a Lwt.t =
    let kind_as_str = Artifact.kind_to_string kind in
    let* r =
      Client.Artifact.get_artifact ?timeout_s client ~kind:kind_as_str
        (Client.API.make_task_id ~id:task.id ())
    in
    match r.art with
    | None -> Error.fail ~kind:Error_kinds.rpcError "missing artifact"
    | Some r ->
      (* decode artifact *)
      if not (String.equal kind_as_str r.kind) then
        Error.failf ~kind:Error_kinds.rpcError
          "Asked for artifact of kind %S, got kind %S" kind_as_str r.kind;

      let r =
        Imandrakit_twine.Decode.decode_string (Artifact.of_twine kind)
          (Bytes.unsafe_to_string r.data)
      in
      Lwt.return r

  let list_artifacts ?timeout_s client (task : task_id) : string list Lwt.t =
    let+ r = Client.Artifact.list_artifacts ?timeout_s client task in
    r.kinds
end
