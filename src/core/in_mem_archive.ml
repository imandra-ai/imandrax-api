open struct
  let pp_data out s =
    Fmt.fprintf out "<data :size %a>" Util.pp_byte_size (String.length s)
end

type raw = {
  ty: string;
  compressed: bool;
  data: (string[@twine.use_bytes]); [@printer pp_data]
}
[@@deriving typereg, twine, show { with_path = false }]

type 'a t = raw [@@deriving typereg]

let pp _ out (self : _ t) = pp_raw out self
let to_twine = raw_to_twine
let of_twine = raw_of_twine
