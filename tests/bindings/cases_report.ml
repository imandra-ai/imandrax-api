(* Reports: every atomic event, as instant events and in spans *)

open Imandrax_api
open Builders
module C = Imandrax_api_common
module R = Imandrax_api_report

let pattern view ty : Mir.Fo_pattern.t = { view; ty }
let x_pat = pattern (FO_var x) int_ty
let circle = sym "Circle" (arrow int_ty (constr "shape" []))

(* One pattern of each kind *)
let patterns : Mir.Fo_pattern.t list =
  [
    pattern FO_any int_ty;
    pattern (FO_bool true) bool_ty;
    pattern (FO_const (Const.Const_z (Z.of_int 1))) int_ty;
    x_pat;
    pattern (FO_app (succ, [ x_pat ])) int_ty;
    pattern
      (FO_cstor { c = Some circle; args = [ x_pat ]; labels = Some [ uid "r" ] })
      (constr "shape" []);
    pattern
      (FO_cstor { c = None; args = [ x_pat; x_pat ]; labels = None })
      (ty (Ty_view.Tuple [ int_ty; int_ty ]));
    pattern
      (FO_destruct
         { c = Some circle; i = 3001; u = pattern FO_any (constr "shape" []) })
      int_ty;
    pattern
      (FO_destruct { c = None; i = 1; u = pattern FO_any (constr "pair" []) })
      int_ty;
    pattern
      (FO_is_a { c = circle; u = pattern FO_any (constr "shape" []) })
      bool_ty;
  ]

let rewrite_rule ?(loop_break = None) head : Mir.Rewrite_rule.t =
  {
    rw_name = cname_uid "rw";
    rw_head = head;
    rw_lhs = pattern (FO_app (succ, [ x_pat ])) int_ty;
    rw_rhs = int 1;
    rw_guard = [ x_pos ];
    rw_vars = [ x ];
    rw_triggers = patterns;
    rw_perm_restrict = false;
    rw_loop_break = loop_break;
  }

let instantiation_rule kind : Mir.Instantiation_rule.t =
  {
    ir_from = Cases_decl.statement "fc";
    ir_triggers =
      [
        {
          trigger_head = PH_datatype_op;
          trigger_patterns = [ x_pat ];
          trigger_instantiation_rule_name = uid "fc";
        };
      ];
    ir_kind = kind;
  }

let model = Cases_model.full

let logic =
  Logic_fragment.(
    B.empty |> B.set f_dt true |> B.set f_lia true |> B.set f_nra true)

let smt_proof : _ R.Smt_proof.t =
  {
    logic;
    unsat_core = [ x_pos ];
    expansions =
      [ { f_name = uid "succ"; lhs = apply succ [ x_t ] int_ty; rhs = int 1 } ];
    instantiations = [ { assertion = x_pos; from_rule = uid "fc" } ];
  }

let goal =
  sequent
    ~hyps:[ Some "h_3002", x_pos; None, bool true ]
    [ Some "c_3003", x_pos ]

let rtext : _ R.Rtext.t =
  [
    S "plain_3004";
    B "bold_3005";
    I "italic_3006";
    Newline;
    Sub [ S "nested" ];
    L [ [ S "a" ]; [ S "b" ] ];
    Uid (uid "u");
    Term x_t;
    Sequent goal;
    Subst [ x_t, int 1 ];
  ]

let atomic_events : R.Atomic_event.Mir.t list =
  [
    E_message rtext;
    E_title "title_3007";
    E_enter_waterfall { vars = [ x ]; goal = x_pos };
    E_enter_tactic "auto_3008";
    E_rw_success (rewrite_rule (PH_id (uid "succ")), x_t, int 1);
    E_rw_fail
      ( rewrite_rule ~loop_break:(Some x_pat) (PH_ty int_ty),
        x_t,
        "no_match_3009" );
    E_inst_success (instantiation_rule IR_forward_chaining, x_pos);
    E_inst_success (instantiation_rule IR_generalization, x_pos);
    E_waterfall_checkpoint [ goal ];
    E_induction_scheme x_pos;
    E_attack_subgoal { name = "sub_3010"; goal; depth = 3011 };
    E_simplify_t (x_t, int 1);
    E_simplify_clause (x_pos, [ x_pos; bool true ]);
    E_proved_by_smt (x_pos, smt_proof);
    E_refuted_by_smt (x_pos, Some model);
    E_refuted_by_smt (x_pos, None);
    E_fun_expansion (apply succ [ x_t ] int_ty, int 1);
  ]

let report (events : R.Report.event list) : R.Report.t =
  { events = Array.of_list events }

let instants =
  report
    (List.mapi
       (fun i ev -> R.Event.EL_atomic { ts = 3100. +. float i; ev })
       atomic_events)

let spans =
  report
    [
      EL_enter_span { ts = 3200.; ev = E_enter_tactic "outer" };
      EL_atomic { ts = 3201.; ev = E_title "inside" };
      EL_enter_span { ts = 3202.; ev = E_enter_tactic "inner" };
      EL_exit_span { ts = 3203. };
      EL_exit_span { ts = 3204. };
    ]

(* As embedded in task results *)
let archive (r : R.Report.t) : _ In_mem_archive.t =
  {
    ty = "report_ser.mir";
    compressed = false;
    data = Imandrakit_twine.Encode.encode_to_string R.Report.to_twine r;
  }

let cases = [ case "instants" A.Report instants; case "spans" A.Report spans ]
