open Lwt.Syntax
open Imandrakit
open Imandrax_api

(** {2 Toplevel stuff} *)

open struct
  let eval_exn str =
    (* Printf.eprintf "eval %S\n%!" str; *)
    let lexbuf = Lexing.from_string str in
    let phrase = !Toploop.parse_toplevel_phrase lexbuf in
    Toploop.execute_phrase false Format.err_formatter phrase

  let install_printer s =
    try ignore (eval_exn ("#install_printer " ^ s ^ " ;; "))
    with _ ->
      Printexc.print_backtrace stderr;
      ()

  let install_printers = List.iter install_printer

  let add_printers () =
    print_endline "installing printers…";
    install_printers
      [
        "Imandrax_api.Chash.pp";
        "Imandrax_api.Cname.pp";
        "Imandrax_api.Uid.pp_full";
        "Imandrax_api_cir.Type.pp";
        "Imandrax_api_cir.Term.pp";
        "Imandrax_api.In_mem_archive.pp";
        "Imandrax_api.In_mem_archive.pp_raw";
        "Imandrax_api_proof.Cir_proof_term.pp";
        "Imandrax_api_proof.Proof_term_poly.pp";
      ]

  let () =
    let f = !Toploop.toplevel_startup_hook in
    Toploop.toplevel_startup_hook :=
      fun () ->
        f ();
        add_printers ()
end

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
