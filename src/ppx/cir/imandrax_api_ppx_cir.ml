(* we follow
   https://ppxlib.readthedocs.io/en/latest/ppx-for-plugin-authors.html .
   Ported from https://github.com/imandra-ai/cbor-pack/ *)

open Ppxlib
module A = Ast_helper

let spf = Printf.sprintf

(* utils *)
open struct
  (* name for variables *)
  let name_poly_var_ v = spf "_cir_%s" v
  let mkstrlit s = A.Exp.constant (A.Const.string s)

  let rec lid_to_str (lid : Longident.t) : string =
    match lid with
    | Longident.Lident s -> s
    | Longident.Ldot (x, s) -> spf "%s.%s" (lid_to_str x) s
    | Longident.Lapply (a, b) -> spf "%s.%s" (lid_to_str a) (lid_to_str b)

  let mk_lambda ~loc args body =
    List.fold_right
      (fun arg bod -> [%expr fun [%p A.Pat.var { loc; txt = arg }] -> [%e bod]])
      args body

  (** list literal *)
  let rec mk_list ~loc = function
    | [] -> [%expr []]
    | x :: tl -> [%expr [%e x] :: [%e mk_list ~loc tl]]

  let rec mk_plist ~loc = function
    | [] -> [%pat? []]
    | x :: tl -> [%pat? [%p x] :: [%p mk_plist ~loc tl]]

  let rec map_lid ~f (lid : Longident.t) : Longident.t =
    match lid with
    | Longident.Lident name -> Longident.Lident (f name)
    | Longident.Lapply (a, b) -> Longident.Lapply (a, map_lid ~f b)
    | Longident.Ldot (m, a) -> Longident.Ldot (m, f a)
end

let of_cir_name_of_ty_name (ty_name : string) : string =
  if ty_name = "t" then
    "of_cir"
  else
    ty_name ^ "_of_cir"

let of_cir_name_of_lid = map_lid ~f:of_cir_name_of_ty_name

let rec expr_of_cir (ty : core_type) (e : expression) : expression =
  let loc = ty.ptyp_loc in
  match ty with
  | [%type: int] | [%type: Z.t] | [%type: Int.t] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Const (Const_z x) -> x
      | _ -> failwith "of-cir: expected int"]
  | [%type: bool] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Const (Const_bool b) -> b
      | _ -> failwith "of-cir: expected bool"]
  | [%type: unit] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Construct { c; args = []; _ } when c.sym.id.name = "()" -> ()
      | _ -> failwith "of-cir: expected unit"]
  | [%type: string] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Const (Const_string s) -> s
      | _ -> failwith "of-cir: expected string"]
  | [%type: Imandrax_api.Uid.t] | [%type: Uid.t] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Const (Const_uid id) -> id
      | _ -> failwith "of-cir: expected id"]
  | [%type: [%t? ty_arg0] option] ->
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Construct { c; args = []; _ } when c.sym.id.name = "None" -> None
      | Construct { c; args = [ x ]; _ } when c.sym.id.name = "Some" ->
        Some [%e expr_of_cir ty_arg0 [%expr x]]
      | _ -> failwith "of-cir: expected option"]
  | [%type: [%t? ty_arg0] list] ->
    [%expr
      let rec get_list t =
        match Imandrax_api_cir.Term.view t with
        | Construct { c; args = []; _ } when c.sym.id.name = "[]" -> []
        | Construct { c; args = [ x; tl ]; _ } when c.sym.id.name = "::" ->
          [%e expr_of_cir ty_arg0 [%expr x]] :: get_list tl
        | _ -> failwith "of-cir: expected option"
      in
      get_list [%e e]]
  | [%type: int32]
  | [%type: int64]
  | [%type: nativeint]
  | [%type: string]
  | [%type: bytes]
  | [%type: char]
  | [%type: float]
  | [%type: _ array] ->
    [%expr [%error "This type is not supported by imandrax-api-ppx.cir"]]
  | { ptyp_desc = Ptyp_var v; ptyp_loc = loc; _ } ->
    (* use function passed as a parameter for each polymorphic argument *)
    let s : string = name_poly_var_ v in
    [%expr [%e A.Exp.ident { loc; txt = Longident.Lident s }] [%e e]]
  | { ptyp_desc = Ptyp_constr (lid, args); ptyp_loc = loc; _ } ->
    [%expr
      [%e
        let args =
          List.map
            (fun a ->
              Nolabel, [%expr fun self -> [%e expr_of_cir a [%expr self]]])
            args
        in
        A.Exp.apply (A.Exp.ident { loc; txt = of_cir_name_of_lid lid.txt }) args]
        [%e e]]
  | { ptyp_desc = Ptyp_tuple args; ptyp_loc = loc; _ } ->
    let pat_args =
      List.mapi (fun i _a -> A.Pat.var { loc; txt = spf "x_%d" i }) args
    in
    let result_args =
      List.mapi
        (fun i (a : core_type) ->
          expr_of_cir a
            (A.Exp.ident { loc; txt = Longident.Lident (spf "x_%d" i) }))
        args
    in
    [%expr
      match Imandrax_api_cir.Term.view [%e e] with
      | Tuple { l = [%p mk_plist ~loc pat_args]; _ } ->
        [%e A.Exp.tuple result_args]
      | _ -> failwith "of-cir: expected tuple"]
  | { ptyp_desc = Ptyp_alias (ty, _); _ } -> expr_of_cir ty e
  | { ptyp_desc = Ptyp_variant _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register polymorphic variants yet"]]
  | { ptyp_desc = Ptyp_arrow _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register functions"]]
  | { ptyp_desc = Ptyp_class _ | Ptyp_object _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register objects yet"]]
  | { ptyp_desc = Ptyp_package _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register first-class modules"]]
  | { ptyp_desc = Ptyp_extension _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register type extensions"]]
  | { ptyp_desc = Ptyp_any; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register values of type `_`"]]
  | { ptyp_desc = Ptyp_poly _; ptyp_loc = loc; _ } ->
    [%expr [%error "Cannot register values of this type"]]

exception Error_gen of Location.t * string

let error_gen ~loc e = raise (Error_gen (loc, e))

let param_names ty =
  ty.ptype_params
  |> List.map (fun (ty, _) ->
         let loc = ty.ptyp_loc in
         match ty.ptyp_desc with
         | Ptyp_var a -> a
         | Ptyp_any -> error_gen ~loc "Cannot derive of_cir for implicit param"
         | _ -> error_gen ~loc "Cannot derive of_cir for non-variable type")

let of_cir_vb_of_tydecl (d : type_declaration) : value_binding =
  let loc = d.ptype_loc in

  let body : expression =
    match d.ptype_kind with
    | Ptype_abstract ->
      (match d.ptype_manifest with
      | Some ty_alias ->
        (* alias, just forward to it *)
        expr_of_cir ty_alias [%expr self]
      | None -> [%expr [%error "cannot derive of_cir for abstract type"]])
    | Ptype_open -> [%expr [%error "cannot derive of_cir for open type"]]
    | Ptype_variant cstors ->
      let case_of_cstor (c : constructor_declaration) : case =
        let loc = c.pcd_loc in
        let c_lid = { loc; txt = Longident.Lident c.pcd_name.txt } in
        let guard = [%expr c.sym.id.name = [%e mkstrlit c.pcd_name.txt]] in
        let pat, rhs =
          match c.pcd_args with
          | Pcstr_tuple [] ->
            ( [%pat? Imandrax_api_cir.Term.Construct { c; args = []; _ }],
              A.Exp.construct c_lid None )
          | Pcstr_tuple [ ty0 ] ->
            ( [%pat? Imandrax_api_cir.Term.Construct { c; args = [ x ]; _ }],
              A.Exp.construct c_lid @@ Some (expr_of_cir ty0 [%expr x]) )
          | Pcstr_tuple l ->
            let pat =
              [%pat?
                Imandrax_api_cir.Term.Construct
                  {
                    c;
                    args =
                      [%p
                        mk_plist ~loc
                        @@ List.mapi
                             (fun i _ -> A.Pat.var { loc; txt = spf "x_%d" i })
                             l];
                    _;
                  }]
            in
            let rhs =
              A.Exp.construct c_lid
              @@ Some
                   (A.Exp.tuple
                   @@ List.mapi
                        (fun i a ->
                          expr_of_cir a
                            (A.Exp.ident
                               { loc; txt = Longident.Lident (spf "x_%d" i) }))
                        l)
            in
            pat, rhs
          | Pcstr_record r ->
            let pat_fields : pattern =
              List.mapi (fun i _r -> A.Pat.var { loc; txt = spf "x_%d" i }) r
              |> mk_plist ~loc
            in
            let pat =
              [%pat?
                Imandrax_api_cir.Term.Construct { c; args = [%p pat_fields]; _ }]
            in
            let rhs_fields =
              List.mapi
                (fun i (r : label_declaration) ->
                  let e =
                    (* [foo_of_cir self.foo] *)
                    expr_of_cir r.pld_type
                      (A.Exp.ident
                         { loc; txt = Longident.Lident (spf "x_%d" i) })
                  in
                  let field =
                    {
                      loc = r.pld_name.loc;
                      txt = Longident.Lident r.pld_name.txt;
                    }
                  in
                  field, e)
                r
            in
            let rhs =
              A.Exp.construct ~loc c_lid
              @@ Some (A.Exp.record ~loc rhs_fields None)
            in
            pat, rhs
        in
        A.Exp.case ~guard pat rhs
      in

      let last_case =
        A.Exp.case
          [%pat? _]
          [%expr
            failwith
              [%e
                mkstrlit @@ spf "of-cir: expected sum type %S" d.ptype_name.txt]]
      in

      A.Exp.match_
        [%expr Imandrax_api_cir.Term.view self]
        (List.map case_of_cstor cstors @ [ last_case ])
    | Ptype_record labels ->
      let fields =
        labels
        |> List.map (fun (f : label_declaration) ->
               let lid =
                 { loc = f.pld_name.loc; txt = Longident.Lident f.pld_name.txt }
               in
               let e =
                 [%expr
                   match
                     List.find_map
                       (fun ((sym, v) : Imandrax_api_cir.Applied_symbol.t * _) ->
                         if sym.sym.id.name = [%e mkstrlit f.pld_name.txt] then
                           Some v
                         else
                           None)
                       rows
                   with
                   | None ->
                     failwith
                       [%e
                         mkstrlit
                           (spf "of-cir: record: missing field: %S"
                              f.pld_name.txt)]
                   | Some v -> [%e expr_of_cir f.pld_type [%expr v]]]
               in
               lid, e)
      in
      [%expr
        match Imandrax_api_cir.Term.view self with
        | Record { rows; rest = None } -> [%e A.Exp.record fields None]
        | Record { rows; rest = Some _rest } ->
          (* TODO: recurse in [rest] *)
          failwith "TODO: of-cir: support record extension"
        | _ -> failwith "expected record"]
  in

  let params = param_names d |> List.map name_poly_var_ in

  let name = of_cir_name_of_ty_name d.ptype_name.txt in
  A.Vb.mk
    (A.Pat.var { loc = d.ptype_loc; txt = name })
    (mk_lambda ~loc params
    @@ [%expr fun (self : Imandrax_api_cir.Term.t) -> [%e body]])

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
    let vbs = List.map of_cir_vb_of_tydecl tys in
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
let myderiver = Deriving.add "of_cir" ~str_type_decl:impl_generator
