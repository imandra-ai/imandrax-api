
(** Proof rules.

    Proof rules in use in ImandraX. *)

(* auto-generated in [gen/mk_rules.ml], do not modify *)

[@@@ocaml.warning "-27-39"]

type 'a offset_for = 'a Imandrakit_twine.offset_for [@@deriving eq, twine, typereg]
let pp_offset_for _ out (Offset_for x:_ offset_for) = Fmt.fprintf out "ref(0x%x)" x


(** A proof step, proving a clause using logical rules. *)
type proof_step =
  | Assume of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** Takes [t] and returns [|- t], adding it to assumptions. *)
  | By_def of {
      concl: Imandrax_api_mir.Sequent.t;
      lhs: Imandrax_api_mir.Term.t;
      body: Imandrax_api_mir.Term.t
    }
    (** Takes [f(t1…tn)] and [body_f[t1…tn]] and asserts [|- f(t1…tn) = body_f[t1…tn]] when [f = λx1…xn. body_f[x1…xn]]. *)
  | Lemma of {
      concl: Imandrax_api_mir.Sequent.t;
      predicate: Imandrax_api_mir.Term.t;
      lemma: Imandrax_api_mir.Sequent.t
    }
    (** Takes [p(t1…tn)] and [body_p], where [p(x1…xn) := body_p[x1…xn]] is a previously proved theorem, and asserts [|- body_p[t1…tn]] *)
  | Sorry of {
      concl: Imandrax_api_mir.Sequent.t
    }
    (** Takes [G ?- t] and returns [G |- t]. This is a hole in the proof, only useful as a temporary placeholder while looking for a real proof. *)
  | Cc of {
      concl: Imandrax_api_mir.Sequent.t
    }
    (** Takes [hyps ?- t=u] and proves [hyps |- t=u] by congruence closure. *)
  | If_true of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [if_true (if a b c)] is [a=true |- (if a b c) = b]. *)
  | If_false of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [if_false (if a b c)] is [a=false |- (if a b c) = c]. *)
  | If_trivial of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [b=true, c=false |- (if a b c) = a]. *)
  | If_trivial_neg of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [b=false, c=true |- (if a b c) = not a]. *)
  | Trivial of {
      concl: Imandrax_api_mir.Sequent.t
    }
    (** [trivial (G,t ?- t, _)] proves [(G,t|-t, …)] *)
  | And_elim of {
      concl: Imandrax_api_mir.Sequent.t;
      lhs: proof_step offset_for;
      rhs: proof_step offset_for
    }
    (** Takes proofs of [G1 |- a] and [G2 |- b], produces a proof of [(G1, G2 |- a && b)]. *)
  | Or_left of {
      concl: Imandrax_api_mir.Sequent.t;
      lhs: proof_step offset_for;
      t: Imandrax_api_mir.Term.t
    }
    (** Takes [G |- a] and [b], produces a proof of [(G |- a || b)]. *)
  | Or_right of {
      concl: Imandrax_api_mir.Sequent.t;
      rhs: proof_step offset_for;
      t: Imandrax_api_mir.Term.t
    }
    (** Takes [G |- b] and [a], produces a proof of [(G |- a || b)]. *)
  | Cstor_inj of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t;
      u: Imandrax_api_mir.Term.t;
      i: int
    }
    (** Given terms [t := C(t1…tn)] and [u := C(u1…un)] with same constructors, and index [i], returns [t = u |- ti = ui]. *)
  | Cstor_disj of {
      concl: Imandrax_api_mir.Sequent.t;
      t1: Imandrax_api_mir.Term.t;
      t2: Imandrax_api_mir.Term.t
    }
    (** Given terms [t1 := C1(…)] and [t2 := C2(…)] with distinct constructors, returns [|- not (t1 = t2)]. *)
  | Cstor_is_a_true of {
      concl: Imandrax_api_mir.Sequent.t;
      isa_t: Imandrax_api_mir.Term.t;
      cstor_t: Imandrax_api_mir.Term.t
    }
    (** Given terms [is(C) t] and [v := C(…)], prove [t = v |- is(C) t = true]. *)
  | Cstor_is_a_false of {
      concl: Imandrax_api_mir.Sequent.t;
      isa_t: Imandrax_api_mir.Term.t;
      cstor_t: Imandrax_api_mir.Term.t
    }
    (** Given terms [is(C) t] and [v := C2(…)] with [C2] a distinct constructor, prove [t = v |- is(C) t = false]. *)
  | Cstor_is_a_project of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** Given term [is-a(C,t)], return [is-a(C,t) = true |- t = C(select(C,0,t), …)] *)
  | Cstor_select of {
      concl: Imandrax_api_mir.Sequent.t;
      t1: Imandrax_api_mir.Term.t;
      t2: Imandrax_api_mir.Term.t
    }
    (** Given [t1 := select(C,i,u)] and [t2 := C(v1…vn)], returns [u=t2 |- t1=v_i] *)
  | Destruct of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t;
      u: Imandrax_api_mir.Term.t
    }
    (** Given terms [t := destruct (C, i, sub_t)] and [u := C (v1…vn)], return [sub_t = u |- t = v_i]. *)
  | And_true_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [true && t |- t] *)
  | And_true_right of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [t && true |- t] *)
  | And_false_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [false && _ |- false] *)
  | And_false_right of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [_  && false |- false] *)
  | And_refl of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [t && t |- t] *)
  | Or_false_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [false || x |- x] *)
  | Or_false_right of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [x || false |- x] *)
  | Or_true_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [true || _ |- true] *)
  | Or_true_right of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [_ || true |- true] *)
  | Or_refl of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [x || x |- x] *)
  | Imply_true_right of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [_ ==> true |- true] *)
  | Imply_true_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [true ==> b |- b] *)
  | Imply_false_left of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [false ==> _ |- true] *)
  | Imply_false_right of {
      concl: Imandrax_api_mir.Sequent.t
    }
    (** [(true ==> false) |- false] *)
  | Imply_refl of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [(t ==> t) |- true] *)
  | Neq of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t;
      u: Imandrax_api_mir.Term.t
    }
    (** [|- (t <> u) = not (t=u)] *)
  | Refl of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [|- (t=t)] *)
  | Neq_const of {
      concl: Imandrax_api_mir.Sequent.t;
      c1: Imandrax_api_mir.Term.t;
      c2: Imandrax_api_mir.Term.t
    }
    (** [|- (c1 = c2) = false] where [c1] and [c2] are distinct. *)
  | Double_neg_elim of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** [not (not t) |- t] *)
  | Eq_true_elim of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** t = true |- t *)
  | Eq_false_not of {
      concl: Imandrax_api_mir.Sequent.t;
      t: Imandrax_api_mir.Term.t
    }
    (** t = false |- not t *)
  | Cut of {
      concl: Imandrax_api_mir.Sequent.t;
      main: proof_step offset_for;
      sides: proof_step offset_for list
    }
    (** Takes [A1…An,B |- G] (main) and [C_i |- A_i] (sides) and returns [B,C_1…C_n |- G]. *)
  | Subst of {
      concl: Imandrax_api_mir.Sequent.t;
      p: proof_step offset_for;
      subst: (Imandrax_api_mir.Var.t * Imandrax_api_mir.Term.t) list
    }
    (** from [A |- B] and [subst] to [subst(A) |- subst(B)]. *)

(** A proof step at the level of deep sequents. *)
and deep_proof_step =
  | Deep_cut of {
      concl: Deep_sequent.t;
      main: deep_proof_step offset_for;
      sides: deep_proof_step offset_for list
    }
    (** Takes [A1…An,B ||- G] (main) and [C_i ||- A_i] (sides) and returns [B, C1…Cn ||- G]. *)
  | Deep_intro of {
      concl: Deep_sequent.t;
      assumptions: Imandrax_api_mir.Sequent.t list;
      last_step: proof_step offset_for
    }
    (** Takes last step [A |- B], a list of assumptions C1…Cn used to prove that last step, and returns [C1…Cn ||- (A |- B)]. *)
  | Deep_subst of {
      concl: Deep_sequent.t;
      p: deep_proof_step offset_for;
      subst: (Imandrax_api_mir.Var.t * Imandrax_api_mir.Term.t) list
    }
    (** From [A1…An ||- C] and [subst] to [A1…An ||- subst(C)]. *)
  | Deep_ref of {
      concl: Deep_sequent.t;
      file_ref: string;
      p: deep_proof_step offset_for
    }
    (** Takes some form of reference to another proof file, and an offset [p] within that file. Intended to be used for subtasks. *)
[@@deriving eq, twine, show {with_path=false}, typereg]

(** iterate on ProofStep *)
let rec iter_proof_step ~yield_proofstep ~yield_deepproofstep x = match x with
  | Assume x -> ()
  | By_def x -> ()
  | Lemma x -> ()
  | Sorry x ->()
  | Cc x ->()
  | If_true x -> ()
  | If_false x -> ()
  | If_trivial x -> ()
  | If_trivial_neg x -> ()
  | Trivial x ->()
  | And_elim x -> yield_proofstep x.lhs; yield_proofstep x.rhs
  | Or_left x -> yield_proofstep x.lhs
  | Or_right x -> yield_proofstep x.rhs
  | Cstor_inj x -> ()
  | Cstor_disj x -> ()
  | Cstor_is_a_true x -> ()
  | Cstor_is_a_false x -> ()
  | Cstor_is_a_project x -> ()
  | Cstor_select x -> ()
  | Destruct x -> ()
  | And_true_left x -> ()
  | And_true_right x -> ()
  | And_false_left x -> ()
  | And_false_right x -> ()
  | And_refl x -> ()
  | Or_false_left x -> ()
  | Or_false_right x -> ()
  | Or_true_left x -> ()
  | Or_true_right x -> ()
  | Or_refl x -> ()
  | Imply_true_right x -> ()
  | Imply_true_left x -> ()
  | Imply_false_left x -> ()
  | Imply_false_right x ->()
  | Imply_refl x -> ()
  | Neq x -> ()
  | Refl x -> ()
  | Neq_const x -> ()
  | Double_neg_elim x -> ()
  | Eq_true_elim x -> ()
  | Eq_false_not x -> ()
  | Cut x -> yield_proofstep x.main; List.iter (fun x -> yield_proofstep x) x.sides
  | Subst x -> yield_proofstep x.p

(** iterate on DeepProofStep *)
and iter_deep_proof_step ~yield_proofstep ~yield_deepproofstep x = match x with
  | Deep_cut x -> yield_deepproofstep x.main; List.iter (fun x -> yield_deepproofstep x) x.sides
  | Deep_intro x -> yield_proofstep x.last_step
  | Deep_subst x -> yield_deepproofstep x.p
  | Deep_ref x -> yield_deepproofstep x.p
[@@deriving eq, twine, show {with_path=false}, typereg]
