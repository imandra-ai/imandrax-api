open Common_

let () =
  Printexc.register_printer (function
    | C.RPC.Error.E err -> Some (C.RPC.Error.show err)
    | _ -> None)

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

let with_client ?port ~json () f =
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "cli.with-client" in
  let@ runner = Moonpool.Fifo_pool.with_ () in
  let client = C.connect_tcp_exn ~runner ~json @@ C.addr_inet_local ?port () in
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

let with_exit f =
  match f () with
  | n -> exit n
  | exception e ->
    let bt = Printexc.get_raw_backtrace () in
    Log.err (fun k ->
        k "uncaught exception: %s@ %s" (Printexc.to_string e)
          (Printexc.raw_backtrace_to_string bt));
    Thread.delay 5.;
    exit 1
