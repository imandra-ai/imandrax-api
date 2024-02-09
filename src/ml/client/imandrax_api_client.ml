(** Simple client for ImandraX *)

module API = Imandrax_api_proto

open struct
  module RPC = Batrpc
end

module Fut = Moonpool.Fut

type err = RPC.Error.t
type nonrec 'a result = ('a, err) result

let[@inline] unwrap_rpc_err = function
  | Ok x -> x
  | Error err -> failwith @@ RPC.Error.show err

type t = {
  rpc: RPC.Rpc_conn.t;
  timer: RPC.Timer.t;
}
(** A RPC client. *)

open struct
  type client = t
end

(** Connect to the server over TCP *)
let connect_tcp (addr : Unix.sockaddr) : t result =
  let timer = RPC.Simple_timer.create () in
  let rpc = RPC.Tcp_client.connect ~timer addr in
  Result.map (fun rpc -> { rpc; timer }) rpc

let connect_tcp_exn (addr : Unix.sockaddr) : t =
  connect_tcp addr |> unwrap_rpc_err

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
