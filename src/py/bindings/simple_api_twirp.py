# -*- coding: utf-8 -*-
# Generated by https://github.com/verloop/twirpy/protoc-gen-twirpy.  DO NOT EDIT!
# source: simple_api.proto

from google.protobuf import symbol_database as _symbol_database

from twirp.base import Endpoint
from twirp.server import TwirpServer
from twirp.client import TwirpClient
try:
	from twirp.async_client import AsyncTwirpClient
	_async_available = True
except ModuleNotFoundError:
	_async_available = False

_sym_db = _symbol_database.Default()

class SimpleServer(TwirpServer):

	def __init__(self, *args, service, server_path_prefix="/twirp"):
		super().__init__(service=service)
		self._prefix = F"{server_path_prefix}/imandrax.simple.Simple"
		self._endpoints = {
			"status": Endpoint(
				service_name="Simple",
				name="status",
				function=getattr(service, "status"),
				input=_sym_db.GetSymbol("Empty"),
				output=_sym_db.GetSymbol("StringMsg"),
			),
			"shutdown": Endpoint(
				service_name="Simple",
				name="shutdown",
				function=getattr(service, "shutdown"),
				input=_sym_db.GetSymbol("Empty"),
				output=_sym_db.GetSymbol("Empty"),
			),
			"decompose": Endpoint(
				service_name="Simple",
				name="decompose",
				function=getattr(service, "decompose"),
				input=_sym_db.GetSymbol("imandrax.simple.DecomposeReq"),
				output=_sym_db.GetSymbol("imandrax.simple.DecomposeRes"),
			),
			"create_session": Endpoint(
				service_name="Simple",
				name="create_session",
				function=getattr(service, "create_session"),
				input=_sym_db.GetSymbol("imandrax.simple.SessionCreateReq"),
				output=_sym_db.GetSymbol("imandrax.session.Session"),
			),
			"eval_src": Endpoint(
				service_name="Simple",
				name="eval_src",
				function=getattr(service, "eval_src"),
				input=_sym_db.GetSymbol("imandrax.simple.EvalSrcReq"),
				output=_sym_db.GetSymbol("imandrax.simple.EvalRes"),
			),
			"verify_src": Endpoint(
				service_name="Simple",
				name="verify_src",
				function=getattr(service, "verify_src"),
				input=_sym_db.GetSymbol("imandrax.simple.VerifySrcReq"),
				output=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			),
			"verify_name": Endpoint(
				service_name="Simple",
				name="verify_name",
				function=getattr(service, "verify_name"),
				input=_sym_db.GetSymbol("imandrax.simple.VerifyNameReq"),
				output=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			),
			"instance_src": Endpoint(
				service_name="Simple",
				name="instance_src",
				function=getattr(service, "instance_src"),
				input=_sym_db.GetSymbol("imandrax.simple.InstanceSrcReq"),
				output=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			),
			"instance_name": Endpoint(
				service_name="Simple",
				name="instance_name",
				function=getattr(service, "instance_name"),
				input=_sym_db.GetSymbol("imandrax.simple.InstanceNameReq"),
				output=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			),
		}

class SimpleClient(TwirpClient):

	def status(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/status",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("StringMsg"),
			**kwargs,
		)

	def shutdown(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/shutdown",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("Empty"),
			**kwargs,
		)

	def decompose(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/decompose",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.DecomposeRes"),
			**kwargs,
		)

	def create_session(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/create_session",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.session.Session"),
			**kwargs,
		)

	def eval_src(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/eval_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.EvalRes"),
			**kwargs,
		)

	def verify_src(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/verify_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			**kwargs,
		)

	def verify_name(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/verify_name",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
			**kwargs,
		)

	def instance_src(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/instance_src",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			**kwargs,
		)

	def instance_name(self, *args, ctx, request, server_path_prefix="/twirp", **kwargs):
		return self._make_request(
			url=F"{server_path_prefix}/imandrax.simple.Simple/instance_name",
			ctx=ctx,
			request=request,
			response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
			**kwargs,
		)


if _async_available:
	class AsyncSimpleClient(AsyncTwirpClient):

		async def status(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/status",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("StringMsg"),
				session=session,
				**kwargs,
			)

		async def shutdown(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/shutdown",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("Empty"),
				session=session,
				**kwargs,
			)

		async def decompose(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/decompose",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.DecomposeRes"),
				session=session,
				**kwargs,
			)

		async def create_session(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/create_session",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.session.Session"),
				session=session,
				**kwargs,
			)

		async def eval_src(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/eval_src",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.EvalRes"),
				session=session,
				**kwargs,
			)

		async def verify_src(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/verify_src",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
				session=session,
				**kwargs,
			)

		async def verify_name(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/verify_name",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.VerifyRes"),
				session=session,
				**kwargs,
			)

		async def instance_src(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/instance_src",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
				session=session,
				**kwargs,
			)

		async def instance_name(self, *, ctx, request, server_path_prefix="/twirp", session=None, **kwargs):
			return await self._make_request(
				url=F"{server_path_prefix}/imandrax.simple.Simple/instance_name",
				ctx=ctx,
				request=request,
				response_obj=_sym_db.GetSymbol("imandrax.simple.InstanceRes"),
				session=session,
				**kwargs,
			)
