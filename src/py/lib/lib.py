
# automatically generated using genbindings.ml, do not edit

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from dataclasses import dataclass


  

# clique Imandrax_api.Builtin_data.kind
# def Imandrax_api.Builtin_data.kind (mangled name: "Builtin_data_kind")
@dataclass(slots=True)
class Builtin_data_kind_Logic_core:
    logic_core_name: str

@dataclass(slots=True)
class Builtin_data_kind_Special:
    tag: str

@dataclass(slots=True)
class Builtin_data_kind_Tactic:
    tac_name: str

type Builtin_data_kind = Builtin_data_kind_Logic_core| Builtin_data_kind_Special| Builtin_data_kind_Tactic

# clique Imandrax_api.Chash.t
# def Imandrax_api.Chash.t (mangled name: "Chash")
type Chash = bytes

# clique Imandrax_api.Cname.t
# def Imandrax_api.Cname.t (mangled name: "Cname")
@dataclass(slots=True)
class Cname:
    name: str
    chash: Chash

# clique Imandrax_api.Uid.gen_kind
# def Imandrax_api.Uid.gen_kind (mangled name: "Uid_gen_kind")
@dataclass(slots=True)
class Uid_gen_kind_Local:
    pass

@dataclass(slots=True)
class Uid_gen_kind_To_be_rewritten:
    pass

type Uid_gen_kind = Uid_gen_kind_Local| Uid_gen_kind_To_be_rewritten

# clique Imandrax_api.Uid.view
# def Imandrax_api.Uid.view (mangled name: "Uid_view")
@dataclass(slots=True)
class Uid_view_Generative:
    id: int
    gen_kind: Uid_gen_kind

@dataclass(slots=True)
class Uid_view_Persistent:
    pass

@dataclass(slots=True)
class Uid_view_Cname:
    cname: Cname

@dataclass(slots=True)
class Uid_view_Builtin:
    kind: Builtin_data_kind

type Uid_view = Uid_view_Generative| Uid_view_Persistent| Uid_view_Cname| Uid_view_Builtin

# clique Imandrax_api.Uid.t
# def Imandrax_api.Uid.t (mangled name: "Uid")
@dataclass(slots=True)
class Uid:
    name: str
    view: Uid_view

# clique Imandrax_api.Uid_set.t
# def Imandrax_api.Uid_set.t (mangled name: "Uid_set")
type Uid_set = set[Uid]

# clique Imandrax_api.Builtin.Fun.t
# def Imandrax_api.Builtin.Fun.t (mangled name: "Builtin_Fun")
@dataclass(slots=True)
class Builtin_Fun:
    id: Uid
    kind: Builtin_data_kind
    lassoc: bool
    commutative: bool
    connective: bool

# clique Imandrax_api.Builtin.Ty.t
# def Imandrax_api.Builtin.Ty.t (mangled name: "Builtin_Ty")
@dataclass(slots=True)
class Builtin_Ty:
    id: Uid
    kind: Builtin_data_kind

# clique Imandrax_api.Ty_view.adt_row
# def Imandrax_api.Ty_view.adt_row (mangled name: "Ty_view_adt_row")
@dataclass(slots=True)
class Ty_view_adt_row[V_tyreg_poly_id,V_tyreg_poly_t]:
    c: "V_tyreg_poly_id"
    labels: None | list["V_tyreg_poly_id"]
    args: list["V_tyreg_poly_t"]
    doc: None | str

# clique Imandrax_api.Ty_view.rec_row
# def Imandrax_api.Ty_view.rec_row (mangled name: "Ty_view_rec_row")
@dataclass(slots=True)
class Ty_view_rec_row[V_tyreg_poly_id,V_tyreg_poly_t]:
    f: "V_tyreg_poly_id"
    ty: "V_tyreg_poly_t"
    doc: None | str

# clique Imandrax_api.Ty_view.decl
# def Imandrax_api.Ty_view.decl (mangled name: "Ty_view_decl")
@dataclass(slots=True)
class Ty_view_decl_Algebraic[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    arg: list[Ty_view_adt_row["V_tyreg_poly_id","V_tyreg_poly_t"]]

@dataclass(slots=True)
class Ty_view_decl_Record[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    arg: list[Ty_view_rec_row["V_tyreg_poly_id","V_tyreg_poly_t"]]

@dataclass(slots=True)
class Ty_view_decl_Alias[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    target: "V_tyreg_poly_alias"
    reexport_def: None | Ty_view_decl["V_tyreg_poly_id","V_tyreg_poly_t","V_tyreg_poly_alias"]

@dataclass(slots=True)
class Ty_view_decl_Skolem[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    pass

@dataclass(slots=True)
class Ty_view_decl_Builtin[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    arg: Builtin_Ty

@dataclass(slots=True)
class Ty_view_decl_Other[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]:
    pass

type Ty_view_decl[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias] = Ty_view_decl_Algebraic[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]| Ty_view_decl_Record[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]| Ty_view_decl_Alias[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]| Ty_view_decl_Skolem[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]| Ty_view_decl_Builtin[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]| Ty_view_decl_Other[V_tyreg_poly_id,V_tyreg_poly_t,V_tyreg_poly_alias]

# clique Imandrax_api.Ty_view.view
# def Imandrax_api.Ty_view.view (mangled name: "Ty_view_view")
@dataclass(slots=True)
class Ty_view_view_Var[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]:
    arg: "V_tyreg_poly_var"

@dataclass(slots=True)
class Ty_view_view_Arrow[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]:
    args: tuple["V_tyreg_poly_lbl","V_tyreg_poly_t","V_tyreg_poly_t"]

@dataclass(slots=True)
class Ty_view_view_Tuple[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]:
    arg: list["V_tyreg_poly_t"]

@dataclass(slots=True)
class Ty_view_view_Constr[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]:
    args: tuple[Uid,list["V_tyreg_poly_t"]]

type Ty_view_view[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t] = Ty_view_view_Var[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]| Ty_view_view_Arrow[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]| Ty_view_view_Tuple[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]| Ty_view_view_Constr[V_tyreg_poly_lbl,V_tyreg_poly_var,V_tyreg_poly_t]

# clique Imandrax_api.Stat_time.t
# def Imandrax_api.Stat_time.t (mangled name: "Stat_time")
@dataclass(slots=True)
class Stat_time:
    time_s: float

# clique Imandrax_api.Sequent_poly.t
# def Imandrax_api.Sequent_poly.t (mangled name: "Sequent_poly")
@dataclass(slots=True)
class Sequent_poly[V_tyreg_poly_term]:
    hyps: list["V_tyreg_poly_term"]
    concls: list["V_tyreg_poly_term"]

# clique Imandrax_api.Misc_types.rec_flag
# def Imandrax_api.Misc_types.rec_flag (mangled name: "Misc_types_rec_flag")
@dataclass(slots=True)
class Misc_types_rec_flag_Recursive:
    pass

@dataclass(slots=True)
class Misc_types_rec_flag_Nonrecursive:
    pass

type Misc_types_rec_flag = Misc_types_rec_flag_Recursive| Misc_types_rec_flag_Nonrecursive

# clique Imandrax_api.Misc_types.apply_label
# def Imandrax_api.Misc_types.apply_label (mangled name: "Misc_types_apply_label")
@dataclass(slots=True)
class Misc_types_apply_label_Nolabel:
    pass

@dataclass(slots=True)
class Misc_types_apply_label_Label:
    arg: str

@dataclass(slots=True)
class Misc_types_apply_label_Optional:
    arg: str

type Misc_types_apply_label = Misc_types_apply_label_Nolabel| Misc_types_apply_label_Label| Misc_types_apply_label_Optional

# clique Imandrax_api.Logic_fragment.t
# def Imandrax_api.Logic_fragment.t (mangled name: "Logic_fragment")
type Logic_fragment = Logic_fragment

# clique Imandrax_api.In_mem_archive.raw
# def Imandrax_api.In_mem_archive.raw (mangled name: "In_mem_archive_raw")
@dataclass(slots=True)
class In_mem_archive_raw:
    ty: str
    compressed: bool
    data: str

# clique Imandrax_api.Const.t
# def Imandrax_api.Const.t (mangled name: "Const")
@dataclass(slots=True)
class Const_Const_float:
    arg: float

@dataclass(slots=True)
class Const_Const_string:
    arg: str

@dataclass(slots=True)
class Const_Const_z:
    arg: int

@dataclass(slots=True)
class Const_Const_q:
    arg: string

@dataclass(slots=True)
class Const_Const_real_approx:
    arg: str

@dataclass(slots=True)
class Const_Const_uid:
    arg: Uid

@dataclass(slots=True)
class Const_Const_bool:
    arg: bool

type Const = Const_Const_float| Const_Const_string| Const_Const_z| Const_Const_q| Const_Const_real_approx| Const_Const_uid| Const_Const_bool

# clique Imandrax_api.As_trigger.t
# def Imandrax_api.As_trigger.t (mangled name: "As_trigger")
@dataclass(slots=True)
class As_trigger_Trig_none:
    pass

@dataclass(slots=True)
class As_trigger_Trig_anon:
    pass

@dataclass(slots=True)
class As_trigger_Trig_named:
    arg: int

@dataclass(slots=True)
class As_trigger_Trig_rw:
    pass

type As_trigger = As_trigger_Trig_none| As_trigger_Trig_anon| As_trigger_Trig_named| As_trigger_Trig_rw

# clique Imandrax_api.Anchor.t
# def Imandrax_api.Anchor.t (mangled name: "Anchor")
@dataclass(slots=True)
class Anchor_Named:
    arg: Cname

@dataclass(slots=True)
class Anchor_Eval:
    arg: int

@dataclass(slots=True)
class Anchor_Proof_check:
    arg: Anchor

type Anchor = Anchor_Named| Anchor_Eval| Anchor_Proof_check

# clique Imandrax_api.Admission.t
# def Imandrax_api.Admission.t (mangled name: "Admission")
@dataclass(slots=True)
class Admission:
    measured_subset: list[str]
    measure_fun: None | Uid

# clique Imandrax_api_model.ty_def
# def Imandrax_api_model.ty_def (mangled name: "Model_ty_def")
@dataclass(slots=True)
class Model_ty_def_Ty_finite[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: list["V_tyreg_poly_term"]

@dataclass(slots=True)
class Model_ty_def_Ty_alias_unit[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: "V_tyreg_poly_ty"

type Model_ty_def[V_tyreg_poly_term,V_tyreg_poly_ty] = Model_ty_def_Ty_finite[V_tyreg_poly_term,V_tyreg_poly_ty]| Model_ty_def_Ty_alias_unit[V_tyreg_poly_term,V_tyreg_poly_ty]

# clique Imandrax_api_model.fi
# def Imandrax_api_model.fi (mangled name: "Model_fi")
@dataclass(slots=True)
class Model_fi[V_tyreg_poly_term,V_tyreg_poly_var,V_tyreg_poly_ty]:
    fi_args: list["V_tyreg_poly_var"]
    fi_ty_ret: "V_tyreg_poly_ty"
    fi_cases: list[tuple[list["V_tyreg_poly_term"],"V_tyreg_poly_term"]]
    fi_else: "V_tyreg_poly_term"

# clique Imandrax_api_model.t
# def Imandrax_api_model.t (mangled name: "Model")
@dataclass(slots=True)
class Model[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    tys: list[tuple["V_tyreg_poly_ty",Model_ty_def["V_tyreg_poly_term","V_tyreg_poly_ty"]]]
    consts: list[tuple["V_tyreg_poly_fn","V_tyreg_poly_term"]]
    funs: list[tuple["V_tyreg_poly_fn",Model_fi["V_tyreg_poly_term","V_tyreg_poly_var","V_tyreg_poly_ty"]]]
    representable: bool
    completed: bool
    ty_subst: list[tuple[Model,"V_tyreg_poly_ty"]]

# clique Imandrax_api_cir.Type.var
# def Imandrax_api_cir.Type.var (mangled name: "Cir_Type_var")
type Cir_Type_var = Uid

# clique Imandrax_api_cir.Type.clique
# def Imandrax_api_cir.Type.clique (mangled name: "Cir_Type_clique")
type Cir_Type_clique = Uid_set

# clique Imandrax_api_cir.Type.t
# def Imandrax_api_cir.Type.t (mangled name: "Cir_Type")
@dataclass(slots=True)
class Cir_Type:
    view: Ty_view_view[None,Cir_Type_var,Cir_Type]

# clique Imandrax_api_cir.Type.def
# def Imandrax_api_cir.Type.def (mangled name: "Cir_Type_def")
@dataclass(slots=True)
class Cir_Type_def:
    name: Cir_Type
    params: list[Cir_Type_var]
    decl: Ty_view_decl[Cir_Type,Cir_Type,Cir_Type]
    clique: None | Cir_Type_clique
    timeout: None | int

# clique Imandrax_api_cir.With_ty.t
# def Imandrax_api_cir.With_ty.t (mangled name: "Cir_With_ty")
@dataclass(slots=True)
class Cir_With_ty[V_tyreg_poly_a]:
    view: "V_tyreg_poly_a"
    ty: Cir_Type

# clique Imandrax_api_cir.Var.t
# def Imandrax_api_cir.Var.t (mangled name: "Cir_Var")
type Cir_Var = Cir_With_ty[Uid]

# clique Imandrax_api_cir.Type_schema.t
# def Imandrax_api_cir.Type_schema.t (mangled name: "Cir_Type_schema")
@dataclass(slots=True)
class Cir_Type_schema:
    params: list[Cir_Type_var]
    ty: Cir_Type

# clique Imandrax_api_cir.Typed_symbol.t
# def Imandrax_api_cir.Typed_symbol.t (mangled name: "Cir_Typed_symbol")
@dataclass(slots=True)
class Cir_Typed_symbol:
    id: Uid
    ty: Cir_Type_schema

# clique Imandrax_api_cir.Applied_symbol.t
# def Imandrax_api_cir.Applied_symbol.t (mangled name: "Cir_Applied_symbol")
@dataclass(slots=True)
class Cir_Applied_symbol:
    sym: Cir_Typed_symbol
    args: list[Cir_Type]
    ty: Cir_Type

# clique Imandrax_api_cir.Fo_pattern.view
# def Imandrax_api_cir.Fo_pattern.view (mangled name: "Cir_Fo_pattern_view")
@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_any[V_tyreg_poly_t]:
    pass

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_bool[V_tyreg_poly_t]:
    arg: bool

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_const[V_tyreg_poly_t]:
    arg: Const

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_var[V_tyreg_poly_t]:
    arg: Cir_Var

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_app[V_tyreg_poly_t]:
    args: tuple[Cir_Applied_symbol,list["V_tyreg_poly_t"]]

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_cstor[V_tyreg_poly_t]:
    args: tuple[None | Cir_Applied_symbol,list["V_tyreg_poly_t"]]

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_destruct[V_tyreg_poly_t]:
    c: None | Cir_Applied_symbol
    i: int
    u: "V_tyreg_poly_t"

@dataclass(slots=True)
class Cir_Fo_pattern_view_FO_is_a[V_tyreg_poly_t]:
    c: Cir_Applied_symbol
    u: "V_tyreg_poly_t"

type Cir_Fo_pattern_view[V_tyreg_poly_t] = Cir_Fo_pattern_view_FO_any[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_bool[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_const[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_var[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_app[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_cstor[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_destruct[V_tyreg_poly_t]| Cir_Fo_pattern_view_FO_is_a[V_tyreg_poly_t]

# clique Imandrax_api_cir.Fo_pattern.t
# def Imandrax_api_cir.Fo_pattern.t (mangled name: "Cir_Fo_pattern")
@dataclass(slots=True)
class Cir_Fo_pattern:
    view: Cir_Fo_pattern_view[Cir_Fo_pattern]
    ty: Cir_Type

# clique Imandrax_api_cir.Pattern_head.t
# def Imandrax_api_cir.Pattern_head.t (mangled name: "Cir_Pattern_head")
@dataclass(slots=True)
class Cir_Pattern_head_PH_id:
    arg: Uid

@dataclass(slots=True)
class Cir_Pattern_head_PH_ty:
    arg: Cir_Type

@dataclass(slots=True)
class Cir_Pattern_head_PH_datatype_op:
    pass

type Cir_Pattern_head = Cir_Pattern_head_PH_id| Cir_Pattern_head_PH_ty| Cir_Pattern_head_PH_datatype_op

# clique Imandrax_api_cir.Trigger.t
# def Imandrax_api_cir.Trigger.t (mangled name: "Cir_Trigger")
@dataclass(slots=True)
class Cir_Trigger:
    trigger_head: Cir_Pattern_head
    trigger_patterns: list[Cir_Fo_pattern]
    trigger_instantiation_rule_name: Uid

# clique Imandrax_api_cir.Case.t
# def Imandrax_api_cir.Case.t (mangled name: "Cir_Case")
@dataclass(slots=True)
class Cir_Case[V_tyreg_poly_t]:
    case_cstor: Cir_Applied_symbol
    case_vars: list[Cir_Var]
    case_rhs: "V_tyreg_poly_t"
    case_labels: None | list[Uid]

# clique Imandrax_api_cir.Clique.t
# def Imandrax_api_cir.Clique.t (mangled name: "Cir_Clique")
type Cir_Clique = Uid_set

# clique Imandrax_api_cir.Logic_config.t
# def Imandrax_api_cir.Logic_config.t (mangled name: "Cir_Logic_config")
@dataclass(slots=True)
class Cir_Logic_config:
    timeout: int
    validate: bool
    skip_proofs: bool
    max_induct: None | int
    backchain_limit: int
    enable_all: bool
    induct_unroll_depth: int
    induct_subgoal_depth: int
    unroll_enable_all: bool
    unroll_depth: int

# clique Imandrax_api_cir.Logic_config.op
# def Imandrax_api_cir.Logic_config.op (mangled name: "Cir_Logic_config_op")
@dataclass(slots=True)
class Cir_Logic_config_op_Op_timeout:
    arg: int

@dataclass(slots=True)
class Cir_Logic_config_op_Op_validate:
    arg: bool

@dataclass(slots=True)
class Cir_Logic_config_op_Op_skip_proofs:
    arg: bool

@dataclass(slots=True)
class Cir_Logic_config_op_Op_max_induct:
    arg: None | int

@dataclass(slots=True)
class Cir_Logic_config_op_Op_backchain_limit:
    arg: int

@dataclass(slots=True)
class Cir_Logic_config_op_Op_enable_all:
    arg: bool

@dataclass(slots=True)
class Cir_Logic_config_op_Op_induct_unroll_depth:
    arg: int

@dataclass(slots=True)
class Cir_Logic_config_op_Op_induct_subgoal_depth:
    arg: int

@dataclass(slots=True)
class Cir_Logic_config_op_Op_unroll_enable_all:
    arg: bool

@dataclass(slots=True)
class Cir_Logic_config_op_Op_unroll_depth:
    arg: int

type Cir_Logic_config_op = Cir_Logic_config_op_Op_timeout| Cir_Logic_config_op_Op_validate| Cir_Logic_config_op_Op_skip_proofs| Cir_Logic_config_op_Op_max_induct| Cir_Logic_config_op_Op_backchain_limit| Cir_Logic_config_op_Op_enable_all| Cir_Logic_config_op_Op_induct_unroll_depth| Cir_Logic_config_op_Op_induct_subgoal_depth| Cir_Logic_config_op_Op_unroll_enable_all| Cir_Logic_config_op_Op_unroll_depth

# clique Imandrax_api_cir.Term.binding
# def Imandrax_api_cir.Term.binding (mangled name: "Cir_Term_binding")
type Cir_Term_binding[V_tyreg_poly_t] = tuple[Cir_Var,"V_tyreg_poly_t"]

# clique Imandrax_api_cir.Term.t,Imandrax_api_cir.Term.view
# def Imandrax_api_cir.Term.t (mangled name: "Cir_Term")
type Cir_Term = Cir_With_ty[Cir_Term_view]
# def Imandrax_api_cir.Term.view (mangled name: "Cir_Term_view")
@dataclass(slots=True)
class Cir_Term_view_Const:
    arg: Const

@dataclass(slots=True)
class Cir_Term_view_If:
    args: tuple[Cir_Term,Cir_Term,Cir_Term]

@dataclass(slots=True)
class Cir_Term_view_Let:
    flg: Misc_types_rec_flag
    bs: list[Cir_Term_binding[Cir_Term]]
    body: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Apply:
    f: Cir_Term
    l: list[Cir_Term]

@dataclass(slots=True)
class Cir_Term_view_Fun:
    v: Cir_Var
    body: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Var:
    arg: Cir_Var

@dataclass(slots=True)
class Cir_Term_view_Sym:
    arg: Cir_Applied_symbol

@dataclass(slots=True)
class Cir_Term_view_Construct:
    c: Cir_Applied_symbol
    args: list[Cir_Term]
    labels: None | list[Uid]

@dataclass(slots=True)
class Cir_Term_view_Destruct:
    c: Cir_Applied_symbol
    i: int
    t: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Is_a:
    c: Cir_Applied_symbol
    t: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Tuple:
    l: list[Cir_Term]

@dataclass(slots=True)
class Cir_Term_view_Field:
    f: Cir_Applied_symbol
    t: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Tuple_field:
    i: int
    t: Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Record:
    rows: list[tuple[Cir_Applied_symbol,Cir_Term]]
    rest: None | Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Case:
    u: Cir_Term
    cases: list[Cir_Case[Cir_Term]]
    default: None | Cir_Term

@dataclass(slots=True)
class Cir_Term_view_Let_tuple:
    vars: list[Cir_Var]
    rhs: Cir_Term
    body: Cir_Term

type Cir_Term_view = Cir_Term_view_Const| Cir_Term_view_If| Cir_Term_view_Let| Cir_Term_view_Apply| Cir_Term_view_Fun| Cir_Term_view_Var| Cir_Term_view_Sym| Cir_Term_view_Construct| Cir_Term_view_Destruct| Cir_Term_view_Is_a| Cir_Term_view_Tuple| Cir_Term_view_Field| Cir_Term_view_Tuple_field| Cir_Term_view_Record| Cir_Term_view_Case| Cir_Term_view_Let_tuple

# clique Imandrax_api_cir.Term.term
# def Imandrax_api_cir.Term.term (mangled name: "Cir_Term_term")
type Cir_Term_term = Cir_Term

# clique Imandrax_api_cir.Hints.style
# def Imandrax_api_cir.Hints.style (mangled name: "Cir_Hints_style")
@dataclass(slots=True)
class Cir_Hints_style_Multiplicative:
    pass

@dataclass(slots=True)
class Cir_Hints_style_Additive:
    pass

type Cir_Hints_style = Cir_Hints_style_Multiplicative| Cir_Hints_style_Additive

# clique Imandrax_api_cir.Hints.Induct.t
# def Imandrax_api_cir.Hints.Induct.t (mangled name: "Cir_Hints_Induct")
@dataclass(slots=True)
class Cir_Hints_Induct_Functional:
    f_name: None | Uid

@dataclass(slots=True)
class Cir_Hints_Induct_Structural:
    style: Cir_Hints_style
    vars: list[str]

@dataclass(slots=True)
class Cir_Hints_Induct_Term:
    t: Cir_Term
    vars: list[Cir_Var]

@dataclass(slots=True)
class Cir_Hints_Induct_Default:
    pass

type Cir_Hints_Induct = Cir_Hints_Induct_Functional| Cir_Hints_Induct_Structural| Cir_Hints_Induct_Term| Cir_Hints_Induct_Default

# clique Imandrax_api_cir.Hints.Method.t
# def Imandrax_api_cir.Hints.Method.t (mangled name: "Cir_Hints_Method")
@dataclass(slots=True)
class Cir_Hints_Method_Unroll:
    steps: None | int

@dataclass(slots=True)
class Cir_Hints_Method_Ext_solver:
    name: str

@dataclass(slots=True)
class Cir_Hints_Method_Auto:
    pass

@dataclass(slots=True)
class Cir_Hints_Method_Induct:
    arg: Cir_Hints_Induct

type Cir_Hints_Method = Cir_Hints_Method_Unroll| Cir_Hints_Method_Ext_solver| Cir_Hints_Method_Auto| Cir_Hints_Method_Induct

# clique Imandrax_api_cir.Hints.t
# def Imandrax_api_cir.Hints.t (mangled name: "Cir_Hints")
@dataclass(slots=True)
class Cir_Hints[V_tyreg_poly_f]:
    basis: Uid_set
    method_: Cir_Hints_Method
    apply_hint: list["V_tyreg_poly_f"]
    logic_config_ops: list[Cir_Logic_config_op]
    otf: bool

# clique Imandrax_api_cir.Fun_def.fun_kind
# def Imandrax_api_cir.Fun_def.fun_kind (mangled name: "Cir_Fun_def_fun_kind")
@dataclass(slots=True)
class Cir_Fun_def_fun_kind_Fun_defined:
    is_macro: bool
    from_lambda: bool

@dataclass(slots=True)
class Cir_Fun_def_fun_kind_Fun_builtin:
    arg: Builtin_Fun

@dataclass(slots=True)
class Cir_Fun_def_fun_kind_Fun_opaque:
    pass

type Cir_Fun_def_fun_kind = Cir_Fun_def_fun_kind_Fun_defined| Cir_Fun_def_fun_kind_Fun_builtin| Cir_Fun_def_fun_kind_Fun_opaque

# clique Imandrax_api_cir.Fun_def.validation_strategy
# def Imandrax_api_cir.Fun_def.validation_strategy (mangled name: "Cir_Fun_def_validation_strategy")
@dataclass(slots=True)
class Cir_Fun_def_validation_strategy_VS_validate:
    tactic: None | Cir_Term

@dataclass(slots=True)
class Cir_Fun_def_validation_strategy_VS_no_validate:
    pass

type Cir_Fun_def_validation_strategy = Cir_Fun_def_validation_strategy_VS_validate| Cir_Fun_def_validation_strategy_VS_no_validate

# clique Imandrax_api_cir.Fun_def.t,Imandrax_api_cir.Fun_def.apply_hint
# def Imandrax_api_cir.Fun_def.t (mangled name: "Cir_Fun_def")
@dataclass(slots=True)
class Cir_Fun_def:
    f_name: Uid
    f_ty: Cir_Type_schema
    f_args: list[Cir_Var]
    f_body: Cir_Term
    f_clique: None | Cir_Clique
    f_kind: Cir_Fun_def_fun_kind
    f_admission: None | Admission
    f_admission_measure: None | Uid
    f_validate_strat: Cir_Fun_def_validation_strategy
    f_hints: None | Cir_Hints[Cir_Fun_def_apply_hint]
    f_enable: list[Uid]
    f_disable: list[Uid]
    f_timeout: None | int
# def Imandrax_api_cir.Fun_def.apply_hint (mangled name: "Cir_Fun_def_apply_hint")
@dataclass(slots=True)
class Cir_Fun_def_apply_hint:
    apply_fun: Cir_Fun_def

# clique Imandrax_api_cir.Pre_trigger.t
# def Imandrax_api_cir.Pre_trigger.t (mangled name: "Cir_Pre_trigger")
type Cir_Pre_trigger = tuple[Cir_Term,As_trigger]

# clique Imandrax_api_cir.Theorem.t
# def Imandrax_api_cir.Theorem.t (mangled name: "Cir_Theorem")
@dataclass(slots=True)
class Cir_Theorem:
    thm_link: Cir_Fun_def
    thm_rewriting: bool
    thm_perm_restrict: bool
    thm_fc: bool
    thm_elim: bool
    thm_gen: bool
    thm_otf: bool
    thm_triggers: list[Cir_Pre_trigger]
    thm_is_axiom: bool
    thm_by: Cir_Term

# clique Imandrax_api_cir.Tactic.t
# def Imandrax_api_cir.Tactic.t (mangled name: "Cir_Tactic")
@dataclass(slots=True)
class Cir_Tactic_Default_termination:
    basis: Uid_set

@dataclass(slots=True)
class Cir_Tactic_Default_thm:
    pass

@dataclass(slots=True)
class Cir_Tactic_Term:
    arg: Cir_Term

type Cir_Tactic = Cir_Tactic_Default_termination| Cir_Tactic_Default_thm| Cir_Tactic_Term

# clique Imandrax_api_cir.Sequent.t
# def Imandrax_api_cir.Sequent.t (mangled name: "Cir_Sequent")
type Cir_Sequent = Sequent_poly[Cir_Term]

# clique Imandrax_api_cir.Rewrite_rule.t
# def Imandrax_api_cir.Rewrite_rule.t (mangled name: "Cir_Rewrite_rule")
@dataclass(slots=True)
class Cir_Rewrite_rule:
    rw_name: Uid
    rw_head: Cir_Pattern_head
    rw_lhs: Cir_Fo_pattern
    rw_rhs: Cir_Term
    rw_guard: list[Cir_Term]
    rw_vars: Cir_Rewrite_rule
    rw_triggers: list[Cir_Fo_pattern]
    rw_perm_restrict: bool
    rw_loop_break: None | Cir_Fo_pattern

# clique Imandrax_api_cir.Proof_obligation.t
# def Imandrax_api_cir.Proof_obligation.t (mangled name: "Cir_Proof_obligation")
@dataclass(slots=True)
class Cir_Proof_obligation:
    descr: str
    goal: Cir_Term
    tactic: Cir_Tactic
    is_instance: bool
    anchor: Anchor
    timeout: None | int

# clique Imandrax_api_cir.Model.ty_def
# def Imandrax_api_cir.Model.ty_def (mangled name: "Cir_Model_ty_def")
type Cir_Model_ty_def = Cir_Model_ty_def[Cir_Term,Cir_Type]

# clique Imandrax_api_cir.Model.fi
# def Imandrax_api_cir.Model.fi (mangled name: "Cir_Model_fi")
type Cir_Model_fi = Cir_Model_fi[Cir_Term,Cir_Var,Cir_Type]

# clique Imandrax_api_cir.Model.t
# def Imandrax_api_cir.Model.t (mangled name: "Cir_Model")
type Cir_Model = Cir_Model[Cir_Term,Cir_Applied_symbol,Cir_Var,Cir_Type]

# clique Imandrax_api_cir.Instantiation_rule_kind.t
# def Imandrax_api_cir.Instantiation_rule_kind.t (mangled name: "Cir_Instantiation_rule_kind")
@dataclass(slots=True)
class Cir_Instantiation_rule_kind_IR_forward_chaining:
    pass

@dataclass(slots=True)
class Cir_Instantiation_rule_kind_IR_generalization:
    pass

type Cir_Instantiation_rule_kind = Cir_Instantiation_rule_kind_IR_forward_chaining| Cir_Instantiation_rule_kind_IR_generalization

# clique Imandrax_api_cir.Instantiation_rule.t
# def Imandrax_api_cir.Instantiation_rule.t (mangled name: "Cir_Instantiation_rule")
@dataclass(slots=True)
class Cir_Instantiation_rule:
    ir_from: Cir_Fun_def
    ir_triggers: list[Cir_Trigger]
    ir_kind: Cir_Instantiation_rule_kind

# clique Imandrax_api_cir.Elimination_rule.t
# def Imandrax_api_cir.Elimination_rule.t (mangled name: "Cir_Elimination_rule")
@dataclass(slots=True)
class Cir_Elimination_rule:
    er_name: Uid
    er_guard: list[Cir_Term]
    er_lhs: Cir_Term
    er_rhs: Cir_Var
    er_dests: list[Cir_Fo_pattern]
    er_dest_tms: list[Cir_Term]

# clique Imandrax_api_cir.Db_ser.uid_map
# def Imandrax_api_cir.Db_ser.uid_map (mangled name: "Cir_Db_ser_uid_map")
type Cir_Db_ser_uid_map[V_tyreg_poly_a] = list[tuple[Uid,"V_tyreg_poly_a"]]

# clique Imandrax_api_cir.Db_ser.ph_map
# def Imandrax_api_cir.Db_ser.ph_map (mangled name: "Cir_Db_ser_ph_map")
type Cir_Db_ser_ph_map[V_tyreg_poly_a] = list[tuple[Cir_Db_ser,"V_tyreg_poly_a"]]

# clique Imandrax_api_cir.Db_ser.ca_ptr
# def Imandrax_api_cir.Db_ser.ca_ptr (mangled name: "Cir_Db_ser_ca_ptr")
type Cir_Db_ser_ca_ptr[V_tyreg_poly_a] = Cir_Db_ser["V_tyreg_poly_a"]

# clique Imandrax_api_cir.Db_ser.t
# def Imandrax_api_cir.Db_ser.t (mangled name: "Cir_Db_ser")
@dataclass(slots=True)
class Cir_Db_ser:
    decls: Uid_set
    rw_rules: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    inst_rules: Cir_Db_ser_uid_map[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]
    rule_spec_fc: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    rule_spec_rw_rules: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    fc: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    elim: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Elimination_rule]]]
    gen: Cir_Db_ser_ph_map[list[Cir_Db_ser_ca_ptr[Cir_Trigger]]]
    thm_as_rw: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Rewrite_rule]]]
    thm_as_fc: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]]
    thm_as_elim: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Elimination_rule]]]
    thm_as_gen: Cir_Db_ser_uid_map[list[Cir_Db_ser_ca_ptr[Cir_Instantiation_rule]]]
    admission: Cir_Db_ser_uid_map[Cir_Db_ser_ca_ptr[Admission]]
    count_funs_of_ty: Cir_Db_ser_uid_map[Uid]
    config: Cir_Db_ser_ca_ptr[Cir_Logic_config]
    disabled: Uid_set

# clique Imandrax_api_eval.Ordinal.t
# def Imandrax_api_eval.Ordinal.t (mangled name: "Eval_Ordinal")
@dataclass(slots=True)
class Eval_Ordinal_Int:
    arg: int

@dataclass(slots=True)
class Eval_Ordinal_Cons:
    args: tuple[Eval_Ordinal,int,Eval_Ordinal]

type Eval_Ordinal = Eval_Ordinal_Int| Eval_Ordinal_Cons

# clique Imandrax_api_eval.Value.cstor_descriptor
# def Imandrax_api_eval.Value.cstor_descriptor (mangled name: "Eval_Value_cstor_descriptor")
@dataclass(slots=True)
class Eval_Value_cstor_descriptor:
    cd_idx: int
    cd_name: Eval_Value

# clique Imandrax_api_eval.Value.record_descriptor
# def Imandrax_api_eval.Value.record_descriptor (mangled name: "Eval_Value_record_descriptor")
@dataclass(slots=True)
class Eval_Value_record_descriptor:
    rd_name: Eval_Value
    rd_fields: list[Eval_Value]

# clique Imandrax_api_eval.Value.view
# def Imandrax_api_eval.Value.view (mangled name: "Eval_Value_view")
@dataclass(slots=True)
class Eval_Value_view_V_true[V_tyreg_poly_v,V_tyreg_poly_closure]:
    pass

@dataclass(slots=True)
class Eval_Value_view_V_false[V_tyreg_poly_v,V_tyreg_poly_closure]:
    pass

@dataclass(slots=True)
class Eval_Value_view_V_int[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: int

@dataclass(slots=True)
class Eval_Value_view_V_real[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: string

@dataclass(slots=True)
class Eval_Value_view_V_string[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: str

@dataclass(slots=True)
class Eval_Value_view_V_cstor[V_tyreg_poly_v,V_tyreg_poly_closure]:
    args: tuple[Eval_Value_cstor_descriptor,list["V_tyreg_poly_v"]]

@dataclass(slots=True)
class Eval_Value_view_V_tuple[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: list["V_tyreg_poly_v"]

@dataclass(slots=True)
class Eval_Value_view_V_record[V_tyreg_poly_v,V_tyreg_poly_closure]:
    args: tuple[Eval_Value_record_descriptor,list["V_tyreg_poly_v"]]

@dataclass(slots=True)
class Eval_Value_view_V_quoted_term[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: Eval_Value

@dataclass(slots=True)
class Eval_Value_view_V_uid[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: Eval_Value

@dataclass(slots=True)
class Eval_Value_view_V_closure[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: "V_tyreg_poly_closure"

@dataclass(slots=True)
class Eval_Value_view_V_custom[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: Eval_Value

@dataclass(slots=True)
class Eval_Value_view_V_ordinal[V_tyreg_poly_v,V_tyreg_poly_closure]:
    arg: Eval_Ordinal

type Eval_Value_view[V_tyreg_poly_v,V_tyreg_poly_closure] = Eval_Value_view_V_true[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_false[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_int[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_real[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_string[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_cstor[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_tuple[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_record[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_quoted_term[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_uid[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_closure[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_custom[V_tyreg_poly_v,V_tyreg_poly_closure]| Eval_Value_view_V_ordinal[V_tyreg_poly_v,V_tyreg_poly_closure]

# clique Imandrax_api_eval.Value.t
# def Imandrax_api_eval.Value.t (mangled name: "Eval_Value")
@dataclass(slots=True)
class Eval_Value:
    v: Eval_Value_view[Eval_Value,None]

# clique Imandrax_api_report.Expansion.t
# def Imandrax_api_report.Expansion.t (mangled name: "Report_Expansion")
@dataclass(slots=True)
class Report_Expansion[V_tyreg_poly_term]:
    f_name: Report_Expansion
    lhs: "V_tyreg_poly_term"
    rhs: "V_tyreg_poly_term"

# clique Imandrax_api_report.Instantiation.t
# def Imandrax_api_report.Instantiation.t (mangled name: "Report_Instantiation")
@dataclass(slots=True)
class Report_Instantiation[V_tyreg_poly_term]:
    assertion: "V_tyreg_poly_term"
    from_rule: Report_Instantiation

# clique Imandrax_api_report.Smt_proof.t
# def Imandrax_api_report.Smt_proof.t (mangled name: "Report_Smt_proof")
@dataclass(slots=True)
class Report_Smt_proof[V_tyreg_poly_term]:
    logic: Report_Smt_proof
    unsat_core: list["V_tyreg_poly_term"]
    expansions: list[Report_Expansion["V_tyreg_poly_term"]]
    instantiations: list[Report_Instantiation["V_tyreg_poly_term"]]

# clique Imandrax_api_report.Rtext.t,Imandrax_api_report.Rtext.item
# def Imandrax_api_report.Rtext.t (mangled name: "Report_Rtext")
type Report_Rtext[V_tyreg_poly_term] = list[Report_Rtext_item["V_tyreg_poly_term"]]
# def Imandrax_api_report.Rtext.item (mangled name: "Report_Rtext_item")
@dataclass(slots=True)
class Report_Rtext_item_S[V_tyreg_poly_term]:
    arg: str

@dataclass(slots=True)
class Report_Rtext_item_B[V_tyreg_poly_term]:
    arg: str

@dataclass(slots=True)
class Report_Rtext_item_I[V_tyreg_poly_term]:
    arg: str

@dataclass(slots=True)
class Report_Rtext_item_Newline[V_tyreg_poly_term]:
    pass

@dataclass(slots=True)
class Report_Rtext_item_Sub[V_tyreg_poly_term]:
    arg: Report_Rtext["V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Rtext_item_L[V_tyreg_poly_term]:
    arg: list[Report_Rtext["V_tyreg_poly_term"]]

@dataclass(slots=True)
class Report_Rtext_item_Uid[V_tyreg_poly_term]:
    arg: Report_Rtext

@dataclass(slots=True)
class Report_Rtext_item_Term[V_tyreg_poly_term]:
    arg: "V_tyreg_poly_term"

@dataclass(slots=True)
class Report_Rtext_item_Sequent[V_tyreg_poly_term]:
    arg: Report_Rtext["V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Rtext_item_Subst[V_tyreg_poly_term]:
    arg: list[tuple["V_tyreg_poly_term","V_tyreg_poly_term"]]

type Report_Rtext_item[V_tyreg_poly_term] = Report_Rtext_item_S[V_tyreg_poly_term]| Report_Rtext_item_B[V_tyreg_poly_term]| Report_Rtext_item_I[V_tyreg_poly_term]| Report_Rtext_item_Newline[V_tyreg_poly_term]| Report_Rtext_item_Sub[V_tyreg_poly_term]| Report_Rtext_item_L[V_tyreg_poly_term]| Report_Rtext_item_Uid[V_tyreg_poly_term]| Report_Rtext_item_Term[V_tyreg_poly_term]| Report_Rtext_item_Sequent[V_tyreg_poly_term]| Report_Rtext_item_Subst[V_tyreg_poly_term]

# clique Imandrax_api_report.Atomic_event.poly
# def Imandrax_api_report.Atomic_event.poly (mangled name: "Report_Atomic_event_poly")
@dataclass(slots=True)
class Report_Atomic_event_poly_E_message[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    arg: Report_Rtext["V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_title[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    arg: str

@dataclass(slots=True)
class Report_Atomic_event_poly_E_enter_waterfall[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    vars: list["V_tyreg_poly_var"]
    goal: "V_tyreg_poly_term"
    hints: Report_Atomic_event

@dataclass(slots=True)
class Report_Atomic_event_poly_E_enter_tactic[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    arg: str

@dataclass(slots=True)
class Report_Atomic_event_poly_E_rw_success[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple[Report_Atomic_event,"V_tyreg_poly_term","V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_rw_fail[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple[Report_Atomic_event,"V_tyreg_poly_term",str]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_inst_success[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple[Report_Atomic_event,"V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_waterfall_checkpoint[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    arg: list[Report_Atomic_event["V_tyreg_poly_term"]]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_induction_scheme[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    arg: "V_tyreg_poly_term"

@dataclass(slots=True)
class Report_Atomic_event_poly_E_attack_subgoal[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    name: str
    goal: Report_Atomic_event["V_tyreg_poly_term"]
    depth: int

@dataclass(slots=True)
class Report_Atomic_event_poly_E_simplify_t[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple["V_tyreg_poly_term","V_tyreg_poly_term"]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_simplify_clause[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple["V_tyreg_poly_term",list["V_tyreg_poly_term"]]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_proved_by_smt[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple["V_tyreg_poly_term",Report_Smt_proof["V_tyreg_poly_term"]]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_refuted_by_smt[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple["V_tyreg_poly_term",None | Report_Atomic_event["V_tyreg_poly_term","V_tyreg_poly_fn","V_tyreg_poly_var","V_tyreg_poly_ty"]]

@dataclass(slots=True)
class Report_Atomic_event_poly_E_fun_expansion[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]:
    args: tuple["V_tyreg_poly_term","V_tyreg_poly_term"]

type Report_Atomic_event_poly[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty] = Report_Atomic_event_poly_E_message[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_title[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_enter_waterfall[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_enter_tactic[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_rw_success[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_rw_fail[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_inst_success[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_waterfall_checkpoint[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_induction_scheme[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_attack_subgoal[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_simplify_t[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_simplify_clause[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_proved_by_smt[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_refuted_by_smt[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]| Report_Atomic_event_poly_E_fun_expansion[V_tyreg_poly_term,V_tyreg_poly_fn,V_tyreg_poly_var,V_tyreg_poly_ty]

# clique Imandrax_api_report.Atomic_event.t
# def Imandrax_api_report.Atomic_event.t (mangled name: "Report_Atomic_event")
type Report_Atomic_event = Report_Atomic_event_poly[Report_Atomic_event,Report_Atomic_event,Report_Atomic_event,Report_Atomic_event]

# clique Imandrax_api_report.Event.t_linear
# def Imandrax_api_report.Event.t_linear (mangled name: "Report_Event_t_linear")
@dataclass(slots=True)
class Report_Event_t_linear_EL_atomic[V_tyreg_poly_atomic_ev]:
    ts: float
    ev: "V_tyreg_poly_atomic_ev"

@dataclass(slots=True)
class Report_Event_t_linear_EL_enter_span[V_tyreg_poly_atomic_ev]:
    ts: float
    ev: "V_tyreg_poly_atomic_ev"

@dataclass(slots=True)
class Report_Event_t_linear_EL_exit_span[V_tyreg_poly_atomic_ev]:
    ts: float

type Report_Event_t_linear[V_tyreg_poly_atomic_ev] = Report_Event_t_linear_EL_atomic[V_tyreg_poly_atomic_ev]| Report_Event_t_linear_EL_enter_span[V_tyreg_poly_atomic_ev]| Report_Event_t_linear_EL_exit_span[V_tyreg_poly_atomic_ev]

# clique Imandrax_api_report.Event.t_tree
# def Imandrax_api_report.Event.t_tree (mangled name: "Report_Event_t_tree")
@dataclass(slots=True)
class Report_Event_t_tree_ET_atomic[V_tyreg_poly_atomic_ev,V_tyreg_poly_sub]:
    ts: float
    ev: "V_tyreg_poly_atomic_ev"

@dataclass(slots=True)
class Report_Event_t_tree_ET_span[V_tyreg_poly_atomic_ev,V_tyreg_poly_sub]:
    ts: float
    duration: float
    ev: "V_tyreg_poly_atomic_ev"
    sub: "V_tyreg_poly_sub"

type Report_Event_t_tree[V_tyreg_poly_atomic_ev,V_tyreg_poly_sub] = Report_Event_t_tree_ET_atomic[V_tyreg_poly_atomic_ev,V_tyreg_poly_sub]| Report_Event_t_tree_ET_span[V_tyreg_poly_atomic_ev,V_tyreg_poly_sub]

# clique Imandrax_api_report.Report.event
# def Imandrax_api_report.Report.event (mangled name: "Report_Report_event")
type Report_Report_event = Report_Event_t_linear[Report_Atomic_event]

# clique Imandrax_api_report.Report.t
# def Imandrax_api_report.Report.t (mangled name: "Report_Report")
@dataclass(slots=True)
class Report_Report:
    events: list[Report_Report_event]

# clique Imandrax_api_proof.Arg.t
# def Imandrax_api_proof.Arg.t (mangled name: "Proof_Arg")
@dataclass(slots=True)
class Proof_Arg_A_term[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: "V_tyreg_poly_term"

@dataclass(slots=True)
class Proof_Arg_A_ty[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: "V_tyreg_poly_ty"

@dataclass(slots=True)
class Proof_Arg_A_int[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: int

@dataclass(slots=True)
class Proof_Arg_A_string[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: str

@dataclass(slots=True)
class Proof_Arg_A_list[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: list[Proof_Arg["V_tyreg_poly_term","V_tyreg_poly_ty"]]

@dataclass(slots=True)
class Proof_Arg_A_dict[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: list[tuple[str,Proof_Arg["V_tyreg_poly_term","V_tyreg_poly_ty"]]]

@dataclass(slots=True)
class Proof_Arg_A_seq[V_tyreg_poly_term,V_tyreg_poly_ty]:
    arg: Proof_Arg["V_tyreg_poly_term"]

type Proof_Arg[V_tyreg_poly_term,V_tyreg_poly_ty] = Proof_Arg_A_term[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_ty[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_int[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_string[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_list[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_dict[V_tyreg_poly_term,V_tyreg_poly_ty]| Proof_Arg_A_seq[V_tyreg_poly_term,V_tyreg_poly_ty]

# clique Imandrax_api_proof.Var_poly.t
# def Imandrax_api_proof.Var_poly.t (mangled name: "Proof_Var_poly")
type Proof_Var_poly[V_tyreg_poly_ty] = tuple[Proof_Var_poly,"V_tyreg_poly_ty"]

# clique Imandrax_api_proof.View.t
# def Imandrax_api_proof.View.t (mangled name: "Proof_View")
@dataclass(slots=True)
class Proof_View_T_assume[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]:
    pass

@dataclass(slots=True)
class Proof_View_T_subst[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]:
    t_subst: list[tuple[Proof_Var_poly["V_tyreg_poly_ty"],"V_tyreg_poly_term"]]
    ty_subst: list[tuple[Proof_View,"V_tyreg_poly_ty"]]
    premise: "V_tyreg_poly_proof"

@dataclass(slots=True)
class Proof_View_T_deduction[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]:
    premises: list[tuple[str,list["V_tyreg_poly_proof"]]]

@dataclass(slots=True)
class Proof_View_T_rule[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]:
    rule: str
    args: list[Proof_Arg["V_tyreg_poly_term","V_tyreg_poly_ty"]]

type Proof_View[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof] = Proof_View_T_assume[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]| Proof_View_T_subst[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]| Proof_View_T_deduction[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]| Proof_View_T_rule[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]

# clique Imandrax_api_proof.Proof_term_poly.t
# def Imandrax_api_proof.Proof_term_poly.t (mangled name: "Proof_Proof_term_poly")
@dataclass(slots=True)
class Proof_Proof_term_poly[V_tyreg_poly_term,V_tyreg_poly_ty,V_tyreg_poly_proof]:
    id: int
    concl: Proof_Proof_term_poly["V_tyreg_poly_term"]
    view: Proof_View["V_tyreg_poly_term","V_tyreg_poly_ty","V_tyreg_poly_proof"]

# clique Imandrax_api_proof.Cir_proof_term.t,Imandrax_api_proof.Cir_proof_term.t_inner
# def Imandrax_api_proof.Cir_proof_term.t (mangled name: "Proof_Cir_proof_term")
@dataclass(slots=True)
class Proof_Cir_proof_term:
    p: Proof_Cir_proof_term_t_inner
# def Imandrax_api_proof.Cir_proof_term.t_inner (mangled name: "Proof_Cir_proof_term_t_inner")
type Proof_Cir_proof_term_t_inner = Proof_Proof_term_poly[Proof_Cir_proof_term,Proof_Cir_proof_term,Proof_Cir_proof_term]

# clique Imandrax_api_tasks.PO_task.t
# def Imandrax_api_tasks.PO_task.t (mangled name: "Tasks_PO_task")
@dataclass(slots=True)
class Tasks_PO_task:
    from_sym: str
    count: int
    db: Tasks_PO_task
    po: Tasks_PO_task

# clique Imandrax_api_tasks.PO_res.stats
# def Imandrax_api_tasks.PO_res.stats (mangled name: "Tasks_PO_res_stats")
type Tasks_PO_res_stats = Stat_time

# clique Imandrax_api_tasks.PO_res.proof_found
# def Imandrax_api_tasks.PO_res.proof_found (mangled name: "Tasks_PO_res_proof_found")
@dataclass(slots=True)
class Tasks_PO_res_proof_found:
    anchor: Tasks_PO_res
    proof: Tasks_PO_res

# clique Imandrax_api_tasks.PO_res.instance
# def Imandrax_api_tasks.PO_res.instance (mangled name: "Tasks_PO_res_instance")
@dataclass(slots=True)
class Tasks_PO_res_instance:
    anchor: Tasks_PO_res
    model: Tasks_PO_res

# clique Imandrax_api_tasks.PO_res.no_proof
# def Imandrax_api_tasks.PO_res.no_proof (mangled name: "Tasks_PO_res_no_proof")
@dataclass(slots=True)
class Tasks_PO_res_no_proof:
    err: Tasks_PO_res
    counter_model: None | Tasks_PO_res
    subgoals: list[Tasks_PO_res]

# clique Imandrax_api_tasks.PO_res.unsat
# def Imandrax_api_tasks.PO_res.unsat (mangled name: "Tasks_PO_res_unsat")
@dataclass(slots=True)
class Tasks_PO_res_unsat:
    anchor: Tasks_PO_res
    err: Tasks_PO_res
    proof: Tasks_PO_res

# clique Imandrax_api_tasks.PO_res.success
# def Imandrax_api_tasks.PO_res.success (mangled name: "Tasks_PO_res_success")
@dataclass(slots=True)
class Tasks_PO_res_success_Proof:
    arg: Tasks_PO_res_proof_found

@dataclass(slots=True)
class Tasks_PO_res_success_Instance:
    arg: Tasks_PO_res_instance

type Tasks_PO_res_success = Tasks_PO_res_success_Proof| Tasks_PO_res_success_Instance

# clique Imandrax_api_tasks.PO_res.error
# def Imandrax_api_tasks.PO_res.error (mangled name: "Tasks_PO_res_error")
@dataclass(slots=True)
class Tasks_PO_res_error_No_proof:
    arg: Tasks_PO_res_no_proof

@dataclass(slots=True)
class Tasks_PO_res_error_Unsat:
    arg: Tasks_PO_res_unsat

@dataclass(slots=True)
class Tasks_PO_res_error_Invalid_model:
    args: tuple[Tasks_PO_res,Tasks_PO_res]

@dataclass(slots=True)
class Tasks_PO_res_error_Error:
    arg: Tasks_PO_res

type Tasks_PO_res_error = Tasks_PO_res_error_No_proof| Tasks_PO_res_error_Unsat| Tasks_PO_res_error_Invalid_model| Tasks_PO_res_error_Error

# clique Imandrax_api_tasks.PO_res.result
# def Imandrax_api_tasks.PO_res.result (mangled name: "Tasks_PO_res_result")
type Tasks_PO_res_result[V_tyreg_poly_a] = Tasks_PO_res["V_tyreg_poly_a",Tasks_PO_res_error]

# clique Imandrax_api_tasks.PO_res.t
# def Imandrax_api_tasks.PO_res.t (mangled name: "Tasks_PO_res")
@dataclass(slots=True)
class Tasks_PO_res:
    from: Tasks_PO_res[Tasks_PO_res]
    res: Tasks_PO_res_result[Tasks_PO_res_success]
    stats: Tasks_PO_res_stats
    report: Tasks_PO_res[Report_Report]

# clique Imandrax_api_tasks.Eval_task.t
# def Imandrax_api_tasks.Eval_task.t (mangled name: "Tasks_Eval_task")
@dataclass(slots=True)
class Tasks_Eval_task:
    db: Tasks_Eval_task
    term: Tasks_Eval_task
    anchor: Tasks_Eval_task
    timeout: None | int

# clique Imandrax_api_tasks.Eval_res.value
# def Imandrax_api_tasks.Eval_res.value (mangled name: "Tasks_Eval_res_value")
type Tasks_Eval_res_value = Tasks_Eval_res

# clique Imandrax_api_tasks.Eval_res.stats
# def Imandrax_api_tasks.Eval_res.stats (mangled name: "Tasks_Eval_res_stats")
@dataclass(slots=True)
class Tasks_Eval_res_stats:
    compile_time: float
    exec_time: float

# clique Imandrax_api_tasks.Eval_res.success
# def Imandrax_api_tasks.Eval_res.success (mangled name: "Tasks_Eval_res_success")
@dataclass(slots=True)
class Tasks_Eval_res_success:
    v: Tasks_Eval_res_value

# clique Imandrax_api_tasks.Eval_res.t
# def Imandrax_api_tasks.Eval_res.t (mangled name: "Tasks_Eval_res")
@dataclass(slots=True)
class Tasks_Eval_res:
    res: Error | Tasks_Eval_res_success
    stats: Tasks_Eval_res_stats
