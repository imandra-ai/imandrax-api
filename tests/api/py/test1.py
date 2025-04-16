import imandrax_api
import time

def timeit(what: str, f, *args, **kwargs):
    t_start = time.monotonic_ns() / 1e9
    res = f(*args, **kwargs)
    t_stop = time.monotonic_ns() / 1e9
    print(f"{what} took {t_stop - t_start:.5}s")
    return res

c = timeit("create client", lambda: imandrax_api.Client(url="http://localhost:8082"))
c.status()

x1 = timeit("eval1", lambda: c.eval_src(src="let f x=x+1 ;;"))
print("x1: ", x1)

x2 = timeit("eval2", lambda: c.eval_src(src="theorem yolo1 x = f x > x ;;"))

print("x2: ", x2)

print(x2.tasks)
task2 = x2.tasks[0]
print("task2: ", task2)

arts = c.list_artifacts(task2)
print("arts:", arts)

art_show = c.get_artifact_zip(task2, kind="show")
print(f'art show size={len(art_show.art_zip)}')

art_po_task = c.get_artifact_zip(task2, kind="po_task")
print(f'art po task size: {len(art_po_task.art_zip)}')

with open('art.po_task.zip', 'wb') as f:
    f.write(art_po_task.art_zip)

art_po_res = c.get_artifact_zip(task2, kind="po_res")
print(f'art po res: {len(art_po_res.art_zip)}')
with open('art.po_res.zip', 'wb') as f:
    f.write(art_po_res.art_zip)

with open('art.po_res.zip', 'wb') as f:
    f.write(art_po_res.art_zip)

del c
