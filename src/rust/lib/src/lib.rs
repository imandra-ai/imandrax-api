
// automatically generated using genbindings.ml, do not edit

#![allow(non_camel_case_types)]

pub mod deser;
pub use deser::FromTwine;
pub mod utils;
  use utils::*;


// do not format
#![cfg_attr(any(), rustfmt::skip)]

//use bumpalo::Bump;
use num_bigint::BigInt;
use num_rational::BigRational as Rational;
//use anyhow::bail;

pub type Error<'a> = ErrorError_core<'a>;

pub type UidSet<'a> = [Uid<'a>];
pub type Var_set<'a> = UidSet<'a>;

// def Uid_set_of_twine(d, off:int) -> UidSet:
//      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off)) 


// clique Imandrakit_error.Kind.t
#[derive(Debug, Clone)]
pub struct ErrorKind<'a> {
  pub name: &'a str,
}


// clique Imandrakit_error.Error_core.message
#[derive(Debug, Clone)]
pub struct ErrorError_coreMessage<'a> {
  pub msg: &'a str,
  pub data: Ignored /* data */,
  pub bt: Option<&'a str>,
}


// clique Imandrakit_error.Error_core.t
#[derive(Debug, Clone)]
pub struct ErrorError_core<'a> {
  pub process: &'a str,
  pub kind: &'a ErrorKind<'a>,
  pub msg: &'a ErrorError_coreMessage<'a>,
  pub stack: &'a [&'a ErrorError_coreMessage<'a>],
}


// clique Imandrax_api.Util_twine_.as_pair
// immediate
#[derive(Debug, Clone)]
pub struct Util_twine_As_pair {
  pub num: BigInt,
  pub denum: BigInt,
}


// clique Imandrax_api.Builtin_data.kind
#[derive(Debug, Clone)]
pub enum Builtin_dataKind<'a> {
  Logic_core {
    logic_core_name: &'a str,
  },
  Special {
    tag: &'a str,
  },
  Tactic {
    tac_name: &'a str,
  },
}

// clique Imandrax_api.Cname.t
#[derive(Debug, Clone)]
pub struct Cname<'a> {
  pub name: &'a str,
  pub chash: &'a str,
}


// clique Imandrax_api.Uid.gen_kind
// immediate
#[derive(Debug, Clone)]
pub enum UidGen_kind {
  Local,
  To_be_rewritten,
}

// clique Imandrax_api.Uid.view
#[derive(Debug, Clone)]
pub enum UidView<'a> {
  Generative {
    id: BigInt,
    gen_kind: UidGen_kind,
  },
  Persistent,
  Cname {
    cname: &'a Cname<'a>,
  },
  Builtin {
    kind: &'a Builtin_dataKind<'a>,
  },
}

// clique Imandrax_api.Uid.t
#[derive(Debug, Clone)]
pub struct Uid<'a> {
  pub name: &'a str,
  pub view: &'a UidView<'a>,
}


// clique Imandrax_api.Builtin.Fun.t
#[derive(Debug, Clone)]
pub struct BuiltinFun<'a> {
  pub id: &'a Uid<'a>,
  pub kind: &'a Builtin_dataKind<'a>,
  pub lassoc: bool,
  pub commutative: bool,
  pub connective: bool,
}


// clique Imandrax_api.Builtin.Ty.t
#[derive(Debug, Clone)]
pub struct BuiltinTy<'a> {
  pub id: &'a Uid<'a>,
  pub kind: &'a Builtin_dataKind<'a>,
}


// clique Imandrax_api.Ty_view.adt_row
#[derive(Debug, Clone)]
pub struct Ty_viewAdt_row<'a,V_tyreg_poly_id:'a,V_tyreg_poly_t:'a> {
  pub c: V_tyreg_poly_id,
  pub labels: Option<&'a [V_tyreg_poly_id]>,
  pub args: &'a [V_tyreg_poly_t],
  pub doc: Option<&'a str>,
}


// clique Imandrax_api.Ty_view.rec_row
#[derive(Debug, Clone)]
pub struct Ty_viewRec_row<'a,V_tyreg_poly_id:'a,V_tyreg_poly_t:'a> {
  pub f: V_tyreg_poly_id,
  pub ty: V_tyreg_poly_t,
  pub doc: Option<&'a str>,
}


// clique Imandrax_api.Ty_view.decl
#[derive(Debug, Clone)]
pub enum Ty_viewDecl<'a,V_tyreg_poly_id:'a,V_tyreg_poly_t:'a,V_tyreg_poly_alias:'a> {
  Algebraic(&'a [&'a Ty_viewAdt_row<'a,V_tyreg_poly_id,V_tyreg_poly_t>]),
  Record(&'a [&'a Ty_viewRec_row<'a,V_tyreg_poly_id,V_tyreg_poly_t>]),
  Alias {
    target: V_tyreg_poly_alias,
    reexport_def: Option<&'a Ty_viewDecl<'a,V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias>>,
  },
  Skolem,
  Builtin(&'a BuiltinTy<'a>),
  Other,
}

// clique Imandrax_api.Ty_view.view
#[derive(Debug, Clone)]
pub enum Ty_viewView<'a,V_tyreg_poly_lbl:'a,V_tyreg_poly_var:'a,V_tyreg_poly_t:'a> {
  Var(V_tyreg_poly_var),
  Arrow(V_tyreg_poly_lbl,V_tyreg_poly_t,V_tyreg_poly_t),
  Tuple(&'a [V_tyreg_poly_t]),
  Constr(&'a Uid<'a>,&'a [V_tyreg_poly_t]),
}

// clique Imandrax_api.Stat_time.t
// immediate
#[derive(Debug, Clone)]
pub struct Stat_time {
  pub time_s: f64,
}


// clique Imandrax_api.Sequent_poly.t
#[derive(Debug, Clone)]
pub struct Sequent_poly<'a,V_tyreg_poly_term:'a> {
  pub hyps: &'a [V_tyreg_poly_term],
  pub concls: &'a [V_tyreg_poly_term],
}


// clique Imandrax_api.Misc_types.rec_flag
// immediate
#[derive(Debug, Clone)]
pub enum Misc_typesRec_flag {
  Recursive,
  Nonrecursive,
}

// clique Imandrax_api.Misc_types.apply_label
#[derive(Debug, Clone)]
pub enum Misc_typesApply_label<'a> {
  Nolabel,
  Label(&'a str),
  Optional(&'a str),
}

// clique Imandrax_api.In_mem_archive.raw
#[derive(Debug, Clone)]
pub struct In_mem_archiveRaw<'a> {
  pub ty: &'a str,
  pub compressed: bool,
  pub data: &'a [u8],
}


// clique Imandrax_api.Const.t
#[derive(Debug, Clone)]
pub enum Const<'a> {
  Const_float(f64),
  Const_string(&'a str),
  Const_z(BigInt),
  Const_q(Rational),
  Const_real_approx(&'a str),
  Const_uid(&'a Uid<'a>),
  Const_bool(bool),
}

// clique Imandrax_api.As_trigger.t
// immediate
#[derive(Debug, Clone)]
pub enum As_trigger {
  Trig_none,
  Trig_anon,
  Trig_named(BigInt),
  Trig_rw,
}

// clique Imandrax_api.Anchor.t
#[derive(Debug, Clone)]
pub enum Anchor<'a> {
  Named(&'a Cname<'a>),
  Eval(BigInt),
  Proof_check(&'a Anchor<'a>),
  Decomp(&'a Anchor<'a>),
}

// clique Imandrax_api.Admission.t
#[derive(Debug, Clone)]
pub struct Admission<'a> {
  pub measured_subset: &'a [&'a str],
  pub measure_fun: Option<&'a Uid<'a>>,
}


// clique Imandrax_api_model.ty_def
#[derive(Debug, Clone)]
pub enum ModelTy_def<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  Ty_finite(&'a [V_tyreg_poly_term]),
  Ty_alias_unit(V_tyreg_poly_ty),
}

// clique Imandrax_api_model.fi
#[derive(Debug, Clone)]
pub struct ModelFi<'a,V_tyreg_poly_term:'a,V_tyreg_poly_var:'a,V_tyreg_poly_ty:'a> {
  pub fi_args: &'a [V_tyreg_poly_var],
  pub fi_ty_ret: V_tyreg_poly_ty,
  pub fi_cases: &'a [(&'a [V_tyreg_poly_term],V_tyreg_poly_term)],
  pub fi_else: V_tyreg_poly_term,
}


// clique Imandrax_api_model.t
#[derive(Debug, Clone)]
pub struct Model<'a,V_tyreg_poly_term:'a,V_tyreg_poly_fn:'a,V_tyreg_poly_var:'a,V_tyreg_poly_ty:'a> {
  pub tys: &'a [(V_tyreg_poly_ty,&'a ModelTy_def<'a,V_tyreg_poly_term,V_tyreg_poly_ty>)],
  pub consts: &'a [(V_tyreg_poly_fn,V_tyreg_poly_term)],
  pub funs: &'a [(V_tyreg_poly_fn,&'a ModelFi<'a,V_tyreg_poly_term,V_tyreg_poly_var,V_tyreg_poly_ty>)],
  pub representable: bool,
  pub completed: bool,
  pub ty_subst: &'a [(&'a Uid<'a>,V_tyreg_poly_ty)],
}


// clique Imandrax_api_ca_store.Ca_ptr.Raw.t
#[derive(Debug, Clone)]
pub struct Ca_storeCa_ptrRaw<'a> {
  pub key: &'a Util_twine_With_tag7<'a,&'a str>,
}


// clique Imandrax_api_cir.Type.t
#[derive(Debug, Clone)]
pub struct CirType<'a> {
  pub view: &'a Ty_viewView<'a,(),&'a Uid<'a>,&'a CirType<'a>>,
}


// clique Imandrax_api_cir.Type.def
#[derive(Debug, Clone)]
pub struct CirTypeDef<'a> {
  pub name: &'a Uid<'a>,
  pub params: &'a [&'a Uid<'a>],
  pub decl: &'a Ty_viewDecl<'a,&'a Uid<'a>,&'a CirType<'a>,Void>,
  pub clique: Option<&'a UidSet<'a>>,
  pub timeout: Option<BigInt>,
}


// clique Imandrax_api_cir.With_ty.t
#[derive(Debug, Clone)]
pub struct CirWith_ty<'a,V_tyreg_poly_a:'a> {
  pub view: V_tyreg_poly_a,
  pub ty: &'a CirType<'a>,
}


// clique Imandrax_api_cir.Type_schema.t
#[derive(Debug, Clone)]
pub struct CirType_schema<'a> {
  pub params: &'a [&'a Uid<'a>],
  pub ty: &'a CirType<'a>,
}


// clique Imandrax_api_cir.Typed_symbol.t
#[derive(Debug, Clone)]
pub struct CirTyped_symbol<'a> {
  pub id: &'a Uid<'a>,
  pub ty: &'a CirType_schema<'a>,
}


// clique Imandrax_api_cir.Applied_symbol.t
#[derive(Debug, Clone)]
pub struct CirApplied_symbol<'a> {
  pub sym: &'a CirTyped_symbol<'a>,
  pub args: &'a [&'a CirType<'a>],
  pub ty: &'a CirType<'a>,
}


// clique Imandrax_api_cir.Fo_pattern.view
#[derive(Debug, Clone)]
pub enum CirFo_patternView<'a,V_tyreg_poly_t:'a> {
  FO_any,
  FO_bool(bool),
  FO_const(&'a Const<'a>),
  FO_var(&'a CirWith_ty<'a,&'a Uid<'a>>),
  FO_app(&'a CirApplied_symbol<'a>,&'a [V_tyreg_poly_t]),
  FO_cstor(Option<&'a CirApplied_symbol<'a>>,&'a [V_tyreg_poly_t]),
  FO_destruct {
    c: Option<&'a CirApplied_symbol<'a>>,
    i: BigInt,
    u: V_tyreg_poly_t,
  },
  FO_is_a {
    c: &'a CirApplied_symbol<'a>,
    u: V_tyreg_poly_t,
  },
}

// clique Imandrax_api_cir.Fo_pattern.t
#[derive(Debug, Clone)]
pub struct CirFo_pattern<'a> {
  pub view: &'a CirFo_patternView<'a,&'a CirFo_pattern<'a>>,
  pub ty: &'a CirType<'a>,
}


// clique Imandrax_api_cir.Pattern_head.t
#[derive(Debug, Clone)]
pub enum CirPattern_head<'a> {
  PH_id(&'a Uid<'a>),
  PH_ty(&'a CirType<'a>),
  PH_datatype_op,
}

// clique Imandrax_api_cir.Trigger.t
#[derive(Debug, Clone)]
pub struct CirTrigger<'a> {
  pub trigger_head: &'a CirPattern_head<'a>,
  pub trigger_patterns: &'a [&'a CirFo_pattern<'a>],
  pub trigger_instantiation_rule_name: &'a Uid<'a>,
}


// clique Imandrax_api_cir.Case.t
#[derive(Debug, Clone)]
pub struct CirCase<'a,V_tyreg_poly_t:'a> {
  pub case_cstor: &'a CirApplied_symbol<'a>,
  pub case_vars: &'a [&'a CirWith_ty<'a,&'a Uid<'a>>],
  pub case_rhs: V_tyreg_poly_t,
  pub case_labels: Option<&'a [&'a Uid<'a>]>,
}


// clique Imandrax_api_cir.Logic_config.t
// immediate
#[derive(Debug, Clone)]
pub struct CirLogic_config {
  pub timeout: BigInt,
  pub validate: bool,
  pub skip_proofs: bool,
  pub max_induct: Option<BigInt>,
  pub backchain_limit: BigInt,
  pub enable_all: bool,
  pub induct_unroll_depth: BigInt,
  pub induct_subgoal_depth: BigInt,
  pub unroll_enable_all: bool,
  pub unroll_depth: BigInt,
}


// clique Imandrax_api_cir.Logic_config.op
// immediate
#[derive(Debug, Clone)]
pub enum CirLogic_configOp {
  Op_timeout(BigInt),
  Op_validate(bool),
  Op_skip_proofs(bool),
  Op_max_induct(Option<BigInt>),
  Op_backchain_limit(BigInt),
  Op_enable_all(bool),
  Op_induct_unroll_depth(BigInt),
  Op_induct_subgoal_depth(BigInt),
  Op_unroll_enable_all(bool),
  Op_unroll_depth(BigInt),
}

// clique Imandrax_api_cir.Term.view
#[derive(Debug, Clone)]
pub enum CirTermView<'a> {
  Const(&'a Const<'a>),
  If(&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirWith_ty<'a,&'a CirTermView<'a>>),
  Let {
    flg: Misc_typesRec_flag,
    bs: &'a [(&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirWith_ty<'a,&'a CirTermView<'a>>)],
    body: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Apply {
    f: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
    l: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
  },
  Fun {
    v: &'a CirWith_ty<'a,&'a Uid<'a>>,
    body: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Var(&'a CirWith_ty<'a,&'a Uid<'a>>),
  Sym(&'a CirApplied_symbol<'a>),
  Construct {
    c: &'a CirApplied_symbol<'a>,
    args: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
    labels: Option<&'a [&'a Uid<'a>]>,
  },
  Destruct {
    c: &'a CirApplied_symbol<'a>,
    i: BigInt,
    t: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Is_a {
    c: &'a CirApplied_symbol<'a>,
    t: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Tuple {
    l: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
  },
  Field {
    f: &'a CirApplied_symbol<'a>,
    t: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Tuple_field {
    i: BigInt,
    t: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
  Record {
    rows: &'a [(&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a CirTermView<'a>>)],
    rest: Option<&'a CirWith_ty<'a,&'a CirTermView<'a>>>,
  },
  Case {
    u: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
    cases: &'a [&'a CirCase<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>>],
    default: Option<&'a CirWith_ty<'a,&'a CirTermView<'a>>>,
  },
  Let_tuple {
    vars: &'a [&'a CirWith_ty<'a,&'a Uid<'a>>],
    rhs: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
    body: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  },
}

// clique Imandrax_api_cir.Hints.style
// immediate
#[derive(Debug, Clone)]
pub enum CirHintsStyle {
  Multiplicative,
  Additive,
}

// clique Imandrax_api_cir.Hints.Induct.t
#[derive(Debug, Clone)]
pub enum CirHintsInduct<'a> {
  Functional {
    f_name: Option<&'a Uid<'a>>,
  },
  Structural {
    style: CirHintsStyle,
    vars: &'a [&'a str],
  },
  Term {
    t: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
    vars: &'a [&'a CirWith_ty<'a,&'a Uid<'a>>],
  },
  Default,
}

// clique Imandrax_api_cir.Hints.Method.t
#[derive(Debug, Clone)]
pub enum CirHintsMethod<'a> {
  Unroll {
    steps: Option<BigInt>,
  },
  Ext_solver {
    name: &'a str,
  },
  Auto,
  Induct(&'a CirHintsInduct<'a>),
}

// clique Imandrax_api_cir.Hints.Top.t
#[derive(Debug, Clone)]
pub struct CirHintsTop<'a,V_tyreg_poly_f:'a> {
  pub basis: &'a UidSet<'a>,
  pub method_: &'a CirHintsMethod<'a>,
  pub apply_hint: &'a [V_tyreg_poly_f],
  pub logic_config_ops: &'a [CirLogic_configOp],
  pub otf: bool,
}


// clique Imandrax_api_cir.Fun_def.fun_kind
#[derive(Debug, Clone)]
pub enum CirFun_defFun_kind<'a> {
  Fun_defined {
    is_macro: bool,
    from_lambda: bool,
  },
  Fun_builtin(&'a BuiltinFun<'a>),
  Fun_opaque,
}

// clique Imandrax_api_cir.Fun_def.validation_strategy
#[derive(Debug, Clone)]
pub enum CirFun_defValidation_strategy<'a> {
  VS_validate {
    tactic: Option<&'a CirWith_ty<'a,&'a CirTermView<'a>>>,
  },
  VS_no_validate,
}

// clique Imandrax_api_cir.Fun_def.t,Imandrax_api_cir.Fun_def.apply_hint
#[derive(Debug, Clone)]
pub struct CirFun_def<'a> {
  pub f_name: &'a Uid<'a>,
  pub f_ty: &'a CirType_schema<'a>,
  pub f_args: &'a [&'a CirWith_ty<'a,&'a Uid<'a>>],
  pub f_body: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub f_clique: Option<&'a UidSet<'a>>,
  pub f_kind: &'a CirFun_defFun_kind<'a>,
  pub f_admission: Option<&'a Admission<'a>>,
  pub f_admission_measure: Option<&'a Uid<'a>>,
  pub f_validate_strat: &'a CirFun_defValidation_strategy<'a>,
  pub f_hints: Option<&'a CirHintsTop<'a,&'a CirFun_defApply_hint<'a>>>,
  pub f_enable: &'a [&'a Uid<'a>],
  pub f_disable: &'a [&'a Uid<'a>],
  pub f_timeout: Option<BigInt>,
}

#[derive(Debug, Clone)]
pub struct CirFun_defApply_hint<'a> {
  pub apply_fun: &'a CirFun_def<'a>,
}


// clique Imandrax_api_cir.Theorem.t
#[derive(Debug, Clone)]
pub struct CirTheorem<'a> {
  pub thm_link: &'a CirFun_def<'a>,
  pub thm_rewriting: bool,
  pub thm_perm_restrict: bool,
  pub thm_fc: bool,
  pub thm_elim: bool,
  pub thm_gen: bool,
  pub thm_otf: bool,
  pub thm_triggers: &'a [(&'a CirWith_ty<'a,&'a CirTermView<'a>>,As_trigger)],
  pub thm_is_axiom: bool,
  pub thm_by: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
}


// clique Imandrax_api_cir.Tactic.t
#[derive(Debug, Clone)]
pub enum CirTactic<'a> {
  Default_termination {
    basis: &'a UidSet<'a>,
  },
  Default_thm,
  Term(&'a CirWith_ty<'a,&'a CirTermView<'a>>),
}

// clique Imandrax_api_cir.Rewrite_rule.t
#[derive(Debug, Clone)]
pub struct CirRewrite_rule<'a> {
  pub rw_name: &'a Uid<'a>,
  pub rw_head: &'a CirPattern_head<'a>,
  pub rw_lhs: &'a CirFo_pattern<'a>,
  pub rw_rhs: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub rw_guard: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
  pub rw_vars: &'a Var_set<'a>,
  pub rw_triggers: &'a [&'a CirFo_pattern<'a>],
  pub rw_perm_restrict: bool,
  pub rw_loop_break: Option<&'a CirFo_pattern<'a>>,
}


// clique Imandrax_api_cir.Proof_obligation.t
#[derive(Debug, Clone)]
pub struct CirProof_obligation<'a> {
  pub descr: &'a str,
  pub goal: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub tactic: &'a CirTactic<'a>,
  pub is_instance: bool,
  pub anchor: &'a Anchor<'a>,
  pub timeout: Option<BigInt>,
}


// clique Imandrax_api_cir.Instantiation_rule_kind.t
// immediate
#[derive(Debug, Clone)]
pub enum CirInstantiation_rule_kind {
  IR_forward_chaining,
  IR_generalization,
}

// clique Imandrax_api_cir.Instantiation_rule.t
#[derive(Debug, Clone)]
pub struct CirInstantiation_rule<'a> {
  pub ir_from: &'a CirFun_def<'a>,
  pub ir_triggers: &'a [&'a CirTrigger<'a>],
  pub ir_kind: CirInstantiation_rule_kind,
}


// clique Imandrax_api_cir.Fun_decomp.status
#[derive(Debug, Clone)]
pub enum CirFun_decompStatus<'a> {
  Unknown,
  Feasible(&'a Model<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirType<'a>>),
}

// clique Imandrax_api_cir.Fun_decomp.Region.t
#[derive(Debug, Clone)]
pub struct CirFun_decompRegion<'a> {
  pub constraints: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
  pub invariant: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub status: &'a CirFun_decompStatus<'a>,
}


// clique Imandrax_api_cir.Fun_decomp.t
#[derive(Debug, Clone)]
pub struct CirFun_decomp<'a> {
  pub f_id: &'a Uid<'a>,
  pub f_args: &'a [&'a CirWith_ty<'a,&'a Uid<'a>>],
  pub regions: &'a [&'a CirFun_decompRegion<'a>],
}


// clique Imandrax_api_cir.Elimination_rule.t
#[derive(Debug, Clone)]
pub struct CirElimination_rule<'a> {
  pub er_name: &'a Uid<'a>,
  pub er_guard: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
  pub er_lhs: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub er_rhs: &'a CirWith_ty<'a,&'a Uid<'a>>,
  pub er_dests: &'a [&'a CirFo_pattern<'a>],
  pub er_dest_tms: &'a [&'a CirWith_ty<'a,&'a CirTermView<'a>>],
}


// clique Imandrax_api_cir.Decomp.lift_bool
// immediate
#[derive(Debug, Clone)]
pub enum CirDecompLift_bool {
  Default,
  Nested_equalities,
  Equalities,
  All,
}

// clique Imandrax_api_cir.Decomp.t
#[derive(Debug, Clone)]
pub struct CirDecomp<'a> {
  pub f_id: &'a Uid<'a>,
  pub assuming: Option<&'a Uid<'a>>,
  pub basis: &'a UidSet<'a>,
  pub rule_specs: &'a UidSet<'a>,
  pub ctx_simp: bool,
  pub lift_bool: CirDecompLift_bool,
  pub prune: bool,
}


// clique Imandrax_api_cir.Db_ser.t
#[derive(Debug, Clone)]
pub struct CirDb_ser<'a> {
  pub decls: &'a UidSet<'a>,
  pub rw_rules: &'a [(&'a CirPattern_head<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub inst_rules: &'a [(&'a Uid<'a>,&'a Ca_storeCa_ptrRaw<'a>)],
  pub rule_spec_fc: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub rule_spec_rw_rules: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub fc: &'a [(&'a CirPattern_head<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub elim: &'a [(&'a CirPattern_head<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub gen: &'a [(&'a CirPattern_head<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_rw: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_fc: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_elim: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_gen: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub admission: &'a [(&'a Uid<'a>,&'a Ca_storeCa_ptrRaw<'a>)],
  pub count_funs_of_ty: &'a [(&'a Uid<'a>,&'a Uid<'a>)],
  pub config: &'a Ca_storeCa_ptrRaw<'a>,
  pub disabled: &'a UidSet<'a>,
}


// clique Imandrax_api_eval.Ordinal.t
#[derive(Debug, Clone)]
pub enum EvalOrdinal<'a> {
  Int(BigInt),
  Cons(&'a EvalOrdinal<'a>,BigInt,&'a EvalOrdinal<'a>),
}

// clique Imandrax_api_eval.Value.cstor_descriptor
#[derive(Debug, Clone)]
pub struct EvalValueCstor_descriptor<'a> {
  pub cd_idx: BigInt,
  pub cd_name: &'a Uid<'a>,
}


// clique Imandrax_api_eval.Value.record_descriptor
#[derive(Debug, Clone)]
pub struct EvalValueRecord_descriptor<'a> {
  pub rd_name: &'a Uid<'a>,
  pub rd_fields: &'a [&'a Uid<'a>],
}


// clique Imandrax_api_eval.Value.view
#[derive(Debug, Clone)]
pub enum EvalValueView<'a,V_tyreg_poly_v:'a,V_tyreg_poly_closure:'a> {
  V_true,
  V_false,
  V_int(BigInt),
  V_real(Rational),
  V_string(&'a str),
  V_cstor(&'a EvalValueCstor_descriptor<'a>,&'a [V_tyreg_poly_v]),
  V_tuple(&'a [V_tyreg_poly_v]),
  V_record(&'a EvalValueRecord_descriptor<'a>,&'a [V_tyreg_poly_v]),
  V_quoted_term(&'a CirWith_ty<'a,&'a CirTermView<'a>>),
  V_uid(&'a Uid<'a>),
  V_closure(V_tyreg_poly_closure),
  V_custom(Ignored /* custom value */),
  V_ordinal(&'a EvalOrdinal<'a>),
}

// clique Imandrax_api_eval.Value.t
#[derive(Debug, Clone)]
pub struct EvalValue<'a> {
  pub v: &'a EvalValueView<'a,&'a EvalValue<'a>,()>,
}


// clique Imandrax_api_report.Expansion.t
#[derive(Debug, Clone)]
pub struct ReportExpansion<'a,V_tyreg_poly_term:'a> {
  pub f_name: &'a Uid<'a>,
  pub lhs: V_tyreg_poly_term,
  pub rhs: V_tyreg_poly_term,
}


// clique Imandrax_api_report.Instantiation.t
#[derive(Debug, Clone)]
pub struct ReportInstantiation<'a,V_tyreg_poly_term:'a> {
  pub assertion: V_tyreg_poly_term,
  pub from_rule: &'a Uid<'a>,
}


// clique Imandrax_api_report.Smt_proof.t
#[derive(Debug, Clone)]
pub struct ReportSmt_proof<'a,V_tyreg_poly_term:'a> {
  pub logic: usize,
  pub unsat_core: &'a [V_tyreg_poly_term],
  pub expansions: &'a [&'a ReportExpansion<'a,V_tyreg_poly_term>],
  pub instantiations: &'a [&'a ReportInstantiation<'a,V_tyreg_poly_term>],
}


// clique Imandrax_api_report.Rtext.item
#[derive(Debug, Clone)]
pub enum ReportRtextItem<'a,V_tyreg_poly_term:'a> {
  S(&'a str),
  B(&'a str),
  I(&'a str),
  Newline,
  Sub(&'a [&'a ReportRtextItem<'a,V_tyreg_poly_term>]),
  L(&'a [&'a [&'a ReportRtextItem<'a,V_tyreg_poly_term>]]),
  Uid(&'a Uid<'a>),
  Term(V_tyreg_poly_term),
  Sequent(&'a Sequent_poly<'a,V_tyreg_poly_term>),
  Subst(&'a [(V_tyreg_poly_term,V_tyreg_poly_term)]),
}

// clique Imandrax_api_report.Atomic_event.poly
#[derive(Debug, Clone)]
pub enum ReportAtomic_eventPoly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_fn:'a,V_tyreg_poly_var:'a,V_tyreg_poly_ty:'a> {
  E_message(&'a [&'a ReportRtextItem<'a,V_tyreg_poly_term>]),
  E_title(&'a str),
  E_enter_waterfall {
    vars: &'a [V_tyreg_poly_var],
    goal: V_tyreg_poly_term,
    hints: &'a CirHintsInduct<'a>,
  },
  E_enter_tactic(&'a str),
  E_rw_success(&'a CirRewrite_rule<'a>,V_tyreg_poly_term,V_tyreg_poly_term),
  E_rw_fail(&'a CirRewrite_rule<'a>,V_tyreg_poly_term,&'a str),
  E_inst_success(&'a CirInstantiation_rule<'a>,V_tyreg_poly_term),
  E_waterfall_checkpoint(&'a [&'a Sequent_poly<'a,V_tyreg_poly_term>]),
  E_induction_scheme(V_tyreg_poly_term),
  E_attack_subgoal {
    name: &'a str,
    goal: &'a Sequent_poly<'a,V_tyreg_poly_term>,
    depth: BigInt,
  },
  E_simplify_t(V_tyreg_poly_term,V_tyreg_poly_term),
  E_simplify_clause(V_tyreg_poly_term,&'a [V_tyreg_poly_term]),
  E_proved_by_smt(V_tyreg_poly_term,&'a ReportSmt_proof<'a,V_tyreg_poly_term>),
  E_refuted_by_smt(V_tyreg_poly_term,Option<&'a Model<'a,V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty>>),
  E_fun_expansion(V_tyreg_poly_term,V_tyreg_poly_term),
}

// clique Imandrax_api_report.Event.t_linear
// immediate
#[derive(Debug, Clone)]
pub enum ReportEventT_linear<V_tyreg_poly_atomic_ev> {
  EL_atomic {
    ts: f64,
    ev: V_tyreg_poly_atomic_ev,
  },
  EL_enter_span {
    ts: f64,
    ev: V_tyreg_poly_atomic_ev,
  },
  EL_exit_span {
    ts: f64,
  },
}

// clique Imandrax_api_report.Event.t_tree
// immediate
#[derive(Debug, Clone)]
pub enum ReportEventT_tree<V_tyreg_poly_atomic_ev,V_tyreg_poly_sub> {
  ET_atomic {
    ts: f64,
    ev: V_tyreg_poly_atomic_ev,
  },
  ET_span {
    ts: f64,
    duration: f64,
    ev: V_tyreg_poly_atomic_ev,
    sub: V_tyreg_poly_sub,
  },
}

// clique Imandrax_api_report.Report.t
#[derive(Debug, Clone)]
pub struct ReportReport<'a> {
  pub events: &'a [&'a ReportEventT_linear<&'a ReportAtomic_eventPoly<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirType<'a>>>],
}


// clique Imandrax_api_proof.Arg.t
#[derive(Debug, Clone)]
pub enum ProofArg<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  A_term(V_tyreg_poly_term),
  A_ty(V_tyreg_poly_ty),
  A_int(BigInt),
  A_string(&'a str),
  A_list(&'a [&'a ProofArg<'a,V_tyreg_poly_term,V_tyreg_poly_ty>]),
  A_dict(&'a [(&'a str,&'a ProofArg<'a,V_tyreg_poly_term,V_tyreg_poly_ty>)]),
  A_seq(&'a Sequent_poly<'a,V_tyreg_poly_term>),
}

// clique Imandrax_api_proof.View.t
#[derive(Debug, Clone)]
pub enum ProofView<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a,V_tyreg_poly_proof:'a> {
  T_assume,
  T_subst {
    t_subst: &'a [((&'a Uid<'a>,V_tyreg_poly_ty),V_tyreg_poly_term)],
    ty_subst: &'a [(&'a Uid<'a>,V_tyreg_poly_ty)],
    premise: V_tyreg_poly_proof,
  },
  T_deduction {
    premises: &'a [(&'a str,&'a [V_tyreg_poly_proof])],
  },
  T_rule {
    rule: &'a str,
    args: &'a [&'a ProofArg<'a,V_tyreg_poly_term,V_tyreg_poly_ty>],
  },
}

// clique Imandrax_api_proof.Proof_term_poly.t
#[derive(Debug, Clone)]
pub struct ProofProof_term_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a,V_tyreg_poly_proof:'a> {
  pub id: BigInt,
  pub concl: &'a Sequent_poly<'a,V_tyreg_poly_term>,
  pub view: &'a ProofView<'a,V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof>,
}


// clique Imandrax_api_proof.Cir_proof_term.t
#[derive(Debug, Clone)]
pub struct ProofCir_proof_term<'a> {
  pub p: &'a ProofProof_term_poly<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirType<'a>,&'a ProofCir_proof_term<'a>>,
}


// clique Imandrax_api_tasks.PO_task.t
#[derive(Debug, Clone)]
pub struct TasksPO_task<'a> {
  pub from_sym: &'a str,
  pub count: BigInt,
  pub db: &'a CirDb_ser<'a>,
  pub po: &'a CirProof_obligation<'a>,
}


// clique Imandrax_api_tasks.PO_res.proof_found
#[derive(Debug, Clone)]
pub struct TasksPO_resProof_found<'a> {
  pub anchor: &'a Anchor<'a>,
  pub proof: &'a ProofCir_proof_term<'a>,
}


// clique Imandrax_api_tasks.PO_res.instance
#[derive(Debug, Clone)]
pub struct TasksPO_resInstance<'a> {
  pub anchor: &'a Anchor<'a>,
  pub model: &'a Model<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirType<'a>>,
}


// clique Imandrax_api_tasks.PO_res.no_proof
#[derive(Debug, Clone)]
pub struct TasksPO_resNo_proof<'a> {
  pub err: &'a ErrorError_core<'a>,
  pub counter_model: Option<&'a Model<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirType<'a>>>,
  pub subgoals: &'a [&'a Sequent_poly<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>>],
}


// clique Imandrax_api_tasks.PO_res.unsat
#[derive(Debug, Clone)]
pub struct TasksPO_resUnsat<'a> {
  pub anchor: &'a Anchor<'a>,
  pub err: &'a ErrorError_core<'a>,
  pub proof: &'a ProofCir_proof_term<'a>,
}


// clique Imandrax_api_tasks.PO_res.success
#[derive(Debug, Clone)]
pub enum TasksPO_resSuccess<'a> {
  Proof(&'a TasksPO_resProof_found<'a>),
  Instance(&'a TasksPO_resInstance<'a>),
}

// clique Imandrax_api_tasks.PO_res.error
#[derive(Debug, Clone)]
pub enum TasksPO_resError<'a> {
  No_proof(&'a TasksPO_resNo_proof<'a>),
  Unsat(&'a TasksPO_resUnsat<'a>),
  Invalid_model(&'a ErrorError_core<'a>,&'a Model<'a,&'a CirWith_ty<'a,&'a CirTermView<'a>>,&'a CirApplied_symbol<'a>,&'a CirWith_ty<'a,&'a Uid<'a>>,&'a CirType<'a>>),
  Error(&'a ErrorError_core<'a>),
}

// clique Imandrax_api_tasks.PO_res.t
#[derive(Debug, Clone)]
pub struct TasksPO_res<'a> {
  pub from_: &'a Ca_storeCa_ptrRaw<'a>,
  pub res: &'a core::result::Result<&'a TasksPO_resSuccess<'a>, &'a TasksPO_resError<'a>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}


// clique Imandrax_api_tasks.Eval_task.t
#[derive(Debug, Clone)]
pub struct TasksEval_task<'a> {
  pub db: &'a CirDb_ser<'a>,
  pub term: &'a CirWith_ty<'a,&'a CirTermView<'a>>,
  pub anchor: &'a Anchor<'a>,
  pub timeout: Option<BigInt>,
}


// clique Imandrax_api_tasks.Eval_res.stats
// immediate
#[derive(Debug, Clone)]
pub struct TasksEval_resStats {
  pub compile_time: f64,
  pub exec_time: f64,
}


// clique Imandrax_api_tasks.Eval_res.success
#[derive(Debug, Clone)]
pub struct TasksEval_resSuccess<'a> {
  pub v: &'a EvalValue<'a>,
}


// clique Imandrax_api_tasks.Eval_res.t
#[derive(Debug, Clone)]
pub struct TasksEval_res<'a> {
  pub res: &'a core::result::Result<&'a TasksEval_resSuccess<'a>,Error<'a>>,
  pub stats: TasksEval_resStats,
}


// clique Imandrax_api_tasks.Decomp_task.t
#[derive(Debug, Clone)]
pub struct TasksDecomp_task<'a> {
  pub db: &'a CirDb_ser<'a>,
  pub decomp: &'a CirDecomp<'a>,
  pub anchor: &'a Anchor<'a>,
}


// clique Imandrax_api_tasks.Decomp_res.success
#[derive(Debug, Clone)]
pub struct TasksDecomp_resSuccess<'a> {
  pub anchor: &'a Anchor<'a>,
  pub decomp: &'a CirFun_decomp<'a>,
}


// clique Imandrax_api_tasks.Decomp_res.error
#[derive(Debug, Clone)]
pub enum TasksDecomp_resError<'a> {
  Error(&'a ErrorError_core<'a>),
}

// clique Imandrax_api_tasks.Decomp_res.t
#[derive(Debug, Clone)]
pub struct TasksDecomp_res<'a> {
  pub from_: &'a Ca_storeCa_ptrRaw<'a>,
  pub res: &'a core::result::Result<&'a TasksDecomp_resSuccess<'a>, &'a TasksDecomp_resError<'a>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}

