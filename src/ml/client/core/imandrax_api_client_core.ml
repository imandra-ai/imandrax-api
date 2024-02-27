(** Simple client for ImandraX *)

module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.client"))

open struct
  let spf = Printf.sprintf
end

module API = Imandrax_api_proto

(** Argument for instantiating the client *)
module type ARG = sig
  module Fut : sig
    type 'a t

    val return : 'a -> 'a t
  end

  module Addr : sig
    type t

    val show : t -> string
  end

  module Err : sig
    type t

    val show : t -> string
  end

  type nonrec 'a result = ('a, Err.t) result

  (** Connection *)
  module Conn : sig
    type t

    val disconnect : t -> unit
  end

  val rpc_call :
    Conn.t ->
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

module Make (Arg : ARG) = struct
  include Arg

  let[@inline] unwrap_err_ = function
    | Ok x -> x
    | Error err -> failwith @@ Err.show err

  type t = {
    addr: Addr.t;
    conn: Conn.t;
    default_timeout_s: float;  (** Default timeout for requests *)
  }
  (** A RPC client. *)

  open struct
    type client = t

    let default_default_timeout_ = 30.
  end

  let pp out (self : t) =
    Format.fprintf out "<imandrax-client on %s>" (Addr.show self.addr)

  let create ?(default_timeout_s = default_default_timeout_) ~addr ~conn () : t
      =
    { addr; conn; default_timeout_s }

  let disconnect (self : t) =
    Log.info (fun k -> k "disconnecting %a" pp self);
    Conn.disconnect self.conn

  module System = struct
    (** GC statistics *)
    let gc_stats ?timeout_s (self : t) : API.gc_stats Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.System.Client.gc_stats ()

    let release_memory ?timeout_s (self : t) : API.gc_stats Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.System.Client.release_memory ()

    let version ?timeout_s (self : t) : API.version_response Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.System.Client.version ()
  end

  module Session = struct
    type t = API.session

    let create ?timeout_s (self : client) : t Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.SessionManager.Client.create_session
      @@ API.make_session_create ~po_check:(Some true) ()

    let open_ ?timeout_s (self : client) (sesh : t) : unit Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.SessionManager.Client.open_session
      @@ API.make_session_open ~id:(Some sesh) ()

    let keep_alive ?timeout_s (self : client) sesh : unit Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      rpc_call ~timeout_s self.conn API.SessionManager.Client.keep_session_alive
        sesh
  end

  (** Evaluating code *)
  module Eval = struct
    type res = API.code_snippet_eval_result

    let eval_code ?timeout_s (self : client) ~session ~code () : res Fut.t =
      let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
      let code = API.make_code_snippet ~code ~session:(Some session) () in
      rpc_call ~timeout_s self.conn API.Eval.Client.eval_code_snippet code
  end

  (* TODO: connect with ezcurl + websocket ugprade, handling auth  *)
end
