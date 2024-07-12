# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# NO CHECKED-IN PROTOBUF GENCODE
# source: simple_api.proto
# Protobuf Python Version: 5.27.2
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import runtime_version as _runtime_version
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
_runtime_version.ValidateProtobufRuntimeVersion(
    _runtime_version.Domain.PUBLIC,
    5,
    27,
    2,
    '',
    'simple_api.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import error_pb2 as error__pb2
import utils_pb2 as utils__pb2
import session_pb2 as session__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\x10simple_api.proto\x12\x0fimandrax.simple\x1a\x0b\x65rror.proto\x1a\x0butils.proto\x1a\rsession.proto\"\xb4\x01\n\x0c\x44\x65\x63omposeReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x15\n\x08\x61ssuming\x18\x03 \x01(\tH\x00\x88\x01\x01\x12\r\n\x05prune\x18\x04 \x01(\x08\x12\x17\n\nmax_rounds\x18\n \x01(\x05H\x01\x88\x01\x01\x12\x14\n\x07stop_at\x18\x0b \x01(\x05H\x02\x88\x01\x01\x42\x0b\n\t_assumingB\r\n\x0b_max_roundsB\n\n\x08_stop_at\"c\n\x0f\x44\x65\x63omposeRegion\x12\x16\n\x0e\x63onstraints_pp\x18\x01 \x03(\t\x12\x14\n\x0cinvariant_pp\x18\x02 \x01(\t\x12\x15\n\x08\x61st_json\x18\x03 \x01(\tH\x00\x88\x01\x01\x42\x0b\n\t_ast_json\"A\n\x0c\x44\x65\x63omposeRes\x12\x31\n\x07regions\x18\x01 \x03(\x0b\x32 .imandrax.simple.DecomposeRegion\"4\n\nEvalSrcReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\"D\n\x07\x45valRes\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\x10\n\x08messages\x18\x02 \x03(\t\x12\x16\n\x06\x65rrors\x18\x03 \x03(\x0b\x32\x06.Error\"r\n\x0cVerifySrcReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\x12*\n\x05hints\x18\n \x01(\x0b\x32\x16.imandrax.simple.HintsH\x00\x88\x01\x01\x42\x08\n\x06_hintsJ\x04\x08\x0b\x10\x0c\"t\n\rVerifyNameReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12*\n\x05hints\x18\n \x01(\x0b\x32\x16.imandrax.simple.HintsH\x00\x88\x01\x01\x42\x08\n\x06_hintsJ\x04\x08\x0b\x10\x0c\"t\n\x0eInstanceSrcReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\x12*\n\x05hints\x18\n \x01(\x0b\x32\x16.imandrax.simple.HintsH\x00\x88\x01\x01\x42\x08\n\x06_hintsJ\x04\x08\x0b\x10\x0c\"v\n\x0fInstanceNameReq\x12\x19\n\x07session\x18\x01 \x01(\x0b\x32\x08.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12*\n\x05hints\x18\n \x01(\x0b\x32\x16.imandrax.simple.HintsH\x00\x88\x01\x01\x42\x08\n\x06_hintsJ\x04\x08\x0b\x10\x0c\",\n\x06Proved\x12\x15\n\x08proof_pp\x18\x01 \x01(\tH\x00\x88\x01\x01\x42\x0b\n\t_proof_pp\"+\n\x05Unsat\x12\x15\n\x08proof_pp\x18\x01 \x01(\tH\x00\x88\x01\x01\x42\x0b\n\t_proof_pp\"@\n\x05Model\x12*\n\x06m_type\x18\x01 \x01(\x0e\x32\x1a.imandrax.simple.ModelType\x12\x0b\n\x03src\x18\x02 \x01(\t\"?\n\x07Refuted\x12*\n\x05model\x18\x01 \x01(\x0b\x32\x16.imandrax.simple.ModelH\x00\x88\x01\x01\x42\x08\n\x06_model\";\n\x03Sat\x12*\n\x05model\x18\x01 \x01(\x0b\x32\x16.imandrax.simple.ModelH\x00\x88\x01\x01\x42\x08\n\x06_model\"\xa0\x01\n\tVerifyRes\x12\x1d\n\x07unknown\x18\x01 \x01(\x0b\x32\n.StringMsgH\x00\x12\x15\n\x03\x65rr\x18\x02 \x01(\x0b\x32\x06.ErrorH\x00\x12)\n\x06proved\x18\x03 \x01(\x0b\x32\x17.imandrax.simple.ProvedH\x00\x12+\n\x07refuted\x18\x04 \x01(\x0b\x32\x18.imandrax.simple.RefutedH\x00\x42\x05\n\x03res\"\x98\x01\n\x0bInstanceRes\x12\x1d\n\x07unknown\x18\x01 \x01(\x0b\x32\n.StringMsgH\x00\x12\x15\n\x03\x65rr\x18\x02 \x01(\x0b\x32\x06.ErrorH\x00\x12\'\n\x05unsat\x18\x03 \x01(\x0b\x32\x16.imandrax.simple.UnsatH\x00\x12#\n\x03sat\x18\x04 \x01(\x0b\x32\x14.imandrax.simple.SatH\x00\x42\x05\n\x03res\"\xc1\x04\n\x05Hints\x12\x16\n\x04\x61uto\x18\x01 \x01(\x0b\x32\x06.EmptyH\x00\x12/\n\x06unroll\x18\x02 \x01(\x0b\x32\x1d.imandrax.simple.Hints.UnrollH\x00\x12/\n\x06induct\x18\x03 \x01(\x0b\x32\x1d.imandrax.simple.Hints.InductH\x00\x1a\xda\x02\n\x06Induct\x12\x19\n\x07\x64\x65\x66\x61ult\x18\x01 \x01(\x0b\x32\x06.EmptyH\x00\x12>\n\nfunctional\x18\x02 \x01(\x0b\x32(.imandrax.simple.Hints.Induct.FunctionalH\x00\x12>\n\nstructural\x18\x03 \x01(\x0b\x32(.imandrax.simple.Hints.Induct.StructuralH\x00\x1a\x1c\n\nFunctional\x12\x0e\n\x06\x66_name\x18\x01 \x01(\t\x1aX\n\nStructural\x12<\n\x05style\x18\x01 \x01(\x0e\x32-.imandrax.simple.Hints.Induct.StructuralStyle\x12\x0c\n\x04vars\x18\x02 \x03(\t\"3\n\x0fStructuralStyle\x12\x0c\n\x08\x41\x64\x64itive\x10\x00\x12\x12\n\x0eMultiplicative\x10\x01\x42\x08\n\x06induct\x1aV\n\x06Unroll\x12\x17\n\nsmt_solver\x18\n \x01(\tH\x00\x88\x01\x01\x12\x16\n\tmax_steps\x18\x0b \x01(\x05H\x01\x88\x01\x01\x42\r\n\x0b_smt_solverB\x0c\n\n_max_stepsB\t\n\x07method_*.\n\tModelType\x12\x13\n\x0f\x43ounter_example\x10\x00\x12\x0c\n\x08Instance\x10\x01\x32\xa8\x04\n\x06Simple\x12\x1c\n\x06status\x12\x06.Empty\x1a\n.StringMsg\x12\x1a\n\x08shutdown\x12\x06.Empty\x1a\x06.Empty\x12I\n\tdecompose\x12\x1d.imandrax.simple.DecomposeReq\x1a\x1d.imandrax.simple.DecomposeRes\x12\"\n\x0e\x63reate_session\x12\x06.Empty\x1a\x08.Session\x12\x41\n\x08\x65val_src\x12\x1b.imandrax.simple.EvalSrcReq\x1a\x18.imandrax.simple.EvalRes\x12G\n\nverify_src\x12\x1d.imandrax.simple.VerifySrcReq\x1a\x1a.imandrax.simple.VerifyRes\x12I\n\x0bverify_name\x12\x1e.imandrax.simple.VerifyNameReq\x1a\x1a.imandrax.simple.VerifyRes\x12M\n\x0cinstance_src\x12\x1f.imandrax.simple.InstanceSrcReq\x1a\x1c.imandrax.simple.InstanceRes\x12O\n\rinstance_name\x12 .imandrax.simple.InstanceNameReq\x1a\x1c.imandrax.simple.InstanceResb\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'simple_api_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  DESCRIPTOR._loaded_options = None
  _globals['_MODELTYPE']._serialized_start=2206
  _globals['_MODELTYPE']._serialized_end=2252
  _globals['_DECOMPOSEREQ']._serialized_start=79
  _globals['_DECOMPOSEREQ']._serialized_end=259
  _globals['_DECOMPOSEREGION']._serialized_start=261
  _globals['_DECOMPOSEREGION']._serialized_end=360
  _globals['_DECOMPOSERES']._serialized_start=362
  _globals['_DECOMPOSERES']._serialized_end=427
  _globals['_EVALSRCREQ']._serialized_start=429
  _globals['_EVALSRCREQ']._serialized_end=481
  _globals['_EVALRES']._serialized_start=483
  _globals['_EVALRES']._serialized_end=551
  _globals['_VERIFYSRCREQ']._serialized_start=553
  _globals['_VERIFYSRCREQ']._serialized_end=667
  _globals['_VERIFYNAMEREQ']._serialized_start=669
  _globals['_VERIFYNAMEREQ']._serialized_end=785
  _globals['_INSTANCESRCREQ']._serialized_start=787
  _globals['_INSTANCESRCREQ']._serialized_end=903
  _globals['_INSTANCENAMEREQ']._serialized_start=905
  _globals['_INSTANCENAMEREQ']._serialized_end=1023
  _globals['_PROVED']._serialized_start=1025
  _globals['_PROVED']._serialized_end=1069
  _globals['_UNSAT']._serialized_start=1071
  _globals['_UNSAT']._serialized_end=1114
  _globals['_MODEL']._serialized_start=1116
  _globals['_MODEL']._serialized_end=1180
  _globals['_REFUTED']._serialized_start=1182
  _globals['_REFUTED']._serialized_end=1245
  _globals['_SAT']._serialized_start=1247
  _globals['_SAT']._serialized_end=1306
  _globals['_VERIFYRES']._serialized_start=1309
  _globals['_VERIFYRES']._serialized_end=1469
  _globals['_INSTANCERES']._serialized_start=1472
  _globals['_INSTANCERES']._serialized_end=1624
  _globals['_HINTS']._serialized_start=1627
  _globals['_HINTS']._serialized_end=2204
  _globals['_HINTS_INDUCT']._serialized_start=1759
  _globals['_HINTS_INDUCT']._serialized_end=2105
  _globals['_HINTS_INDUCT_FUNCTIONAL']._serialized_start=1924
  _globals['_HINTS_INDUCT_FUNCTIONAL']._serialized_end=1952
  _globals['_HINTS_INDUCT_STRUCTURAL']._serialized_start=1954
  _globals['_HINTS_INDUCT_STRUCTURAL']._serialized_end=2042
  _globals['_HINTS_INDUCT_STRUCTURALSTYLE']._serialized_start=2044
  _globals['_HINTS_INDUCT_STRUCTURALSTYLE']._serialized_end=2095
  _globals['_HINTS_UNROLL']._serialized_start=2107
  _globals['_HINTS_UNROLL']._serialized_end=2193
  _globals['_SIMPLE']._serialized_start=2255
  _globals['_SIMPLE']._serialized_end=2807
# @@protoc_insertion_point(module_scope)
