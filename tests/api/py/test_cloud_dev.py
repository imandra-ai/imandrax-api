#!/usr/bin/env python3
# pyright: basic
"""Test imandrax_api Python client: eval, artifacts, parsing."""

import os
import sys

import imandrax_api
import imandrax_api.lib as xtypes


def main():
    url = imandrax_api.url_dev
    auth_path = os.path.expanduser("~/.config/imandrax/api_key")

    try:
        with open(auth_path, "r") as f:
            auth_token = f.read().strip()
    except Exception as e:
        print(f"ERROR: Could not read auth token from {auth_path}: {e}")
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

    with open("art.po_task.zip", "wb") as f:
        f.write(art_po_task.art_zip)
    with open("art.po_res.zip", "wb") as f:
        f.write(art_po_res.art_zip)

    del c

    print("5. parse artifacts")
    art_task = xtypes.read_artifact_zip("art.po_task.zip")
    art_res = xtypes.read_artifact_zip("art.po_res.zip")
    assert art_task is not None, "failed to parse po_task"
    assert art_res is not None, "failed to parse po_res"

    print("PASSED")


if __name__ == "__main__":
    main()
