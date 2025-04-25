open struct
  module Log = Imandrax_api_client_core.Log
  module C = Twirp_cohttp_lwt_unix

  let spf = Printf.sprintf
end

open Lwt.Syntax
include Imandrax_api_client_lwt

module Addr = struct
  type t = { url: string } [@@unboxed]

  let show self = self.url
end

module Conn = struct
  type t = {
    active: bool Atomic.t;
    addr: Addr.t;
    encoding: [ `JSON | `BINARY ];
    verbose: bool;
    auth_token: string option;  (** JWT *)
  }

  let pp out (self : t) =
    Format.fprintf out "<twirp-ezcurl-client %s>" (Addr.show self.addr)

  let disconnect (self : t) : unit =
    if Atomic.exchange self.active false then
      Log.debug (fun k -> k "disconnecting %a" pp self)

  let rpc_call (self : t) ~timeout_s rpc req : _ Lwt.t =
    let fut : _ Lwt.t =
      let auth_header =
        match self.auth_token with
        | None -> []
        | Some tok -> [ "Authorization", spf "Bearer %s" tok ]
      in
      Log.debug (fun k ->
          k "auth headers: [%s]"
            (String.concat ","
            @@ List.map (fun (k, _) -> spf "%s: ****" k)
            @@ auth_header));

      let headers = auth_header in

      C.call ~encoding:self.encoding ~prefix:(Some "api/v1")
        ~base_url:self.addr.url ~headers rpc req
    in
    Lwt.pick [ fut; Lwt_unix.timeout timeout_s ]

  let to_rpc (self : t) : rpc_client =
    object
      method disconnect () = disconnect self
      method active () = Atomic.get self.active

      method rpc_call :
          'req 'res.
          timeout_s:float ->
          ( 'req,
            Pbrt_services.Value_mode.unary,
            'res,
            Pbrt_services.Value_mode.unary )
          Pbrt_services.Client.rpc ->
          'req ->
          'res Lwt.t =
        fun ~timeout_s rpc req ->
          let* r = rpc_call self ~timeout_s rpc req in
          match r with
          | Ok x -> Lwt.return x
          | Error err ->
            let err = Failure err.msg in
            Lwt.fail err
    end
end

let create ?(tls = true) ?(verbose = false) ?(encoding = `JSON) ~host ~port
    ~(auth_token : string option) () : t =
  let addr = { Addr.tls; host; port } in
  let conn =
    { Conn.active = Atomic.make true; encoding; verbose; addr; auth_token }
  in
  create ~addr:(Addr.show addr) ~rpc:(Conn.to_rpc conn) ()

let dispose = Conn.disconnect
