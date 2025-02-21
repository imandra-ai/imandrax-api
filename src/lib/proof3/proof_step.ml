(** Single proof steps *)

  open Common_

type arg =
  | Term
  | Seq

  | Int
  (* | String *)
  | List of arg
[@@deriving show { with_path = false }, twine, typereg]

  (** A proof rule *)
type rule = {
  name: string;
  descr: string;
  args: arg list;
}
[@@deriving show { with_path = false }, twine, typereg]

type ('term, 'ty) t_poly = { concl: 'term }
[@@deriving show { with_path = false }, twine, typereg, map, iter]

and ('term, 'ty) view = Cut of ref_ list * ref_
    | Rule of 

