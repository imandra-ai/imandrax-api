type raw = {
  ty: string;
  compressed: bool;
  data: string; [@use_bytes]
}
[@@deriving twine, typereg]

type _ t = raw

let to_twine = raw_to_twine
let of_twine = raw_of_twine
