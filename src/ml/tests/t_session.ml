module C = Imandrax_api_client

let pf = Format.printf
let client = C.connect_tcp_exn @@ C.addr_inet_local ()
let session : C.API.session = C.Session.create client |> C.Fut.wait_block_exn
let () = pf "got session@."

(* let () = pf "session=%S@." (Bytes.unsafe_to_string session.id) *)

(* let () = Format.printf "GC info: %a\n%!" C.API.pp_gc_stats _gc_stats *)

let () = C.disconnect client
let () = pf "disconnected@."
