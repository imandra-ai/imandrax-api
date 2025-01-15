
// automatically generated using genbindings.ml, do not edit

#![allow(non_camel_case_types)]

// do not format
#![cfg_attr(any(), rustfmt::skip)]


pub mod deser;
pub use deser::FromTwine;
pub mod utils;
use utils::*;

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

// clique Imandrax_api.Ty_view.def_poly
#[derive(Debug, Clone)]
pub struct Ty_viewDef_poly<'a,V_tyreg_poly_ty:'a> {
  pub name: &'a Uid<'a>,
  pub params: &'a [&'a Uid<'a>],
  pub decl: &'a Ty_viewDecl<'a,&'a Uid<'a>,V_tyreg_poly_ty,Void>,
  pub clique: Option<&'a UidSet<'a>>,
  pub timeout: Option<BigInt>,
}


// clique Imandrax_api.Stat_time.t
// immediate
#[derive(Debug, Clone)]
pub struct Stat_time {
  pub time_s: f64,
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

// clique Imandrax_api.Case_poly.t_poly
#[derive(Debug, Clone)]
pub struct Case_polyT_poly<'a,V_tyreg_poly_t:'a,V_tyreg_poly_var:'a,V_tyreg_poly_sym:'a> {
  pub case_cstor: V_tyreg_poly_sym,
  pub case_vars: &'a [V_tyreg_poly_var],
  pub case_rhs: V_tyreg_poly_t,
  pub case_labels: Option<&'a [&'a Uid<'a>]>,
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

// clique Imandrax_api_ca_store.Ca_ptr.Raw.t
#[derive(Debug, Clone)]
pub struct Ca_storeCa_ptrRaw<'a> {
  pub key: &'a Util_twine_With_tag7<'a,&'a str>,
}


// clique Imandrax_api_common.Var.t_poly
#[derive(Debug, Clone)]
pub struct CommonVarT_poly<'a,V_tyreg_poly_ty:'a> {
  pub id: &'a Uid<'a>,
  pub ty: V_tyreg_poly_ty,
}


// clique Imandrax_api_common.Type_schema.t_poly
#[derive(Debug, Clone)]
pub struct CommonType_schemaT_poly<'a,V_tyreg_poly_ty:'a> {
  pub params: &'a [&'a Uid<'a>],
  pub ty: V_tyreg_poly_ty,
}


// clique Imandrax_api_common.Typed_symbol.t_poly
#[derive(Debug, Clone)]
pub struct CommonTyped_symbolT_poly<'a,V_tyreg_poly_ty:'a> {
  pub id: &'a Uid<'a>,
  pub ty: &'a CommonType_schemaT_poly<'a,V_tyreg_poly_ty>,
}


// clique Imandrax_api_common.Applied_symbol.t_poly
#[derive(Debug, Clone)]
pub struct CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty:'a> {
  pub sym: &'a CommonTyped_symbolT_poly<'a,V_tyreg_poly_ty>,
  pub args: &'a [V_tyreg_poly_ty],
  pub ty: V_tyreg_poly_ty,
}


// clique Imandrax_api_common.Fo_pattern.view
#[derive(Debug, Clone)]
pub enum CommonFo_patternView<'a,V_tyreg_poly_t:'a,V_tyreg_poly_ty:'a> {
  FO_any,
  FO_bool(bool),
  FO_const(&'a Const<'a>),
  FO_var(&'a CommonVarT_poly<'a,V_tyreg_poly_ty>),
  FO_app(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,&'a [V_tyreg_poly_t]),
  FO_cstor(Option<&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>>,&'a [V_tyreg_poly_t]),
  FO_destruct {
    c: Option<&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>>,
    i: BigInt,
    u: V_tyreg_poly_t,
  },
  FO_is_a {
    c: &'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,
    u: V_tyreg_poly_t,
  },
}

// clique Imandrax_api_common.Fo_pattern.t_poly
#[derive(Debug, Clone)]
pub struct CommonFo_patternT_poly<'a,V_tyreg_poly_ty:'a> {
  pub view: &'a CommonFo_patternView<'a,&'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>,V_tyreg_poly_ty>,
  pub ty: V_tyreg_poly_ty,
}


// clique Imandrax_api_common.Pattern_head.t_poly
#[derive(Debug, Clone)]
pub enum CommonPattern_headT_poly<'a,V_tyreg_poly_ty:'a> {
  PH_id(&'a Uid<'a>),
  PH_ty(V_tyreg_poly_ty),
  PH_datatype_op,
}

// clique Imandrax_api_common.Trigger.t_poly
#[derive(Debug, Clone)]
pub struct CommonTriggerT_poly<'a,V_tyreg_poly_ty:'a> {
  pub trigger_head: &'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,
  pub trigger_patterns: &'a [&'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>],
  pub trigger_instantiation_rule_name: &'a Uid<'a>,
}


// clique Imandrax_api_common.Admission.t
#[derive(Debug, Clone)]
pub struct CommonAdmission<'a> {
  pub measured_subset: &'a [&'a str],
  pub measure_fun: Option<&'a Uid<'a>>,
}


// clique Imandrax_api_common.Hints.validation_strategy
#[derive(Debug, Clone)]
pub enum CommonHintsValidation_strategy<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  VS_validate {
    tactic: Option<(&'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],V_tyreg_poly_term)>,
  },
  VS_no_validate,
}

// clique Imandrax_api_common.Hints.t_poly
#[derive(Debug, Clone)]
pub struct CommonHintsT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub f_validate_strat: &'a CommonHintsValidation_strategy<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub f_unroll_def: Option<BigInt>,
  pub f_enable: &'a [&'a Uid<'a>],
  pub f_disable: &'a [&'a Uid<'a>],
  pub f_timeout: Option<BigInt>,
  pub f_admission: Option<&'a CommonAdmission<'a>>,
}


// clique Imandrax_api_common.Fun_def.fun_kind
#[derive(Debug, Clone)]
pub enum CommonFun_defFun_kind<'a> {
  Fun_defined {
    is_macro: bool,
    from_lambda: bool,
  },
  Fun_builtin(&'a BuiltinFun<'a>),
  Fun_opaque,
}

// clique Imandrax_api_common.Fun_def.t_poly
#[derive(Debug, Clone)]
pub struct CommonFun_defT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub f_name: &'a Uid<'a>,
  pub f_ty: &'a CommonType_schemaT_poly<'a,V_tyreg_poly_ty>,
  pub f_args: &'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],
  pub f_body: V_tyreg_poly_term,
  pub f_clique: Option<&'a UidSet<'a>>,
  pub f_kind: &'a CommonFun_defFun_kind<'a>,
  pub f_hints: &'a CommonHintsT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_common.Theorem.t_poly
#[derive(Debug, Clone)]
pub struct CommonTheoremT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub thm_link: &'a CommonFun_defT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub thm_rewriting: bool,
  pub thm_perm_restrict: bool,
  pub thm_fc: bool,
  pub thm_elim: bool,
  pub thm_gen: bool,
  pub thm_triggers: &'a [(V_tyreg_poly_term,As_trigger)],
  pub thm_is_axiom: bool,
  pub thm_by: (&'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],V_tyreg_poly_term),
}


// clique Imandrax_api_common.Tactic.t_poly
#[derive(Debug, Clone)]
pub enum CommonTacticT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  Default_termination {
    basis: &'a UidSet<'a>,
  },
  Default_thm,
  Term((&'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],V_tyreg_poly_term)),
}

// clique Imandrax_api_common.Sequent.t_poly
#[derive(Debug, Clone)]
pub struct CommonSequentT_poly<'a,V_tyreg_poly_term:'a> {
  pub hyps: &'a [V_tyreg_poly_term],
  pub concls: &'a [V_tyreg_poly_term],
}


// clique Imandrax_api_common.Rewrite_rule.t_poly
#[derive(Debug, Clone)]
pub struct CommonRewrite_ruleT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub rw_name: &'a Uid<'a>,
  pub rw_head: &'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,
  pub rw_lhs: &'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>,
  pub rw_rhs: V_tyreg_poly_term,
  pub rw_guard: &'a [V_tyreg_poly_term],
  pub rw_vars: &'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],
  pub rw_triggers: &'a [&'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>],
  pub rw_perm_restrict: bool,
  pub rw_loop_break: Option<&'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>>,
}


// clique Imandrax_api_common.Model.ty_def
#[derive(Debug, Clone)]
pub enum CommonModelTy_def<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  Ty_finite(&'a [V_tyreg_poly_term]),
  Ty_alias_unit(V_tyreg_poly_ty),
}

// clique Imandrax_api_common.Model.fi
#[derive(Debug, Clone)]
pub struct CommonModelFi<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub fi_args: &'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],
  pub fi_ty_ret: V_tyreg_poly_ty,
  pub fi_cases: &'a [(&'a [V_tyreg_poly_term],V_tyreg_poly_term)],
  pub fi_else: V_tyreg_poly_term,
}


// clique Imandrax_api_common.Model.t_poly
#[derive(Debug, Clone)]
pub struct CommonModelT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub tys: &'a [(V_tyreg_poly_ty,&'a CommonModelTy_def<'a,V_tyreg_poly_term,V_tyreg_poly_ty>)],
  pub consts: &'a [(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,V_tyreg_poly_term)],
  pub funs: &'a [(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,&'a CommonModelFi<'a,V_tyreg_poly_term,V_tyreg_poly_ty>)],
  pub representable: bool,
  pub completed: bool,
  pub ty_subst: &'a [(&'a Uid<'a>,V_tyreg_poly_ty)],
}


// clique Imandrax_api_common.Region.status
#[derive(Debug, Clone)]
pub enum CommonRegionStatus<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  Unknown,
  Feasible(&'a CommonModelT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
}

// clique Imandrax_api_common.Region.t_poly
#[derive(Debug, Clone)]
pub struct CommonRegionT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub constraints: &'a [V_tyreg_poly_term],
  pub invariant: V_tyreg_poly_term,
  pub status: &'a CommonRegionStatus<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_common.Proof_obligation.t_poly
#[derive(Debug, Clone)]
pub struct CommonProof_obligationT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub descr: &'a str,
  pub goal: (&'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],V_tyreg_poly_term),
  pub tactic: &'a CommonTacticT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub is_instance: bool,
  pub anchor: &'a Anchor<'a>,
  pub timeout: Option<BigInt>,
}


// clique Imandrax_api_common.Instantiation_rule_kind.t
// immediate
#[derive(Debug, Clone)]
pub enum CommonInstantiation_rule_kind {
  IR_forward_chaining,
  IR_generalization,
}

// clique Imandrax_api_common.Instantiation_rule.t_poly
#[derive(Debug, Clone)]
pub struct CommonInstantiation_ruleT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub ir_from: &'a CommonFun_defT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub ir_triggers: &'a [&'a CommonTriggerT_poly<'a,V_tyreg_poly_ty>],
  pub ir_kind: CommonInstantiation_rule_kind,
}


// clique Imandrax_api_common.Fun_decomp.t_poly
#[derive(Debug, Clone)]
pub struct CommonFun_decompT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub f_id: &'a Uid<'a>,
  pub f_args: &'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],
  pub regions: &'a [&'a CommonRegionT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>],
}


// clique Imandrax_api_common.Elimination_rule.t_poly
#[derive(Debug, Clone)]
pub struct CommonElimination_ruleT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub er_name: &'a Uid<'a>,
  pub er_guard: &'a [V_tyreg_poly_term],
  pub er_lhs: V_tyreg_poly_term,
  pub er_rhs: &'a CommonVarT_poly<'a,V_tyreg_poly_ty>,
  pub er_dests: &'a [&'a CommonFo_patternT_poly<'a,V_tyreg_poly_ty>],
  pub er_dest_tms: &'a [V_tyreg_poly_term],
}


// clique Imandrax_api_common.Decomp.lift_bool
// immediate
#[derive(Debug, Clone)]
pub enum CommonDecompLift_bool {
  Default,
  Nested_equalities,
  Equalities,
  All,
}

// clique Imandrax_api_common.Decomp.t
#[derive(Debug, Clone)]
pub struct CommonDecomp<'a> {
  pub f_id: &'a Uid<'a>,
  pub assuming: Option<&'a Uid<'a>>,
  pub basis: &'a UidSet<'a>,
  pub rule_specs: &'a UidSet<'a>,
  pub ctx_simp: bool,
  pub lift_bool: CommonDecompLift_bool,
  pub prune: bool,
}


// clique Imandrax_api_common.Db_ser.t_poly
#[derive(Debug, Clone)]
pub struct CommonDb_serT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub decls: &'a UidSet<'a>,
  pub rw_rules: &'a [(&'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub inst_rules: &'a [(&'a Uid<'a>,&'a Ca_storeCa_ptrRaw<'a>)],
  pub rule_spec_fc: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub rule_spec_rw_rules: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub fc: &'a [(&'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub elim: &'a [(&'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub gen: &'a [(&'a CommonPattern_headT_poly<'a,V_tyreg_poly_ty>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_rw: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_fc: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_elim: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub thm_as_gen: &'a [(&'a Uid<'a>,&'a [&'a Ca_storeCa_ptrRaw<'a>])],
  pub admission: &'a [(&'a Uid<'a>,&'a Ca_storeCa_ptrRaw<'a>)],
  pub count_funs_of_ty: &'a [(&'a Uid<'a>,&'a Uid<'a>)],
  pub disabled: &'a UidSet<'a>,
}


// clique Imandrax_api_mir.Type.t
#[derive(Debug, Clone)]
pub struct MirType<'a> {
  pub view: &'a Ty_viewView<'a,(),&'a Uid<'a>,&'a MirType<'a>>,
}


// clique Imandrax_api_mir.Type.ser
#[derive(Debug, Clone)]
pub struct MirTypeSer<'a> {
  pub view: &'a Ty_viewView<'a,(),&'a Uid<'a>,&'a MirType<'a>>,
}


// clique Imandrax_api_mir.Term.view
#[derive(Debug, Clone)]
pub enum MirTermView<'a,V_tyreg_poly_t:'a,V_tyreg_poly_ty:'a> {
  Const(&'a Const<'a>),
  If(V_tyreg_poly_t,V_tyreg_poly_t,V_tyreg_poly_t),
  Apply {
    f: V_tyreg_poly_t,
    l: &'a [V_tyreg_poly_t],
  },
  Var(&'a CommonVarT_poly<'a,V_tyreg_poly_ty>),
  Sym(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>),
  Construct {
    c: &'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,
    args: &'a [V_tyreg_poly_t],
  },
  Destruct {
    c: &'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,
    i: BigInt,
    t: V_tyreg_poly_t,
  },
  Is_a {
    c: &'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,
    t: V_tyreg_poly_t,
  },
  Tuple {
    l: &'a [V_tyreg_poly_t],
  },
  Field {
    f: &'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,
    t: V_tyreg_poly_t,
  },
  Tuple_field {
    i: BigInt,
    t: V_tyreg_poly_t,
  },
  Record {
    rows: &'a [(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,V_tyreg_poly_t)],
    rest: Option<V_tyreg_poly_t>,
  },
  Case {
    u: V_tyreg_poly_t,
    cases: &'a [(&'a CommonApplied_symbolT_poly<'a,V_tyreg_poly_ty>,V_tyreg_poly_t)],
    default: Option<V_tyreg_poly_t>,
  },
}

// clique Imandrax_api_mir.Term.t
#[derive(Debug, Clone)]
pub struct MirTerm<'a> {
  pub view: &'a MirTermView<'a,&'a MirTerm<'a>,&'a MirType<'a>>,
  pub ty: &'a MirType<'a>,
}


// clique Imandrax_api_mir.Term.ser
#[derive(Debug, Clone)]
pub struct MirTermSer<'a> {
  pub view: &'a MirTermView<'a,&'a MirTerm<'a>,&'a MirType<'a>>,
  pub ty: &'a MirType<'a>,
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
  V_quoted_term((&'a [&'a CommonVarT_poly<'a,&'a MirType<'a>>],&'a MirTerm<'a>)),
  V_uid(&'a Uid<'a>),
  V_closure(V_tyreg_poly_closure),
  V_custom(Ignored /* custom value */),
  V_ordinal(&'a EvalOrdinal<'a>),
}

// clique Imandrax_api_eval.Value.erased_closure
// immediate
#[derive(Debug, Clone)]
pub struct EvalValueErased_closure {
  pub missing: BigInt,
}


// clique Imandrax_api_eval.Value.t
#[derive(Debug, Clone)]
pub struct EvalValue<'a> {
  pub v: &'a EvalValueView<'a,&'a EvalValue<'a>,EvalValueErased_closure>,
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
  Sequent(&'a CommonSequentT_poly<'a,V_tyreg_poly_term>),
  Subst(&'a [(V_tyreg_poly_term,V_tyreg_poly_term)]),
}

// clique Imandrax_api_report.Atomic_event.poly
#[derive(Debug, Clone)]
pub enum ReportAtomic_eventPoly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a,V_tyreg_poly_term2:'a,V_tyreg_poly_ty2:'a> {
  E_message(&'a [&'a ReportRtextItem<'a,V_tyreg_poly_term>]),
  E_title(&'a str),
  E_enter_waterfall {
    vars: &'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],
    goal: V_tyreg_poly_term,
  },
  E_enter_tactic(&'a str),
  E_rw_success(&'a CommonRewrite_ruleT_poly<'a,V_tyreg_poly_term2,V_tyreg_poly_ty2>,V_tyreg_poly_term,V_tyreg_poly_term),
  E_rw_fail(&'a CommonRewrite_ruleT_poly<'a,V_tyreg_poly_term2,V_tyreg_poly_ty2>,V_tyreg_poly_term,&'a str),
  E_inst_success(&'a CommonInstantiation_ruleT_poly<'a,V_tyreg_poly_term2,V_tyreg_poly_ty2>,V_tyreg_poly_term),
  E_waterfall_checkpoint(&'a [&'a CommonSequentT_poly<'a,V_tyreg_poly_term>]),
  E_induction_scheme(V_tyreg_poly_term),
  E_attack_subgoal {
    name: &'a str,
    goal: &'a CommonSequentT_poly<'a,V_tyreg_poly_term>,
    depth: BigInt,
  },
  E_simplify_t(V_tyreg_poly_term,V_tyreg_poly_term),
  E_simplify_clause(V_tyreg_poly_term,&'a [V_tyreg_poly_term]),
  E_proved_by_smt(V_tyreg_poly_term,&'a ReportSmt_proof<'a,V_tyreg_poly_term>),
  E_refuted_by_smt(V_tyreg_poly_term,Option<&'a CommonModelT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>>),
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
  pub events: &'a [&'a ReportEventT_linear<&'a ReportAtomic_eventPoly<'a,&'a MirTerm<'a>,&'a MirType<'a>,&'a MirTerm<'a>,&'a MirType<'a>>>],
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
  A_seq(&'a CommonSequentT_poly<'a,V_tyreg_poly_term>),
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

// clique Imandrax_api_proof.Proof_term.t_poly
#[derive(Debug, Clone)]
pub struct ProofProof_termT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub id: BigInt,
  pub concl: &'a CommonSequentT_poly<'a,V_tyreg_poly_term>,
  pub view: &'a ProofView<'a,V_tyreg_poly_term,V_tyreg_poly_ty,&'a ProofProof_termT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>>,
}


// clique Imandrax_api_tasks.PO_task.t_poly
#[derive(Debug, Clone)]
pub struct TasksPO_taskT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub from_sym: &'a str,
  pub count: BigInt,
  pub db: &'a CommonDb_serT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub po: &'a CommonProof_obligationT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_tasks.PO_res.proof_found
#[derive(Debug, Clone)]
pub struct TasksPO_resProof_found<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub anchor: &'a Anchor<'a>,
  pub proof: &'a ProofProof_termT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_tasks.PO_res.instance
#[derive(Debug, Clone)]
pub struct TasksPO_resInstance<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub anchor: &'a Anchor<'a>,
  pub model: &'a CommonModelT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_tasks.PO_res.no_proof
#[derive(Debug, Clone)]
pub struct TasksPO_resNo_proof<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub err: &'a ErrorError_core<'a>,
  pub counter_model: Option<&'a CommonModelT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>>,
  pub subgoals: &'a [&'a CommonSequentT_poly<'a,&'a MirTerm<'a>>],
}


// clique Imandrax_api_tasks.PO_res.unsat
#[derive(Debug, Clone)]
pub struct TasksPO_resUnsat<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub anchor: &'a Anchor<'a>,
  pub err: &'a ErrorError_core<'a>,
  pub proof: &'a ProofProof_termT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_tasks.PO_res.success
#[derive(Debug, Clone)]
pub enum TasksPO_resSuccess<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  Proof(&'a TasksPO_resProof_found<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
  Instance(&'a TasksPO_resInstance<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
}

// clique Imandrax_api_tasks.PO_res.error
#[derive(Debug, Clone)]
pub enum TasksPO_resError<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  No_proof(&'a TasksPO_resNo_proof<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
  Unsat(&'a TasksPO_resUnsat<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
  Invalid_model(&'a ErrorError_core<'a>,&'a CommonModelT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>),
  Error(&'a ErrorError_core<'a>),
}

// clique Imandrax_api_tasks.PO_res.shallow_poly
#[derive(Debug, Clone)]
pub struct TasksPO_resShallow_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub from_: &'a Ca_storeCa_ptrRaw<'a>,
  pub res: &'a core::result::Result<&'a TasksPO_resSuccess<'a,V_tyreg_poly_term,V_tyreg_poly_ty>, &'a TasksPO_resError<'a,V_tyreg_poly_term,V_tyreg_poly_ty>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}


// clique Imandrax_api_tasks.PO_res.full_poly
#[derive(Debug, Clone)]
pub struct TasksPO_resFull_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub from_: &'a CommonProof_obligationT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub res: &'a core::result::Result<&'a TasksPO_resSuccess<'a,V_tyreg_poly_term,V_tyreg_poly_ty>, &'a TasksPO_resError<'a,V_tyreg_poly_term,V_tyreg_poly_ty>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}


// clique Imandrax_api_tasks.Eval_task.t_poly
#[derive(Debug, Clone)]
pub struct TasksEval_taskT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub db: &'a CommonDb_serT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub term: (&'a [&'a CommonVarT_poly<'a,V_tyreg_poly_ty>],V_tyreg_poly_term),
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


// clique Imandrax_api_tasks.Decomp_task.t_poly
#[derive(Debug, Clone)]
pub struct TasksDecomp_taskT_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub db: &'a CommonDb_serT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
  pub decomp: &'a CommonDecomp<'a>,
  pub anchor: &'a Anchor<'a>,
}


// clique Imandrax_api_tasks.Decomp_res.success
#[derive(Debug, Clone)]
pub struct TasksDecomp_resSuccess<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub anchor: &'a Anchor<'a>,
  pub decomp: &'a CommonFun_decompT_poly<'a,V_tyreg_poly_term,V_tyreg_poly_ty>,
}


// clique Imandrax_api_tasks.Decomp_res.error
#[derive(Debug, Clone)]
pub enum TasksDecomp_resError<'a> {
  Error(&'a ErrorError_core<'a>),
}

// clique Imandrax_api_tasks.Decomp_res.shallow_poly
#[derive(Debug, Clone)]
pub struct TasksDecomp_resShallow_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub from_: &'a Ca_storeCa_ptrRaw<'a>,
  pub res: &'a core::result::Result<&'a TasksDecomp_resSuccess<'a,V_tyreg_poly_term,V_tyreg_poly_ty>, &'a TasksDecomp_resError<'a>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}


// clique Imandrax_api_tasks.Decomp_res.full_poly
#[derive(Debug, Clone)]
pub struct TasksDecomp_resFull_poly<'a,V_tyreg_poly_term:'a,V_tyreg_poly_ty:'a> {
  pub from_: &'a CommonDecomp<'a>,
  pub res: &'a core::result::Result<&'a TasksDecomp_resSuccess<'a,V_tyreg_poly_term,V_tyreg_poly_ty>, &'a TasksDecomp_resError<'a>>,
  pub stats: Stat_time,
  pub report: &'a In_mem_archiveRaw<'a>,
}

