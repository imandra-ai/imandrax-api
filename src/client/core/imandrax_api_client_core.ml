(** Example client for ImandraX *)

open struct
  module Prelude = struct
    module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.client"))
    module API = Imandrax_api_proto
    module L_API = Imandrax_api
    module Rpool = Rpool
  end
end

include Prelude

module type FUT = sig
  type 'a t
end

module Make (Fut : FUT) = struct
  class type rpc_client = object
    method disconnect : unit -> unit
    method active : unit -> bool

    method rpc_call :
      'req 'res.
      timeout_s:float ->
      ( 'req,
        Pbrt_services.Value_mode.unary,
        'res,
        Pbrt_services.Value_mode.unary )
      Pbrt_services.Client.rpc ->
      'req ->
      'res Fut.t
    (** Generic RPC call *)
  end

  type t = {
    addr: string;
    rpc: rpc_client;
    default_timeout_s: float;  (** Default timeout for requests *)
  }
  (** A RPC client. *)

  open struct
    type client = t

    let default_default_timeout_ = 30.
  end

  let pp out (self : t) = Format.fprintf out "<imandrax-client on %s>" self.addr

  let create ?(default_timeout_s = default_default_timeout_) ~addr
      ~(rpc : #rpc_client) () : t =
    let rpc = (rpc :> rpc_client) in
    { addr; rpc; default_timeout_s }

  let[@inline] is_active (self : t) = self.rpc#active ()

  let disconnect (self : t) =
    Log.info (fun k -> k "disconnecting %a" pp self);
    self.rpc#disconnect ()

  let get_session ?timeout_s (self : t) : API.session Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let req =
      API.make_session_create_req
        ~api_version:L_API.Versioning.api_types_version ()
    in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.create_session req

  let status ?timeout_s (self : t) : API.string_msg Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.status ()

  let eval_src ?timeout_s (self : t) ~(src : string) ~(session : API.session) ()
      : API.eval_res Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg = API.make_eval_src_req ~session:(Some session) ~src () in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.eval_src arg

  let instance_src ?timeout_s (self : t) ~(src : string) ?hints
      ~(session : API.session) () : API.instance_res Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg =
      API.make_instance_src_req ~session:(Some session) ~hints ~src ()
    in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.instance_src arg

  let verify_src ?timeout_s (self : t) ~(src : string) ?hints
      ~(session : API.session) () : API.verify_res Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg = API.make_verify_src_req ~session:(Some session) ~hints ~src () in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.verify_src arg

  let decompose ?timeout_s (self : t) ~(name : string) ?assuming ?(basis = [])
      ?(rule_specs = []) ?(prune = true) ?ctx_simp ?lift_bool
      ~(session : API.session) () : API.decompose_res Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg =
      API.make_decompose_req ~session:(Some session) ~name ?assuming ~basis
        ?lift_bool ?ctx_simp ~rule_specs ~prune ()
    in
    self.rpc#rpc_call ~timeout_s API.Simple.Client.decompose arg

  let list_artifacts ?timeout_s (self : t) ~(task : API.task_id) () :
      API.artifact_list_result Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg = API.make_artifact_list_query ~task_id:(Some task) () in
    self.rpc#rpc_call ~timeout_s API.Eval.Client.list_artifacts arg

  let get_artifact_zip ?timeout_s (self : t) ~(task : API.task_id)
      ~(kind : string) () : API.artifact_zip Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let arg = API.make_artifact_get_query ~task_id:(Some task) ~kind () in
    self.rpc#rpc_call ~timeout_s API.Eval.Client.get_artifact_zip arg

  module System = struct
    (** GC statistics *)
    let gc_stats ?timeout_s (self : t) : API.gc_stats Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.System.Client.gc_stats ()

    let release_memory ?timeout_s (self : t) : API.gc_stats Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.System.Client.release_memory ()

    let version ?timeout_s (self : t) : API.version_response Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.System.Client.version ()
  end

  module Session = struct
    type t = API.session

    let create ?timeout_s (self : client) : t Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.SessionManager.Client.create_session
      @@ API.make_session_create
           ~api_version:Imandrax_api.Versioning.api_types_version
           ~po_check:(Some true) ()

    let open_ ?timeout_s (self : client) (sesh : t) : unit Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.SessionManager.Client.open_session
      @@ API.make_session_open
           ~api_version:Imandrax_api.Versioning.api_types_version
           ~id:(Some sesh) ()

    let keep_alive ?timeout_s (self : client) sesh : unit Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.SessionManager.Client.keep_session_alive
        sesh
  end

  (** Evaluating code *)
  module Eval = struct
    type res = API.code_snippet_eval_result

    let eval_code ?timeout_s (self : client) ~session ~code () : res Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      let code = API.make_code_snippet ~code ~session:(Some session) () in
      self.rpc#rpc_call ~timeout_s API.Eval.Client.eval_code_snippet code
  end

  module Artifact = struct
    let list_artifacts ?timeout_s (self : client) (t : API.task_id) :
        API.artifact_list_result Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      let q = API.make_artifact_list_query ~task_id:(Some t) () in
      self.rpc#rpc_call ~timeout_s API.Eval.Client.list_artifacts q

    let get_artifact ?timeout_s (self : client) ~(kind : string)
        (t : API.task_id) : API.artifact Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      let q = API.make_artifact_get_query ~task_id:(Some t) ~kind () in
      self.rpc#rpc_call ~timeout_s API.Eval.Client.get_artifact q
  end
end

module Fut_blocking = struct
  type 'a t = 'a
end

(** Blocking style RPC *)
module Blocking = struct
  include Prelude
  include Make (Fut_blocking)
end
