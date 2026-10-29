(* Models *)

open Builders

let shape = constr "shape" []

let model ?(tys = []) ?(consts = []) ?(funs = []) ?(ty_subst = []) () :
    Mir.Model.t =
  { tys; consts; funs; representable = true; completed = false; ty_subst }

let full =
  model
    ~tys:
      [
        shape, Ty_finite [ int 0; int 1 ];
        constr "unit_alias" [], Ty_alias_unit (constr "unit" []);
      ]
    ~consts:[ sym "c" int_ty, int 3 ]
    ~funs:
      [
        ( succ,
          {
            fi_args = [ x ];
            fi_ty_ret = int_ty;
            fi_cases = [ [ x_pos ], int 1; [], int 2 ];
            fi_else = int 0;
          } );
      ]
    ~ty_subst:[ alpha, int_ty ]
    ()

let cases = [ case "empty" A.Model (model ()); case "full" A.Model full ]
