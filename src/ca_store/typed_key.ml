type 'a t = Key.t

let to_raw = Fun.id
let unsafe_of_raw = Fun.id
let show = Key.show
let pp = Key.pp
