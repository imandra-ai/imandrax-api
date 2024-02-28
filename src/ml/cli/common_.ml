module C = Imandrax_api_client_moonpool
module C_RPC = Imandrax_api_client_rpc
module C_curl = Imandrax_api_client_ezcurl
module Fmt = CCFormat
module Fut = Moonpool.Fut
module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.cli"))
module Trace = Trace_core

let ( let@ ) = ( @@ )
let spf = Printf.sprintf
