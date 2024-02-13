module C = Imandrax_api_client

let pf = Printf.printf

let () =
  Printexc.register_printer (function
    | C.RPC.Error.E err -> Some (C.RPC.Error.show err)
    | _ -> None)

let client = C.connect_tcp_exn @@ C.addr_inet_local ()

let () = pf "getting GC info…\n%!"

let _gc_stats = C.Fut.wait_block_exn @@ C.System.gc_stats client

(* let () = Format.printf "GC info: %a\n%!" C.API.pp_gc_stats _gc_stats *)

let () = pf "got GC info…\n%!"

let () = C.disconnect client

let () = pf "disconnected\n%!"
