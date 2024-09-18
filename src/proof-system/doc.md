# Imandra Proof System


## DAG terms

### Terms returning `Clause`

- `clause : [Term] -> Clause`
  Build a sequent from premises and conclusions


### Terms returning `Const`

- `cn.string : String -> Const`
  A string literal.

- `cn.q : Bytes, Bytes -> Const`
  A rational, as a pair of bigints.

- `cn.z : Bytes -> Const`
  A bigint, serialized to bytes with zigzag encoding.

- `cn.int : Int -> Const`
  An integer literal.


### Terms returning `MProofStep`

- `m.subst : Scope, MProofStep, [(Var, Term)] -> MProofStep`
  `A1… An ||- C` and `σ` --> `A1…An ||- Cσ`.

- `m.intro : Scope, ProofStep -> MProofStep`
  Takes `A |- B` and returns `C1, C2 …, Cn ||- (A|-B)`, where `C_i` are the assumptions in the current scope.

- `m.cut : Scope, MProofStep, [MProofStep] -> MProofStep`
  Takes `A1…An,B ||- G` and `C_i ||- A_i` and returns `B, ,(C_i)_i ||- G`.


### Terms returning `ProofStep`

- `p.subst : Scope, ProofStep, [(Var, Term)] -> ProofStep`
  `C` and `σ` --> `Cσ`.

- `p.cut : Scope, ProofStep, [ProofStep] -> ProofStep`
  Takes `A1…An,B |- G` and `C_i |- A_i` and returns `B, ,(C_i)_i |- G`.

- `p.eq_false_not : Scope, Term -> ProofStep`
  a = false --> not a

- `p.eq_true_elim : Scope, Term -> ProofStep`
  a = true  --> a

- `p.double_neg_elim : Scope, Term -> ProofStep`
  `not (not a)  --> a`

- `p.eq-const : Scope, Term, Term -> ProofStep`
  Decides equality of constants: `|- (c1 = c2) = true/false`

- `p.neq : Scope, Term -> ProofStep`
  `|- (a <> b) = not (a=b)`

- `p.imply-refl : Scope, Term -> ProofStep`
  `a ==> a  --> true`

- `p.imply-false-right : Scope, Term -> ProofStep`
  `true ==> false  --> false`

- `p.imply-false-left : Scope, Term -> ProofStep`
  `false ==> _  --> true`

- `p.imply-true-left : Scope, Term -> ProofStep`
  `true ==> b  --> b`

- `p.imply-true-right : Scope, Term -> ProofStep`
  `_ ==> true  --> true`

- `p.or-refl : Scope, Term -> ProofStep`
  `x || x  --> x`

- `p.or-true-right : Scope, Term -> ProofStep`
  `_ || true  --> true`

- `p.or-true-left : Scope, Term -> ProofStep`
  `true && _ --> true`

- `p.or-false-right : Scope, Term -> ProofStep`
  `x || false --> x`

- `p.or-false-left : Scope, Term -> ProofStep`
  `false || x --> x`

- `p.and-refl : Scope, Term -> ProofStep`
  `x && x  --> x`

- `p.and-false-right : Scope, Term -> ProofStep`
  `_  && false --> false`

- `p.and-false-left : Scope, Term -> ProofStep`
  `false && _ --> false`

- `p.and-true-right : Scope, Term -> ProofStep`
  `x && true --> x`

- `p.and-true-left : Scope, Term -> ProofStep`
  `true && x --> x`

- `p.destruct : Scope, Term, Term -> ProofStep`
  Given terms `t := destruct (C, i, sub_t)` and `u := C (v1…vn)`,
      return `sub_t = u |- t = v_i`.

- `p.cstor-select : Scope, Term, Term -> ProofStep`
  Given `t1 := select(C,i,u)` and `t2 := C(v1…vn)`, returns `u=t2 |- t1=v_i`

- `p.cstor-is-a-project : Scope, Term -> ProofStep`
  Given term `is-a(C,t)`, return `is-a(C,t) = true |- t = C(select(C,0,t), …)`

- `p.cstor-is-a-false : Scope, Term, Term -> ProofStep`
  Given terms `is(C) t` and `v := C2(…)` with `C2` a distinct constructor,
      prove `t = v |- is(C) t = false`.

- `p.cstor-is-a-true : Scope, Term, Term -> ProofStep`
  Given terms `is(C) t` and `v := C(…)`, prove `t = v |- is(C) t = true`.

- `p.cstor-disj : Scope, Term, Term -> ProofStep`
  Given terms `t1 := C1(…)` and `t2 := C2(…)` with distinct constructors,
      returns `|- (t1 = t2) = false`.

- `p.cstor-inj : Scope, Term, Term, Int -> ProofStep`
  Given terms `t := C(t1…tn)` and `u := C(u1…un)` with same constructors, and index `i`,
  returns `t = u |- ti = ui`.

- `p.or-right : Scope, Clause, Term -> ProofStep`
  Takes `G ?- b` and `a`, produces a proof of `box (G |- b) |- box (G |- a || b)`.

- `p.or-left : Scope, Clause, Term -> ProofStep`
  Takes `G ?- a` and `b`, produces a proof of `box (G |- a) |- box (G |- a || b)`.

- `p.and-elim : Scope, Clause, Clause -> ProofStep`
  Takes `G1 ?- a` and `G2 ?- b`,
     produces a proof of `box (G1 |- a), box (G2 |- b) |- box (G1, G2 |- a && b)`.

- `p.trivial : Scope, Clause -> ProofStep`
  `trivial (G,t |- t, _)` proves `box (G,t|-t, …)`

- `p.if-trivial-neg : Scope, Term -> ProofStep`
  `b=false, c=true |- (if a b c) = not a`.

- `p.if-trivial : Scope, Term -> ProofStep`
  `b=true, c=false |- (if a b c) = a`.

- `p.if-false : Scope, Term -> ProofStep`
  `if- (if a b c)` is `a=false |- (if a b c) = c`.

- `p.if-true : Scope, Term -> ProofStep`
  `if+ (if a b c)` is `a=true |- (if a b c) = b`.

- `p.unintros : Scope, [Term], Clause -> ProofStep`
  Takes `{i1…in}, (H_{i1…in} U other_hyps ?- u)` and returns `box (other_hyps ?- (hyps_{i1} / … / H_n) ==> u)) |- box (H_{i1…in} |- u)`.

- `p.intros : Scope, Clause -> ProofStep`
  Takes `hyps ?- (t1…tn => u)`,
   returns `box (hyps, t1…tn |- u) |- box (hyps |- (t1…tn => u))`.

- `p.cc : Scope, Clause -> ProofStep`
  Takes `hyps ?- t=u` and proves `hyps |- t=u` by congruence closure.

- `p.sorry : Scope, Clause -> ProofStep`
  Takes `G ?- t` and returns `G |- t`. This is a hole in the proof, only useful as a temporary placeholder while looking for a real proof.

- `p.lemma : Scope, Term, Clause -> ProofStep`
  Takes `p(t1…tn)` and `body_p`, where `p(x1…xn) := body_p[x1…xn]` is a previously proved theorem, and asserts `|- body_p[t1…tn]`

- `p.by-def : Scope, Term, Term -> ProofStep`
  Takes `f(t1…tn)` and `body_f[t1…tn]` and asserts `|- f(t1…tn) = body_f[t1…tn]` when `f = λx1…xn. body_f[x1…xn]`.

- `p.assume : Scope, Term -> ProofStep`
  Takes `t` and returns `|- t`, adding it to assumptions in the given scope.


### Terms returning `[FunDefID]`

- `fun.defs : [(String, [Var], Type, Term)] -> [FunDefID]`
  Defines a set of mutually recursive functions. Each tuple is a regular function definition.


### Terms returning `Term`

- `t.destr : FunDefID, [Type], Int, Term -> Term`
  A construct destruction (takes cstor, type parameters, argument index, destructed term).

- `t.isa : FunDefID, Term -> Term`
  A cstor-testing term (takes the constructor and the term to test)

- `t.cs : FunDefID, [Type], [Term] -> Term`
  A constructor term (takes cstor, type params, argument list).

- `t.if : Term, Term, Term -> Term`
  A conditional term (if/then/else).

- `t.v : Var -> Term`
  (full name used for codegen: `t.var`)
  A free variable.

- `t.b : String, [Type], [Term] -> Term`
  (full name used for codegen: `t.builtin`)
  An application of a builtin symbol.

- `t.@ : FunDefID, [Type], [Term] -> Term`
  (full name used for codegen: `t.app`)
  An application.

- `t.bool : Bool -> Term`
  A boolean literal term (true or false).

- `t.cn : Const -> Term`
  A literal constant term.


### Terms returning `TypeDefID`

- `ty.decl : String, Int -> TypeDefID`
  Declares a type constructor with given arity.


### Terms returning `Type`

- `ty.arr : [Type], Type -> Type`
  An arrow type `args -> ret`.

- `ty.b : String, [Type] -> Type`
  (full name used for codegen: `ty.builtin`)
  A builtin type constructor, e.g `int`.

- `ty.@ : String, [Type] -> Type`
  (full name used for codegen: `ty.app`)
  A type constructor applied to arguments, e.g `list(int)`.

- `ty.v : String -> Type`
  (full name used for codegen: `ty.var`)
  A type variable.


### Terms returning `MSeq`

- `mseq : [Clause], Clause -> MSeq`
  Build a meta-sequent from premises and conclusion


### Terms returning `Var`

- `var : String, Type -> Var`
  A variable.


### Terms returning `FunDefID`

- `fun.def : String, [Var], Type, Term -> FunDefID`
  Defines a function `f args : ret := body`.

- `fun.decl : FunDefID, [Type], Type -> FunDefID`
  Declares a function symbol `f : args -> ret`.


### Terms returning `Scope`

- `scope.enter : Scope -> Scope`
  Enter a new scope, child of a previous scope (or `0` for the root scope).



## Builtin symbols

- type builtin `Bool`

- type builtin `Int`

- type builtin `Rational`

- builtin symbol `not : Bool -> Bool`

- builtin symbol `and : Bool, Bool -> Bool`

- builtin symbol `or : Bool, Bool -> Bool`

- builtin symbol `=> : Bool, Bool -> Bool`

- builtin symbol `= : A. A, A -> Bool`

