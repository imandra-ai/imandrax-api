open Common_

let format_datetime time : string =
  let tm = Unix.localtime time in
  let msec = (time -. floor time) *. 1_000. |> int_of_float in
  spf "%02d-%02d-%02dT%02d:%02d:%02d.%03d" (tm.tm_year - 100) tm.tm_mday
    (tm.tm_mon + 1) tm.tm_hour tm.tm_min tm.tm_sec msec

let reporter ?log_file () : Logs.reporter =
  let out =
    match log_file with
    | None -> stderr
    | Some f -> open_out f
  in

  let report src level ~over k msgf =
    let ts = Unix.gettimeofday () in
    let src = Logs.Src.name src in
    let lvl = Logs.level_to_string @@ Some level in

    let k (_tags : Logs.Tag.set) msg =
      Printf.fprintf out "%s[%s|%s] %s\n%!" (format_datetime ts) lvl src msg;
      over ();
      k ()
    in

    msgf (fun ?header:_ ?(tags = Logs.Tag.empty) fmt ->
        Format.kasprintf (k tags) fmt)
  in
  { Logs.report }

let auth_token_filename ~dev () : string =
  let xdg = Xdg.create ~env:Sys.getenv_opt () in
  let dir = Filename.concat (Xdg.cache_dir xdg) "imandrax" in
  let base =
    if dev then
      "auth_token_dev"
    else
      "auth_token"
  in
  let file = Filename.concat dir base in
  file

(** Read token from disk *)
let get_auth_token ~dev () : string option =
  let file = auth_token_filename ~dev () in
  Log.info (fun k -> k "looking for auth token in %S" file);
  try Some (CCIO.File.read_exn file)
  with exn ->
    Log.warn (fun k ->
        k "could not read token from %S:\n%s" file (Printexc.to_string exn));
    None

let with_client ?rpc_port ~rpc_json ~local_rpc ~dev ~runner ~debug ()
    (f : C.t -> 'a) : 'a =
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "cli.with-client" in
  let client =
    if local_rpc then (
      let port = Option.value ~default:9991 rpc_port in
      Log.app (fun k -> k "connecting via RPC on port %d" port);
      C_RPC.connect_tcp_exn ~runner ~json:rpc_json
      @@ C_RPC.addr_inet_local ~port ()
    ) else (
      let host =
        if dev then
          "imandrax.dev.imandracapital.com"
        else
          failwith "prod not implemented yet (use --dev)"
      in
      let auth_token = get_auth_token ~dev () in
      C_curl.create ~verbose:debug ~runner ~tls:true ~host ~port:443 ~auth_token
        ()
    )
  in
  let finally () =
    C.disconnect client;
    Log.debug (fun k -> k "disconnected")
  in
  Fun.protect ~finally (fun () -> f client)

let setup_logs ?log_file ?lvl ?(debug = false) () : unit =
  Logs.set_reporter (reporter ?log_file ());
  Logs.set_level ~all:true
    (Some
       (if debug then
         Logs.Debug
       else
         Option.value ~default:Logs.Info lvl));
  Log.debug (fun k -> k "logs are setup");
  ()

open struct
  exception E_exit of int
end

(** Exit main application with given code *)
let exit_with n = raise (E_exit n)

let with_exit f =
  match f () with
  | n -> exit n
  | exception E_exit n ->
    Thread.delay 2.;
    exit n
  | exception e ->
    let bt = Printexc.get_raw_backtrace () in
    Log.err (fun k ->
        k "uncaught exception: %s@ %s" (Printexc.to_string e)
          (Printexc.raw_backtrace_to_string bt));
    Thread.delay 2.;
    exit 1
