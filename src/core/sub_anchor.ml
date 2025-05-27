type t = {
  fname: string;
      (** name of the symbol containing this sub-anchor in its definition *)
  anchor: int;
}
[@@deriving eq, ord, show { with_path = false }, twine]

let[@inline] hash (self : t) : int =
  CCHash.(combine2 (string self.fname) (int self.anchor))
