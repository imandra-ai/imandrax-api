open Common_
module M = Moonpool
module Opts = Cli_opts_
module H = Tiny_httpd
module Html = Tiny_httpd.Html

type error =
  | Bad_tok_type of string
  | Missing_auth_token
  | Bad_nonce of string
  | Missing_nonce
  | Invalid_percent_encoding
  | Missing_token_type
[@@deriving show { with_path = false }]

let mk_js_code ~port () : string =
  spf
    {yikes|
(async () => {
  console.log(`location is: ${document.location}`);

  const res = await fetch("http://localhost:%d/cb", {
    method: "POST",
    body: document.location.hash.slice(1), // remove '#'
  });

  console.log(`response: ${res}`);
  document.body.innerHTML =
    `authentication ${ res.trim() == 'ok' ? 'succeeded' : 'failed' } <br/> <b>you can close this window now<b>`;
})();
|yikes}
    port

let run (self : Opts.login) : int =
  let@ () = Trace_tef.with_setup () in
  Utils.setup_logs ~debug:self.debug ();
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "cli.login" in

  let nonce : string =
    Uuidm.v4_gen (Random.State.make_self_init ()) () |> Uuidm.to_string
  in

  (* we will receive the response here *)
  let response = M.Blocking_queue.create () in

  (* local server for the callback *)
  let h = Tiny_httpd.create ~port:self.local_port () in

  (* serve JS because the data is only client side 🙄 *)
  H.add_route_handler h ~meth:`GET
    H.Route.(exact "cb" @/ return)
    (fun _req ->
      let js_code = mk_js_code ~port:self.local_port () in
      let doc =
        Html.(
          html []
            [ head [] []; body [] [ script [] [ Html.raw_html js_code ] ] ])
      in
      H.Response.make_string @@ Ok (Html.to_string_top doc));

  (* receive the actual data, sent by JS *)
  H.add_route_handler h ~meth:`POST
    H.Route.(exact "cb" @/ return)
    (fun req ->
      let body = H.Request.body req in
      Log.debug (fun k -> k "body: %s" body);

      (* decode the body, which is the path of the original query *)
      let items =
        body |> String.split_on_char '&'
        |> List.map (fun item ->
               let k, v = CCString.Split.left_exn ~by:"=" item in
               k, H.Util.percent_decode v |> Option.get)
      in

      Log.debug (fun k ->
          k "items: [%s]"
            (String.concat ","
            @@ List.map (fun (k, v) -> spf "%S: %S" k v) items));

      let ok =
        (* check for the nonce *)
        match
          ( List.assoc_opt "state" items,
            List.assoc_opt "access_token" items,
            List.assoc_opt "token_type" items )
        with
        | _, _, None ->
          M.Blocking_queue.push response @@ Error Missing_token_type;
          false
        | Some n, Some tok, Some "Bearer" ->
          if n = nonce then (
            M.Blocking_queue.push response @@ Ok tok;
            true
          ) else (
            M.Blocking_queue.push response @@ Error (Bad_nonce n);
            false
          )
        | _, None, _ ->
          M.Blocking_queue.push response @@ Error Missing_auth_token;
          false
        | None, _, _ ->
          M.Blocking_queue.push response @@ Error Missing_nonce;
          false
        | _, _, Some tk ->
          M.Blocking_queue.push response @@ Error (Bad_tok_type tk);
          false
      in
      let msg =
        if ok then
          "success"
        else
          "invalid"
      in
      H.Response.make_string ~code:200 @@ Ok msg);
  (* background thread for the server *)
  let _t_server = Thread.create (fun () -> H.run_exn h) () in

  let redirect_uri = spf "http://localhost:%d/cb/" self.local_port in
  (* URL to open in the user's browser *)
  let url =
    let client_id = "EZBvjhs2aiatKUNeUuIWcph7ZoBpYckB" in
    if self.dev then
      spf
        "https://test-ai.eu.auth0.com/authorize?response_type=token&client_id=%s&redirect_uri=%s&state=%s"
        client_id
        (H.Util.percent_encode redirect_uri)
        (H.Util.percent_encode nonce)
    else
      failwith "login to prod not implemented yet"
  in
  Log.info (fun k -> k "openining auth page on %s" url);
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "login.open-browser" in
  (match Webbrowser.reload url with
  | Ok () -> ()
  | Error (`Msg msg) ->
    Log.err (fun k ->
        k "could not open browser: %s" msg;
        Utils.exit_with 10));

  (* now wait *)
  let res = M.Blocking_queue.pop response in
  match res with
  | Error err ->
    Log.err (fun k -> k "Error: %a" pp_error err);
    10
  | Ok tok ->
    (* success! *)
    Log.debug (fun k -> k "success! got token %S" tok);
    let tok_file = Utils.auth_token_filename ~dev:self.dev () in
    (* TODO: make it less ugly *)
    (try ignore (Unix.system (spf "mkdir -p %s" (Filename.dirname tok_file)))
     with _ -> ());
    (try CCIO.File.write_exn tok_file tok
     with exn ->
       Log.err (fun k ->
           k "Cannot write token file %S:@ %s" tok_file (Printexc.to_string exn));
       Utils.exit_with 10);
    Log.info (fun k -> k "token has been written to %s" tok_file);
    0
