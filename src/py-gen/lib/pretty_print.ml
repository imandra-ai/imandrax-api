open Imandrax_api_mir

(* Custom pretty-printer for Term.view with better indentation *)
let pp_term_view pp_t pp_ty out (v : (_, _) Term.view) =
  let open Format in
  match v with
  | Term.Const c ->
    fprintf out "(Const %a)" Imandrax_api.Const.pp c
  | Term.If (a, b, c) ->
    fprintf out "@[<hv 2>If@ (@,%a,@ %a,@ %a@,)@]" pp_t a pp_t b pp_t c
  | Term.Apply { f; l } ->
    fprintf out "@[<hv 2>Apply@ {@,@[<hv 2>f =@ %a@];@,@[<hv 2>l =@ @[<hv 2>[%a]@]@]@,}@]"
      pp_t f
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t) l
  | Term.Var v ->
    fprintf out "@[<hv 2>(Var@ %a)@]" (Imandrax_api_common.Var.pp_t_poly pp_ty) v
  | Term.Sym s ->
    fprintf out "@[<hv 2>(Sym@ %a)@]" (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) s
  | Term.Construct { c; args } ->
    fprintf out "@[<hv 2>Construct@ {@,@[<hv 2>c =@ %a@];@,@[<hv 2>args =@ @[<hv 2>[%a]@]@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) c
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t) args
  | Term.Destruct { c; i; t } ->
    fprintf out "@[<hv 2>Destruct@ {@,@[<hv 2>c =@ %a@];@,@[<hv 2>i =@ %d@];@,@[<hv 2>t =@ %a@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) c i pp_t t
  | Term.Is_a { c; t } ->
    fprintf out "@[<hv 2>Is_a@ {@,@[<hv 2>c =@ %a@];@,@[<hv 2>t =@ %a@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) c pp_t t
  | Term.Tuple { l } ->
    fprintf out "@[<hv 2>Tuple@ {@,@[<hv 2>l =@ @[<hv 2>[%a]@]@]@,}@]"
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t) l
  | Term.Field { f; t } ->
    fprintf out "@[<hv 2>Field@ {@,@[<hv 2>f =@ %a@];@,@[<hv 2>t =@ %a@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) f pp_t t
  | Term.Tuple_field { i; t } ->
    fprintf out "@[<hv 2>Tuple_field@ {@,@[<hv 2>i =@ %d@];@,@[<hv 2>t =@ %a@]@,}@]"
      i pp_t t
  | Term.Record { rows; rest } ->
    let pp_row out (sym, t) =
      fprintf out "@[<hv 2>(@,%a,@ %a@,)@]"
        (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) sym pp_t t
    in
    let pp_rest out = function
      | None -> fprintf out "None"
      | Some t -> fprintf out "@[<hv 2>(Some@ %a)@]" pp_t t
    in
    fprintf out "@[<hv 2>Record@ {@,@[<hv 2>rows =@ @[<hv 2>[%a]@]@];@,@[<hv 2>rest =@ %a@]@,}@]"
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_row) rows
      pp_rest rest
  | Term.Case { u; cases; default } ->
    let pp_case out (sym, t) =
      fprintf out "@[<hv 2>(@,%a,@ %a@,)@]"
        (Imandrax_api_common.Applied_symbol.pp_t_poly pp_ty) sym pp_t t
    in
    let pp_default out = function
      | None -> fprintf out "None"
      | Some t -> fprintf out "@[<hv 2>(Some@ %a)@]" pp_t t
    in
    fprintf out "@[<hv 2>Case@ {@,@[<hv 2>u =@ %a@];@,@[<hv 2>cases =@ @[<hv 2>[%a]@]@];@,@[<hv 2>default =@ %a@]@,}@]"
      pp_t u
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_case) cases
      pp_default default

(* Pretty print a term with custom view printer *)
let pp_term out (term : Term.term) =
  let open Format in
  fprintf out "@[<hv 2>{ @[<hv 2>view =@ %a@];@ @[<hv 2>ty =@ %a@];@ @[<hv 2>generation =@ %a@];@ @[<hv 2>sub_anchor =@ %a@] }@]"
    (pp_term_view Term.pp Type.pp) term.view
    Type.pp term.ty
    Term.pp_generation term.generation
    (fun out -> function
      | None -> fprintf out "None"
      | Some a -> fprintf out "(Some %a)" (fun out _ -> fprintf out "...") a) term.sub_anchor
