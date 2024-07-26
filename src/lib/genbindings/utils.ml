open Common_

let rec subst_ty (subst : tyexpr Str_map.t) (ty : tyexpr) : tyexpr =
  match ty with
  | Var v -> (try Str_map.find v subst with Not_found -> ty)
  | Arrow _ | Tuple _ | Cstor _ -> TR.Ty_expr.map_shallow ty ~f:(subst_ty subst)
