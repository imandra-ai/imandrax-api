module TR = Imandrakit_typereg
module Str_map = CCMap.Make (CCString)

type tyexpr = TR.Ty_expr.t
type tydef = TR.Ty_def.t
type tycstor = TR.Ty_def.cstor
type tyrecord = TR.Ty_def.record

let spf = Printf.sprintf
let dump = ref false
let debug = ref false
