# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# NO CHECKED-IN PROTOBUF GENCODE
# source: task.proto
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
    'task.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\ntask.proto\"\x14\n\x06TaskID\x12\n\n\x02id\x18\x01 \x01(\t\"4\n\x04Task\x12\x13\n\x02id\x18\x01 \x01(\x0b\x32\x07.TaskID\x12\x17\n\x04kind\x18\x02 \x01(\x0e\x32\t.TaskKind*X\n\x08TaskKind\x12\x14\n\x10TASK_UNSPECIFIED\x10\x00\x12\r\n\tTASK_EVAL\x10\x01\x12\x11\n\rTASK_CHECK_PO\x10\x02\x12\x14\n\x10TASK_PROOF_CHECK\x10\x03\x62\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'task_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  DESCRIPTOR._loaded_options = None
  _globals['_TASKKIND']._serialized_start=90
  _globals['_TASKKIND']._serialized_end=178
  _globals['_TASKID']._serialized_start=14
  _globals['_TASKID']._serialized_end=34
  _globals['_TASK']._serialized_start=36
  _globals['_TASK']._serialized_end=88
# @@protoc_insertion_point(module_scope)
