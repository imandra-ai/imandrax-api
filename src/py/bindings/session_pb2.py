# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: session.proto
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import utils_pb2 as utils__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\rsession.proto\x12\x10imandrax.session\x1a\x0butils.proto\"\x15\n\x07Session\x12\n\n\x02id\x18\x01 \x01(\t\"H\n\rSessionCreate\x12\x15\n\x08po_check\x18\x01 \x01(\x08H\x00\x88\x01\x01\x12\x13\n\x0b\x61pi_version\x18\x02 \x01(\tB\x0b\n\t_po_check\"I\n\x0bSessionOpen\x12%\n\x02id\x18\x01 \x01(\x0b\x32\x19.imandrax.session.Session\x12\x13\n\x0b\x61pi_version\x18\x02 \x01(\t2\x80\x02\n\x0eSessionManager\x12L\n\x0e\x63reate_session\x12\x1f.imandrax.session.SessionCreate\x1a\x19.imandrax.session.Session\x12\x35\n\x0copen_session\x12\x1d.imandrax.session.SessionOpen\x1a\x06.Empty\x12\x30\n\x0b\x65nd_session\x12\x19.imandrax.session.Session\x1a\x06.Empty\x12\x37\n\x12keep_session_alive\x12\x19.imandrax.session.Session\x1a\x06.Emptyb\x06proto3')



_SESSION = DESCRIPTOR.message_types_by_name['Session']
_SESSIONCREATE = DESCRIPTOR.message_types_by_name['SessionCreate']
_SESSIONOPEN = DESCRIPTOR.message_types_by_name['SessionOpen']
Session = _reflection.GeneratedProtocolMessageType('Session', (_message.Message,), {
  'DESCRIPTOR' : _SESSION,
  '__module__' : 'session_pb2'
  # @@protoc_insertion_point(class_scope:imandrax.session.Session)
  })
_sym_db.RegisterMessage(Session)

SessionCreate = _reflection.GeneratedProtocolMessageType('SessionCreate', (_message.Message,), {
  'DESCRIPTOR' : _SESSIONCREATE,
  '__module__' : 'session_pb2'
  # @@protoc_insertion_point(class_scope:imandrax.session.SessionCreate)
  })
_sym_db.RegisterMessage(SessionCreate)

SessionOpen = _reflection.GeneratedProtocolMessageType('SessionOpen', (_message.Message,), {
  'DESCRIPTOR' : _SESSIONOPEN,
  '__module__' : 'session_pb2'
  # @@protoc_insertion_point(class_scope:imandrax.session.SessionOpen)
  })
_sym_db.RegisterMessage(SessionOpen)

_SESSIONMANAGER = DESCRIPTOR.services_by_name['SessionManager']
if _descriptor._USE_C_DESCRIPTORS == False:

  DESCRIPTOR._options = None
  _SESSION._serialized_start=48
  _SESSION._serialized_end=69
  _SESSIONCREATE._serialized_start=71
  _SESSIONCREATE._serialized_end=143
  _SESSIONOPEN._serialized_start=145
  _SESSIONOPEN._serialized_end=218
  _SESSIONMANAGER._serialized_start=221
  _SESSIONMANAGER._serialized_end=477
# @@protoc_insertion_point(module_scope)
