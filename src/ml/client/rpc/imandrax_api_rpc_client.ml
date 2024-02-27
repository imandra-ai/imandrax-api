(* TODO: instantiate core client with
   our Fut, our way of connecting, and our way of making a request/reply
*)

module API = Imandrax_api_proto
module RPC = Batrpc
module Timer = RPC.Timer

open struct
  module Log = Imandrax_api_client_core.Log

  let spf = Printf.sprintf

  let[@inline] unwrap_rpc_err = function
    | Ok x -> x
    | Error err -> failwith @@ RPC.Error.show err
end

module Arg = struct
  module Fut = Moonpool.Fut

  module Err = struct
    type t = RPC.Error.t

    let show = RPC.Error.show
  end

  type nonrec 'a result = ('a, Err.t) result

  module Addr = struct
    type t = Unix.sockaddr

    let show = function
      | Unix.ADDR_UNIX s -> spf "unix:%s" s
      | Unix.ADDR_INET (addr, port) ->
        spf "tcp://%s:%d" (Unix.string_of_inet_addr addr) port
  end

  module Conn = struct
    type t = {
      addr: Addr.t;
      rpc: RPC.Rpc_conn.t;
      active: RPC.Switch.t;
      runner: Moonpool.Runner.t;
      timer: RPC.Timer.t;
    }

    let pp out (self : t) =
      Format.fprintf out "<rpc-client %s>" (Addr.show self.addr)

    let disconnect (self : t) : unit =
      Log.debug (fun k -> k "disconnecting %a" pp self);
      RPC.Tcp_client.close_without_joining self.rpc
  end

  let rpc_call (self : Conn.t) ~timeout_s rpc req : _ Fut.t =
    RPC.Rpc_conn.call ~timeout_s self.rpc rpc req
end

include Imandrax_api_client_core.Make (Arg)

let addr_inet_local ?(port = 9991) () : Unix.sockaddr =
  Unix.ADDR_INET (Unix.inet_addr_loopback, port)

(** Connect to the server over TCP *)
let connect_tcp ?active ?default_timeout_s ?(json = false) ~runner
    (addr : Unix.sockaddr) : t result =
  Log.debug (fun k -> k "connecting to %s…" (Arg.Addr.show addr));
  let active =
    match active with
    | Some sw -> sw
    | None -> Batrpc_unix.Simple_switch.create ()
  in
  let timer = RPC.Simple_timer.create () in
  let encoding =
    if json then
      RPC.Encoding.Json
    else
      RPC.Encoding.Binary
  in
  let rpc = RPC.Tcp_client.connect ~active ~runner ~timer ~encoding addr in
  match rpc with
  | Ok rpc ->
    let conn = { Arg.Conn.active; addr; rpc; runner; timer } in
    Log.debug (fun k -> k "connected: %a" Arg.Conn.pp conn);
    let self = create ?default_timeout_s ~addr ~conn () in
    Ok self
  | Error err as res ->
    Log.err (fun k ->
        k "coud not connect to %s:@ %a" (Arg.Addr.show addr) RPC.Error.pp err);
    res

let connect_tcp_exn ?active ?json ~runner (addr : Unix.sockaddr) : t =
  connect_tcp ?active ?json ~runner addr |> unwrap_rpc_err
