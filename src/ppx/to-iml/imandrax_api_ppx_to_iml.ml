(* we follow
   https://ppxlib.readthedocs.io/en/latest/ppx-for-plugin-authors.html .
   Ported from https://github.com/imandra-ai/cbor-pack/ *)

open Ppxlib
module A = Ast_helper

let spf = Printf.sprintf

(* utils *)
open struct
  (* name for variables *)
  let name_poly_var_ v = spf "_iml_%s" v
  let mkstrlit s = A.Exp.constant (A.Const.string s)

  let mk_lambda ~loc args body =
    List.fold_right
      (fun arg bod -> [%expr fun [%p A.Pat.var { loc; txt = arg }] -> [%e bod]])
      args body

  (** list literal *)
  let rec mk_list ~loc = function
    | [] -> [%expr []]
    | x :: tl -> [%expr [%e x] :: [%e mk_list ~loc tl]]

  let rec map_lid ~f (lid : Longident.t) : Longident.t =
    match lid with
    | Longident.Lident name -> Longident.Lident (f name)
    | Longident.Lapply (a, b) -> Longident.Lapply (a, map_lid ~f b)
    | Longident.Ldot (m, a) -> Longident.Ldot (m, f a)
end

let to_iml_name_of_ty_name (ty_name : string) : string =
  if ty_name = "t" then
    "to_iml_string"
  else
    ty_name ^ "_to_iml_string"

let to_iml_name_of_lid = map_lid ~f:to_iml_name_of_ty_name

let rec expr_to_iml (ty : core_type) (e : expression) : expression =
  let loc = ty.ptyp_loc in
  match ty with
  | [%type: int] | [%type: Z.t] | [%type: Int.t] -> [%expr Z.to_string [%e e]]
  | [%type: real] | [%type: Q.t] | [%type: Real.t] ->
    [%expr Printf.sprintf "(Real.mk_of_string \"%a\")" Q.sprint [%e e]]
  | [%type: float] -> [%expr Printf.sprintf "%sp" (string_of_float [%e e])]
  | [%type: bool] -> [%expr string_of_bool [%e e]]
  | [%type: unit] -> [%expr "()"]
  | [%type: string] -> [%expr Printf.sprintf "%S" [%e e]]
  | [%type: Imandrax_api.Uid.t] | [%type: Uid.t] ->
    [%expr
      let name = Uid.name [%e e] in
      Printf.sprintf "[%%id %S]" name]
  | [%type: [%t? ty_arg0] option] ->
    [%expr
      match [%e e] with
      | None -> "None"
      | Some x -> Printf.sprintf "(Some %s)" [%e expr_to_iml ty_arg0 [%expr x]]]
  | [%type: [%t? ty_arg0] list] ->
    [%expr
      let l = List.map (fun x -> [%e expr_to_iml ty_arg0 [%expr x]]) [%e e] in
      Printf.sprintf "[%s]" (String.concat "; " l)]
  | [%type: int32]
  | [%type: int64]
  | [%type: nativeint]
  | [%type: bytes]
  | [%type: char]
  | [%type: _ array] ->
    [%expr [%error "This type is not supported by imandrax-api-ppx.to-iml"]]
  | { ptyp_desc = Ptyp_var v; ptyp_loc = loc; _ } ->
    (* use function passed as a parameter for each polymorphic argument *)
    let s : string = name_poly_var_ v in
    [%expr [%e A.Exp.ident { loc; txt = Longident.Lident s }] [%e e]]
  | { ptyp_desc = Ptyp_constr (lid, args); ptyp_loc = loc; _ } ->
    let args =
      List.map
        (fun a -> Nolabel, [%expr fun self -> [%e expr_to_iml a [%expr self]]])
        args
    in
    A.Exp.apply
      (A.Exp.ident { loc; txt = to_iml_name_of_lid lid.txt })
      (args @ [ Nolabel, e ])
  | { ptyp_desc = Ptyp_tuple args; ptyp_loc = loc; _ } ->
    let pat_args =
      List.mapi (fun i _a -> A.Pat.var { loc; txt = spf "x_%d" i }) args
    in
    let result_args =
      List.mapi
        (fun i (a : core_type) ->
          expr_to_iml a
            (A.Exp.ident { loc; txt = Longident.Lident (spf "x_%d" i) }))
        args
    in
    [%expr
      let [%p A.Pat.tuple ~loc pat_args] = [%e e] in
      let items = [%e mk_list ~loc result_args] in
      Printf.sprintf "(%s)" (String.concat ", " items)]
  | { ptyp_desc = Ptyp_alias (ty, _); _ } -> expr_to_iml ty e
  | { ptyp_desc = Ptyp_variant _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml polymorphic variants yet"]]
  | { ptyp_desc = Ptyp_arrow _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml functions"]]
  | { ptyp_desc = Ptyp_class _ | Ptyp_object _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml objects yet"]]
  | { ptyp_desc = Ptyp_package _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml first-class modules"]]
  | { ptyp_desc = Ptyp_extension _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml type extensions"]]
  | { ptyp_desc = Ptyp_any; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml values of type `_`"]]
  | { ptyp_desc = Ptyp_poly _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot turn to iml values of this type"]]

exception Error_gen of Location.t * string

let error_gen ~loc e = raise (Error_gen (loc, e))

let param_names ty =
  ty.ptype_params
  |> List.map (fun (ty, _) ->
         let loc = ty.ptyp_loc in
         match ty.ptyp_desc with
         | Ptyp_var a -> a
         | Ptyp_any -> error_gen ~loc "Cannot derive to_iml for implicit param"
         | _ -> error_gen ~loc "Cannot derive to_iml for non-variable type")

let to_iml_vb_of_tydecl (d : type_declaration) : value_binding =
  let loc = d.ptype_loc in

  let body : expression =
    match d.ptype_kind with
    | Ptype_abstract ->
      (match d.ptype_manifest with
      | Some ty_alias ->
        (* alias, just forward to it *)
        expr_to_iml ty_alias [%expr self]
      | None -> [%expr [%error "cannot derive to_iml for abstract type"]])
    | Ptype_open -> [%expr [%error "cannot derive to_iml for open type"]]
    | Ptype_variant cstors ->
      let case_of_cstor (c : constructor_declaration) : case =
        let loc = c.pcd_loc in
        let c_lid = { loc; txt = Longident.Lident c.pcd_name.txt } in

        let pat, rhs =
          match c.pcd_args with
          | Pcstr_tuple [] ->
            A.Pat.construct c_lid None, mkstrlit c.pcd_name.txt
          | Pcstr_tuple [ ty0 ] ->
            ( A.Pat.construct c_lid @@ Some [%pat? x],
              [%expr
                Printf.sprintf
                  [%e mkstrlit @@ spf "(%s %%s)" c.pcd_name.txt]
                  [%e expr_to_iml ty0 [%expr x]]] )
          | Pcstr_tuple l ->
            let pat =
              A.Pat.construct c_lid
              @@ Some
                   (A.Pat.tuple
                   @@ List.mapi
                        (fun i _ -> A.Pat.var { loc; txt = spf "x_%d" i })
                        l)
            in
            let args =
              List.mapi
                (fun i a ->
                  ( Nolabel,
                    expr_to_iml a
                      (A.Exp.ident
                         { loc; txt = Longident.Lident (spf "x_%d" i) }) ))
                l
            in
            let spf_exp =
              let n =
                if c.pcd_name.txt = "::" then
                  "(::)"
                else
                  c.pcd_name.txt
              in
              [%expr
                Printf.sprintf
                  [%e
                    mkstrlit
                    @@ spf "(%s (%s))" n
                         (String.concat "," @@ List.map (fun _ -> "%s") l)]]
            in
            let rhs = A.Exp.apply spf_exp args in
            pat, rhs
          | Pcstr_record r ->
            let pat = A.Pat.construct c_lid @@ Some [%pat? r] in
            let res_fields =
              r
              |> List.map (fun (f : label_declaration) ->
                     let field_expr =
                       A.Exp.field [%expr r]
                         { loc; txt = Longident.Lident f.pld_name.txt }
                     in
                     let rhs = [%expr [%e expr_to_iml f.pld_type field_expr]] in
                     let kv =
                       [%expr
                         Printf.sprintf
                           [%e mkstrlit (f.pld_name.txt ^ " = %s")]
                           [%e rhs]]
                     in
                     kv)
            in
            let rhs =
              [%expr
                Printf.sprintf "{%s}" @@ String.concat "; "
                @@ [%e mk_list ~loc @@ res_fields]]
            in
            pat, rhs
        in
        A.Exp.case pat rhs
      in
      let cases = List.map case_of_cstor cstors in
      A.Exp.match_ [%expr self] cases
    | Ptype_record labels ->
      let res_fields =
        labels
        |> List.map (fun (f : label_declaration) ->
               let field_expr =
                 A.Exp.field [%expr self]
                   { loc; txt = Longident.Lident f.pld_name.txt }
               in
               let rhs = [%expr [%e expr_to_iml f.pld_type field_expr]] in
               let kv =
                 [%expr
                   Printf.sprintf
                     [%e mkstrlit (f.pld_name.txt ^ " = %s")]
                     [%e rhs]]
               in
               kv)
      in
      [%expr
        Printf.sprintf "{%s}" @@ String.concat "; "
        @@ [%e mk_list ~loc @@ res_fields]]
  in

  let params = param_names d |> List.map name_poly_var_ in
  let name = to_iml_name_of_ty_name d.ptype_name.txt in
  A.Vb.mk
    (A.Pat.var { loc = d.ptype_loc; txt = name })
    (mk_lambda ~loc params @@ [%expr fun self : string -> [%e body]])

let bracket_warn type_declarations stri =
  let loc =
    match type_declarations with
    | [] -> Location.none
    | ty :: _ -> ty.ptype_loc
  in
  let disable = [%stri [@@@ocaml.warning "-27-33-39"]] in
  let enable = [%stri [@@@ocaml.warning "+27+33+39"]] in
  (disable :: stri) @ [ enable ]

let generate_impl_ (_rec_flag, type_declarations) : structure_item list =
  let add (tys : type_declaration list) : structure_item =
    let vbs = List.map to_iml_vb_of_tydecl tys in
    let loc = Location.none in
    A.Str.value ~loc Recursive vbs
  in

  bracket_warn type_declarations [ add type_declarations ]

let generate_impl ~ctxt:_ (rec_flag, type_declarations) =
  try generate_impl_ (rec_flag, type_declarations)
  with Error_gen (loc, msg) ->
    (* emit an error in generated code *)
    let str0 =
      [%stri let () = [%error [%e A.Exp.constant (A.Const.string msg)]]]
    in
    [ str0 ]

let impl_generator = Deriving.Generator.V2.make_noarg generate_impl
let myderiver = Deriving.add "to_iml" ~str_type_decl:impl_generator
