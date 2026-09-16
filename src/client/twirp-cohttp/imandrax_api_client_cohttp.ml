open struct
  module Log = Imandrax_api_client_core.Log

  let spf = Printf.sprintf
end

open Lwt.Syntax
include Imandrax_api_client_lwt

(** This is [Twirp_cohttp_lwt_unix], except that the client
    threaded through the calls is a {!Cookie_jar} rather than [unit], so that
    cookies survive from one call to the next.  *)
module C = struct
  (* ai-disclosure: ai-generated *)
  include Twirp_core.Client.Common

  include Twirp_core.Client.Make (struct
    module IO = struct
      type 'a t = 'a Lwt.t

      let ( let* ) = Lwt.bind
      let return = Lwt.return
    end

    type client = Cookie_jar.t

    let http_post ~headers ~url ~body (jar : client) () : _ result Lwt.t =
      let uri = Uri.of_string url in
      Lwt.catch
        (fun () ->
          let headers =
            match Cookie_jar.to_header jar with
            | None -> headers
            | Some h -> h :: headers
          in
          let headers = Cohttp.Header.of_list headers in
          let* resp, res_body =
            Cohttp_lwt_unix.Client.post ~body:(`String body) ~headers uri
          in
          let code =
            Cohttp.Response.status resp |> Cohttp.Code.code_of_status
          in
          let* res_body = res_body |> Cohttp_lwt.Body.to_string in
          let headers = Cohttp.Response.headers resp |> Cohttp.Header.to_list in
          Cookie_jar.update_from_response jar headers;
          Lwt.return @@ Ok (res_body, code, headers))
        (fun exn -> Lwt.return @@ Error (Printexc.to_string exn))
  end)
end

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
    cookies: Cookie_jar.t;
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

      let headers =
        auth_header @ Imandrax_api_client_core.Standard_endpoints.headers
      in

      C.call ~encoding:self.encoding ~prefix:(Some "api/v1")
        ~base_url:self.addr.url ~headers self.cookies rpc req
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

include Imandrax_api_client_core.Standard_endpoints

let create ?(verbose = false) ?(encoding = `JSON) ?(url = url_prod)
    ~(auth_token : string option) () : t =
  let addr = { Addr.url } in
  let conn =
    {
      Conn.active = Atomic.make true;
      encoding;
      verbose;
      addr;
      auth_token;
      cookies = Cookie_jar.create ();
    }
  in
  create ~addr:(Addr.show addr) ~rpc:(Conn.to_rpc conn) ()

let dispose = Conn.disconnect
