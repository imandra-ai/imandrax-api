(** Simple client for ImandraX *)

module API = Imandrax_api_proto
module RPC = Batrpc
module Timer = RPC.Timer

open struct
  let spf = Printf.sprintf

  module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.client"))
end

module Fut = Moonpool.Fut

type err = RPC.Error.t
type nonrec 'a result = ('a, err) result

let[@inline] unwrap_rpc_err = function
  | Ok x -> x
  | Error err -> failwith @@ RPC.Error.show err

type t = {
  addr: Unix.sockaddr;
  rpc: RPC.Rpc_conn.t;
  timer: RPC.Timer.t;
  default_timeout_s: float;  (** Default timeout for requests *)
}
(** A RPC client. *)

open struct
  type client = t

  let string_of_sockaddr = function
    | Unix.ADDR_UNIX s -> spf "unix:%s" s
    | Unix.ADDR_INET (addr, port) ->
      spf "tcp://%s:%d" (Unix.string_of_inet_addr addr) port

  let default_default_timeout_ = 30.
end

let pp out (self : t) =
  Format.fprintf out "<imandrax-client on %s>" (string_of_sockaddr self.addr)

let addr_inet_local ?(port = 9991) () : Unix.sockaddr =
  Unix.ADDR_INET (Unix.inet_addr_loopback, port)

(** Connect to the server over TCP *)
let connect_tcp ?(default_timeout_s = default_default_timeout_)
    (addr : Unix.sockaddr) : t result =
  Log.debug (fun k -> k "connecting to %s…" (string_of_sockaddr addr));
  let timer = RPC.Simple_timer.create () in
  let rpc = RPC.Tcp_client.connect ~timer addr in
  match rpc with
  | Ok rpc ->
    let self = { addr; rpc; timer; default_timeout_s } in
    Log.debug (fun k -> k "connected: %a" pp self);
    Ok self
  | Error err as res ->
    Log.err (fun k ->
        k "coud not connect to %s:@ %a" (string_of_sockaddr addr) RPC.Error.pp
          err);
    res

let connect_tcp_exn (addr : Unix.sockaddr) : t =
  connect_tcp addr |> unwrap_rpc_err

let disconnect (self : t) : unit =
  Log.debug (fun k -> k "disconnecting %a" pp self);
  RPC.Tcp_client.close_without_joining self.rpc

module System = struct
  (** GC statistics *)
  let gc_stats ?timeout_s (self : t) : API.gc_stats Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    RPC.Rpc_conn.call ~timeout_s self.rpc API.System.Client.gc_stats ()

  let release_memory ?timeout_s (self : t) : API.gc_stats Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    RPC.Rpc_conn.call ~timeout_s self.rpc API.System.Client.release_memory ()

  let version ?timeout_s (self : t) : API.version_response Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    RPC.Rpc_conn.call ~timeout_s self.rpc API.System.Client.version ()
end

module Session = struct
  type t = API.session

  let create ?timeout_s (self : client) : t Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    RPC.Rpc_conn.call ~timeout_s self.rpc
      API.SessionManager.Client.create_session
    @@ API.make_session_create ~po_check:(Some true) ()

  let keep_alive (self : client) sesh : unit Fut.t =
    let timeout_s = 5. in
    RPC.Rpc_conn.call ~timeout_s self.rpc
      API.SessionManager.Client.keep_session_alive sesh
end

(** Evaluating code *)
module Eval = struct
  type res = API.code_snippet_eval_result

  let eval_code ?timeout_s (self : client) ~session ~code () : res Fut.t =
    let timeout_s = Option.value ~default:self.default_timeout_s timeout_s in
    let code = API.make_code_snippet ~code ~session:(Some session) () in
    RPC.Rpc_conn.call ~timeout_s self.rpc API.Eval.Client.eval_code_snippet code
end

(* TODO: connect with ezcurl + websocket ugprade, handling auth  *)
