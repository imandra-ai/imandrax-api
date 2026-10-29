(* Tasks: proof obligations, evaluations and decompositions, with a database
   holding every kind of operation *)

open Imandrax_api
open Builders
module C = Imandrax_api_common
module T = Imandrax_api_tasks

(* Database
   ======== *)

let x_pat = Cases_report.x_pat
let rw = Cases_report.rewrite_rule (PH_id (uid "succ"))
let ir = Cases_report.instantiation_rule IR_forward_chaining

let trigger : Mir.Trigger.t =
  {
    trigger_head = PH_id (uid "f");
    trigger_patterns = [ x_pat ];
    trigger_instantiation_rule_name = uid "fc";
  }

let elim : Mir.Elimination_rule.t =
  {
    er_name = uid "elim";
    er_guard = [ x_pos ];
    er_lhs = x_pos;
    er_rhs = x;
    er_dests = [ x_pat ];
    er_dest_tms = [ x_t ];
  }

let thm = cname_uid "thm"
let rule = cname_uid "rule"

let ops : (Mir.Term.t, Mir.Type.t) C.Db_op.t_poly list =
  [
    Op_add_decls (List.map snd Cases_decl.decls);
    Op_disable [ uid "f" ];
    Op_enable [ uid "f" ];
    Op_add_rw (PH_id (uid "succ"), rw);
    Op_add_fc_trigger (PH_id (uid "f"), trigger);
    Op_add_elim (PH_datatype_op, elim);
    Op_add_gen_trigger (PH_ty int_ty, trigger);
    Op_add_count_fun (uid "count", Cases_decl.fun_def "count");
    Op_set_admission (uid "g", { measured_subset = [ "x" ]; measure_fun = None });
    Op_set_thm_as_rw (thm, [ rw ]);
    Op_set_thm_as_fc (thm, [ ir ]);
    Op_set_thm_as_elim (thm, [ elim ]);
    Op_set_thm_as_gen (thm, ir);
    Op_add_instantiation_rule ir;
    Op_add_rule_spec_fc_triggers (rule, [ trigger ]);
    Op_add_rule_spec_rw (rule, [ rw ]);
  ]

(* The database, and the storage its operations are in *)
let db, storage =
  let ptrs, storage =
    List.map
      (store ~ty:"db_op"
         (C.Db_op.t_poly_to_twine Mir.Term.to_twine Mir.Type.to_twine))
      ops
    |> List.split
  in
  ({ ops = ptrs } : Mir.Db_ser.t), storage

let empty_db : Mir.Db_ser.t = { ops = [] }

(* Proof obligation tasks
   ====================== *)

let po ?(db = empty_db)
    ?(tactic = C.Tactic.Default_thm { max_steps = 7001; upto = None }) ?timeout
    ?upto ?verify_kind ?(named_hypotheses = []) anchor : T.PO_task.Mir.t =
  {
    from_sym = "f_7002";
    count = 7003;
    db;
    po =
      {
        descr = "descr_7004";
        goal = [ x ], x_pos;
        tactic;
        is_instance = false;
        anchor;
        timeout;
        upto;
        verify_kind;
        named_hypotheses;
      };
  }

let po_tasks =
  [
    ( "full",
      po ~db
        ~tactic:(Default_thm { max_steps = 7005; upto = Some (N_steps 7006) })
        ~timeout:7007 ~upto:(N_steps 7008) ~verify_kind:K_verify
        ~named_hypotheses:[ "h_7009", x_pos ]
        (Named (cname "thm")) );
    "minimal", po (Eval 7010);
    ( "tactic_termination",
      po
        ~tactic:
          (Default_termination
             { max_steps = 7011; basis = Uid.Set.of_list [ uid "b" ] })
        (Proof_check (Eval 0)) );
    ( "tactic_test",
      po
        ~tactic:(Default_test { num_steps = Some 7012; seed = Some 7013 })
        (Decomp (Eval 0)) );
    ( "tactic_test_defaults",
      po ~tactic:(Default_test { num_steps = None; seed = None }) anchor );
    "tactic_term", po ~tactic:(Term ([ x ], x_pos)) anchor;
  ]

(* Evaluation tasks
   ================ *)

let eval ?timeout () : T.Eval_task.Mir.t =
  { db = empty_db; term = [ x ], apply succ [ x_t ] int_ty; anchor; timeout }

(* Decomposition tasks
   =================== *)

let decomp ?assuming lift_bool : C.Decomp.t_ =
  {
    f_id = uid "f";
    assuming;
    basis = Uid.Set.of_list [ uid "b" ];
    rule_specs = Uid.Set.of_list [ rule ];
    ctx_simp = true;
    lift_bool;
    prune = false;
  }

(* Every kind of decomposition request *)
let request : T.Decomp_task.Mir.decomp =
  Let
    {
      bindings = [ "d_7101", Decomp (decomp ~assuming:(uid "pre") Default) ];
      and_then =
        Enumerate
          {
            d_f =
              Merge
                ( Get "d_7101",
                  Compound_merge (Term x_t, Return Cases_decomp.fun_decomp) );
            ds =
              [
                Enumerate
                  {
                    d_f = Prune (Decomp (decomp Nested_equalities));
                    ds = [];
                    style = None;
                  };
                Enumerate
                  {
                    d_f = Combine (Decomp (decomp Equalities));
                    ds = [ Decomp (decomp All) ];
                    style = Some Additive;
                  };
              ];
            style = Some Multiplicative;
          };
    }

let decomp_task ?timeout () : T.Decomp_task.Mir.t =
  { db = empty_db; decomp = request; anchor; timeout }

let cases =
  List.map
    (fun (name, t) ->
      let storage =
        if t.T.PO_task.db == db then
          storage
        else
          []
      in
      case ~storage name A.PO_task t)
    po_tasks
  @ [
      case "eval" A.Eval_task (eval ~timeout:7201 ());
      case "eval_no_timeout" A.Eval_task (eval ());
      case "decomp" A.Decomp_task (decomp_task ~timeout:7301 ());
      case "decomp_no_timeout" A.Decomp_task (decomp_task ());
    ]
