(** Simple client for ImandraX *)

module API = Imandrax_api_proto

open struct
  module RPC = Batrpc

  let spf = Printf.sprintf

  let ( let@ ) = ( @@ )
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
}
(** A RPC client. *)

open struct
  type client = t

  let string_of_sockaddr = function
    | Unix.ADDR_UNIX s -> spf "unix:%s" s
    | Unix.ADDR_INET (addr, port) ->
      spf "tcp://%s:%d" (Unix.string_of_inet_addr addr) port
end

let pp out (self : t) =
  Format.fprintf out "<imandrax-client on %s>" (string_of_sockaddr self.addr)

let addr_inet_local ?(port = 9991) () : Unix.sockaddr =
  Unix.ADDR_INET (Unix.inet_addr_loopback, port)

(** Connect to the server over TCP *)
let connect_tcp (addr : Unix.sockaddr) : t result =
  let timer = RPC.Simple_timer.create () in
  let rpc = RPC.Tcp_client.connect ~timer addr in
  Result.map (fun rpc -> { addr; rpc; timer }) rpc

let connect_tcp_exn (addr : Unix.sockaddr) : t =
  connect_tcp addr |> unwrap_rpc_err

let disconnect (self : t) : unit = RPC.Tcp_client.close_and_join self.rpc

module GC = struct
  (** GC statistics *)
  let stats (self : t) : API.gc_stats Fut.t =
    RPC.Rpc_conn.call self.rpc API.Gc_service.Client.get_stats ()
end

module Session = struct
  type t = API.session

  let create (self : client) : t Fut.t =
    RPC.Rpc_conn.call self.rpc API.SessionManager.Client.create_session
    @@ API.make_session_create ~po_check:(Some true) ()

  let delete (self : client) (sesh : t) : unit Fut.t =
    RPC.Rpc_conn.call self.rpc API.SessionManager.Client.delete_session sesh
end

(* TODO: connect with ezcurl + websocket ugprade, handling auth  *)
