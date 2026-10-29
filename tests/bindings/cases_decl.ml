(* Declarations: functions, types, theorems, rule specs, verify *)

open Imandrax_api
open Builders
module C = Imandrax_api_common

let hints ?(validate = C.Hints.VS_no_validate) ?unroll_def ?(enable = [])
    ?(disable = []) ?timeout ?admission ?decomp () : Mir.Hints.t =
  {
    f_validate_strat = validate;
    f_unroll_def = unroll_def;
    f_enable = enable;
    f_disable = disable;
    f_timeout = timeout;
    f_admission = admission;
    f_decomp = decomp;
  }

let fun_def
    ?(kind = C.Fun_def.Fun_defined { is_macro = false; from_lambda = false })
    ?clique ?(hints = hints ()) ?(args = [ x ])
    ?(body = apply succ [ x_t ] int_ty) ?(ty = arrow int_ty int_ty) name :
    Mir.Fun_def.t =
  {
    f_name = cname_uid name;
    f_ty = { params = []; ty };
    f_args = args;
    f_body = body;
    f_clique = clique;
    f_kind = kind;
    f_hints = hints;
  }

let ty_def ?(params = []) ?clique ?(timeout = Some 2001) name decl :
    Mir.Type.t Ty_view.def_poly =
  { name = cname_uid name; params; decl; clique; timeout }

(* A theorem's link is its statement, as a boolean function of the theorem's variables *)
let statement name = fun_def ~body:x_pos ~ty:(arrow int_ty bool_ty) name

let theorem ?(rewriting = false) ?(fc = false) ?(triggers = [])
    ?(named_hypotheses = []) name : Mir.Decl.t =
  Theorem
    {
      thm_link = statement name;
      thm_rewriting = rewriting;
      thm_perm_restrict = false;
      thm_fc = fc;
      thm_elim = false;
      thm_gen = false;
      thm_triggers = triggers;
      thm_is_axiom = false;
      thm_by = [ x ], x_pos;
      thm_named_hypotheses = named_hypotheses;
    }

let verify kind ?upto ?(minimize = []) ?by name : Mir.Decl.t =
  Verify
    {
      verify_link = statement name;
      verify_simplify = true;
      verify_nonlin = false;
      verify_upto = upto;
      verify_kind = kind;
      verify_minimize = minimize;
      verify_by = by;
    }

let decls : (string * Mir.Decl.t) list =
  [
    "fun_defined", Fun (fun_def "f");
    ( "fun_recursive",
      Fun
        (fun_def
           ~clique:(Uid.Set.of_list [ cname_uid "g" ])
           ~hints:
             (hints
                ~validate:(C.Hints.VS_validate { tactic = Some ([ x ], x_pos) })
                ~unroll_def:2002
                ~enable:[ uid "e" ]
                ~disable:[ uid "d" ]
                ~timeout:2003
                ~admission:
                  {
                    measured_subset = [ "x_2004" ];
                    measure_fun = Some (uid "measure");
                  }
                ~decomp:(int 0) ())
           "g") );
    ( "fun_validate_default",
      Fun
        (fun_def
           ~hints:(hints ~validate:(VS_validate { tactic = None }) ())
           "vd") );
    ( "fun_macro",
      Fun
        (fun_def
           ~kind:(Fun_defined { is_macro = true; from_lambda = true })
           "macro") );
    ( "fun_builtin",
      Fun
        (fun_def
           ~kind:
             (Fun_builtin
                {
                  id = builtin_uid "+";
                  kind = builtin_kind "+";
                  lassoc = true;
                  commutative = true;
                  connective = false;
                })
           "plus") );
    "fun_opaque", Fun (fun_def ~kind:Fun_opaque "opaque");
    ( "ty_algebraic",
      Ty
        (ty_def ~params:[ alpha ] "option"
           (Algebraic
              [
                { c = cname_uid "None"; labels = None; args = []; doc = None };
                {
                  c = cname_uid "Some";
                  labels = None;
                  args = [ alpha_ty ];
                  doc = Some "doc_2005";
                };
                {
                  c = cname_uid "Pair";
                  labels = Some [ uid "fst"; uid "snd" ];
                  args = [ int_ty; int_ty ];
                  doc = None;
                };
              ])) );
    ( "ty_record",
      Ty
        (ty_def
           ~clique:(Uid.Set.of_list [ cname_uid "point" ])
           "point"
           (Record
              [
                { f = cname_uid "x"; ty = int_ty; doc = None };
                { f = cname_uid "y"; ty = int_ty; doc = Some "doc_2006" };
              ])) );
    "ty_skolem", Ty (ty_def "skolem" Skolem);
    ( "ty_builtin",
      Ty
        (ty_def "int"
           (Builtin { id = builtin_uid "int"; kind = builtin_kind "int" })) );
    "ty_other", Ty (ty_def ~timeout:None "other" Other);
    ( "theorem",
      theorem ~rewriting:true ~fc:true
        ~triggers:
          [
            x_t, As_trigger.Trig_none;
            x_t, Trig_anon;
            x_t, Trig_named 2007;
            x_t, Trig_rw;
          ]
        ~named_hypotheses:[ "h_2008", x_pos ]
        "thm" );
    ( "rule_spec",
      Rule_spec
        {
          rule_spec_fc = true;
          rule_spec_rewriting = false;
          rule_spec_perm_restrict = true;
          rule_spec_link = statement "rule";
          rule_spec_triggers = [ x_t, Trig_anon ];
        } );
    ( "verify",
      verify C.Verify.K_verify ~upto:(N_steps 5) ~minimize:[ x_t ]
        ~by:([ x ], x_pos) "v" );
    "verify_instance", verify C.Verify.K_instance "i";
    "verify_test", verify C.Verify.K_test "t";
  ]

let cases = List.map (fun (name, d) -> case name A.Decl d) decls
