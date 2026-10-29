(* Proof obligation results: every success and error *)

open Builders
module T = Imandrax_api_tasks
module P = Imandrax_api_proof

let goal = Cases_report.goal

(* A proof using every kind of step and argument *)
let proof : P.Mir_proof_term.t =
  let step id view : P.Mir_proof_term.t = { id; concl = goal; view } in
  let assume = step 4001 T_assume in
  let rule =
    step 2
      (T_rule
         {
           rule = "axiom_4002";
           args =
             [
               A_term x_t;
               A_ty int_ty;
               A_int 4003;
               A_string "s_4004";
               A_list [ A_int 1 ];
               A_dict [ "k_4005", A_int 2 ];
               A_seq goal;
             ];
         })
  in
  let subst =
    step 3
      (T_subst
         {
           t_subst = [ (x.id, int_ty), int 1 ];
           ty_subst = [ alpha, int_ty ];
           premise = assume;
         })
  in
  step 4 (T_deduction { premises = [ "cc_4006", [ subst; rule ] ] })

let res ?(sub_res = []) ?(stats = stats) res : T.PO_res.Shallow.t =
  {
    from = ca_ptr "po_4007";
    res;
    stats;
    report = Cases_report.archive Cases_report.spans;
    sub_res;
  }

let sub_res res : _ T.PO_res.sub_res =
  { sub_anchor = { fname = "f"; anchor = 0 }; goal; sub_goals = [ goal ]; res }

let model = Cases_model.full

let results =
  [
    ( "proof",
      res
        ~sub_res:[ [ sub_res (Ok ()); sub_res (Error "failed_4008") ] ]
        (Ok
           (Proof
              { anchor; proof; sub_anchor = Some { fname = "f"; anchor = 1 } }))
    );
    ( "proof_no_sub_anchor",
      res
        ~stats:{ time_s = 0.5; tactic = None }
        (Ok (Proof { anchor; proof; sub_anchor = None })) );
    "instance", res (Ok (Instance { anchor; model }));
    "verified_upto", res (Ok (Verified_upto { anchor; upto = N_steps 10 }));
    "test_ok", res (Ok Test_ok);
    ( "no_proof",
      res
        (Error
           (No_proof
              {
                err =
                  error ~stack:[ "context" ] ~bt:"backtrace_4009"
                    "no_proof_4010";
                counter_model = Some model;
                subgoals = [ goal ];
                sub_anchor = Some { fname = "f"; anchor = 2 };
              })) );
    ( "no_proof_no_model",
      res
        (Error
           (No_proof
              {
                err = error "no proof";
                counter_model = None;
                subgoals = [];
                sub_anchor = None;
              })) );
    ( "unsat",
      res
        (Error (Unsat { anchor; err = error "unsat"; proof; sub_anchor = None }))
    );
    ( "unsat_sub_anchor",
      res
        (Error
           (Unsat
              {
                anchor;
                err = error "unsat";
                proof;
                sub_anchor = Some { fname = "f"; anchor = 3 };
              })) );
    "invalid_model", res (Error (Invalid_model (error "invalid", model)));
    "error", res (Error (Error (error "error")));
  ]

let cases = List.map (fun (name, r) -> case name A.PO_res r) results
