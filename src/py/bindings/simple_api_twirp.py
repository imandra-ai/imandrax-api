# -*- coding: utf-8 -*-
# Generated by https://github.com/verloop/twirpy/protoc-gen-twirpy.  DO NOT EDIT!
# source: simple_api.proto

from google.protobuf import symbol_database as _symbol_database

from ..twirp.client import TwirpClient
_async_available = False

_sym_db = _symbol_database.Default()


class SimpleClient(TwirpClient):

	def status(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/status",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("StringMsg"),
			**kwargs,
		)

	def shutdown(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/shutdown",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("Empty"),
			**kwargs,
		)

	def create_session(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/create_session",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.session.Session"),
			**kwargs,
		)

	def end_session(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/end_session",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("Empty"),
			**kwargs,
		)

	def eval_src(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/eval_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.EvalRes"),
			**kwargs,
		)

	def verify_src(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/verify_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			**kwargs,
		)

	def verify_name(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/verify_name",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			**kwargs,
		)

	def instance_src(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/instance_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			**kwargs,
		)

	def instance_name(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/instance_name",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			**kwargs,
		)

	def decompose(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/decompose",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.DecomposeRes"),
			**kwargs,
		)

	def typecheck(self, *args, ctx, request, **kwargs):
		return self._make_request(
			url=F"{self._server_path_prefix}/imandrax.simple.Simple/typecheck",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.TypecheckRes"),
			**kwargs,
		)
