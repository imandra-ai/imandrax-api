type t = Var.Set.t

let to_twine enc s =
  Imandrakit_twine.Encode.(
    array_iter enc (Var.Set.to_iter s |> Iter.map (Var.to_twine enc)))

let of_twine dec s =
  Imandrakit_twine.Decode.(
    let c = array dec s in
    Array_cursor.to_iter_of c (Var.of_twine dec) |> Var.Set.of_iter)

let pp out (self : t) =
  Fmt.fprintf out "{@[%a@]}" (Util.pp_iter Var.pp) (Var.Set.to_iter self)
