# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# NO CHECKED-IN PROTOBUF GENCODE
# source: error.proto
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
    'error.proto'
)
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import locs_pb2 as locs__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\x0b\x65rror.proto\x1a\nlocs.proto\"\xca\x01\n\x05\x45rror\x12\x1b\n\x03msg\x18\x01 \x01(\x0b\x32\x0e.Error.Message\x12\x0c\n\x04kind\x18\x02 \x01(\t\x12\x1d\n\x05stack\x18\x03 \x03(\x0b\x32\x0e.Error.Message\x12\x14\n\x07process\x18\x04 \x01(\tH\x00\x88\x01\x01\x1aU\n\x07Message\x12\x0b\n\x03msg\x18\x01 \x01(\t\x12\x17\n\x04locs\x18\x02 \x03(\x0b\x32\t.Location\x12\x16\n\tbacktrace\x18\x03 \x01(\tH\x00\x88\x01\x01\x42\x0c\n\n_backtraceB\n\n\x08_processb\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'error_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
  DESCRIPTOR._loaded_options = None
  _globals['_ERROR']._serialized_start=28
  _globals['_ERROR']._serialized_end=230
  _globals['_ERROR_MESSAGE']._serialized_start=133
  _globals['_ERROR_MESSAGE']._serialized_end=218
# @@protoc_insertion_point(module_scope)
