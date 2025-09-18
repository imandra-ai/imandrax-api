type 'a list_with_len = 'a list [@@deriving twine, map, iter, typereg]

open struct
  let pp_list_with_len ppx out l =
    Fmt.fprintf out "[@[(%d elements)@ %a@]]" (List.length l)
      (Util.pp_list ~sep:"; " ppx)
      l
end

type ('term, 'ty) t_poly = {
  f_id: Imandrax_api.Uid.t;
  f_args: 'ty Var.t_poly list;
  regions: ('term, 'ty) Region.t_poly list_with_len;
}
[@@deriving show { with_path = false }, twine, typereg, map, iter]
