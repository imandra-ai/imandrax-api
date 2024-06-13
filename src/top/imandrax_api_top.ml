(** {2 Re-exports} *)

module Cir = Imandrax_api_cir
module Ty = Cir.Type
module T = Cir.Term
module Artifact = Imandrax_api_artifact
module Artifact_zip = Imandrax_api_artifact_zip

(** {2 Client} *)

module Fut = Moonpool.Fut
module Client = Imandrax_api_client_ezcurl

let thread_pool = Moonpool.Ws_pool.create ~num_threads:4 ()

let connect ?(tls = false) ?(host = "127.0.0.1") ?encoding ~port () : Client.t =
  Client.create ~verbose:true ~tls ~host ~port ?encoding ~runner:thread_pool
    ~auth_token:None ()

let disconnect = Client.disconnect

module Session = struct
  type t = Client.Session.t

  let create ?timeout_s client : t =
    Fut.wait_block_exn @@ Client.Session.create ?timeout_s client

  let open_ ?timeout_s client sesh : unit =
    Fut.wait_block_exn @@ Client.Session.open_ ?timeout_s client sesh
end

module System = struct
  let gc_stats client : Client.API.gc_stats =
    Fut.await @@ Client.System.gc_stats client

  let release_memory client : Client.API.gc_stats =
    Fut.await @@ Client.System.release_memory client

  let version client : string =
    (Fut.await @@ Client.System.version client).version

  let git_version client : string option =
    (Fut.await @@ Client.System.version client).git_version
end

type task_id = Client.API.task_id [@@deriving show { with_path = false }]

type task = Client.API.task = {
  id: task_id option;
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

  let eval client ~session (code : string) =
    let r = Fut.await @@ Client.Eval.eval_code client ~session ~code () in
    let is_ok =
      match r.res with
      | Client.API.Eval_ok -> true
      | Client.API.Eval_errors -> false
    in
    { is_ok; tasks = r.tasks; duration_s = r.duration_s; errors = r.errors }
end
