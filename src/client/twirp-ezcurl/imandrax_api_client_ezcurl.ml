(** A simple HTTP client based on {{:https://github.com/c-cube/ezcurl/} ezcurl}.

    All calls in this clients are blocking. The client is not thread safe and
    must be protected adequately if shared between threads. *)

(* TODO: instantiate core client with
   our Fut, our way of connecting, and our way of making a request/reply
*)

open Imandrakit_thread

open struct
  module C = Twirp_ezcurl

  let ( let@ ) = ( @@ )
  let spf = Printf.sprintf

  let () =
    Printexc.register_printer (function
      | C.E_twirp err ->
        Some (Format.asprintf "twirp error: %a" C.Error.pp_error err)
      | _ -> None)
end

include Imandrax_api_client_core.Blocking

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
    client: Curl.t Lock.t;  (** single, sessionfull client *)
    auth_token: string option;  (** JWT *)
  }

  let pp out (self : t) =
    Format.fprintf out "<twirp-ezcurl-client %s>" (Addr.show self.addr)

  let disconnect (self : t) : unit =
    if Atomic.exchange self.active false then (
      Log.debug (fun k -> k "disconnecting %a" pp self);
      let@ c = Lock.with_lock self.client in
      Ezcurl.delete c
    );
    ()

  let rpc_call (self : t) ~timeout_s:_ rpc req : _ =
    (* FIXME: use timeout *)
    let@ client = Lock.with_lock self.client in

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
    Curl.set_verbose client self.verbose;

    C.call_exn ~encoding:self.encoding ~prefix:(Some "api/v1") ~client
      ~base_url:self.addr.url ~headers rpc req

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
          'res =
        fun ~timeout_s rpc req -> rpc_call self ~timeout_s rpc req
    end
end

include Imandrax_api_client_core.Standard_endpoints

let create ?(verbose = false) ?(encoding = `JSON) ?(url = url_prod)
    ~(auth_token : string option) () : t =
  let addr = { Addr.url } in
  let client =
    let set_opts curl =
      (* enable cookie handling so we always talk to the same server *)
      Curl.set_cookiefile curl ""
    in
    let c = Ezcurl.make ~set_opts () in
    Lock.create c
  in
  let conn =
    {
      Conn.active = Atomic.make true;
      encoding;
      verbose;
      addr;
      client;
      auth_token;
    }
  in
  create ~addr:(Addr.show addr) ~rpc:(Conn.to_rpc conn) ()

let dispose = Conn.disconnect
