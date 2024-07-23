// automatically generated using genbindings.ml, do not edit

#![allow(non_camel_case_types)]

use anyhow::bail;
use num_bigint::BigInt;
use std::collections::HashSet;

// TODO: pub trait FromTwine { … }

// data we ignore upon deserialization.
#[derive(Clone, Copy, Debug)]
pub struct Ignored;

pub type Error = ErrorError_core;

// clique Imandrakit_error.Kind.t
// def Imandrakit_error.Kind.t (mangled name: "ErrorKind")
#[derive(Debug, Clone)]
pub struct ErrorKind {
    pub name: String,
}

// clique Imandrakit_error.Error_core.message
// def Imandrakit_error.Error_core.message (mangled name: "ErrorError_coreMessage")
#[derive(Debug, Clone)]
pub struct ErrorError_coreMessage {
    pub msg: String,
    pub data: Ignored, /* data */
    pub bt: Option<String>,
}

// clique Imandrakit_error.Error_core.stack
// def Imandrakit_error.Error_core.stack (mangled name: "ErrorError_coreStack")
pub type ErrorError_coreStack = Vec<ErrorError_coreMessage>;

// clique Imandrakit_error.Error_core.t
// def Imandrakit_error.Error_core.t (mangled name: "ErrorError_core")
#[derive(Debug, Clone)]
pub struct ErrorError_core {
    pub process: String,
    pub kind: ErrorKind,
    pub msg: ErrorError_coreMessage,
    pub stack: ErrorError_coreStack,
}

// clique Imandrax_api.Util_twine_.as_pair
// def Imandrax_api.Util_twine_.as_pair (mangled name: "Util_twine_As_pair")
#[derive(Debug, Clone)]
pub struct Util_twine_As_pair {
    pub num: BigInt,
    pub denum: BigInt,
}

// clique Imandrax_api.Builtin_data.kind
// def Imandrax_api.Builtin_data.kind (mangled name: "Builtin_dataKind")
#[derive(Debug, Clone)]
pub enum Builtin_dataKind {
    Logic_core { logic_core_name: String },
    Special { tag: String },
    Tactic { tac_name: String },
}

// clique Imandrax_api.Chash.t
// def Imandrax_api.Chash.t (mangled name: "Chash")
#[derive(Debug, Clone)]
pub struct Chash(pub Vec<u8>);

//fn Chash_of_twine(d, off: usize) -> Chash {
//    d.get_bytes(off)
//}

// clique Imandrax_api.Cname.t
// def Imandrax_api.Cname.t (mangled name: "Cname")
#[derive(Debug, Clone)]
pub struct Cname {
    pub name: String,
    pub chash: Chash,
}

// clique Imandrax_api.Uid.gen_kind
// def Imandrax_api.Uid.gen_kind (mangled name: "UidGen_kind")
#[derive(Debug, Clone)]
pub enum UidGen_kind {
    Local,
    To_be_rewritten,
}

// clique Imandrax_api.Uid.view
// def Imandrax_api.Uid.view (mangled name: "UidView")
#[derive(Debug, Clone)]
pub enum UidView {
    Generative { id: BigInt, gen_kind: UidGen_kind },
    Persistent,
    Cname { cname: Cname },
    Builtin { kind: Builtin_dataKind },
}

// clique Imandrax_api.Uid.t
// def Imandrax_api.Uid.t (mangled name: "Uid")
#[derive(Debug, Clone)]
pub struct Uid {
    pub name: String,
    pub view: UidView,
}

// clique Imandrax_api.Uid_set.t
// def Imandrax_api.Uid_set.t (mangled name: "Uid_set")
pub type Uid_set = HashSet<Uid>;

// def Uid_set_of_twine(d, off:int) -> Uid_set:
//      return set(Uid_of_twine(d,off=x) for x in d.get_array(off=off))

// clique Imandrax_api.Builtin.Fun.t
// def Imandrax_api.Builtin.Fun.t (mangled name: "BuiltinFun")
#[derive(Debug, Clone)]
pub struct BuiltinFun {
    pub id: Uid,
    pub kind: Builtin_dataKind,
    pub lassoc: bool,
    pub commutative: bool,
    pub connective: bool,
}

// clique Imandrax_api.Builtin.Ty.t
// def Imandrax_api.Builtin.Ty.t (mangled name: "BuiltinTy")
#[derive(Debug, Clone)]
pub struct BuiltinTy {
    pub id: Uid,
    pub kind: Builtin_dataKind,
}

// clique Imandrax_api.Ty_view.adt_row
// def Imandrax_api.Ty_view.adt_row (mangled name: "Ty_viewAdt_row")
#[derive(Debug, Clone)]
pub struct Ty_viewAdt_row<V_tyreg_poly_id, V_tyreg_poly_t> {
    pub c: V_tyreg_poly_id,
    pub labels: Option<Vec<V_tyreg_poly_id>>,
    pub args: Vec<V_tyreg_poly_t>,
    pub doc: Option<String>,
}

// clique Imandrax_api.Ty_view.rec_row
// def Imandrax_api.Ty_view.rec_row (mangled name: "Ty_viewRec_row")
#[derive(Debug, Clone)]
pub struct Ty_viewRec_row<V_tyreg_poly_id, V_tyreg_poly_t> {
    pub f: V_tyreg_poly_id,
    pub ty: V_tyreg_poly_t,
    pub doc: Option<String>,
}

// clique Imandrax_api.Ty_view.decl
// def Imandrax_api.Ty_view.decl (mangled name: "Ty_viewDecl")
#[derive(Debug, Clone)]
pub enum Ty_viewDecl<V_tyreg_poly_id, V_tyreg_poly_t, V_tyreg_poly_alias> {
    Algebraic(Vec<Ty_viewAdt_row<V_tyreg_poly_id, V_tyreg_poly_t>>),
    Record(Vec<Ty_viewRec_row<V_tyreg_poly_id, V_tyreg_poly_t>>),
    Alias {
        target: V_tyreg_poly_alias,
        reexport_def: Option<Ty_viewDecl<V_tyreg_poly_id, V_tyreg_poly_t, V_tyreg_poly_alias>>,
    },
    Skolem,
    Builtin(BuiltinTy),
    Other,
}

// clique Imandrax_api.Ty_view.view
// def Imandrax_api.Ty_view.view (mangled name: "Ty_viewView")
#[derive(Debug, Clone)]
pub enum Ty_viewView<V_tyreg_poly_lbl, V_tyreg_poly_var, V_tyreg_poly_t> {
    Var(V_tyreg_poly_var),
    Arrow(V_tyreg_poly_lbl, V_tyreg_poly_t, V_tyreg_poly_t),
    Tuple(Vec<V_tyreg_poly_t>),
    Constr(Uid, Vec<V_tyreg_poly_t>),
}

// clique Imandrax_api.Stat_time.t
// def Imandrax_api.Stat_time.t (mangled name: "Stat_time")
#[derive(Debug, Clone)]
pub struct Stat_time {
    pub time_s: f64,
}

// clique Imandrax_api.Sequent_poly.t
// def Imandrax_api.Sequent_poly.t (mangled name: "Sequent_poly")
#[derive(Debug, Clone)]
pub struct Sequent_poly<V_tyreg_poly_term> {
    pub hyps: Vec<V_tyreg_poly_term>,
    pub concls: Vec<V_tyreg_poly_term>,
}

// clique Imandrax_api.Misc_types.rec_flag
// def Imandrax_api.Misc_types.rec_flag (mangled name: "Misc_typesRec_flag")
#[derive(Debug, Clone)]
pub enum Misc_typesRec_flag {
    Recursive,
    Nonrecursive,
}

// clique Imandrax_api.Misc_types.apply_label
// def Imandrax_api.Misc_types.apply_label (mangled name: "Misc_typesApply_label")
#[derive(Debug, Clone)]
pub enum Misc_typesApply_label {
    Nolabel,
    Label(String),
    Optional(String),
}

// clique Imandrax_api.Logic_fragment.t
// def Imandrax_api.Logic_fragment.t (mangled name: "Logic_fragment")
pub type Logic_fragment = usize;

// clique Imandrax_api.In_mem_archive.raw
// def Imandrax_api.In_mem_archive.raw (mangled name: "In_mem_archiveRaw")
#[derive(Debug, Clone)]
pub struct In_mem_archiveRaw {
    pub ty: String,
    pub compressed: bool,
    pub data: String,
}

// clique Imandrax_api.In_mem_archive.t
// def Imandrax_api.In_mem_archive.t (mangled name: "In_mem_archive")
pub type In_mem_archive<V_tyreg_poly_a> = In_mem_archiveRaw;

// clique Imandrax_api.Const.t
// def Imandrax_api.Const.t (mangled name: "Const")
#[derive(Debug, Clone)]
pub enum Const {
    Const_float(f64),
    Const_string(String),
    Const_z(BigInt),
    Const_q(Vec<u8>),
    Const_real_approx(String),
    Const_uid(Uid),
    Const_bool(bool),
}

// clique Imandrax_api.As_trigger.t
// def Imandrax_api.As_trigger.t (mangled name: "As_trigger")
#[derive(Debug, Clone)]
pub enum As_trigger {
    Trig_none,
    Trig_anon,
    Trig_named(BigInt),
    Trig_rw,
}

// clique Imandrax_api.Anchor.t
// def Imandrax_api.Anchor.t (mangled name: "Anchor")
#[derive(Debug, Clone)]
pub enum Anchor {
    Named(Cname),
    Eval(BigInt),
    Proof_check(Anchor),
}

// clique Imandrax_api.Admission.t
// def Imandrax_api.Admission.t (mangled name: "Admission")
#[derive(Debug, Clone)]
pub struct Admission {
    pub measured_subset: Vec<String>,
    pub measure_fun: Option<Uid>,
}

// clique Imandrax_api_model.ty_def
// def Imandrax_api_model.ty_def (mangled name: "ModelTy_def")
#[derive(Debug, Clone)]
pub enum ModelTy_def<V_tyreg_poly_term, V_tyreg_poly_ty> {
    Ty_finite(Vec<V_tyreg_poly_term>),
    Ty_alias_unit(V_tyreg_poly_ty),
}

// clique Imandrax_api_model.fi
// def Imandrax_api_model.fi (mangled name: "ModelFi")
#[derive(Debug, Clone)]
pub struct ModelFi<V_tyreg_poly_term, V_tyreg_poly_var, V_tyreg_poly_ty> {
    pub fi_args: Vec<V_tyreg_poly_var>,
    pub fi_ty_ret: V_tyreg_poly_ty,
    pub fi_cases: Vec<(Vec<V_tyreg_poly_term>, V_tyreg_poly_term)>,
    pub fi_else: V_tyreg_poly_term,
}

// clique Imandrax_api_model.t
// def Imandrax_api_model.t (mangled name: "Model")
#[derive(Debug, Clone)]
pub struct Model<V_tyreg_poly_term, V_tyreg_poly_fn, V_tyreg_poly_var, V_tyreg_poly_ty> {
    pub tys: Vec<(
        V_tyreg_poly_ty,
        ModelTy_def<V_tyreg_poly_term, V_tyreg_poly_ty>,
    )>,
    pub consts: Vec<(V_tyreg_poly_fn, V_tyreg_poly_term)>,
    pub funs: Vec<(
        V_tyreg_poly_fn,
        ModelFi<V_tyreg_poly_term, V_tyreg_poly_var, V_tyreg_poly_ty>,
    )>,
    pub representable: bool,
    pub completed: bool,
    pub ty_subst: Vec<(Uid, V_tyreg_poly_ty)>,
}

// clique Imandrax_api_ca_store.Key.t
// def Imandrax_api_ca_store.Key.t (mangled name: "Ca_storeKey")
pub type Ca_storeKey = String;

// clique Imandrax_api_ca_store.Ca_ptr.Raw.t
// def Imandrax_api_ca_store.Ca_ptr.Raw.t (mangled name: "Ca_storeCa_ptrRaw")
#[derive(Debug, Clone)]
pub struct Ca_storeCa_ptrRaw {
    pub key: Ca_storeKey,
}

// clique Imandrax_api_ca_store.Ca_ptr.t
// def Imandrax_api_ca_store.Ca_ptr.t (mangled name: "Ca_storeCa_ptr")
pub type Ca_storeCa_ptr<V_tyreg_poly_a> = Ca_storeCa_ptrRaw;

// clique Imandrax_api_cir.Type.var
// def Imandrax_api_cir.Type.var (mangled name: "CirTypeVar")
pub type CirTypeVar = Uid;

// clique Imandrax_api_cir.Type.clique
// def Imandrax_api_cir.Type.clique (mangled name: "CirTypeClique")
pub type CirTypeClique = Uid_set;

// clique Imandrax_api_cir.Type.t
// def Imandrax_api_cir.Type.t (mangled name: "CirType")
#[derive(Debug, Clone)]
pub struct CirType {
    pub view: Ty_viewView<(), CirTypeVar, CirType>,
}

// clique Imandrax_api_cir.Type.def
// def Imandrax_api_cir.Type.def (mangled name: "CirTypeDef")
#[derive(Debug, Clone)]
pub struct CirTypeDef {
    pub name: Uid,
    pub params: Vec<CirTypeVar>,
    pub decl: Ty_viewDecl<Uid, CirType, Void>,
    pub clique: Option<CirTypeClique>,
    pub timeout: Option<BigInt>,
}

// clique Imandrax_api_cir.With_ty.t
// def Imandrax_api_cir.With_ty.t (mangled name: "CirWith_ty")
#[derive(Debug, Clone)]
pub struct CirWith_ty<V_tyreg_poly_a> {
    pub view: V_tyreg_poly_a,
    pub ty: CirType,
}

// clique Imandrax_api_cir.Var.t
// def Imandrax_api_cir.Var.t (mangled name: "CirVar")
pub type CirVar = CirWith_ty<Uid>;

// clique Imandrax_api_cir.Type_schema.t
// def Imandrax_api_cir.Type_schema.t (mangled name: "CirType_schema")
#[derive(Debug, Clone)]
pub struct CirType_schema {
    pub params: Vec<CirTypeVar>,
    pub ty: CirType,
}

// clique Imandrax_api_cir.Typed_symbol.t
// def Imandrax_api_cir.Typed_symbol.t (mangled name: "CirTyped_symbol")
#[derive(Debug, Clone)]
pub struct CirTyped_symbol {
    pub id: Uid,
    pub ty: CirType_schema,
}

// clique Imandrax_api_cir.Applied_symbol.t
// def Imandrax_api_cir.Applied_symbol.t (mangled name: "CirApplied_symbol")
#[derive(Debug, Clone)]
pub struct CirApplied_symbol {
    pub sym: CirTyped_symbol,
    pub args: Vec<CirType>,
    pub ty: CirType,
}

// clique Imandrax_api_cir.Fo_pattern.view
// def Imandrax_api_cir.Fo_pattern.view (mangled name: "CirFo_patternView")
#[derive(Debug, Clone)]
pub enum CirFo_patternView<V_tyreg_poly_t> {
    FO_any,
    FO_bool(bool),
    FO_const(Const),
    FO_var(CirVar),
    FO_app(CirApplied_symbol, Vec<V_tyreg_poly_t>),
    FO_cstor(Option<CirApplied_symbol>, Vec<V_tyreg_poly_t>),
    FO_destruct {
        c: Option<CirApplied_symbol>,
        i: BigInt,
        u: V_tyreg_poly_t,
    },
    FO_is_a {
        c: CirApplied_symbol,
        u: V_tyreg_poly_t,
    },
}

// clique Imandrax_api_cir.Fo_pattern.t
// def Imandrax_api_cir.Fo_pattern.t (mangled name: "CirFo_pattern")
#[derive(Debug, Clone)]
pub struct CirFo_pattern {
    pub view: CirFo_patternView<CirFo_pattern>,
    pub ty: CirType,
}

// clique Imandrax_api_cir.Pattern_head.t
// def Imandrax_api_cir.Pattern_head.t (mangled name: "CirPattern_head")
#[derive(Debug, Clone)]
pub enum CirPattern_head {
    PH_id(Uid),
    PH_ty(CirType),
    PH_datatype_op,
}

// clique Imandrax_api_cir.Trigger.t
// def Imandrax_api_cir.Trigger.t (mangled name: "CirTrigger")
#[derive(Debug, Clone)]
pub struct CirTrigger {
    pub trigger_head: CirPattern_head,
    pub trigger_patterns: Vec<CirFo_pattern>,
    pub trigger_instantiation_rule_name: Uid,
}

// clique Imandrax_api_cir.Case.t
// def Imandrax_api_cir.Case.t (mangled name: "CirCase")
#[derive(Debug, Clone)]
pub struct CirCase<V_tyreg_poly_t> {
    pub case_cstor: CirApplied_symbol,
    pub case_vars: Vec<CirVar>,
    pub case_rhs: V_tyreg_poly_t,
    pub case_labels: Option<Vec<Uid>>,
}

// clique Imandrax_api_cir.Clique.t
// def Imandrax_api_cir.Clique.t (mangled name: "CirClique")
pub type CirClique = Uid_set;

// clique Imandrax_api_cir.Logic_config.t
// def Imandrax_api_cir.Logic_config.t (mangled name: "CirLogic_config")
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
// def Imandrax_api_cir.Logic_config.op (mangled name: "CirLogic_configOp")
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

// clique Imandrax_api_cir.Term.binding
// def Imandrax_api_cir.Term.binding (mangled name: "CirTermBinding")
pub type CirTermBinding<V_tyreg_poly_t> = (CirVar, V_tyreg_poly_t);

// clique Imandrax_api_cir.Term.t,Imandrax_api_cir.Term.view
// def Imandrax_api_cir.Term.t (mangled name: "CirTerm")
pub type CirTerm = CirWith_ty<CirTermView>;

// def Imandrax_api_cir.Term.view (mangled name: "CirTermView")
#[derive(Debug, Clone)]
pub enum CirTermView {
    Const(Const),
    If(CirTerm, CirTerm, CirTerm),
    Let {
        flg: Misc_typesRec_flag,
        bs: Vec<CirTermBinding<CirTerm>>,
        body: CirTerm,
    },
    Apply {
        f: CirTerm,
        l: Vec<CirTerm>,
    },
    Fun {
        v: CirVar,
        body: CirTerm,
    },
    Var(CirVar),
    Sym(CirApplied_symbol),
    Construct {
        c: CirApplied_symbol,
        args: Vec<CirTerm>,
        labels: Option<Vec<Uid>>,
    },
    Destruct {
        c: CirApplied_symbol,
        i: BigInt,
        t: CirTerm,
    },
    Is_a {
        c: CirApplied_symbol,
        t: CirTerm,
    },
    Tuple {
        l: Vec<CirTerm>,
    },
    Field {
        f: CirApplied_symbol,
        t: CirTerm,
    },
    Tuple_field {
        i: BigInt,
        t: CirTerm,
    },
    Record {
        rows: Vec<(CirApplied_symbol, CirTerm)>,
        rest: Option<CirTerm>,
    },
    Case {
        u: CirTerm,
        cases: Vec<CirCase<CirTerm>>,
        default: Option<CirTerm>,
    },
    Let_tuple {
        vars: Vec<CirVar>,
        rhs: CirTerm,
        body: CirTerm,
    },
}

// clique Imandrax_api_cir.Term.term
// def Imandrax_api_cir.Term.term (mangled name: "CirTermTerm")
pub type CirTermTerm = CirTerm;

// clique Imandrax_api_cir.Hints.style
// def Imandrax_api_cir.Hints.style (mangled name: "CirHintsStyle")
#[derive(Debug, Clone)]
pub enum CirHintsStyle {
    Multiplicative,
    Additive,
}

// clique Imandrax_api_cir.Hints.Induct.t
// def Imandrax_api_cir.Hints.Induct.t (mangled name: "CirHintsInduct")
#[derive(Debug, Clone)]
pub enum CirHintsInduct {
    Functional {
        f_name: Option<Uid>,
    },
    Structural {
        style: CirHintsStyle,
        vars: Vec<String>,
    },
    Term {
        t: CirTerm,
        vars: Vec<CirVar>,
    },
    Default,
}

// clique Imandrax_api_cir.Hints.Method.t
// def Imandrax_api_cir.Hints.Method.t (mangled name: "CirHintsMethod")
#[derive(Debug, Clone)]
pub enum CirHintsMethod {
    Unroll { steps: Option<BigInt> },
    Ext_solver { name: String },
    Auto,
    Induct(CirHintsInduct),
}

// clique Imandrax_api_cir.Hints.Top.t
// def Imandrax_api_cir.Hints.Top.t (mangled name: "CirHintsTop")
#[derive(Debug, Clone)]
pub struct CirHintsTop<V_tyreg_poly_f> {
    pub basis: Uid_set,
    pub method_: CirHintsMethod,
    pub apply_hint: Vec<V_tyreg_poly_f>,
    pub logic_config_ops: Vec<CirLogic_configOp>,
    pub otf: bool,
}

// clique Imandrax_api_cir.Fun_def.fun_kind
// def Imandrax_api_cir.Fun_def.fun_kind (mangled name: "CirFun_defFun_kind")
#[derive(Debug, Clone)]
pub enum CirFun_defFun_kind {
    Fun_defined { is_macro: bool, from_lambda: bool },
    Fun_builtin(BuiltinFun),
    Fun_opaque,
}

// clique Imandrax_api_cir.Fun_def.validation_strategy
// def Imandrax_api_cir.Fun_def.validation_strategy (mangled name: "CirFun_defValidation_strategy")
#[derive(Debug, Clone)]
pub enum CirFun_defValidation_strategy {
    VS_validate { tactic: Option<CirTerm> },
    VS_no_validate,
}

// clique Imandrax_api_cir.Fun_def.t,Imandrax_api_cir.Fun_def.apply_hint
// def Imandrax_api_cir.Fun_def.t (mangled name: "CirFun_def")
#[derive(Debug, Clone)]
pub struct CirFun_def {
    pub f_name: Uid,
    pub f_ty: CirType_schema,
    pub f_args: Vec<CirVar>,
    pub f_body: CirTerm,
    pub f_clique: Option<CirClique>,
    pub f_kind: CirFun_defFun_kind,
    pub f_admission: Option<Admission>,
    pub f_admission_measure: Option<Uid>,
    pub f_validate_strat: CirFun_defValidation_strategy,
    pub f_hints: Option<CirHintsTop<CirFun_defApply_hint>>,
    pub f_enable: Vec<Uid>,
    pub f_disable: Vec<Uid>,
    pub f_timeout: Option<BigInt>,
}

// def Imandrax_api_cir.Fun_def.apply_hint (mangled name: "CirFun_defApply_hint")
#[derive(Debug, Clone)]
pub struct CirFun_defApply_hint {
    pub apply_fun: CirFun_def,
}

// clique Imandrax_api_cir.Pre_trigger.t
// def Imandrax_api_cir.Pre_trigger.t (mangled name: "CirPre_trigger")
pub type CirPre_trigger = (CirTerm, As_trigger);

// clique Imandrax_api_cir.Theorem.t
// def Imandrax_api_cir.Theorem.t (mangled name: "CirTheorem")
#[derive(Debug, Clone)]
pub struct CirTheorem {
    pub thm_link: CirFun_def,
    pub thm_rewriting: bool,
    pub thm_perm_restrict: bool,
    pub thm_fc: bool,
    pub thm_elim: bool,
    pub thm_gen: bool,
    pub thm_otf: bool,
    pub thm_triggers: Vec<CirPre_trigger>,
    pub thm_is_axiom: bool,
    pub thm_by: CirTerm,
}

// clique Imandrax_api_cir.Tactic.t
// def Imandrax_api_cir.Tactic.t (mangled name: "CirTactic")
#[derive(Debug, Clone)]
pub enum CirTactic {
    Default_termination { basis: Uid_set },
    Default_thm,
    Term(CirTerm),
}

// clique Imandrax_api_cir.Sequent.t
// def Imandrax_api_cir.Sequent.t (mangled name: "CirSequent")
pub type CirSequent = Sequent_poly<CirTerm>;

// clique Imandrax_api_cir.Rewrite_rule.t
// def Imandrax_api_cir.Rewrite_rule.t (mangled name: "CirRewrite_rule")
#[derive(Debug, Clone)]
pub struct CirRewrite_rule {
    pub rw_name: Uid,
    pub rw_head: CirPattern_head,
    pub rw_lhs: CirFo_pattern,
    pub rw_rhs: CirTerm,
    pub rw_guard: Vec<CirTerm>,
    pub rw_vars: Var_set,
    pub rw_triggers: Vec<CirFo_pattern>,
    pub rw_perm_restrict: bool,
    pub rw_loop_break: Option<CirFo_pattern>,
}

// clique Imandrax_api_cir.Proof_obligation.t
// def Imandrax_api_cir.Proof_obligation.t (mangled name: "CirProof_obligation")
#[derive(Debug, Clone)]
pub struct CirProof_obligation {
    pub descr: String,
    pub goal: CirTerm,
    pub tactic: CirTactic,
    pub is_instance: bool,
    pub anchor: Anchor,
    pub timeout: Option<BigInt>,
}

// clique Imandrax_api_cir.Model.ty_def
// def Imandrax_api_cir.Model.ty_def (mangled name: "CirModelTy_def")
pub type CirModelTy_def = ModelTy_def<CirTerm, CirType>;

// clique Imandrax_api_cir.Model.fi
// def Imandrax_api_cir.Model.fi (mangled name: "CirModelFi")
pub type CirModelFi = ModelFi<CirTerm, CirVar, CirType>;

// clique Imandrax_api_cir.Model.t
// def Imandrax_api_cir.Model.t (mangled name: "CirModel")
pub type CirModel = Model<CirTerm, CirApplied_symbol, CirVar, CirType>;

// clique Imandrax_api_cir.Instantiation_rule_kind.t
// def Imandrax_api_cir.Instantiation_rule_kind.t (mangled name: "CirInstantiation_rule_kind")
#[derive(Debug, Clone)]
pub enum CirInstantiation_rule_kind {
    IR_forward_chaining,
    IR_generalization,
}

// clique Imandrax_api_cir.Instantiation_rule.t
// def Imandrax_api_cir.Instantiation_rule.t (mangled name: "CirInstantiation_rule")
#[derive(Debug, Clone)]
pub struct CirInstantiation_rule {
    pub ir_from: CirFun_def,
    pub ir_triggers: Vec<CirTrigger>,
    pub ir_kind: CirInstantiation_rule_kind,
}

// clique Imandrax_api_cir.Elimination_rule.t
// def Imandrax_api_cir.Elimination_rule.t (mangled name: "CirElimination_rule")
#[derive(Debug, Clone)]
pub struct CirElimination_rule {
    pub er_name: Uid,
    pub er_guard: Vec<CirTerm>,
    pub er_lhs: CirTerm,
    pub er_rhs: CirVar,
    pub er_dests: Vec<CirFo_pattern>,
    pub er_dest_tms: Vec<CirTerm>,
}

// clique Imandrax_api_cir.Db_ser.uid_map
// def Imandrax_api_cir.Db_ser.uid_map (mangled name: "CirDb_serUid_map")
pub type CirDb_serUid_map<V_tyreg_poly_a> = Vec<(Uid, V_tyreg_poly_a)>;

// clique Imandrax_api_cir.Db_ser.ph_map
// def Imandrax_api_cir.Db_ser.ph_map (mangled name: "CirDb_serPh_map")
pub type CirDb_serPh_map<V_tyreg_poly_a> = Vec<(CirPattern_head, V_tyreg_poly_a)>;

// clique Imandrax_api_cir.Db_ser.ca_ptr
// def Imandrax_api_cir.Db_ser.ca_ptr (mangled name: "CirDb_serCa_ptr")
pub type CirDb_serCa_ptr<V_tyreg_poly_a> = Ca_storeCa_ptr<V_tyreg_poly_a>;

// clique Imandrax_api_cir.Db_ser.t
// def Imandrax_api_cir.Db_ser.t (mangled name: "CirDb_ser")
#[derive(Debug, Clone)]
pub struct CirDb_ser {
    pub decls: Uid_set,
    pub rw_rules: CirDb_serPh_map<Vec<CirDb_serCa_ptr<CirRewrite_rule>>>,
    pub inst_rules: CirDb_serUid_map<CirDb_serCa_ptr<CirInstantiation_rule>>,
    pub rule_spec_fc: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirTrigger>>>,
    pub rule_spec_rw_rules: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirRewrite_rule>>>,
    pub fc: CirDb_serPh_map<Vec<CirDb_serCa_ptr<CirTrigger>>>,
    pub elim: CirDb_serPh_map<Vec<CirDb_serCa_ptr<CirElimination_rule>>>,
    pub gen: CirDb_serPh_map<Vec<CirDb_serCa_ptr<CirTrigger>>>,
    pub thm_as_rw: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirRewrite_rule>>>,
    pub thm_as_fc: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirInstantiation_rule>>>,
    pub thm_as_elim: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirElimination_rule>>>,
    pub thm_as_gen: CirDb_serUid_map<Vec<CirDb_serCa_ptr<CirInstantiation_rule>>>,
    pub admission: CirDb_serUid_map<CirDb_serCa_ptr<Admission>>,
    pub count_funs_of_ty: CirDb_serUid_map<Uid>,
    pub config: CirDb_serCa_ptr<CirLogic_config>,
    pub disabled: Uid_set,
}

// clique Imandrax_api_eval.Ordinal.t
// def Imandrax_api_eval.Ordinal.t (mangled name: "EvalOrdinal")
#[derive(Debug, Clone)]
pub enum EvalOrdinal {
    Int(BigInt),
    Cons(EvalOrdinal, BigInt, EvalOrdinal),
}

// clique Imandrax_api_eval.Value.cstor_descriptor
// def Imandrax_api_eval.Value.cstor_descriptor (mangled name: "EvalValueCstor_descriptor")
#[derive(Debug, Clone)]
pub struct EvalValueCstor_descriptor {
    pub cd_idx: BigInt,
    pub cd_name: Uid,
}

// clique Imandrax_api_eval.Value.record_descriptor
// def Imandrax_api_eval.Value.record_descriptor (mangled name: "EvalValueRecord_descriptor")
#[derive(Debug, Clone)]
pub struct EvalValueRecord_descriptor {
    pub rd_name: Uid,
    pub rd_fields: Vec<Uid>,
}

// clique Imandrax_api_eval.Value.view
// def Imandrax_api_eval.Value.view (mangled name: "EvalValueView")
#[derive(Debug, Clone)]
pub enum EvalValueView<V_tyreg_poly_v, V_tyreg_poly_closure> {
    V_true,
    V_false,
    V_int(BigInt),
    V_real(Vec<u8>),
    V_string(String),
    V_cstor(EvalValueCstor_descriptor, Vec<V_tyreg_poly_v>),
    V_tuple(Vec<V_tyreg_poly_v>),
    V_record(EvalValueRecord_descriptor, Vec<V_tyreg_poly_v>),
    V_quoted_term(CirTerm),
    V_uid(Uid),
    V_closure(V_tyreg_poly_closure),
    V_custom(Eval__ValueCustom_value),
    V_ordinal(EvalOrdinal),
}

// clique Imandrax_api_eval.Value.t
// def Imandrax_api_eval.Value.t (mangled name: "EvalValue")
#[derive(Debug, Clone)]
pub struct EvalValue {
    pub v: EvalValueView<EvalValue, ()>,
}

// clique Imandrax_api_report.Expansion.t
// def Imandrax_api_report.Expansion.t (mangled name: "ReportExpansion")
#[derive(Debug, Clone)]
pub struct ReportExpansion<V_tyreg_poly_term> {
    pub f_name: Uid,
    pub lhs: V_tyreg_poly_term,
    pub rhs: V_tyreg_poly_term,
}

// clique Imandrax_api_report.Instantiation.t
// def Imandrax_api_report.Instantiation.t (mangled name: "ReportInstantiation")
#[derive(Debug, Clone)]
pub struct ReportInstantiation<V_tyreg_poly_term> {
    pub assertion: V_tyreg_poly_term,
    pub from_rule: Uid,
}

// clique Imandrax_api_report.Smt_proof.t
// def Imandrax_api_report.Smt_proof.t (mangled name: "ReportSmt_proof")
#[derive(Debug, Clone)]
pub struct ReportSmt_proof<V_tyreg_poly_term> {
    pub logic: Logic_fragment,
    pub unsat_core: Vec<V_tyreg_poly_term>,
    pub expansions: Vec<ReportExpansion<V_tyreg_poly_term>>,
    pub instantiations: Vec<ReportInstantiation<V_tyreg_poly_term>>,
}

// clique Imandrax_api_report.Rtext.t,Imandrax_api_report.Rtext.item
// def Imandrax_api_report.Rtext.t (mangled name: "ReportRtext")
pub type ReportRtext<V_tyreg_poly_term> = Vec<ReportRtextItem<V_tyreg_poly_term>>;

// def Imandrax_api_report.Rtext.item (mangled name: "ReportRtextItem")
#[derive(Debug, Clone)]
pub enum ReportRtextItem<V_tyreg_poly_term> {
    S(String),
    B(String),
    I(String),
    Newline,
    Sub(ReportRtext<V_tyreg_poly_term>),
    L(Vec<ReportRtext<V_tyreg_poly_term>>),
    Uid(Uid),
    Term(V_tyreg_poly_term),
    Sequent(Sequent_poly<V_tyreg_poly_term>),
    Subst(Vec<(V_tyreg_poly_term, V_tyreg_poly_term)>),
}

// clique Imandrax_api_report.Atomic_event.poly
// def Imandrax_api_report.Atomic_event.poly (mangled name: "ReportAtomic_eventPoly")
#[derive(Debug, Clone)]
pub enum ReportAtomic_eventPoly<
    V_tyreg_poly_term,
    V_tyreg_poly_fn,
    V_tyreg_poly_var,
    V_tyreg_poly_ty,
> {
    E_message(ReportRtext<V_tyreg_poly_term>),
    E_title(String),
    E_enter_waterfall {
        vars: Vec<V_tyreg_poly_var>,
        goal: V_tyreg_poly_term,
        hints: CirHintsInduct,
    },
    E_enter_tactic(String),
    E_rw_success(CirRewrite_rule, V_tyreg_poly_term, V_tyreg_poly_term),
    E_rw_fail(CirRewrite_rule, V_tyreg_poly_term, String),
    E_inst_success(CirInstantiation_rule, V_tyreg_poly_term),
    E_waterfall_checkpoint(Vec<Sequent_poly<V_tyreg_poly_term>>),
    E_induction_scheme(V_tyreg_poly_term),
    E_attack_subgoal {
        name: String,
        goal: Sequent_poly<V_tyreg_poly_term>,
        depth: BigInt,
    },
    E_simplify_t(V_tyreg_poly_term, V_tyreg_poly_term),
    E_simplify_clause(V_tyreg_poly_term, Vec<V_tyreg_poly_term>),
    E_proved_by_smt(V_tyreg_poly_term, ReportSmt_proof<V_tyreg_poly_term>),
    E_refuted_by_smt(
        V_tyreg_poly_term,
        Option<Model<V_tyreg_poly_term, V_tyreg_poly_fn, V_tyreg_poly_var, V_tyreg_poly_ty>>,
    ),
    E_fun_expansion(V_tyreg_poly_term, V_tyreg_poly_term),
}

// clique Imandrax_api_report.Atomic_event.t
// def Imandrax_api_report.Atomic_event.t (mangled name: "ReportAtomic_event")
pub type ReportAtomic_event = ReportAtomic_eventPoly<CirTerm, CirApplied_symbol, CirVar, CirType>;

// clique Imandrax_api_report.Event.t_linear
// def Imandrax_api_report.Event.t_linear (mangled name: "ReportEventT_linear")
#[derive(Debug, Clone)]
pub enum ReportEventT_linear<V_tyreg_poly_atomic_ev> {
    EL_atomic { ts: f64, ev: V_tyreg_poly_atomic_ev },
    EL_enter_span { ts: f64, ev: V_tyreg_poly_atomic_ev },
    EL_exit_span { ts: f64 },
}

// clique Imandrax_api_report.Event.t_tree
// def Imandrax_api_report.Event.t_tree (mangled name: "ReportEventT_tree")
#[derive(Debug, Clone)]
pub enum ReportEventT_tree<V_tyreg_poly_atomic_ev, V_tyreg_poly_sub> {
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

// clique Imandrax_api_report.Report.event
// def Imandrax_api_report.Report.event (mangled name: "ReportReportEvent")
pub type ReportReportEvent = ReportEventT_linear<ReportAtomic_event>;

// clique Imandrax_api_report.Report.t
// def Imandrax_api_report.Report.t (mangled name: "ReportReport")
#[derive(Debug, Clone)]
pub struct ReportReport {
    pub events: Vec<ReportReportEvent>,
}

// clique Imandrax_api_proof.Arg.t
// def Imandrax_api_proof.Arg.t (mangled name: "ProofArg")
#[derive(Debug, Clone)]
pub enum ProofArg<V_tyreg_poly_term, V_tyreg_poly_ty> {
    A_term(V_tyreg_poly_term),
    A_ty(V_tyreg_poly_ty),
    A_int(BigInt),
    A_string(String),
    A_list(Vec<ProofArg<V_tyreg_poly_term, V_tyreg_poly_ty>>),
    A_dict(Vec<(String, ProofArg<V_tyreg_poly_term, V_tyreg_poly_ty>)>),
    A_seq(Sequent_poly<V_tyreg_poly_term>),
}

// clique Imandrax_api_proof.Var_poly.t
// def Imandrax_api_proof.Var_poly.t (mangled name: "ProofVar_poly")
pub type ProofVar_poly<V_tyreg_poly_ty> = (Uid, V_tyreg_poly_ty);

// clique Imandrax_api_proof.View.t
// def Imandrax_api_proof.View.t (mangled name: "ProofView")
#[derive(Debug, Clone)]
pub enum ProofView<V_tyreg_poly_term, V_tyreg_poly_ty, V_tyreg_poly_proof> {
    T_assume,
    T_subst {
        t_subst: Vec<(ProofVar_poly<V_tyreg_poly_ty>, V_tyreg_poly_term)>,
        ty_subst: Vec<(Uid, V_tyreg_poly_ty)>,
        premise: V_tyreg_poly_proof,
    },
    T_deduction {
        premises: Vec<(String, Vec<V_tyreg_poly_proof>)>,
    },
    T_rule {
        rule: String,
        args: Vec<ProofArg<V_tyreg_poly_term, V_tyreg_poly_ty>>,
    },
}

// clique Imandrax_api_proof.Proof_term_poly.t
// def Imandrax_api_proof.Proof_term_poly.t (mangled name: "ProofProof_term_poly")
#[derive(Debug, Clone)]
pub struct ProofProof_term_poly<V_tyreg_poly_term, V_tyreg_poly_ty, V_tyreg_poly_proof> {
    pub id: BigInt,
    pub concl: Sequent_poly<V_tyreg_poly_term>,
    pub view: ProofView<V_tyreg_poly_term, V_tyreg_poly_ty, V_tyreg_poly_proof>,
}

// clique Imandrax_api_proof.Cir_proof_term.t,Imandrax_api_proof.Cir_proof_term.t_inner
// def Imandrax_api_proof.Cir_proof_term.t (mangled name: "ProofCir_proof_term")
#[derive(Debug, Clone)]
pub struct ProofCir_proof_term {
    pub p: ProofCir_proof_termT_inner,
}

// def Imandrax_api_proof.Cir_proof_term.t_inner (mangled name: "ProofCir_proof_termT_inner")
pub type ProofCir_proof_termT_inner = ProofProof_term_poly<CirTerm, CirType, ProofCir_proof_term>;

// clique Imandrax_api_tasks.PO_task.t
// def Imandrax_api_tasks.PO_task.t (mangled name: "TasksPO_task")
#[derive(Debug, Clone)]
pub struct TasksPO_task {
    pub from_sym: String,
    pub count: BigInt,
    pub db: CirDb_ser,
    pub po: CirProof_obligation,
}

// clique Imandrax_api_tasks.PO_res.stats
// def Imandrax_api_tasks.PO_res.stats (mangled name: "TasksPO_resStats")
pub type TasksPO_resStats = Stat_time;

// clique Imandrax_api_tasks.PO_res.proof_found
// def Imandrax_api_tasks.PO_res.proof_found (mangled name: "TasksPO_resProof_found")
#[derive(Debug, Clone)]
pub struct TasksPO_resProof_found {
    pub anchor: Anchor,
    pub proof: ProofCir_proof_term,
}

// clique Imandrax_api_tasks.PO_res.instance
// def Imandrax_api_tasks.PO_res.instance (mangled name: "TasksPO_resInstance")
#[derive(Debug, Clone)]
pub struct TasksPO_resInstance {
    pub anchor: Anchor,
    pub model: CirModel,
}

// clique Imandrax_api_tasks.PO_res.no_proof
// def Imandrax_api_tasks.PO_res.no_proof (mangled name: "TasksPO_resNo_proof")
#[derive(Debug, Clone)]
pub struct TasksPO_resNo_proof {
    pub err: ErrorError_core,
    pub counter_model: Option<CirModel>,
    pub subgoals: Vec<CirSequent>,
}

// clique Imandrax_api_tasks.PO_res.unsat
// def Imandrax_api_tasks.PO_res.unsat (mangled name: "TasksPO_resUnsat")
#[derive(Debug, Clone)]
pub struct TasksPO_resUnsat {
    pub anchor: Anchor,
    pub err: ErrorError_core,
    pub proof: ProofCir_proof_term,
}

// clique Imandrax_api_tasks.PO_res.success
// def Imandrax_api_tasks.PO_res.success (mangled name: "TasksPO_resSuccess")
#[derive(Debug, Clone)]
pub enum TasksPO_resSuccess {
    Proof(TasksPO_resProof_found),
    Instance(TasksPO_resInstance),
}

// clique Imandrax_api_tasks.PO_res.error
// def Imandrax_api_tasks.PO_res.error (mangled name: "TasksPO_resError")
#[derive(Debug, Clone)]
pub enum TasksPO_resError {
    No_proof(TasksPO_resNo_proof),
    Unsat(TasksPO_resUnsat),
    Invalid_model(ErrorError_core, CirModel),
    Error(ErrorError_core),
}

// clique Imandrax_api_tasks.PO_res.result
// def Imandrax_api_tasks.PO_res.result (mangled name: "TasksPO_resResult")
pub type TasksPO_resResult<V_tyreg_poly_a> = core::result::Result<V_tyreg_poly_a, TasksPO_resError>;

// clique Imandrax_api_tasks.PO_res.t
// def Imandrax_api_tasks.PO_res.t (mangled name: "TasksPO_res")
#[derive(Debug, Clone)]
pub struct TasksPO_res {
    pub from_: Ca_storeCa_ptr<CirProof_obligation>,
    pub res: TasksPO_resResult<TasksPO_resSuccess>,
    pub stats: TasksPO_resStats,
    pub report: In_mem_archive<ReportReport>,
}

// clique Imandrax_api_tasks.Eval_task.t
// def Imandrax_api_tasks.Eval_task.t (mangled name: "TasksEval_task")
#[derive(Debug, Clone)]
pub struct TasksEval_task {
    pub db: CirDb_ser,
    pub term: CirTerm,
    pub anchor: Anchor,
    pub timeout: Option<BigInt>,
}

// clique Imandrax_api_tasks.Eval_res.value
// def Imandrax_api_tasks.Eval_res.value (mangled name: "TasksEval_resValue")
pub type TasksEval_resValue = EvalValue;

// clique Imandrax_api_tasks.Eval_res.stats
// def Imandrax_api_tasks.Eval_res.stats (mangled name: "TasksEval_resStats")
#[derive(Debug, Clone)]
pub struct TasksEval_resStats {
    pub compile_time: f64,
    pub exec_time: f64,
}

// clique Imandrax_api_tasks.Eval_res.success
// def Imandrax_api_tasks.Eval_res.success (mangled name: "TasksEval_resSuccess")
#[derive(Debug, Clone)]
pub struct TasksEval_resSuccess {
    pub v: TasksEval_resValue,
}

// clique Imandrax_api_tasks.Eval_res.t
// def Imandrax_api_tasks.Eval_res.t (mangled name: "TasksEval_res")
#[derive(Debug, Clone)]
pub struct TasksEval_res {
    pub res: core::result::Result<TasksEval_resSuccess, Error>,
    pub stats: TasksEval_resStats,
}
