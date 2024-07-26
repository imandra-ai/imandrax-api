from imandrax_api.bindings import utils_pb2, simple_api_twirp, simple_api_pb2
from twirp.context import Context

c = simple_api_twirp.SimpleClient("http://localhost:8082")
c.status(ctx=Context(), server_path_prefix="/api/v1", request=utils_pb2.Empty())

sesh = c.create_session(
    ctx=Context(), server_path_prefix="/api/v1", request=utils_pb2.Empty()
)

x1 = c.eval_src(
    ctx=Context(),
    server_path_prefix="/api/v1",
    request=simple_api_pb2.EvalSrcReq(src="let f x=x+1 ;;", session=sesh),
)
print('x1: ', x1)

x2 = c.eval_src(
    ctx=Context(),
    server_path_prefix="/api/v1",
    request=simple_api_pb2.EvalSrcReq(src="theorem yolo1 x = f x > x ;;", session=sesh),
)

print('x2: ', x2)
