(** Simple client for ImandraX *)

module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.client"))
module API = Imandrax_api_proto
module Rpool = Rpool

module type FUT = sig
  type 'a t
end

module Make (Fut : FUT) = struct
  module Fut = Fut

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
      @@ API.make_session_create ~po_check:(Some true) ()

    let open_ ?timeout_s (self : client) (sesh : t) : unit Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      self.rpc#rpc_call ~timeout_s API.SessionManager.Client.open_session
      @@ API.make_session_open ~id:(Some sesh) ()

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
end
