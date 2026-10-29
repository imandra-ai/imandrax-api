(* Types and terms *)

open Imandrax_api
open Builders

let types =
  [
    "var", ty (Ty_view.Var alpha);
    "arrow", ty (Ty_view.Arrow ((), int_ty, bool_ty));
    "tuple", ty (Ty_view.Tuple [ int_ty; bool_ty ]);
    "constr", constr "list" [ int_ty ];
  ]

let const_uid u = term (Mir.Term.Const (Const.Const_uid u)) (constr "uid" [])

let builtin name (kind : Builtin_data.kind) =
  Uid.Private_.make name (Uid.Builtin { kind })

let terms =
  let open Mir.Term in
  let point = constr "point" [] in
  let shape = constr "shape" [] in
  let circle = sym "Circle" (ty (Ty_view.Arrow ((), int_ty, shape))) in
  let field_x = sym "x" (ty (Ty_view.Arrow ((), point, int_ty))) in
  let p = term (Var (var "p" 3 point)) point in
  [
    "const_int", int 1001;
    "const_bool", bool true;
    ( "const_string",
      term (Const (Const.Const_string "hi_1002")) (constr "string" []) );
    ( "const_rational",
      term (Const (Const.Const_q (Q.of_ints 1003 1004))) (constr "real" []) );
    "const_float", term (Const (Const.Const_float 1005.5)) (constr "float" []);
    ( "const_real_approx",
      term (Const (Const.Const_real_approx "1006.41?")) (constr "real" []) );
    "const_uid", const_uid (uid "u_1007");
    "const_uid_cname", const_uid (cname_uid "c_1008");
    "const_uid_local", const_uid (local_uid "l" 1009);
    ( "const_uid_to_be_rewritten",
      const_uid
        (Uid.Private_.make "r"
           (Uid.Generative { id = 1; gen_kind = Uid.To_be_rewritten })) );
    ( "const_uid_logic_core",
      const_uid (builtin "lc" (Logic_core { logic_core_name = "core_1010" })) );
    "const_uid_special", const_uid (builtin "s" (Special { tag = "tag_1011" }));
    ( "const_uid_tactic",
      const_uid (builtin "t" (Tactic { tac_name = "tac_1012" })) );
    ( "const_uid_decomp",
      const_uid (builtin "d" (Decomp { decomp_name = "decomp_1013" })) );
    ( "sub_anchor",
      Mir.Term.make
        ~sub_anchor:{ fname = "f_1014"; anchor = 1015 }
        Mir.Term.State.non_hashconsing
        (Const (Const.Const_z (Z.of_int 1)))
        int_ty );
    "if", term (If (bool true, int 1, int 2)) int_ty;
    "var", term (Var x) int_ty;
    ( "apply",
      let succ = sym "succ" (ty (Ty_view.Arrow ((), int_ty, int_ty))) in
      term (Apply { f = term (Sym succ) succ.ty; l = [ int 1 ] }) int_ty );
    ( "sym_polymorphic",
      let a = ty (Ty_view.Var alpha) in
      let id_ =
        sym ~params:[ alpha ] ~args:[ int_ty ]
          ~inst:(ty (Ty_view.Arrow ((), int_ty, int_ty)))
          "id"
          (ty (Ty_view.Arrow ((), a, a)))
      in
      term (Sym id_) id_.ty );
    ( "construct",
      term (Construct { c = circle; args = [ int 2 ]; labels = None }) shape );
    ( "construct_labels",
      term
        (Construct
           {
             c = sym "Rect" shape;
             args = [ int 1; int 2 ];
             labels = Some [ uid "w"; uid "h" ];
           })
        shape );
    ( "destruct",
      term
        (Destruct
           { c = circle; i = 1016; t = term (Var (var "s" 4 shape)) shape })
        int_ty );
    ( "is_a",
      term (Is_a { c = circle; t = term (Var (var "s" 4 shape)) shape }) bool_ty
    );
    ( "tuple",
      term
        (Tuple { l = [ int 1; bool false ] })
        (ty (Ty_view.Tuple [ int_ty; bool_ty ])) );
    "field", term (Field { f = field_x; t = p }) int_ty;
    ( "tuple_field",
      term
        (Tuple_field
           {
             i = 1017;
             t =
               term
                 (Tuple { l = [ int 1; int 2 ] })
                 (ty (Ty_view.Tuple [ int_ty; int_ty ]));
           })
        int_ty );
    "record", term (Record { rows = [ field_x, int 1 ]; rest = None }) point;
    ( "record_rest",
      term (Record { rows = [ field_x, int 1 ]; rest = Some p }) point );
    ( "case",
      term
        (Case
           {
             u = term (Var (var "s" 4 shape)) shape;
             cases = [ circle, int 1 ];
             default = Some (int 0);
           })
        int_ty );
    ( "case_no_default",
      term
        (Case
           {
             u = term (Var (var "s" 4 shape)) shape;
             cases = [ circle, int 1 ];
             default = None;
           })
        int_ty );
    "sequence", term (Sequence ([ int 1; int 2 ], int 3)) int_ty;
  ]

let cases =
  List.map (fun (name, x) -> case name A.Type x) types
  @ List.map (fun (name, x) -> case name A.Term x) terms
