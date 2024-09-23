
import imandrax_api
import imandrax_api.lib as xtypes

c = imandrax_api.Client(url="http://localhost:8082")
c.status()

x1 = c.eval_src(src="let f x=x+1 ;;")
print("x1: ", x1)

x2 = c.instance_src(src="fun x -> x > 10 && x < 12")

print("x2: ", x2)

# artifact
art = x2.sat.model.artifact
print("artifact: ", art)

with open('/tmp/yolo.art', 'wb') as f:
    f.write(art.data)

# read model
m = xtypes.read_artifact_data(art.data, kind=art.kind)
print("decoded model: ", m)
