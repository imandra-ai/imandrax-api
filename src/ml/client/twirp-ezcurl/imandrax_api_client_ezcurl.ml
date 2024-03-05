(* TODO: instantiate core client with
   our Fut, our way of connecting, and our way of making a request/reply
*)

open struct
  module Log = Imandrax_api_client_core.Log
  module Rpool = Imandrax_api_client_core.Rpool
  module C = Twirp_ezcurl

  let ( let@ ) = ( @@ )
  let spf = Printf.sprintf

  let () =
    Printexc.register_printer (function
      | C.E_twirp err ->
        Some (Format.asprintf "twirp error: %a" C.Error.pp_error err)
      | _ -> None)
end

include Imandrax_api_client_moonpool

module Addr = struct
  type t = {
    tls: bool;
    host: string;
    port: int;
  }

  let show self =
    spf "http%s://%s:%d"
      (if self.tls then
        "s"
      else
        "")
      self.host self.port
end

module Conn = struct
  type t = {
    active: bool Atomic.t;
    addr: Addr.t;
    verbose: bool;
    clients: Curl.t Rpool.t;  (** pool of clients *)
    auth_token: string option;  (** JWT *)
    runner: Moonpool.Runner.t;
  }

  let pp out (self : t) =
    Format.fprintf out "<twirp-ezcurl-client %s>" (Addr.show self.addr)

  let disconnect (self : t) : unit =
    if Atomic.exchange self.active false then (
      Log.debug (fun k -> k "disconnecting %a" pp self);
      Rpool.dispose self.clients
    );
    ()

  let rpc_call (self : t) ~timeout_s:_ rpc req : _ Fut.t =
    (* FIXME: use timeout *)
    let run () =
      let@ client = Rpool.with_resource self.clients in

      let auth_header =
        match self.auth_token with
        | None -> []
        | Some tok -> [ "Authorization", spf "Bearer %s" tok ]
      in
      Log.debug (fun k ->
          k "auth headers: [%s]"
            (String.concat ","
            @@ List.map (fun (k, v) -> spf "%s: %s" k v)
            @@ auth_header));

      let headers = auth_header in
      Curl.set_verbose client self.verbose;

      C.call_exn ~prefix:(Some "api/v1") ~client ~host:self.addr.host
        ~port:self.addr.port ~use_tls:self.addr.tls ~headers rpc req
    in

    Moonpool.Fut.spawn ~on:self.runner run

  let to_rpc (self : t) : rpc_client =
    object
      method disconnect () = disconnect self
      method active () = Atomic.get self.active

      method rpc_call
          : 'req 'res.
            timeout_s:float ->
            ( 'req,
              Pbrt_services.Value_mode.unary,
              'res,
              Pbrt_services.Value_mode.unary )
            Pbrt_services.Client.rpc ->
            'req ->
            'res Fut.t =
        fun ~timeout_s rpc req -> rpc_call self ~timeout_s rpc req
    end
end

let create ?(tls = true) ?(verbose = false) ~host ~port ~runner
    ~(auth_token : string option) () : t =
  let addr = { Addr.tls; host; port } in
  let clients =
    Rpool.create ~clear:Curl.reset ~dispose:Curl.cleanup
      ~mk_item:(fun () -> Curl.init ())
      ~max_size:16 ()
  in
  let conn =
    {
      Conn.active = Atomic.make true;
      verbose;
      addr;
      clients;
      auth_token;
      runner;
    }
  in
  create ~addr:(Addr.show addr) ~rpc:(Conn.to_rpc conn) ()

let dispose = Conn.disconnect
