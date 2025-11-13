#!/usr/bin/env python3
# pyright: basic
"""Test decomposition and region string parsing."""

import os
import sys

import imandrax_api
import imandrax_api.lib as xtypes


def main():
    url = imandrax_api.url_dev
    auth_path = os.path.expanduser("~/.config/imandrax/api_key")

    with open(auth_path, "r") as f:
        auth_token = f.read().strip()

    c = imandrax_api.Client(url, auth_token=auth_token)

    status = c.status()
    assert status.msg, "status should return message"

    src = "let add_positive x y = if x > 0 && y > 0 then x + y else 0 ;;"
    result = c.eval_src(src=src)
    assert result.success, f"eval_src failed: {result.errors}"

    decomp_result = c.decompose(name="add_positive", prune=True, str=True, timeout=30.0)
    assert decomp_result.HasField("artifact"), f"decompose missing artifact: {decomp_result.errors}"

    artifact = decomp_result.artifact
    assert artifact.kind == "mir.fun_decomp", f"unexpected artifact kind: {artifact.kind}"
    assert len(artifact.data) > 0, "artifact data is empty"

    with open("art.decomp.data", "wb") as f:
        f.write(artifact.data)

    region_strs = xtypes.get_region_str_from_decomp_artifact(
        data=artifact.data, kind=artifact.kind
    )
    assert len(region_strs) == 3, f"expected 3 regions, got {len(region_strs)}"

    print(f"Regions ({len(region_strs)}):")
    for i, r in enumerate(region_strs, 1):
        assert r.invariant_str is not None, f"region {i} missing invariant_str"
        assert r.model_str is not None, f"region {i} missing model_str"
        assert len(r.model_str) > 0, f"region {i} has empty model"

        print(f"  {i}. invariant: {r.invariant_str}")
        if r.constraints_str:
            for c in r.constraints_str[:2]:  # show first 2
                print(f"     constraint: {c}")
            if len(r.constraints_str) > 2:
                print(f"     ... {len(r.constraints_str) - 2} more")

    del c
    print("PASSED")


if __name__ == "__main__":
    main()
