# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Python bindings for the ImandraX API types.

Types live in one module per OCaml module, eg. `lib.common.region.Region`
for `Imandrax_api_common.Region.t_poly`. The flat names of earlier versions
(eg. `Common_Region_t_poly`) are re-exported here for backward compatibility.
"""

from . import twine as twine
from . import _runtime as _rt
from . import error as error
from . import core as core
from . import ca_store as ca_store
from . import common as common
from . import mir as mir
from . import eval as eval
from . import report as report
from . import proof as proof
from . import tasks as tasks
from . import artifact as artifact
from .artifact import Artifact as Artifact
from .artifact import artifact_decoders as artifact_decoders
from .artifact import read_artifact_data as read_artifact_data
from .artifact import read_artifact_zip as read_artifact_zip
from .artifact import RegionStr as RegionStr
from .artifact import region_meta_value as region_meta_value
from .artifact import get_region_str_from_decomp_artifact as get_region_str_from_decomp_artifact
from .artifact import unwrap_region_str as unwrap_region_str
from .tasks import po_task as _tasks_po_task
from .tasks import po_res as _tasks_po_res
from .tasks import eval_task as _tasks_eval_task
from .tasks import eval_res as _tasks_eval_res
from .tasks import decomp_task as _tasks_decomp_task
from .tasks import decomp_res as _tasks_decomp_res
from .report import smt_proof as _report_smt_proof
from .report import rtext as _report_rtext
from .report import report as _report_report
from .report import instantiation as _report_instantiation
from .report import expansion as _report_expansion
from .report import event as _report_event
from .report import atomic_event as _report_atomic_event
from .proof import view as _proof_view
from .proof import var_poly as _proof_var_poly
from .proof import proof_term as _proof_proof_term
from .proof import arg as _proof_arg
from .mir import var as _mir_var
from .mir import typed_symbol as _mir_typed_symbol
from .mir import type_schema as _mir_type_schema
from .mir import type as _mir_type
from .mir import trigger as _mir_trigger
from .mir import top_fun as _mir_top_fun
from .mir import theorem as _mir_theorem
from .mir import term as _mir_term
from .mir import tactic as _mir_tactic
from .mir import sequent as _mir_sequent
from .mir import rewrite_rule as _mir_rewrite_rule
from .mir import region as _mir_region
from .mir import proof_obligation as _mir_proof_obligation
from .mir import pre_trigger as _mir_pre_trigger
from .mir import pattern_head as _mir_pattern_head
from .mir import model as _mir_model
from .mir import instantiation_rule as _mir_instantiation_rule
from .mir import hints as _mir_hints
from .mir import fun_def as _mir_fun_def
from .mir import fun_decomp as _mir_fun_decomp
from .mir import fo_pattern as _mir_fo_pattern
from .mir import elimination_rule as _mir_elimination_rule
from .mir import decomp as _mir_decomp
from .mir import decl as _mir_decl
from .mir import db_ser as _mir_db_ser
from .mir import applied_symbol as _mir_applied_symbol
from .eval import value as _eval_value
from .eval import ordinal as _eval_ordinal
from .error import kind as _error_kind
from .error import error_core as _error_error_core
from .core import upto as _core_upto
from .core import uid_set as _core_uid_set
from .core import uid as _core_uid
from .core import ty_view as _core_ty_view
from .core import sub_anchor as _core_sub_anchor
from .core import statistics as _core_statistics
from .core import misc_types as _core_misc_types
from .core import logic_fragment as _core_logic_fragment
from .core import in_mem_archive as _core_in_mem_archive
from .core import const as _core_const
from .core import cname as _core_cname
from .core import clique as _core_clique
from .core import chash as _core_chash
from .core import case_poly as _core_case_poly
from .core import builtin_data as _core_builtin_data
from .core import builtin as _core_builtin
from .core import as_trigger as _core_as_trigger
from .core import anchor as _core_anchor
from .common import verify as _common_verify
from .common import var as _common_var
from .common import typed_symbol as _common_typed_symbol
from .common import type_schema as _common_type_schema
from .common import trigger as _common_trigger
from .common import theorem as _common_theorem
from .common import tactic as _common_tactic
from .common import sequent as _common_sequent
from .common import rule_spec as _common_rule_spec
from .common import rewrite_rule as _common_rewrite_rule
from .common import region as _common_region
from .common import proof_obligation as _common_proof_obligation
from .common import pre_trigger as _common_pre_trigger
from .common import pattern_head as _common_pattern_head
from .common import model as _common_model
from .common import instantiation_rule_kind as _common_instantiation_rule_kind
from .common import instantiation_rule as _common_instantiation_rule
from .common import hints as _common_hints
from .common import fun_def as _common_fun_def
from .common import fun_decomp as _common_fun_decomp
from .common import fo_pattern as _common_fo_pattern
from .common import elimination_rule as _common_elimination_rule
from .common import decomp as _common_decomp
from .common import decl as _common_decl
from .common import db_ser as _common_db_ser
from .common import db_op as _common_db_op
from .common import applied_symbol as _common_applied_symbol
from .common import admission as _common_admission
from .ca_store import key as _ca_store_key
from .ca_store import ca_ptr as _ca_store_ca_ptr

# Legacy flat names
# =================

twine_result = _rt.twine_result
type WithTag6[T] = _rt.WithTag6[T]
type WithTag7[T] = _rt.WithTag7[T]
decode_with_tag = _rt.decode_with_tag
decode_q = _rt.decode_q
Void_of_twine = _rt.decode_void
Eval__Value_Custom_value = _rt.Custom_value
Eval__Value_Custom_value_of_twine = _rt.decode_custom_value
Error = _error_error_core.ErrorCore

Error_Kind = _error_kind.Kind
Error_Kind_of_twine = _error_kind.Kind_of_twine

Error_Error_core_message = _error_error_core.Message
Error_Error_core_message_of_twine = _error_error_core.Message_of_twine

Error_Error_core_stack = _error_error_core.Stack
Error_Error_core_stack_of_twine = _error_error_core.Stack_of_twine

Error_Error_core = _error_error_core.ErrorCore
Error_Error_core_of_twine = _error_error_core.ErrorCore_of_twine

Upto_N_steps = _core_upto.NSteps
Upto_N_steps_of_twine = _core_upto.NSteps_of_twine
Upto = _core_upto.Upto
Upto_of_twine = _core_upto.Upto_of_twine

Builtin_data_kind_Logic_core = _core_builtin_data.KindLogicCore
Builtin_data_kind_Logic_core_of_twine = _core_builtin_data.KindLogicCore_of_twine
Builtin_data_kind_Special = _core_builtin_data.KindSpecial
Builtin_data_kind_Special_of_twine = _core_builtin_data.KindSpecial_of_twine
Builtin_data_kind_Tactic = _core_builtin_data.KindTactic
Builtin_data_kind_Tactic_of_twine = _core_builtin_data.KindTactic_of_twine
Builtin_data_kind_Decomp = _core_builtin_data.KindDecomp
Builtin_data_kind_Decomp_of_twine = _core_builtin_data.KindDecomp_of_twine
Builtin_data_kind = _core_builtin_data.Kind
Builtin_data_kind_of_twine = _core_builtin_data.Kind_of_twine

Chash = _core_chash.Chash
Chash_of_twine = _core_chash.Chash_of_twine

Cname_t_ = _core_cname.CnameT
Cname_t__of_twine = _core_cname.CnameT_of_twine

Cname = _core_cname.Cname
Cname_of_twine = _core_cname.Cname_of_twine

Uid_gen_kind_Local = _core_uid.GenKindLocal
Uid_gen_kind_To_be_rewritten = _core_uid.GenKindToBeRewritten
Uid_gen_kind = _core_uid.GenKind
Uid_gen_kind_of_twine = _core_uid.GenKind_of_twine

Uid_view_Generative = _core_uid.ViewGenerative
Uid_view_Generative_of_twine = _core_uid.ViewGenerative_of_twine
Uid_view_Persistent = _core_uid.ViewPersistent
Uid_view_Cname = _core_uid.ViewCname
Uid_view_Cname_of_twine = _core_uid.ViewCname_of_twine
Uid_view_Builtin = _core_uid.ViewBuiltin
Uid_view_Builtin_of_twine = _core_uid.ViewBuiltin_of_twine
Uid_view = _core_uid.View
Uid_view_of_twine = _core_uid.View_of_twine

Uid = _core_uid.Uid
Uid_of_twine = _core_uid.Uid_of_twine

Uid_set = _core_uid_set.UidSet
Uid_set_of_twine = _core_uid_set.UidSet_of_twine

Builtin_Fun = _core_builtin.Fun
Builtin_Fun_of_twine = _core_builtin.Fun_of_twine

Builtin_Ty = _core_builtin.Ty
Builtin_Ty_of_twine = _core_builtin.Ty_of_twine

Clique = _core_clique.Clique
Clique_of_twine = _core_clique.Clique_of_twine

Ty_view_adt_row = _core_ty_view.AdtRow
Ty_view_adt_row_of_twine = _core_ty_view.AdtRow_of_twine

Ty_view_rec_row = _core_ty_view.RecRow
Ty_view_rec_row_of_twine = _core_ty_view.RecRow_of_twine

Ty_view_decl_Algebraic = _core_ty_view.DeclAlgebraic
Ty_view_decl_Algebraic_of_twine = _core_ty_view.DeclAlgebraic_of_twine
Ty_view_decl_Record = _core_ty_view.DeclRecord
Ty_view_decl_Record_of_twine = _core_ty_view.DeclRecord_of_twine
Ty_view_decl_Alias = _core_ty_view.DeclAlias
Ty_view_decl_Alias_of_twine = _core_ty_view.DeclAlias_of_twine
Ty_view_decl_Skolem = _core_ty_view.DeclSkolem
Ty_view_decl_Builtin = _core_ty_view.DeclBuiltin
Ty_view_decl_Builtin_of_twine = _core_ty_view.DeclBuiltin_of_twine
Ty_view_decl_Other = _core_ty_view.DeclOther
Ty_view_decl = _core_ty_view.Decl
Ty_view_decl_of_twine = _core_ty_view.Decl_of_twine

Ty_view_view_Var = _core_ty_view.ViewVar
Ty_view_view_Var_of_twine = _core_ty_view.ViewVar_of_twine
Ty_view_view_Arrow = _core_ty_view.ViewArrow
Ty_view_view_Arrow_of_twine = _core_ty_view.ViewArrow_of_twine
Ty_view_view_Tuple = _core_ty_view.ViewTuple
Ty_view_view_Tuple_of_twine = _core_ty_view.ViewTuple_of_twine
Ty_view_view_Constr = _core_ty_view.ViewConstr
Ty_view_view_Constr_of_twine = _core_ty_view.ViewConstr_of_twine
Ty_view_view = _core_ty_view.View
Ty_view_view_of_twine = _core_ty_view.View_of_twine

Ty_view_def_poly = _core_ty_view.Def
Ty_view_def_poly_of_twine = _core_ty_view.Def_of_twine

Sub_anchor_fname = _core_sub_anchor.Fname
Sub_anchor_fname_of_twine = _core_sub_anchor.Fname_of_twine

Sub_anchor = _core_sub_anchor.SubAnchor
Sub_anchor_of_twine = _core_sub_anchor.SubAnchor_of_twine

Statistics = _core_statistics.Statistics
Statistics_of_twine = _core_statistics.Statistics_of_twine

Misc_types_rec_flag_Recursive = _core_misc_types.RecFlagRecursive
Misc_types_rec_flag_Nonrecursive = _core_misc_types.RecFlagNonrecursive
Misc_types_rec_flag = _core_misc_types.RecFlag
Misc_types_rec_flag_of_twine = _core_misc_types.RecFlag_of_twine

Misc_types_apply_label_Nolabel = _core_misc_types.ApplyLabelNolabel
Misc_types_apply_label_Label = _core_misc_types.ApplyLabelLabel
Misc_types_apply_label_Label_of_twine = _core_misc_types.ApplyLabelLabel_of_twine
Misc_types_apply_label_Optional = _core_misc_types.ApplyLabelOptional
Misc_types_apply_label_Optional_of_twine = _core_misc_types.ApplyLabelOptional_of_twine
Misc_types_apply_label = _core_misc_types.ApplyLabel
Misc_types_apply_label_of_twine = _core_misc_types.ApplyLabel_of_twine

Logic_fragment = _core_logic_fragment.LogicFragment
Logic_fragment_of_twine = _core_logic_fragment.LogicFragment_of_twine

In_mem_archive_raw = _core_in_mem_archive.Raw
In_mem_archive_raw_of_twine = _core_in_mem_archive.Raw_of_twine

In_mem_archive = _core_in_mem_archive.InMemArchive
In_mem_archive_of_twine = _core_in_mem_archive.InMemArchive_of_twine

Const_Const_float = _core_const.ConstFloat
Const_Const_float_of_twine = _core_const.ConstFloat_of_twine
Const_Const_string = _core_const.ConstString
Const_Const_string_of_twine = _core_const.ConstString_of_twine
Const_Const_z = _core_const.ConstZ
Const_Const_z_of_twine = _core_const.ConstZ_of_twine
Const_Const_q = _core_const.ConstQ
Const_Const_q_of_twine = _core_const.ConstQ_of_twine
Const_Const_real_approx = _core_const.ConstRealApprox
Const_Const_real_approx_of_twine = _core_const.ConstRealApprox_of_twine
Const_Const_uid = _core_const.ConstUid
Const_Const_uid_of_twine = _core_const.ConstUid_of_twine
Const_Const_bool = _core_const.ConstBool
Const_Const_bool_of_twine = _core_const.ConstBool_of_twine
Const = _core_const.Const
Const_of_twine = _core_const.Const_of_twine

Case_poly_t_poly = _core_case_poly.CasePoly
Case_poly_t_poly_of_twine = _core_case_poly.CasePoly_of_twine

As_trigger_Trig_none = _core_as_trigger.TrigNone
As_trigger_Trig_anon = _core_as_trigger.TrigAnon
As_trigger_Trig_named = _core_as_trigger.TrigNamed
As_trigger_Trig_named_of_twine = _core_as_trigger.TrigNamed_of_twine
As_trigger_Trig_rw = _core_as_trigger.TrigRw
As_trigger = _core_as_trigger.AsTrigger
As_trigger_of_twine = _core_as_trigger.AsTrigger_of_twine

Anchor_Named = _core_anchor.Named
Anchor_Named_of_twine = _core_anchor.Named_of_twine
Anchor_Eval = _core_anchor.Eval
Anchor_Eval_of_twine = _core_anchor.Eval_of_twine
Anchor_Proof_check = _core_anchor.ProofCheck
Anchor_Proof_check_of_twine = _core_anchor.ProofCheck_of_twine
Anchor_Decomp = _core_anchor.Decomp
Anchor_Decomp_of_twine = _core_anchor.Decomp_of_twine
Anchor = _core_anchor.Anchor
Anchor_of_twine = _core_anchor.Anchor_of_twine

Ca_store_Key = _ca_store_key.Key
Ca_store_Key_of_twine = _ca_store_key.Key_of_twine

Ca_store_Ca_ptr_Raw = _ca_store_ca_ptr.Raw
Ca_store_Ca_ptr_Raw_of_twine = _ca_store_ca_ptr.Raw_of_twine

Ca_store_Ca_ptr = _ca_store_ca_ptr.CaPtr
Ca_store_Ca_ptr_of_twine = _ca_store_ca_ptr.CaPtr_of_twine

Common_Admission = _common_admission.Admission
Common_Admission_of_twine = _common_admission.Admission_of_twine

Common_Var_t_poly = _common_var.Var
Common_Var_t_poly_of_twine = _common_var.Var_of_twine

Common_Hints_validation_strategy_VS_validate = _common_hints.VS_Validate
Common_Hints_validation_strategy_VS_validate_of_twine = _common_hints.VS_Validate_of_twine
Common_Hints_validation_strategy_VS_no_validate = _common_hints.VS_NoValidate
Common_Hints_validation_strategy = _common_hints.ValidationStrategy
Common_Hints_validation_strategy_of_twine = _common_hints.ValidationStrategy_of_twine

Common_Hints_t_poly = _common_hints.Hints
Common_Hints_t_poly_of_twine = _common_hints.Hints_of_twine

Common_Type_schema_t_poly = _common_type_schema.TypeSchema
Common_Type_schema_t_poly_of_twine = _common_type_schema.TypeSchema_of_twine

Common_Fun_def_fun_kind_Fun_defined = _common_fun_def.FunKindFunDefined
Common_Fun_def_fun_kind_Fun_defined_of_twine = _common_fun_def.FunKindFunDefined_of_twine
Common_Fun_def_fun_kind_Fun_builtin = _common_fun_def.FunKindFunBuiltin
Common_Fun_def_fun_kind_Fun_builtin_of_twine = _common_fun_def.FunKindFunBuiltin_of_twine
Common_Fun_def_fun_kind_Fun_opaque = _common_fun_def.FunKindFunOpaque
Common_Fun_def_fun_kind = _common_fun_def.FunKind
Common_Fun_def_fun_kind_of_twine = _common_fun_def.FunKind_of_twine

Common_Fun_def_t_poly = _common_fun_def.FunDef
Common_Fun_def_t_poly_of_twine = _common_fun_def.FunDef_of_twine

Common_Verify_kind_K_verify = _common_verify.K_Verify
Common_Verify_kind_K_instance = _common_verify.K_Instance
Common_Verify_kind_K_test = _common_verify.K_Test
Common_Verify_kind = _common_verify.Kind
Common_Verify_kind_of_twine = _common_verify.Kind_of_twine

Common_Verify_t_poly = _common_verify.Verify
Common_Verify_t_poly_of_twine = _common_verify.Verify_of_twine

Common_Typed_symbol_t_poly = _common_typed_symbol.TypedSymbol
Common_Typed_symbol_t_poly_of_twine = _common_typed_symbol.TypedSymbol_of_twine

Common_Applied_symbol_t_poly = _common_applied_symbol.AppliedSymbol
Common_Applied_symbol_t_poly_of_twine = _common_applied_symbol.AppliedSymbol_of_twine

Common_Fo_pattern_view_FO_any = _common_fo_pattern.FO_Any
Common_Fo_pattern_view_FO_bool = _common_fo_pattern.FO_Bool
Common_Fo_pattern_view_FO_bool_of_twine = _common_fo_pattern.FO_Bool_of_twine
Common_Fo_pattern_view_FO_const = _common_fo_pattern.FO_Const
Common_Fo_pattern_view_FO_const_of_twine = _common_fo_pattern.FO_Const_of_twine
Common_Fo_pattern_view_FO_var = _common_fo_pattern.FO_Var
Common_Fo_pattern_view_FO_var_of_twine = _common_fo_pattern.FO_Var_of_twine
Common_Fo_pattern_view_FO_app = _common_fo_pattern.FO_App
Common_Fo_pattern_view_FO_app_of_twine = _common_fo_pattern.FO_App_of_twine
Common_Fo_pattern_view_FO_cstor = _common_fo_pattern.FO_Cstor
Common_Fo_pattern_view_FO_cstor_of_twine = _common_fo_pattern.FO_Cstor_of_twine
Common_Fo_pattern_view_FO_destruct = _common_fo_pattern.FO_Destruct
Common_Fo_pattern_view_FO_destruct_of_twine = _common_fo_pattern.FO_Destruct_of_twine
Common_Fo_pattern_view_FO_is_a = _common_fo_pattern.FO_IsA
Common_Fo_pattern_view_FO_is_a_of_twine = _common_fo_pattern.FO_IsA_of_twine
Common_Fo_pattern_view = _common_fo_pattern.View
Common_Fo_pattern_view_of_twine = _common_fo_pattern.View_of_twine

Common_Fo_pattern_t_poly = _common_fo_pattern.FoPattern
Common_Fo_pattern_t_poly_of_twine = _common_fo_pattern.FoPattern_of_twine

Common_Pattern_head_t_poly_PH_id = _common_pattern_head.PH_Id
Common_Pattern_head_t_poly_PH_id_of_twine = _common_pattern_head.PH_Id_of_twine
Common_Pattern_head_t_poly_PH_ty = _common_pattern_head.PH_Ty
Common_Pattern_head_t_poly_PH_ty_of_twine = _common_pattern_head.PH_Ty_of_twine
Common_Pattern_head_t_poly_PH_datatype_op = _common_pattern_head.PH_DatatypeOp
Common_Pattern_head_t_poly = _common_pattern_head.PatternHead
Common_Pattern_head_t_poly_of_twine = _common_pattern_head.PatternHead_of_twine

Common_Trigger_t_poly = _common_trigger.Trigger
Common_Trigger_t_poly_of_twine = _common_trigger.Trigger_of_twine

Common_Pre_trigger_t_poly = _common_pre_trigger.PreTrigger
Common_Pre_trigger_t_poly_of_twine = _common_pre_trigger.PreTrigger_of_twine

Common_Theorem_t_poly = _common_theorem.Theorem
Common_Theorem_t_poly_of_twine = _common_theorem.Theorem_of_twine

Common_Tactic_t_poly_Default_termination = _common_tactic.DefaultTermination
Common_Tactic_t_poly_Default_termination_of_twine = _common_tactic.DefaultTermination_of_twine
Common_Tactic_t_poly_Default_thm = _common_tactic.DefaultThm
Common_Tactic_t_poly_Default_thm_of_twine = _common_tactic.DefaultThm_of_twine
Common_Tactic_t_poly_Default_test = _common_tactic.DefaultTest
Common_Tactic_t_poly_Default_test_of_twine = _common_tactic.DefaultTest_of_twine
Common_Tactic_t_poly_Term = _common_tactic.Term
Common_Tactic_t_poly_Term_of_twine = _common_tactic.Term_of_twine
Common_Tactic_t_poly = _common_tactic.Tactic
Common_Tactic_t_poly_of_twine = _common_tactic.Tactic_of_twine

Common_Sequent_t_poly = _common_sequent.Sequent
Common_Sequent_t_poly_of_twine = _common_sequent.Sequent_of_twine

Common_Rule_spec_t_poly = _common_rule_spec.RuleSpec
Common_Rule_spec_t_poly_of_twine = _common_rule_spec.RuleSpec_of_twine

Common_Rewrite_rule_t_poly = _common_rewrite_rule.RewriteRule
Common_Rewrite_rule_t_poly_of_twine = _common_rewrite_rule.RewriteRule_of_twine

Common_Model_ty_def_Ty_finite = _common_model.TyDefTyFinite
Common_Model_ty_def_Ty_finite_of_twine = _common_model.TyDefTyFinite_of_twine
Common_Model_ty_def_Ty_alias_unit = _common_model.TyDefTyAliasUnit
Common_Model_ty_def_Ty_alias_unit_of_twine = _common_model.TyDefTyAliasUnit_of_twine
Common_Model_ty_def = _common_model.TyDef
Common_Model_ty_def_of_twine = _common_model.TyDef_of_twine

Common_Model_fi = _common_model.Fi
Common_Model_fi_of_twine = _common_model.Fi_of_twine

Common_Model_t_poly = _common_model.Model
Common_Model_t_poly_of_twine = _common_model.Model_of_twine

Common_Region_status_Unknown = _common_region.StatusUnknown
Common_Region_status_Feasible = _common_region.StatusFeasible
Common_Region_status_Feasible_of_twine = _common_region.StatusFeasible_of_twine
Common_Region_status_Feasibility_check_failed = _common_region.StatusFeasibilityCheckFailed
Common_Region_status_Feasibility_check_failed_of_twine = _common_region.StatusFeasibilityCheckFailed_of_twine
Common_Region_status = _common_region.Status
Common_Region_status_of_twine = _common_region.Status_of_twine

Common_Region_meta_Null = _common_region.MetaNull
Common_Region_meta_Bool = _common_region.MetaBool
Common_Region_meta_Bool_of_twine = _common_region.MetaBool_of_twine
Common_Region_meta_Int = _common_region.MetaInt
Common_Region_meta_Int_of_twine = _common_region.MetaInt_of_twine
Common_Region_meta_Real = _common_region.MetaReal
Common_Region_meta_Real_of_twine = _common_region.MetaReal_of_twine
Common_Region_meta_String = _common_region.MetaString
Common_Region_meta_String_of_twine = _common_region.MetaString_of_twine
Common_Region_meta_Assoc = _common_region.MetaAssoc
Common_Region_meta_Assoc_of_twine = _common_region.MetaAssoc_of_twine
Common_Region_meta_Term = _common_region.MetaTerm
Common_Region_meta_Term_of_twine = _common_region.MetaTerm_of_twine
Common_Region_meta_List = _common_region.MetaList
Common_Region_meta_List_of_twine = _common_region.MetaList_of_twine
Common_Region_meta = _common_region.Meta
Common_Region_meta_of_twine = _common_region.Meta_of_twine

Common_Region_t_poly = _common_region.Region
Common_Region_t_poly_of_twine = _common_region.Region_of_twine

Common_Proof_obligation_t_poly = _common_proof_obligation.ProofObligation
Common_Proof_obligation_t_poly_of_twine = _common_proof_obligation.ProofObligation_of_twine

Common_Instantiation_rule_kind_IR_forward_chaining = _common_instantiation_rule_kind.IR_ForwardChaining
Common_Instantiation_rule_kind_IR_generalization = _common_instantiation_rule_kind.IR_Generalization
Common_Instantiation_rule_kind = _common_instantiation_rule_kind.InstantiationRuleKind
Common_Instantiation_rule_kind_of_twine = _common_instantiation_rule_kind.InstantiationRuleKind_of_twine

Common_Instantiation_rule_t_poly = _common_instantiation_rule.InstantiationRule
Common_Instantiation_rule_t_poly_of_twine = _common_instantiation_rule.InstantiationRule_of_twine

Common_Fun_decomp_list_with_len = _common_fun_decomp.ListWithLen
Common_Fun_decomp_list_with_len_of_twine = _common_fun_decomp.ListWithLen_of_twine

Common_Fun_decomp_t_poly = _common_fun_decomp.FunDecomp
Common_Fun_decomp_t_poly_of_twine = _common_fun_decomp.FunDecomp_of_twine

Common_Elimination_rule_t_poly = _common_elimination_rule.EliminationRule
Common_Elimination_rule_t_poly_of_twine = _common_elimination_rule.EliminationRule_of_twine

Common_Decomp_lift_bool_Default = _common_decomp.LiftBoolDefault
Common_Decomp_lift_bool_Nested_equalities = _common_decomp.LiftBoolNestedEqualities
Common_Decomp_lift_bool_Equalities = _common_decomp.LiftBoolEqualities
Common_Decomp_lift_bool_All = _common_decomp.LiftBoolAll
Common_Decomp_lift_bool = _common_decomp.LiftBool
Common_Decomp_lift_bool_of_twine = _common_decomp.LiftBool_of_twine

Common_Decomp_t_ = _common_decomp.Decomp
Common_Decomp_t__of_twine = _common_decomp.Decomp_of_twine

Common_Decl_t_poly_Fun = _common_decl.Fun
Common_Decl_t_poly_Fun_of_twine = _common_decl.Fun_of_twine
Common_Decl_t_poly_Ty = _common_decl.Ty
Common_Decl_t_poly_Ty_of_twine = _common_decl.Ty_of_twine
Common_Decl_t_poly_Theorem = _common_decl.Theorem
Common_Decl_t_poly_Theorem_of_twine = _common_decl.Theorem_of_twine
Common_Decl_t_poly_Rule_spec = _common_decl.RuleSpec
Common_Decl_t_poly_Rule_spec_of_twine = _common_decl.RuleSpec_of_twine
Common_Decl_t_poly_Verify = _common_decl.Verify
Common_Decl_t_poly_Verify_of_twine = _common_decl.Verify_of_twine
Common_Decl_t_poly = _common_decl.Decl
Common_Decl_t_poly_of_twine = _common_decl.Decl_of_twine

Common_Db_op_t_poly_Op_enable = _common_db_op.OpEnable
Common_Db_op_t_poly_Op_enable_of_twine = _common_db_op.OpEnable_of_twine
Common_Db_op_t_poly_Op_disable = _common_db_op.OpDisable
Common_Db_op_t_poly_Op_disable_of_twine = _common_db_op.OpDisable_of_twine
Common_Db_op_t_poly_Op_add_decls = _common_db_op.OpAddDecls
Common_Db_op_t_poly_Op_add_decls_of_twine = _common_db_op.OpAddDecls_of_twine
Common_Db_op_t_poly_Op_add_rw = _common_db_op.OpAddRw
Common_Db_op_t_poly_Op_add_rw_of_twine = _common_db_op.OpAddRw_of_twine
Common_Db_op_t_poly_Op_add_fc_trigger = _common_db_op.OpAddFcTrigger
Common_Db_op_t_poly_Op_add_fc_trigger_of_twine = _common_db_op.OpAddFcTrigger_of_twine
Common_Db_op_t_poly_Op_add_elim = _common_db_op.OpAddElim
Common_Db_op_t_poly_Op_add_elim_of_twine = _common_db_op.OpAddElim_of_twine
Common_Db_op_t_poly_Op_add_gen_trigger = _common_db_op.OpAddGenTrigger
Common_Db_op_t_poly_Op_add_gen_trigger_of_twine = _common_db_op.OpAddGenTrigger_of_twine
Common_Db_op_t_poly_Op_add_count_fun = _common_db_op.OpAddCountFun
Common_Db_op_t_poly_Op_add_count_fun_of_twine = _common_db_op.OpAddCountFun_of_twine
Common_Db_op_t_poly_Op_set_admission = _common_db_op.OpSetAdmission
Common_Db_op_t_poly_Op_set_admission_of_twine = _common_db_op.OpSetAdmission_of_twine
Common_Db_op_t_poly_Op_set_thm_as_rw = _common_db_op.OpSetThmAsRw
Common_Db_op_t_poly_Op_set_thm_as_rw_of_twine = _common_db_op.OpSetThmAsRw_of_twine
Common_Db_op_t_poly_Op_set_thm_as_fc = _common_db_op.OpSetThmAsFc
Common_Db_op_t_poly_Op_set_thm_as_fc_of_twine = _common_db_op.OpSetThmAsFc_of_twine
Common_Db_op_t_poly_Op_set_thm_as_elim = _common_db_op.OpSetThmAsElim
Common_Db_op_t_poly_Op_set_thm_as_elim_of_twine = _common_db_op.OpSetThmAsElim_of_twine
Common_Db_op_t_poly_Op_set_thm_as_gen = _common_db_op.OpSetThmAsGen
Common_Db_op_t_poly_Op_set_thm_as_gen_of_twine = _common_db_op.OpSetThmAsGen_of_twine
Common_Db_op_t_poly_Op_add_instantiation_rule = _common_db_op.OpAddInstantiationRule
Common_Db_op_t_poly_Op_add_instantiation_rule_of_twine = _common_db_op.OpAddInstantiationRule_of_twine
Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers = _common_db_op.OpAddRuleSpecFcTriggers
Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers_of_twine = _common_db_op.OpAddRuleSpecFcTriggers_of_twine
Common_Db_op_t_poly_Op_add_rule_spec_rw = _common_db_op.OpAddRuleSpecRw
Common_Db_op_t_poly_Op_add_rule_spec_rw_of_twine = _common_db_op.OpAddRuleSpecRw_of_twine
Common_Db_op_t_poly = _common_db_op.DbOp
Common_Db_op_t_poly_of_twine = _common_db_op.DbOp_of_twine

Common_Db_ser_ca_ptr = _common_db_ser.CaPtr
Common_Db_ser_ca_ptr_of_twine = _common_db_ser.CaPtr_of_twine

Common_Db_ser_t_poly = _common_db_ser.DbSer
Common_Db_ser_t_poly_of_twine = _common_db_ser.DbSer_of_twine

Mir_Type_var = _mir_type.Var
Mir_Type_var_of_twine = _mir_type.Var_of_twine

Mir_Type_clique = _mir_type.Clique
Mir_Type_clique_of_twine = _mir_type.Clique_of_twine

Mir_Type_generation = _mir_type.Generation
Mir_Type_generation_of_twine = _mir_type.Generation_of_twine

Mir_Type = _mir_type.Type
Mir_Type_of_twine = _mir_type.Type_of_twine

Mir_Type_ser = _mir_type.Ser
Mir_Type_ser_of_twine = _mir_type.Ser_of_twine

Mir_Type_def = _mir_type.Def
Mir_Type_def_of_twine = _mir_type.Def_of_twine

Mir_Var = _mir_var.Var
Mir_Var_of_twine = _mir_var.Var_of_twine

Mir_Typed_symbol = _mir_typed_symbol.TypedSymbol
Mir_Typed_symbol_of_twine = _mir_typed_symbol.TypedSymbol_of_twine

Mir_Type_schema = _mir_type_schema.TypeSchema
Mir_Type_schema_of_twine = _mir_type_schema.TypeSchema_of_twine

Mir_Trigger = _mir_trigger.Trigger
Mir_Trigger_of_twine = _mir_trigger.Trigger_of_twine

Mir_Applied_symbol = _mir_applied_symbol.AppliedSymbol
Mir_Applied_symbol_of_twine = _mir_applied_symbol.AppliedSymbol_of_twine

Mir_Term_view_Const = _mir_term.ViewConst
Mir_Term_view_Const_of_twine = _mir_term.ViewConst_of_twine
Mir_Term_view_If = _mir_term.ViewIf
Mir_Term_view_If_of_twine = _mir_term.ViewIf_of_twine
Mir_Term_view_Apply = _mir_term.ViewApply
Mir_Term_view_Apply_of_twine = _mir_term.ViewApply_of_twine
Mir_Term_view_Var = _mir_term.ViewVar
Mir_Term_view_Var_of_twine = _mir_term.ViewVar_of_twine
Mir_Term_view_Sym = _mir_term.ViewSym
Mir_Term_view_Sym_of_twine = _mir_term.ViewSym_of_twine
Mir_Term_view_Construct = _mir_term.ViewConstruct
Mir_Term_view_Construct_of_twine = _mir_term.ViewConstruct_of_twine
Mir_Term_view_Destruct = _mir_term.ViewDestruct
Mir_Term_view_Destruct_of_twine = _mir_term.ViewDestruct_of_twine
Mir_Term_view_Is_a = _mir_term.ViewIsA
Mir_Term_view_Is_a_of_twine = _mir_term.ViewIsA_of_twine
Mir_Term_view_Tuple = _mir_term.ViewTuple
Mir_Term_view_Tuple_of_twine = _mir_term.ViewTuple_of_twine
Mir_Term_view_Field = _mir_term.ViewField
Mir_Term_view_Field_of_twine = _mir_term.ViewField_of_twine
Mir_Term_view_Tuple_field = _mir_term.ViewTupleField
Mir_Term_view_Tuple_field_of_twine = _mir_term.ViewTupleField_of_twine
Mir_Term_view_Record = _mir_term.ViewRecord
Mir_Term_view_Record_of_twine = _mir_term.ViewRecord_of_twine
Mir_Term_view_Case = _mir_term.ViewCase
Mir_Term_view_Case_of_twine = _mir_term.ViewCase_of_twine
Mir_Term_view_Sequence = _mir_term.ViewSequence
Mir_Term_view_Sequence_of_twine = _mir_term.ViewSequence_of_twine
Mir_Term_view = _mir_term.View
Mir_Term_view_of_twine = _mir_term.View_of_twine

Mir_Term_generation = _mir_term.Generation
Mir_Term_generation_of_twine = _mir_term.Generation_of_twine

Mir_Term = _mir_term.Term
Mir_Term_of_twine = _mir_term.Term_of_twine

Mir_Term_ser = _mir_term.Ser
Mir_Term_ser_of_twine = _mir_term.Ser_of_twine

Mir_Term_term = _mir_term.TermTerm
Mir_Term_term_of_twine = _mir_term.TermTerm_of_twine

Mir_Top_fun = _mir_top_fun.TopFun
Mir_Top_fun_of_twine = _mir_top_fun.TopFun_of_twine

Mir_Theorem = _mir_theorem.Theorem
Mir_Theorem_of_twine = _mir_theorem.Theorem_of_twine

Mir_Tactic = _mir_tactic.Tactic
Mir_Tactic_of_twine = _mir_tactic.Tactic_of_twine

Mir_Sequent = _mir_sequent.Sequent
Mir_Sequent_of_twine = _mir_sequent.Sequent_of_twine

Mir_Rewrite_rule = _mir_rewrite_rule.RewriteRule
Mir_Rewrite_rule_of_twine = _mir_rewrite_rule.RewriteRule_of_twine

Mir_Region_Region = _mir_region.Region
Mir_Region_Region_of_twine = _mir_region.Region_of_twine

Mir_Proof_obligation = _mir_proof_obligation.ProofObligation
Mir_Proof_obligation_of_twine = _mir_proof_obligation.ProofObligation_of_twine

Mir_Pre_trigger = _mir_pre_trigger.PreTrigger
Mir_Pre_trigger_of_twine = _mir_pre_trigger.PreTrigger_of_twine

Mir_Pattern_head = _mir_pattern_head.PatternHead
Mir_Pattern_head_of_twine = _mir_pattern_head.PatternHead_of_twine

Mir_Model = _mir_model.Model
Mir_Model_of_twine = _mir_model.Model_of_twine

Mir_Instantiation_rule = _mir_instantiation_rule.InstantiationRule
Mir_Instantiation_rule_of_twine = _mir_instantiation_rule.InstantiationRule_of_twine

Mir_Hints = _mir_hints.Hints
Mir_Hints_of_twine = _mir_hints.Hints_of_twine

Mir_Fun_def = _mir_fun_def.FunDef
Mir_Fun_def_of_twine = _mir_fun_def.FunDef_of_twine

Mir_Fun_decomp = _mir_fun_decomp.FunDecomp
Mir_Fun_decomp_of_twine = _mir_fun_decomp.FunDecomp_of_twine

Mir_Fo_pattern = _mir_fo_pattern.FoPattern
Mir_Fo_pattern_of_twine = _mir_fo_pattern.FoPattern_of_twine

Mir_Elimination_rule = _mir_elimination_rule.EliminationRule
Mir_Elimination_rule_of_twine = _mir_elimination_rule.EliminationRule_of_twine

Mir_Decomp = _mir_decomp.Decomp
Mir_Decomp_of_twine = _mir_decomp.Decomp_of_twine

Mir_Decl = _mir_decl.Decl
Mir_Decl_of_twine = _mir_decl.Decl_of_twine

Mir_Db_ser = _mir_db_ser.DbSer
Mir_Db_ser_of_twine = _mir_db_ser.DbSer_of_twine

Eval_Ordinal_Int = _eval_ordinal.Int
Eval_Ordinal_Int_of_twine = _eval_ordinal.Int_of_twine
Eval_Ordinal_Cons = _eval_ordinal.Cons
Eval_Ordinal_Cons_of_twine = _eval_ordinal.Cons_of_twine
Eval_Ordinal = _eval_ordinal.Ordinal
Eval_Ordinal_of_twine = _eval_ordinal.Ordinal_of_twine

Eval_Value_cstor_descriptor = _eval_value.CstorDescriptor
Eval_Value_cstor_descriptor_of_twine = _eval_value.CstorDescriptor_of_twine

Eval_Value_record_descriptor = _eval_value.RecordDescriptor
Eval_Value_record_descriptor_of_twine = _eval_value.RecordDescriptor_of_twine

Eval_Value_view_V_true = _eval_value.V_True
Eval_Value_view_V_false = _eval_value.V_False
Eval_Value_view_V_int = _eval_value.V_Int
Eval_Value_view_V_int_of_twine = _eval_value.V_Int_of_twine
Eval_Value_view_V_real = _eval_value.V_Real
Eval_Value_view_V_real_of_twine = _eval_value.V_Real_of_twine
Eval_Value_view_V_string = _eval_value.V_String
Eval_Value_view_V_string_of_twine = _eval_value.V_String_of_twine
Eval_Value_view_V_cstor = _eval_value.V_Cstor
Eval_Value_view_V_cstor_of_twine = _eval_value.V_Cstor_of_twine
Eval_Value_view_V_tuple = _eval_value.V_Tuple
Eval_Value_view_V_tuple_of_twine = _eval_value.V_Tuple_of_twine
Eval_Value_view_V_record = _eval_value.V_Record
Eval_Value_view_V_record_of_twine = _eval_value.V_Record_of_twine
Eval_Value_view_V_quoted_term = _eval_value.V_QuotedTerm
Eval_Value_view_V_quoted_term_of_twine = _eval_value.V_QuotedTerm_of_twine
Eval_Value_view_V_uid = _eval_value.V_Uid
Eval_Value_view_V_uid_of_twine = _eval_value.V_Uid_of_twine
Eval_Value_view_V_closure = _eval_value.V_Closure
Eval_Value_view_V_closure_of_twine = _eval_value.V_Closure_of_twine
Eval_Value_view_V_custom = _eval_value.V_Custom
Eval_Value_view_V_custom_of_twine = _eval_value.V_Custom_of_twine
Eval_Value_view_V_ordinal = _eval_value.V_Ordinal
Eval_Value_view_V_ordinal_of_twine = _eval_value.V_Ordinal_of_twine
Eval_Value_view = _eval_value.View
Eval_Value_view_of_twine = _eval_value.View_of_twine

Eval_Value_erased_closure = _eval_value.ErasedClosure
Eval_Value_erased_closure_of_twine = _eval_value.ErasedClosure_of_twine

Eval_Value = _eval_value.Value
Eval_Value_of_twine = _eval_value.Value_of_twine

Report_Expansion = _report_expansion.Expansion
Report_Expansion_of_twine = _report_expansion.Expansion_of_twine

Report_Instantiation = _report_instantiation.Instantiation
Report_Instantiation_of_twine = _report_instantiation.Instantiation_of_twine

Report_Smt_proof = _report_smt_proof.SmtProof
Report_Smt_proof_of_twine = _report_smt_proof.SmtProof_of_twine

Report_Rtext = _report_rtext.Rtext
Report_Rtext_of_twine = _report_rtext.Rtext_of_twine

Report_Rtext_item_S = _report_rtext.ItemS
Report_Rtext_item_S_of_twine = _report_rtext.ItemS_of_twine
Report_Rtext_item_B = _report_rtext.ItemB
Report_Rtext_item_B_of_twine = _report_rtext.ItemB_of_twine
Report_Rtext_item_I = _report_rtext.ItemI
Report_Rtext_item_I_of_twine = _report_rtext.ItemI_of_twine
Report_Rtext_item_Newline = _report_rtext.ItemNewline
Report_Rtext_item_Sub = _report_rtext.ItemSub
Report_Rtext_item_Sub_of_twine = _report_rtext.ItemSub_of_twine
Report_Rtext_item_L = _report_rtext.ItemL
Report_Rtext_item_L_of_twine = _report_rtext.ItemL_of_twine
Report_Rtext_item_Uid = _report_rtext.ItemUid
Report_Rtext_item_Uid_of_twine = _report_rtext.ItemUid_of_twine
Report_Rtext_item_Term = _report_rtext.ItemTerm
Report_Rtext_item_Term_of_twine = _report_rtext.ItemTerm_of_twine
Report_Rtext_item_Sequent = _report_rtext.ItemSequent
Report_Rtext_item_Sequent_of_twine = _report_rtext.ItemSequent_of_twine
Report_Rtext_item_Subst = _report_rtext.ItemSubst
Report_Rtext_item_Subst_of_twine = _report_rtext.ItemSubst_of_twine
Report_Rtext_item = _report_rtext.Item
Report_Rtext_item_of_twine = _report_rtext.Item_of_twine

Report_Atomic_event_model = _report_atomic_event.Model
Report_Atomic_event_model_of_twine = _report_atomic_event.Model_of_twine

Report_Atomic_event_poly_E_message = _report_atomic_event.E_Message
Report_Atomic_event_poly_E_message_of_twine = _report_atomic_event.E_Message_of_twine
Report_Atomic_event_poly_E_title = _report_atomic_event.E_Title
Report_Atomic_event_poly_E_title_of_twine = _report_atomic_event.E_Title_of_twine
Report_Atomic_event_poly_E_enter_waterfall = _report_atomic_event.E_EnterWaterfall
Report_Atomic_event_poly_E_enter_waterfall_of_twine = _report_atomic_event.E_EnterWaterfall_of_twine
Report_Atomic_event_poly_E_enter_tactic = _report_atomic_event.E_EnterTactic
Report_Atomic_event_poly_E_enter_tactic_of_twine = _report_atomic_event.E_EnterTactic_of_twine
Report_Atomic_event_poly_E_rw_success = _report_atomic_event.E_RwSuccess
Report_Atomic_event_poly_E_rw_success_of_twine = _report_atomic_event.E_RwSuccess_of_twine
Report_Atomic_event_poly_E_rw_fail = _report_atomic_event.E_RwFail
Report_Atomic_event_poly_E_rw_fail_of_twine = _report_atomic_event.E_RwFail_of_twine
Report_Atomic_event_poly_E_inst_success = _report_atomic_event.E_InstSuccess
Report_Atomic_event_poly_E_inst_success_of_twine = _report_atomic_event.E_InstSuccess_of_twine
Report_Atomic_event_poly_E_waterfall_checkpoint = _report_atomic_event.E_WaterfallCheckpoint
Report_Atomic_event_poly_E_waterfall_checkpoint_of_twine = _report_atomic_event.E_WaterfallCheckpoint_of_twine
Report_Atomic_event_poly_E_induction_scheme = _report_atomic_event.E_InductionScheme
Report_Atomic_event_poly_E_induction_scheme_of_twine = _report_atomic_event.E_InductionScheme_of_twine
Report_Atomic_event_poly_E_attack_subgoal = _report_atomic_event.E_AttackSubgoal
Report_Atomic_event_poly_E_attack_subgoal_of_twine = _report_atomic_event.E_AttackSubgoal_of_twine
Report_Atomic_event_poly_E_simplify_t = _report_atomic_event.E_SimplifyT
Report_Atomic_event_poly_E_simplify_t_of_twine = _report_atomic_event.E_SimplifyT_of_twine
Report_Atomic_event_poly_E_simplify_clause = _report_atomic_event.E_SimplifyClause
Report_Atomic_event_poly_E_simplify_clause_of_twine = _report_atomic_event.E_SimplifyClause_of_twine
Report_Atomic_event_poly_E_proved_by_smt = _report_atomic_event.E_ProvedBySmt
Report_Atomic_event_poly_E_proved_by_smt_of_twine = _report_atomic_event.E_ProvedBySmt_of_twine
Report_Atomic_event_poly_E_refuted_by_smt = _report_atomic_event.E_RefutedBySmt
Report_Atomic_event_poly_E_refuted_by_smt_of_twine = _report_atomic_event.E_RefutedBySmt_of_twine
Report_Atomic_event_poly_E_fun_expansion = _report_atomic_event.E_FunExpansion
Report_Atomic_event_poly_E_fun_expansion_of_twine = _report_atomic_event.E_FunExpansion_of_twine
Report_Atomic_event_poly = _report_atomic_event.AtomicEvent
Report_Atomic_event_poly_of_twine = _report_atomic_event.AtomicEvent_of_twine

Report_Atomic_event_Mir = _report_atomic_event.Mir
Report_Atomic_event_Mir_of_twine = _report_atomic_event.Mir_of_twine

Report_Event_t_linear_EL_atomic = _report_event.EL_Atomic
Report_Event_t_linear_EL_atomic_of_twine = _report_event.EL_Atomic_of_twine
Report_Event_t_linear_EL_enter_span = _report_event.EL_EnterSpan
Report_Event_t_linear_EL_enter_span_of_twine = _report_event.EL_EnterSpan_of_twine
Report_Event_t_linear_EL_exit_span = _report_event.EL_ExitSpan
Report_Event_t_linear_EL_exit_span_of_twine = _report_event.EL_ExitSpan_of_twine
Report_Event_t_linear = _report_event.TLinear
Report_Event_t_linear_of_twine = _report_event.TLinear_of_twine

Report_Event_t_tree_ET_atomic = _report_event.ET_Atomic
Report_Event_t_tree_ET_atomic_of_twine = _report_event.ET_Atomic_of_twine
Report_Event_t_tree_ET_span = _report_event.ET_Span
Report_Event_t_tree_ET_span_of_twine = _report_event.ET_Span_of_twine
Report_Event_t_tree = _report_event.TTree
Report_Event_t_tree_of_twine = _report_event.TTree_of_twine

Report_Report_event = _report_report.Event
Report_Report_event_of_twine = _report_report.Event_of_twine

Report_Report = _report_report.Report
Report_Report_of_twine = _report_report.Report_of_twine

Proof_Arg_A_term = _proof_arg.A_Term
Proof_Arg_A_term_of_twine = _proof_arg.A_Term_of_twine
Proof_Arg_A_ty = _proof_arg.A_Ty
Proof_Arg_A_ty_of_twine = _proof_arg.A_Ty_of_twine
Proof_Arg_A_int = _proof_arg.A_Int
Proof_Arg_A_int_of_twine = _proof_arg.A_Int_of_twine
Proof_Arg_A_string = _proof_arg.A_String
Proof_Arg_A_string_of_twine = _proof_arg.A_String_of_twine
Proof_Arg_A_list = _proof_arg.A_List
Proof_Arg_A_list_of_twine = _proof_arg.A_List_of_twine
Proof_Arg_A_dict = _proof_arg.A_Dict
Proof_Arg_A_dict_of_twine = _proof_arg.A_Dict_of_twine
Proof_Arg_A_seq = _proof_arg.A_Seq
Proof_Arg_A_seq_of_twine = _proof_arg.A_Seq_of_twine
Proof_Arg = _proof_arg.Arg
Proof_Arg_of_twine = _proof_arg.Arg_of_twine

Proof_Var_poly = _proof_var_poly.VarPoly
Proof_Var_poly_of_twine = _proof_var_poly.VarPoly_of_twine

Proof_View_T_assume = _proof_view.T_Assume
Proof_View_T_subst = _proof_view.T_Subst
Proof_View_T_subst_of_twine = _proof_view.T_Subst_of_twine
Proof_View_T_deduction = _proof_view.T_Deduction
Proof_View_T_deduction_of_twine = _proof_view.T_Deduction_of_twine
Proof_View_T_rule = _proof_view.T_Rule
Proof_View_T_rule_of_twine = _proof_view.T_Rule_of_twine
Proof_View = _proof_view.View
Proof_View_of_twine = _proof_view.View_of_twine

Proof_Proof_term_t_poly = _proof_proof_term.ProofTerm
Proof_Proof_term_t_poly_of_twine = _proof_proof_term.ProofTerm_of_twine

Tasks_PO_task_t_poly = _tasks_po_task.POTask
Tasks_PO_task_t_poly_of_twine = _tasks_po_task.POTask_of_twine

Tasks_PO_task_Mir = _tasks_po_task.Mir
Tasks_PO_task_Mir_of_twine = _tasks_po_task.Mir_of_twine

Tasks_PO_res_sub_res = _tasks_po_res.SubRes
Tasks_PO_res_sub_res_of_twine = _tasks_po_res.SubRes_of_twine

Tasks_PO_res_proof_found = _tasks_po_res.ProofFound
Tasks_PO_res_proof_found_of_twine = _tasks_po_res.ProofFound_of_twine

Tasks_PO_res_verified_upto = _tasks_po_res.VerifiedUpto
Tasks_PO_res_verified_upto_of_twine = _tasks_po_res.VerifiedUpto_of_twine

Tasks_PO_res_instance = _tasks_po_res.Instance
Tasks_PO_res_instance_of_twine = _tasks_po_res.Instance_of_twine

Tasks_PO_res_no_proof = _tasks_po_res.NoProof
Tasks_PO_res_no_proof_of_twine = _tasks_po_res.NoProof_of_twine

Tasks_PO_res_unsat = _tasks_po_res.Unsat
Tasks_PO_res_unsat_of_twine = _tasks_po_res.Unsat_of_twine

Tasks_PO_res_success_Proof = _tasks_po_res.SuccessProof
Tasks_PO_res_success_Proof_of_twine = _tasks_po_res.SuccessProof_of_twine
Tasks_PO_res_success_Instance = _tasks_po_res.SuccessInstance
Tasks_PO_res_success_Instance_of_twine = _tasks_po_res.SuccessInstance_of_twine
Tasks_PO_res_success_Verified_upto = _tasks_po_res.SuccessVerifiedUpto
Tasks_PO_res_success_Verified_upto_of_twine = _tasks_po_res.SuccessVerifiedUpto_of_twine
Tasks_PO_res_success_Test_ok = _tasks_po_res.SuccessTestOk
Tasks_PO_res_success = _tasks_po_res.Success
Tasks_PO_res_success_of_twine = _tasks_po_res.Success_of_twine

Tasks_PO_res_error_No_proof = _tasks_po_res.ErrorNoProof
Tasks_PO_res_error_No_proof_of_twine = _tasks_po_res.ErrorNoProof_of_twine
Tasks_PO_res_error_Unsat = _tasks_po_res.ErrorUnsat
Tasks_PO_res_error_Unsat_of_twine = _tasks_po_res.ErrorUnsat_of_twine
Tasks_PO_res_error_Invalid_model = _tasks_po_res.ErrorInvalidModel
Tasks_PO_res_error_Invalid_model_of_twine = _tasks_po_res.ErrorInvalidModel_of_twine
Tasks_PO_res_error_Error = _tasks_po_res.ErrorError
Tasks_PO_res_error_Error_of_twine = _tasks_po_res.ErrorError_of_twine
Tasks_PO_res_error = _tasks_po_res.Error
Tasks_PO_res_error_of_twine = _tasks_po_res.Error_of_twine

Tasks_PO_res_result = _tasks_po_res.Result
Tasks_PO_res_result_of_twine = _tasks_po_res.Result_of_twine

Tasks_PO_res_shallow_poly = _tasks_po_res.ShallowPoly
Tasks_PO_res_shallow_poly_of_twine = _tasks_po_res.ShallowPoly_of_twine

Tasks_PO_res_full_poly = _tasks_po_res.FullPoly
Tasks_PO_res_full_poly_of_twine = _tasks_po_res.FullPoly_of_twine

Tasks_PO_res_Shallow = _tasks_po_res.Shallow
Tasks_PO_res_Shallow_of_twine = _tasks_po_res.Shallow_of_twine

Tasks_PO_res_full = _tasks_po_res.Full
Tasks_PO_res_full_of_twine = _tasks_po_res.Full_of_twine

Tasks_Eval_task_t_poly = _tasks_eval_task.EvalTask
Tasks_Eval_task_t_poly_of_twine = _tasks_eval_task.EvalTask_of_twine

Tasks_Eval_task_Mir = _tasks_eval_task.Mir
Tasks_Eval_task_Mir_of_twine = _tasks_eval_task.Mir_of_twine

Tasks_Eval_res_value = _tasks_eval_res.Value
Tasks_Eval_res_value_of_twine = _tasks_eval_res.Value_of_twine

Tasks_Eval_res_stats = _tasks_eval_res.Stats
Tasks_Eval_res_stats_of_twine = _tasks_eval_res.Stats_of_twine

Tasks_Eval_res_success = _tasks_eval_res.Success
Tasks_Eval_res_success_of_twine = _tasks_eval_res.Success_of_twine

Tasks_Eval_res = _tasks_eval_res.EvalRes
Tasks_Eval_res_of_twine = _tasks_eval_res.EvalRes_of_twine

Tasks_Decomp_task_enumeration_style_Additive = _tasks_decomp_task.EnumerationStyleAdditive
Tasks_Decomp_task_enumeration_style_Multiplicative = _tasks_decomp_task.EnumerationStyleMultiplicative
Tasks_Decomp_task_enumeration_style = _tasks_decomp_task.EnumerationStyle
Tasks_Decomp_task_enumeration_style_of_twine = _tasks_decomp_task.EnumerationStyle_of_twine

Tasks_Decomp_task_decomp_poly_Decomp = _tasks_decomp_task.DecompDecomp
Tasks_Decomp_task_decomp_poly_Decomp_of_twine = _tasks_decomp_task.DecompDecomp_of_twine
Tasks_Decomp_task_decomp_poly_Term = _tasks_decomp_task.DecompTerm
Tasks_Decomp_task_decomp_poly_Term_of_twine = _tasks_decomp_task.DecompTerm_of_twine
Tasks_Decomp_task_decomp_poly_Return = _tasks_decomp_task.DecompReturn
Tasks_Decomp_task_decomp_poly_Return_of_twine = _tasks_decomp_task.DecompReturn_of_twine
Tasks_Decomp_task_decomp_poly_Prune = _tasks_decomp_task.DecompPrune
Tasks_Decomp_task_decomp_poly_Prune_of_twine = _tasks_decomp_task.DecompPrune_of_twine
Tasks_Decomp_task_decomp_poly_Merge = _tasks_decomp_task.DecompMerge
Tasks_Decomp_task_decomp_poly_Merge_of_twine = _tasks_decomp_task.DecompMerge_of_twine
Tasks_Decomp_task_decomp_poly_Compound_merge = _tasks_decomp_task.DecompCompoundMerge
Tasks_Decomp_task_decomp_poly_Compound_merge_of_twine = _tasks_decomp_task.DecompCompoundMerge_of_twine
Tasks_Decomp_task_decomp_poly_Combine = _tasks_decomp_task.DecompCombine
Tasks_Decomp_task_decomp_poly_Combine_of_twine = _tasks_decomp_task.DecompCombine_of_twine
Tasks_Decomp_task_decomp_poly_Get = _tasks_decomp_task.DecompGet
Tasks_Decomp_task_decomp_poly_Get_of_twine = _tasks_decomp_task.DecompGet_of_twine
Tasks_Decomp_task_decomp_poly_Let = _tasks_decomp_task.DecompLet
Tasks_Decomp_task_decomp_poly_Let_of_twine = _tasks_decomp_task.DecompLet_of_twine
Tasks_Decomp_task_decomp_poly_Enumerate = _tasks_decomp_task.DecompEnumerate
Tasks_Decomp_task_decomp_poly_Enumerate_of_twine = _tasks_decomp_task.DecompEnumerate_of_twine
Tasks_Decomp_task_decomp_poly = _tasks_decomp_task.Decomp
Tasks_Decomp_task_decomp_poly_of_twine = _tasks_decomp_task.Decomp_of_twine

Tasks_Decomp_task_t_poly = _tasks_decomp_task.DecompTask
Tasks_Decomp_task_t_poly_of_twine = _tasks_decomp_task.DecompTask_of_twine

Tasks_Decomp_task_Mir_decomp = _tasks_decomp_task.MirDecomp
Tasks_Decomp_task_Mir_decomp_of_twine = _tasks_decomp_task.MirDecomp_of_twine

Tasks_Decomp_task_Mir = _tasks_decomp_task.Mir
Tasks_Decomp_task_Mir_of_twine = _tasks_decomp_task.Mir_of_twine

Tasks_Decomp_res_success = _tasks_decomp_res.Success
Tasks_Decomp_res_success_of_twine = _tasks_decomp_res.Success_of_twine

Tasks_Decomp_res_error_Error = _tasks_decomp_res.ErrorError
Tasks_Decomp_res_error_Error_of_twine = _tasks_decomp_res.ErrorError_of_twine
Tasks_Decomp_res_error = _tasks_decomp_res.Error
Tasks_Decomp_res_error_of_twine = _tasks_decomp_res.Error_of_twine

Tasks_Decomp_res_result = _tasks_decomp_res.Result
Tasks_Decomp_res_result_of_twine = _tasks_decomp_res.Result_of_twine

Tasks_Decomp_res_shallow_poly = _tasks_decomp_res.ShallowPoly
Tasks_Decomp_res_shallow_poly_of_twine = _tasks_decomp_res.ShallowPoly_of_twine

Tasks_Decomp_res_full_poly = _tasks_decomp_res.FullPoly
Tasks_Decomp_res_full_poly_of_twine = _tasks_decomp_res.FullPoly_of_twine

Tasks_Decomp_res_Shallow = _tasks_decomp_res.Shallow
Tasks_Decomp_res_Shallow_of_twine = _tasks_decomp_res.Shallow_of_twine

Tasks_Decomp_res_Full = _tasks_decomp_res.Full
Tasks_Decomp_res_Full_of_twine = _tasks_decomp_res.Full_of_twine
