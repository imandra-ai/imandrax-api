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

(** Connect to the server over TCP *)
let connect_tcp (addr : Unix.sockaddr) : t result =
  let timer = RPC.Simple_timer.create () in
  let rpc = RPC.Tcp_client.connect ~timer addr in
  Result.map (fun rpc -> { rpc; timer }) rpc

let connect_tcp_exn (addr : Unix.sockaddr) : t =
  connect_tcp addr |> unwrap_rpc_err

(** GC statistics *)
let gc_stats (self : t) : API.gc_stats Fut.t =
  RPC.Rpc_conn.call self.rpc API.Gc_service.Client.get_stats ()

(* TODO: connect with ezcurl + websocket ugprade, handling auth  *)
