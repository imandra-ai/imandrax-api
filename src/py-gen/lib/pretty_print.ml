open Imandrax_api_mir
open Imandrax_api

(* Custom pretty-printer for Ty_view.view with vertically aligned Arrow arguments *)
let pp_ty_view pp_lbl pp_var pp_t out (v : ('lbl, 'var, 't) Ty_view.view) =
  let open Format in
  match v with
  | Ty_view.Var v -> fprintf out "(Var %a)" pp_var v
  | Ty_view.Arrow (lbl, a, b) ->
    fprintf out "@[<v>(Arrow (@[<v>%a,@,%a,@,%a@]))@]" pp_lbl lbl pp_t a pp_t b
  | Ty_view.Tuple ts ->
    fprintf out "@[<hv 2>(Tuple@ @[<hv 2>[%a]@])@]"
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t)
      ts
  | Ty_view.Constr (uid, args) ->
    fprintf out "@[<hv 2>(Constr@ (@[<hv>%a,@,@[<v 1>[%a]@]@]))@]" Uid.pp uid
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@,") pp_t)
      args

(* Custom pretty-printer for Type.t with better Arrow formatting *)
let rec pp_type out (ty : Type.t) =
  let open Format in
  fprintf out
    "@[<hv 2>{ @[<v>@[<hv 2>view =@ %a@];@ @[<h 2>generation =@ %a@]@] }@]"
    (pp_ty_view (fun out () -> fprintf out "()") Uid.pp pp_type)
    ty.view Type.pp_generation ty.generation

(* Custom pretty-printer for Term.view with better indentation *)
let pp_term_view pp_t out (v : (_, _) Term.view) =
  let open Format in
  match v with
  | Term.Const c -> fprintf out "(Const %a)" Imandrax_api.Const.pp c
  | Term.If (a, b, c) ->
    fprintf out "@[<hv 2>If@ (@,%a,@ %a,@ %a@,)@]" pp_t a pp_t b pp_t c
  | Term.Apply { f; l } ->
    fprintf out
      "Apply {@[<hv>@[<hv 2>f = %a@];@,@[<hv 2>l =@ @[<hv 1>[%a]@]@]@,@]}" pp_t
      f
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@,") pp_t)
      l
  | Term.Var v ->
    fprintf out "@[<hv 2>(Var@ %a)@]"
      (Imandrax_api_common.Var.pp_t_poly pp_type)
      v
  | Term.Sym s ->
    fprintf out "@[<hv 2>(Sym@ %a)@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
      s
  | Term.Construct { c; args } ->
    fprintf out
      "@[<hv 2>Construct@ {@,\
       @[<hv 2>c =@ %a@];@,\
       @[<hv 2>args =@ @[<hv 2>[%a]@]@]@,\
       }@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
      c
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t)
      args
  | Term.Destruct { c; i; t } ->
    fprintf out
      "@[<hv 2>Destruct@ {@,\
       @[<hv 2>c =@ %a@];@,\
       @[<hv 2>i =@ %d@];@,\
       @[<hv 2>t =@ %a@]@,\
       }@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
      c i pp_t t
  | Term.Is_a { c; t } ->
    fprintf out "@[<hv 2>Is_a@ {@,@[<hv 2>c =@ %a@];@,@[<hv 2>t =@ %a@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
      c pp_t t
  | Term.Tuple { l } ->
    fprintf out "@[<hv 2>Tuple@ {@,@[<hv 2>l =@ @[<hv 2>[%a]@]@]@,}@]"
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_t)
      l
  | Term.Field { f; t } ->
    fprintf out "@[<hv 2>Field@ {@,@[<hv 2>f =@ %a@];@,@[<hv 2>t =@ %a@]@,}@]"
      (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
      f pp_t t
  | Term.Tuple_field { i; t } ->
    fprintf out
      "@[<hv 2>Tuple_field@ {@,@[<hv 2>i =@ %d@];@,@[<hv 2>t =@ %a@]@,}@]" i
      pp_t t
  | Term.Record { rows; rest } ->
    let pp_row out (sym, t) =
      fprintf out "@[<hv 2>(@,%a,@ %a@,)@]"
        (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
        sym pp_t t
    in
    let pp_rest out = function
      | None -> fprintf out "None"
      | Some t -> fprintf out "@[<hv 2>(Some@ %a)@]" pp_t t
    in
    fprintf out
      "@[<hv 2>Record@ {@,\
       @[<hv 2>rows =@ @[<hv 2>[%a]@]@];@,\
       @[<hv 2>rest =@ %a@]@,\
       }@]"
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_row)
      rows pp_rest rest
  | Term.Case { u; cases; default } ->
    let pp_case out (sym, t) =
      fprintf out "@[<hv 2>(@,%a,@ %a@,)@]"
        (Imandrax_api_common.Applied_symbol.pp_t_poly pp_type)
        sym pp_t t
    in
    let pp_default out = function
      | None -> fprintf out "None"
      | Some t -> fprintf out "@[<hv 2>(Some@ %a)@]" pp_t t
    in
    fprintf out
      "@[<hv 2>Case@ {@,\
       @[<hv 2>u =@ %a@];@,\
       @[<hv 2>cases =@ @[<hv 2>[%a]@]@];@,\
       @[<hv 2>default =@ %a@]@,\
       }@]"
      pp_t u
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_case)
      cases pp_default default

(* Pretty print a term with custom view printer *)
let rec pp_term out (term : Term.term) =
  let open Format in
  fprintf out
    ("@[<hv 2>{ @[<hv 2>view =@ %a@];@\n" ^^ "@[<hv 2>ty =@ %a@];@\n"
   ^^ "@[<hv 2>generation =@ %a@];@ @[<hv 2>sub_anchor =@ %a@] }@]")
    (pp_term_view pp_term) term.view pp_type term.ty Term.pp_generation
    term.generation
    (fun out -> function
      | None -> fprintf out "None"
      | Some a -> fprintf out "(Some %a)" (fun out _ -> fprintf out "...") a)
    term.sub_anchor

(* Pretty printer for Fun_decomp.t with better formatting *)
let pp_fun_decomp
    out
    (fd : (Term.term, Type.t) Imandrax_api_common.Fun_decomp.t_poly) =
  let open Format in
  let open Imandrax_api_common in
  (* Pretty print a variable *)
  let pp_var out (v : Type.t Var.t_poly) =
    fprintf out "@[<hv 2>{ id =@ %a;@ ty =@ %a }@]" Imandrax_api.Uid.pp v.id
      pp_type v.ty
  in

  (* Pretty print region status *)
  let pp_status out = function
    | Region.Unknown -> fprintf out "Unknown"
    | Region.Feasible model ->
      fprintf out "@[<hv 2>Feasible@ %a@]"
        (Model.pp_t_poly pp_term pp_type)
        model
  in

  (* Pretty print meta value *)
  let rec pp_meta out = function
    | Region.Null -> fprintf out "Null"
    | Region.Bool b -> fprintf out "Bool %b" b
    | Region.Int z -> fprintf out "Int %s" (Z.to_string z)
    | Region.Real q -> fprintf out "Real %s" (Q.to_string q)
    | Region.String s -> fprintf out "String %S" s
    | Region.Term t -> fprintf out "@[<hv 2>Term@ %a@]" pp_term t
    | Region.List l ->
      fprintf out "@[<hv 2>List@ [@[<hv>%a@]]@]"
        (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_meta)
        l
    | Region.Assoc assoc ->
      let pp_pair out (k, v) = fprintf out "@[<hv 2>%S:@ %a@]" k pp_meta v in
      fprintf out "@[<hv 2>Assoc@ {@[<hv>%a@]}@]"
        (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_pair)
        assoc
  in

  (* Pretty print a region *)
  let pp_region out (r : (Term.term, Type.t) Region.t_poly) =
    fprintf out
      ("@[<v 2>{ @," ^^ "@[<hv 2>constraints =@ [@[<hv>%a@]]@];@,"
     ^^ "@[<hv 2>invariant =@ %a@];@," ^^ "@[<hv 2>meta =@ [@[<v>%a@]]@];@,"
     ^^ "@[<hv 2>status =@ %a@]@," ^^ "}@]")
      (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_term)
      r.constraints pp_term r.invariant
      (pp_print_list
         ~pp_sep:(fun out () -> fprintf out ";@,")
         (fun out (k, v) -> fprintf out "@[<hv 2>%S:@ %a@]" k pp_meta v))
      r.meta pp_status r.status
  in

  fprintf out
    ("@[<v 2>{ @," ^^ "@[<hv 2>f_id =@ %a@];@,"
   ^^ "@[<hv 2>f_args =@ [@[<hv>%a@]]@];@,"
   ^^ "@[<hv 2>regions =@ [(%d elements)@  @[<v>%a@]]@]@," ^^ "}@]")
    Imandrax_api.Uid.pp fd.f_id
    (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@ ") pp_var)
    fd.f_args (List.length fd.regions)
    (pp_print_list ~pp_sep:(fun out () -> fprintf out ";@,") pp_region)
    fd.regions
