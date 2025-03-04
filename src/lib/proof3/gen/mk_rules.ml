module Parse_spec = Parse_spec

let spf = Printf.sprintf
let pf = Printf.printf

let caml_name_of_name s =
  CCString.map
    (function
      | '-' -> '_'
      | c -> c)
    s

let prelude =
  {|
(** Proof rules.

    Proof rules in use in ImandraX. *)

(* auto-generated in [gen/mk_rules.ml], do not modify *)

|}

let mk_special = [ "weaken", "if x0 = [] && x1=[] then x2 else " ]

(* TODO:
- generate a ['proof_step t] sum type for rules, using ['proof_step offset_for]
- derive twine
- generate builders for each one
- use it in [Proof_step.t]
*)

let main () =
  pf "%s" prelude;
  pf "\n";

  let spec = Parse_spec.spec in

  (*
  (* builders *)
  let gen_mk_rule (r : rule) : unit =
    pf "(** %s *)\n" r.descr;
    let special = try List.assoc r.name mk_special with _ -> "" in
    pf
      "let %s ~concl:c_ %s : Proof_step.t = %sProof_step.(apply_rule ~concl:c_ \
       %S [%s])\n"
      (caml_name_of_name r.name)
      (String.concat " "
      @@ List.mapi (fun i a -> spf "(x%d : %s)" i (ty_of_arg a)) r.args)
      special r.name
      (String.concat "; "
      @@ List.mapi (fun i a -> pt_arg_of_arg a (spf "x%d" i)) r.args);
    pf "\n"
  in

  List.iter gen_mk_rule rules;

  pf "let deduction ~concl prems : PT.t =\n";
  pf "  PT.deduction ~concl prems\n\n";

  (* view *)
  pf "(** View of a proof term. *)\n";
  pf "type view =\n";
  List.iter
    (fun r ->
      let args =
        match r.args with
        | [] -> ""
        | _ -> spf " of %s" @@ String.concat " * " @@ List.map ty_of_arg r.args
      in
      pf "  | R_%s%s\n" (caml_name_of_name r.name) args;
      pf "  (** %s *)\n" r.descr;
      pf "\n")
    rules;
  pf "[@@deriving show {with_path=false}]\n";
  pf "\n";

  pf "exception Bad_arg of PT.t * PT.arg\n";
  pf "exception Bad_rule of PT.t\n";
  pf "\n";

  pf
    "let view (pt:PT.t) (rule:string) (args:PT.arg list) : view = match rule, \
     args with\n";
  List.iter
    (fun r ->
      pf "  | %S, [%s] ->\n" r.name
        (String.concat ";" @@ List.mapi (fun i _ -> spf "x%d" i) r.args);

      List.iteri
        (fun i arg ->
          pf "    let x%d = %s in\n" i (get_arg "pt" arg (spf "x%d" i)))
        r.args;
      pf "    R_%s (%s)\n" (caml_name_of_name r.name)
        (String.concat ", " @@ List.mapi (fun i _ -> spf "x%d" i) r.args))
    rules;
  pf "  | _ -> raise (Bad_rule pt)\n";
  pf "\n";

  (* find doc by name *)
  pf "let doc_by_name (name:string) : string option = match name with\n";
  List.iter (fun (r : rule) -> pf "  | %S -> Some %S\n" r.name r.descr) rules;
  pf "  | _ -> None\n";
  pf "\n";
*)
  ()

let () = main ()
