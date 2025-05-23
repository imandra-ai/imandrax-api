# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# NO CHECKED-IN PROTOBUF GENCODE
# source: simple_api.proto
# Protobuf Python Version: 5.29.4
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import runtime_version as _runtime_version
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
_runtime_version.ValidateProtobufRuntimeVersion(
    _runtime_version.Domain.PUBLIC,
    5,
    29,
    4,
    '',
    'simple_api.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import error_pb2 as error__pb2
import utils_pb2 as utils__pb2
import session_pb2 as session__pb2
import artmsg_pb2 as artmsg__pb2
import task_pb2 as task__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\x10simple_api.proto\x12\x0fimandrax.simple\x1a\x0b\x65rror.proto\x1a\x0butils.proto\x1a\rsession.proto\x1a\x0c\x61rtmsg.proto\x1a\ntask.proto\"\'\n\x10SessionCreateReq\x12\x13\n\x0b\x61pi_version\x18\x01 \x01(\t\"\x9d\x02\n\x0c\x44\x65\x63omposeReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x15\n\x08\x61ssuming\x18\x03 \x01(\tH\x00\x88\x01\x01\x12\r\n\x05\x62\x61sis\x18\x04 \x03(\t\x12\x12\n\nrule_specs\x18\x05 \x03(\t\x12\r\n\x05prune\x18\x06 \x01(\x08\x12\x15\n\x08\x63tx_simp\x18\x07 \x01(\x08H\x01\x88\x01\x01\x12\x31\n\tlift_bool\x18\x08 \x01(\x0e\x32\x19.imandrax.simple.LiftBoolH\x02\x88\x01\x01\x12\x10\n\x03str\x18\t \x01(\x08H\x03\x88\x01\x01\x42\x0b\n\t_assumingB\x0b\n\t_ctx_simpB\x0c\n\n_lift_boolB\x06\n\x04_str\"s\n\x0c\x44\x65\x63omposeRes\x12\x18\n\x08\x61rtifact\x18\x01 \x01(\x0b\x32\x04.ArtH\x00\x12\x15\n\x03\x65rr\x18\x02 \x01(\x0b\x32\x06.EmptyH\x00\x12\x16\n\x06\x65rrors\x18\n \x03(\x0b\x32\x06.Error\x12\x13\n\x04task\x18\x0b \x01(\x0b\x32\x05.TaskB\x05\n\x03res\"E\n\nEvalSrcReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\"Z\n\x07\x45valRes\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\x10\n\x08messages\x18\x02 \x03(\t\x12\x16\n\x06\x65rrors\x18\x03 \x03(\x0b\x32\x06.Error\x12\x14\n\x05tasks\x18\x04 \x03(\x0b\x32\x05.Task\"e\n\x0cVerifySrcReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\x12\x12\n\x05hints\x18\n \x01(\tH\x00\x88\x01\x01\x42\x08\n\x06_hints\"g\n\rVerifyNameReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x12\n\x05hints\x18\n \x01(\tH\x00\x88\x01\x01\x42\x08\n\x06_hints\"g\n\x0eInstanceSrcReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\x12\x12\n\x05hints\x18\n \x01(\tH\x00\x88\x01\x01\x42\x08\n\x06_hints\"i\n\x0fInstanceNameReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0c\n\x04name\x18\x02 \x01(\t\x12\x12\n\x05hints\x18\n \x01(\tH\x00\x88\x01\x01\x42\x08\n\x06_hints\",\n\x06Proved\x12\x15\n\x08proof_pp\x18\x01 \x01(\tH\x00\x88\x01\x01\x42\x0b\n\t_proof_pp\")\n\rVerified_upto\x12\x10\n\x03msg\x18\x01 \x01(\tH\x00\x88\x01\x01\x42\x06\n\x04_msg\"+\n\x05Unsat\x12\x15\n\x08proof_pp\x18\x01 \x01(\tH\x00\x88\x01\x01\x42\x0b\n\t_proof_pp\"j\n\x05Model\x12*\n\x06m_type\x18\x01 \x01(\x0e\x32\x1a.imandrax.simple.ModelType\x12\x0b\n\x03src\x18\x02 \x01(\t\x12\x1b\n\x08\x61rtifact\x18\x03 \x01(\x0b\x32\x04.ArtH\x00\x88\x01\x01\x42\x0b\n\t_artifact\"?\n\x07Refuted\x12*\n\x05model\x18\x01 \x01(\x0b\x32\x16.imandrax.simple.ModelH\x00\x88\x01\x01\x42\x08\n\x06_model\";\n\x03Sat\x12*\n\x05model\x18\x01 \x01(\x0b\x32\x16.imandrax.simple.ModelH\x00\x88\x01\x01\x42\x08\n\x06_model\"\x86\x02\n\tVerifyRes\x12\x1d\n\x07unknown\x18\x01 \x01(\x0b\x32\n.StringMsgH\x00\x12\x15\n\x03\x65rr\x18\x02 \x01(\x0b\x32\x06.EmptyH\x00\x12)\n\x06proved\x18\x03 \x01(\x0b\x32\x17.imandrax.simple.ProvedH\x00\x12+\n\x07refuted\x18\x04 \x01(\x0b\x32\x18.imandrax.simple.RefutedH\x00\x12\x37\n\rverified_upto\x18\x05 \x01(\x0b\x32\x1e.imandrax.simple.Verified_uptoH\x00\x12\x16\n\x06\x65rrors\x18\n \x03(\x0b\x32\x06.Error\x12\x13\n\x04task\x18\x0b \x01(\x0b\x32\x05.TaskB\x05\n\x03res\"\xc5\x01\n\x0bInstanceRes\x12\x1d\n\x07unknown\x18\x01 \x01(\x0b\x32\n.StringMsgH\x00\x12\x15\n\x03\x65rr\x18\x02 \x01(\x0b\x32\x06.EmptyH\x00\x12\'\n\x05unsat\x18\x03 \x01(\x0b\x32\x16.imandrax.simple.UnsatH\x00\x12#\n\x03sat\x18\x04 \x01(\x0b\x32\x14.imandrax.simple.SatH\x00\x12\x16\n\x06\x65rrors\x18\n \x03(\x0b\x32\x06.Error\x12\x13\n\x04task\x18\x0b \x01(\x0b\x32\x05.TaskB\x05\n\x03res\"G\n\x0cTypecheckReq\x12*\n\x07session\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x0b\n\x03src\x18\x02 \x01(\t\"F\n\x0cTypecheckRes\x12\x0f\n\x07success\x18\x01 \x01(\x08\x12\r\n\x05types\x18\x02 \x01(\t\x12\x16\n\x06\x65rrors\x18\x03 \x03(\x0b\x32\x06.Error*F\n\x08LiftBool\x12\x0b\n\x07\x44\x65\x66\x61ult\x10\x00\x12\x14\n\x10NestedEqualities\x10\x01\x12\x0e\n\nEqualities\x10\x02\x12\x07\n\x03\x41ll\x10\x03*.\n\tModelType\x12\x13\n\x0f\x43ounter_example\x10\x00\x12\x0c\n\x08Instance\x10\x01\x32\xd1\x05\n\x06Simple\x12\x1c\n\x06status\x12\x06.Empty\x1a\n.StringMsg\x12\x1a\n\x08shutdown\x12\x06.Empty\x1a\x06.Empty\x12N\n\x0e\x63reate_session\x12!.imandrax.simple.SessionCreateReq\x1a\x19.imandrax.session.Session\x12\x30\n\x0b\x65nd_session\x12\x19.imandrax.session.Session\x1a\x06.Empty\x12\x41\n\x08\x65val_src\x12\x1b.imandrax.simple.EvalSrcReq\x1a\x18.imandrax.simple.EvalRes\x12G\n\nverify_src\x12\x1d.imandrax.simple.VerifySrcReq\x1a\x1a.imandrax.simple.VerifyRes\x12I\n\x0bverify_name\x12\x1e.imandrax.simple.VerifyNameReq\x1a\x1a.imandrax.simple.VerifyRes\x12M\n\x0cinstance_src\x12\x1f.imandrax.simple.InstanceSrcReq\x1a\x1c.imandrax.simple.InstanceRes\x12O\n\rinstance_name\x12 .imandrax.simple.InstanceNameReq\x1a\x1c.imandrax.simple.InstanceRes\x12I\n\tdecompose\x12\x1d.imandrax.simple.DecomposeReq\x1a\x1d.imandrax.simple.DecomposeRes\x12I\n\ttypecheck\x12\x1d.imandrax.simple.TypecheckReq\x1a\x1d.imandrax.simple.TypecheckResb\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'simple_api_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  DESCRIPTOR._loaded_options = None
  _globals['_LIFTBOOL']._serialized_start=2111
  _globals['_LIFTBOOL']._serialized_end=2181
  _globals['_MODELTYPE']._serialized_start=2183
  _globals['_MODELTYPE']._serialized_end=2229
  _globals['_SESSIONCREATEREQ']._serialized_start=104
  _globals['_SESSIONCREATEREQ']._serialized_end=143
  _globals['_DECOMPOSEREQ']._serialized_start=146
  _globals['_DECOMPOSEREQ']._serialized_end=431
  _globals['_DECOMPOSERES']._serialized_start=433
  _globals['_DECOMPOSERES']._serialized_end=548
  _globals['_EVALSRCREQ']._serialized_start=550
  _globals['_EVALSRCREQ']._serialized_end=619
  _globals['_EVALRES']._serialized_start=621
  _globals['_EVALRES']._serialized_end=711
  _globals['_VERIFYSRCREQ']._serialized_start=713
  _globals['_VERIFYSRCREQ']._serialized_end=814
  _globals['_VERIFYNAMEREQ']._serialized_start=816
  _globals['_VERIFYNAMEREQ']._serialized_end=919
  _globals['_INSTANCESRCREQ']._serialized_start=921
  _globals['_INSTANCESRCREQ']._serialized_end=1024
  _globals['_INSTANCENAMEREQ']._serialized_start=1026
  _globals['_INSTANCENAMEREQ']._serialized_end=1131
  _globals['_PROVED']._serialized_start=1133
  _globals['_PROVED']._serialized_end=1177
  _globals['_VERIFIED_UPTO']._serialized_start=1179
  _globals['_VERIFIED_UPTO']._serialized_end=1220
  _globals['_UNSAT']._serialized_start=1222
  _globals['_UNSAT']._serialized_end=1265
  _globals['_MODEL']._serialized_start=1267
  _globals['_MODEL']._serialized_end=1373
  _globals['_REFUTED']._serialized_start=1375
  _globals['_REFUTED']._serialized_end=1438
  _globals['_SAT']._serialized_start=1440
  _globals['_SAT']._serialized_end=1499
  _globals['_VERIFYRES']._serialized_start=1502
  _globals['_VERIFYRES']._serialized_end=1764
  _globals['_INSTANCERES']._serialized_start=1767
  _globals['_INSTANCERES']._serialized_end=1964
  _globals['_TYPECHECKREQ']._serialized_start=1966
  _globals['_TYPECHECKREQ']._serialized_end=2037
  _globals['_TYPECHECKRES']._serialized_start=2039
  _globals['_TYPECHECKRES']._serialized_end=2109
  _globals['_SIMPLE']._serialized_start=2232
  _globals['_SIMPLE']._serialized_end=2953
# @@protoc_insertion_point(module_scope)
