type raw = Imandrakit_twine.offset [@@deriving show, eq, twine]
type _ t = raw

let[@inline] make o : _ t = o
let equal o1 o2 = o1 = o2
let[@inline] show o = show_raw o
let[@inline] pp out o = pp_raw out o
let[@inline] to_twine' enc o = raw_to_twine enc o
let[@inline] of_twine' dec o = raw_of_twine dec o
let to_twine _ = to_twine'
let of_twine _ = of_twine'
