(* Function decompositions and decomposition results *)

open Builders
module C = Imandrax_api_common
module T = Imandrax_api_tasks

let meta : (string * Mir.Term.t C.Region.meta) list =
  [
    "null_6001", Null;
    "bool", Bool true;
    "int", Int (Z.of_int 6002);
    "real", Real (Q.of_ints 6003 6004);
    "string", String "s_6005";
    "assoc", Assoc [ "k_6006", Int (Z.of_int 2) ];
    "term", Term x_t;
    "list", List [ Null; Bool false ];
  ]

let region status : Mir.Region.t =
  { constraints = [ x_pos ]; invariant = int 1; meta; status }

let fun_decomp : Mir.Fun_decomp.t =
  {
    f_id = uid "f";
    f_args = [ x ];
    regions =
      [
        region Unknown;
        region (Feasible Cases_model.full);
        region (Feasibility_check_failed "timeout_6007");
      ];
  }

let res r : T.Decomp_res.Shallow.t =
  {
    from = ca_ptr "decomp";
    res = r;
    stats;
    report = Cases_report.archive Cases_report.spans;
  }

let cases =
  [
    case "regions" A.Fun_decomp fun_decomp;
    case "success" A.Decomp_res (res (Ok { anchor; decomp = fun_decomp }));
    case "error" A.Decomp_res (res (Error (Error (error "decomp failed"))));
  ]
