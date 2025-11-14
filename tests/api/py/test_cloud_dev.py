#!/usr/bin/env python3
# pyright: basic
"""Test imandrax_api Python client: eval, artifacts, parsing."""

import io
import os
import sys
import zipfile

import imandrax_api
import imandrax_api.lib as xtypes


def main():
    url = imandrax_api.url_dev
    auth_token = os.environ.get("IMANDRAX_API_KEY")
    if auth_token is None:
        auth_path = os.path.expanduser("~/.config/imandrax/api_key")

        try:
            with open(auth_path, "r") as f:
                auth_token = f.read().strip()
        except Exception:
            pass
    if auth_token is None:
        print(f"ERROR: API key is not set and could not be from {auth_path}")
        sys.exit(1)

    c = imandrax_api.Client(url, auth_token=auth_token)

    print("1. status")
    status = c.status()
    assert status.msg, "status should return message"

    print("2. eval_src")
    x1 = c.eval_src(src="let f x=x+1 ;;")
    assert x1.success, f"eval_src failed: {x1.errors}"

    print("3. theorem")
    x2 = c.eval_src(src="theorem yolo1 x = f x > x ;;")
    assert x2.success, f"theorem failed: {x2.errors}"
    assert len(x2.tasks) > 0, "no tasks returned"

    task = x2.tasks[0]

    print("4. get artifacts")
    art_po_task = c.get_artifact_zip(task, kind="po_task")
    art_po_res = c.get_artifact_zip(task, kind="po_res")

    assert len(art_po_task.art_zip) > 0, "po_task artifact is empty"
    assert len(art_po_res.art_zip) > 0, "po_res artifact is empty"

    del c

    print("5. parse artifacts")
    # Extract from zip
    with zipfile.ZipFile(io.BytesIO(art_po_task.art_zip)) as zf:
        art_task_data = zf.read(zf.namelist()[0])
    with zipfile.ZipFile(io.BytesIO(art_po_res.art_zip)) as zf:
        art_res_data = zf.read(zf.namelist()[0])

    art_task = xtypes.read_artifact_data(data=art_task_data, kind="po_task")
    art_res = xtypes.read_artifact_data(data=art_res_data, kind="po_res")
    assert art_task is not None, "failed to parse po_task"
    assert art_res is not None, "failed to parse po_res"

    print("PASSED")


if __name__ == "__main__":
    main()
