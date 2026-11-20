#!/usr/bin/env python3
"""Check that every language client has what docs/dev-language-api.md requires.

Usage: python3 scripts/check_parity.py docs/parity.toml

The TOML file lists the clients, the features and the differences (see its header). Exits 1 and lists what a
client is missing. Paths are relative to the repository root.
"""

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MARKER = re.compile(r"^\s*(?:#|//)\s*parity:\s*([\w.]*\w)", re.M)


def files(path: Path, ext: str) -> list[Path]:
    if not path.exists():
        sys.exit(f"{path} does not exist: fix docs/parity.toml")
    return [path] if path.is_file() else sorted(path.rglob(f"*{ext}"))


def spell(rpc: str, case: str) -> str:
    if case == "snake":
        return rpc
    head, *rest = rpc.split("_")
    return head + "".join(w.capitalize() for w in rest)


def check(config: dict) -> tuple[list[str], list[str]]:
    features: dict = config["features"]
    protos = (ROOT / "src/proto").glob("*.proto")
    rpcs = {
        r for p in protos for r in re.findall(r"^\s*rpc\s+(\w+)", p.read_text(), re.M)
    }
    rpcs -= set(config["rpc"]["not_a_method"])
    errors: list[str] = []
    gaps: list[str] = []
    for lang, client in config["clients"].items():
        src = "\n".join(
            p.read_text() for p in files(ROOT / client["src"], client["ext"])
        )
        tests = {
            p.relative_to(ROOT): p.read_text()
            for p in files(ROOT / client["tests"], client["ext"])
        }
        all_tests = "\n".join(tests.values())

        for rpc in sorted(rpcs):
            name = spell(rpc, client["case"])
            if not re.search(client["method"].format(name=name), src, re.M):
                errors.append(f"{lang}: no method {name} for rpc {rpc} (4.3)")
            elif not re.search(rf"\.{name}\s*\(", all_tests):
                errors.append(f"{lang}: no test calls .{name}( (4.3)")

        marked: dict[str, Path] = {}
        for path, text in tests.items():
            for m in MARKER.finditer(text):
                marked.setdefault(m[1], path)
        for fid in sorted(marked.keys() - features.keys()):
            errors.append(f"{lang}: unknown feature `parity: {fid}` in {marked[fid]}")

        for fid, feature in features.items():
            differs = feature.get(lang)
            gap = feature.get("missing", {}).get(lang)
            if fid in marked and (differs or gap):
                errors.append(
                    f"{lang}: {fid} is marked in {marked[fid]}, but listed as "
                    f"{'a difference' if differs else 'missing'}: delete that entry"
                )
            elif gap:
                gaps.append(f"{lang}: {fid} ({feature['spec']}): {gap}")
            elif fid not in marked and not differs:
                errors.append(
                    f"{lang}: no test marked `parity: {fid}` ({feature['spec']})"
                )
        differences = {
            did for did, d in config["differences"].items() if d["client"] == lang
        }
        annotated: dict[str, Path] = {}
        for path in files(ROOT / client["lib"], client["ext"]):
            for m in MARKER.finditer(path.read_text()):
                annotated.setdefault(m[1], path.relative_to(ROOT))
        for did in sorted(annotated.keys() - differences):
            errors.append(
                f"{lang}: unknown difference `parity: {did}` in {annotated[did]}"
            )
        for did in sorted(differences - annotated.keys()):
            errors.append(
                f"{lang}: difference {did} is not annotated `parity: {did}` in {client['lib']}"
            )
    return errors, gaps


def main() -> int:
    config = tomllib.loads(Path(sys.argv[1]).read_text())
    errors, gaps = check(config)
    if gaps:
        print("Known gaps (not failures):", *gaps, sep="\n  ")
    if errors:
        print("Parity check failed:", *errors, sep="\n  ")
        return 1
    print(
        f"Parity check passed: {', '.join(config['clients'])}, "
        f"{len(config['features'])} features, {len(config['differences'])} differences"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
