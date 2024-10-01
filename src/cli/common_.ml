module C = Imandrax_api_client_ezcurl
module Fmt = CCFormat
module Log = (val Logs.src_log (Logs.Src.create "imandrax.api.cli"))
module Fut = Moonpool.Fut
module Trace = Trace_core

let ( let@ ) = ( @@ )
let spf = Printf.sprintf
