import imandrax_api

c = imandrax_api.Client(url="http://localhost:8082")
c.status()

x1 = c.eval_src(src="let f x=x+1 ;;")
print("x1: ", x1)

x2 = c.eval_src(src="theorem yolo1 x = f x > x ;;")

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
