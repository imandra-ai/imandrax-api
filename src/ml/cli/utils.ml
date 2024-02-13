open Common_

let () =
  Printexc.register_printer (function
    | C.RPC.Error.E err -> Some (C.RPC.Error.show err)
    | _ -> None)

let with_client ?port () f =
  let@ _sp = Trace.with_span ~__FILE__ ~__LINE__ "cli.with-client" in
  let client = C.connect_tcp_exn @@ C.addr_inet_local ?port () in
  let finally () =
    C.disconnect client;
    Log.info (fun k -> k "disconnected")
  in
  Fun.protect ~finally (fun () -> f client)

let setup_logs ?(debug = false) () : unit =
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level ~all:true
    (Some
       (if debug then
         Logs.Debug
       else
         Logs.Info));
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
