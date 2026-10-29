(* Evaluation results: every kind of value *)

open Builders
module T = Imandrax_api_tasks
module V = Imandrax_api_eval.Value

let v view : V.t = { v = view }
let int n = v (V_int (Z.of_int n))
let ord_int n = Imandrax_api_eval.Ordinal.Int (Z.of_int n)

let values : (string * V.t) list =
  [
    "true", v V_true;
    "false", v V_false;
    "int", int 5001;
    "real", v (V_real (Q.of_ints 5002 5003));
    "string", v (V_string "hi_5004");
    "cstor", v (V_cstor ({ cd_idx = 5005; cd_name = uid "Some" }, [| int 1 |]));
    "tuple", v (V_tuple [| int 1; v V_true |]);
    ( "record",
      v
        (V_record
           ( { rd_name = uid "point"; rd_fields = [| uid "x"; uid "y" |] },
             [| int 1; int 2 |] )) );
    "quoted_term", v (V_quoted_term ([ x ], x_pos));
    "uid", v (V_uid (uid "u"));
    "closure", v (V_closure { missing = 5006 });
    "ordinal", v (V_ordinal (Cons (ord_int 5007, Z.of_int 5008, ord_int 5009)));
  ]

let res r : T.Eval_res.t =
  { res = r; stats = { compile_time = 5010.5; exec_time = 5011.25 } }

let cases =
  List.map (fun (name, x) -> case name A.Eval_res (res (Ok { v = x }))) values
  @ [ case "error" A.Eval_res (res (Error (error "eval failed"))) ]
