open struct
  let pp_data out s =
    Fmt.fprintf out "<data :size %a>" Util.pp_byte_size (String.length s)
end

type raw = {
  ty: string;
  compressed: bool;
  data: string; [@use_bytes] [@printer pp_data]
}
[@@deriving twine, typereg, show { with_path = false }]

type _ t = raw

let pp _ out (self : _ t) = pp_raw out self
let to_twine = raw_to_twine
let of_twine = raw_of_twine
