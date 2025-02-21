module Parse_spec = Parse_spec

let spf = Printf.sprintf
let pf = Printf.printf

type arg =
  | Term
  | Seq
  | Int
  (* | String *)
  | Step
  | List of arg

type rule = {
  name: string;
  descr: string;
  args: arg list;
}

let rec ty_of_arg = function
  | Term -> "Imandrax_api_mir.Term.t"
  | Seq -> "Imandrax_api_mir.Sequent.t"
  | Int -> "int"
  (* | String -> "string" *)
  | Step -> spf "Proof_step.t Imandrakit_twine.offset_for"
  | List l -> spf "%s list" (ty_of_arg l)

let caml_name_of_name s =
  CCString.map
    (function
      | '-' -> '_'
      | c -> c)
    s

let mk name args descr : rule = { name; args; descr }

(** All rules *)
let rules : rule list =
  [
    mk "assume" [ Term ] "Takes `t` and returns `t |- t`.";
    mk "by-def" [ Term; Term ]
      "Takes `f(t1…tn)` and `body_f[t1…tn]` and asserts `|- f(t1…tn) = \
       body_f[t1…tn]` when `f = λx1…xn. body_f[x1…xn]`.";
    mk "lemma" [ Term; Seq ]
      "Takes `p(t1…tn)` and `body_p`, where `p(x1…xn) := body_p[x1…xn]` is a \
       previously proved theorem, and asserts `|- body_p[t1…tn]`";
    mk "sorry" [ Seq ]
      "Takes `G ?- t` and returns `G |- t`. This is a hole in the proof, only \
       useful as a temporary placeholder while looking for a real proof.";
    mk "cc" [ Seq ]
      "Takes [hyps ?- t=u] and proves [hyps |- t=u] by congruence closure.";
    mk "intros" [ Seq ]
      "Takes [hyps ?- (t1…tn => u)],\n\
      \ returns [box (hyps, t1…tn |- u) |- box (hyps |- (t1…tn => u))].";
    mk "unintros" [ List Term; Seq ]
      "Takes [{i1…in}, (H_{i1…in} U other_hyps ?- u)] and returns [box \
       (other_hyps ?- (hyps_{i1} / … / H_n) ==> u)) |- box (H_{i1…in} |- u)].";
    mk "if-true" [ Term ] "[if+ (if a b c)] is [a=true |- (if a b c) = b].";
    mk "if-false" [ Term ] "[if- (if a b c)] is [a=false |- (if a b c) = c].";
    mk "if-trivial" [ Term ] "[b=true, c=false |- (if a b c) = a].";
    mk "if-trivial-neg" [ Term ] "[b=false, c=true |- (if a b c) = not a].";
    mk "trivial" [ Seq ] "[trivial (G,t |- t, _)] proves [box (G,t|-t, …)]";
    mk "and-elim" [ Seq; Seq ]
      "Takes [G1 ?- a] and [G2 ?- b],\n\
      \   produces a proof of [box (G1 |- a), box (G2 |- b) |- box (G1, G2 |- \
       a && b)].";
    mk "or-left" [ Seq; Term ]
      "Takes [G ?- a] and [b], produces a proof of [box (G |- a) |- box (G |- \
       a || b)].";
    mk "or-right" [ Seq; Term ]
      "Takes [G ?- b] and [a], produces a proof of [box (G |- b) |- box (G |- \
       a || b)].";
    mk "cstor-inj" [ Term; Term; Int ]
      "Given terms [t := C(t1…tn)] and [u := C(u1…un)] with same constructors, \
       and index [i],\n\
       returns [t = u |- ti = ui].";
    mk "cstor-disj" [ Term; Term ]
      "Given terms [t1 := C1(…)] and [t2 := C2(…)] with distinct constructors,\n\
      \    returns [|- (t1 = t2) = false].";
    mk "cstor-is-a-true" [ Term; Term ]
      "Given terms [is(C) t] and [v := C(…)], prove [t = v |- is(C) t = true].";
    mk "cstor-is-a-false" [ Term; Term ]
      "Given terms [is(C) t] and [v := C2(…)] with [C2] a distinct constructor,\n\
      \    prove [t = v |- is(C) t = false].";
    mk "cstor-is-a-project" [ Term ]
      "Given term [is-a(C,t)], return [is-a(C,t) = true |- t = \
       C(select(C,0,t), …)]";
    mk "cstor-select" [ Term; Term ]
      "Given [t1 := select(C,i,u)] and [t2 := C(v1…vn)], returns [u=t2 |- \
       t1=v_i]";
    mk "destruct" [ Term; Term ]
      "Given terms [t := destruct (C, i, sub_t)] and [u := C (v1…vn)],\n\
      \    return [sub_t = u |- t = v_i].";
    mk "and-true-left" [ Term ] "[true && x --> x]";
    mk "and-true-right" [ Term ] "[x && true --> x]";
    mk "and-false-left" [ Term ] "[false && _ --> false]";
    mk "and-false-right" [ Term ] "[_  && false --> false]";
    mk "and-refl" [ Term ] "[x && x  --> x]";
    mk "or-false-left" [ Term ] "[false || x --> x]";
    mk "or-false-right" [ Term ] "[x || false --> x]";
    mk "or-true-left" [ Term ] "[true && _ --> true]";
    mk "or-true-right" [ Term ] "[_ || true  --> true]";
    mk "or-refl" [ Term ] "[x || x  --> x]";
    mk "imply-true-right" [ Term ] "[_ ==> true  --> true]";
    mk "imply-true-left" [ Term ] "[true ==> b  --> b]";
    mk "imply-false-left" [ Term ] "[false ==> _  --> true]";
    mk "imply-false-right" [ Term ] "[true ==> false  --> false]";
    mk "imply-refl" [ Term ] "[a ==> a  --> true]";
    mk "neq" [ Term ] "[|- (a <> b) = not (a=b)]";
    mk "eq-const" [ Term; Term ]
      "Decides equality of constants: [|- (c1 = c2) = true/false]";
    mk "double_neg_elim" [ Term ] "[not (not a)  --> a]";
    mk "eq_true_elim" [ Term ] "a = true  --> a";
    mk "eq_false_not" [ Term ] "a = false --> not a";
  ]

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

  ()

let () = main ()
