import { assert, describe, expect, test } from "vitest";

import { ConstructedType } from "../../lib/internal/mir.js";
import { noApiKey, sharedClient } from "./setup.js";

const SRC_DECOMP_DUP_VAR = `
let pos (x : int) : bool = x > 0
let g (x : int) : int = if x > 8 then 1 else if x < -5 then 2 else 0
let d = g [@@decomp top () |>> enumerate_all ~style:Additive [top () [%id pos]] |>> prune]
`;

describe.skipIf(noApiKey)("region models", () => {
  const client = sharedClient();

  test("model tells same-named variables apart", async () => {
    // Region's model keys arguments by UID, so it's possible to tell them apart even
    // if they have the same short name, e.g. in case of `enumerate_all ~style:Additive`
    const res = await client().evalSrc(SRC_DECOMP_DUP_VAR);
    expect(res.success, res.errors.join("\n")).toBe(true);
    expect(res.decompResults).toHaveLength(1);
    const decomp = res.decompResults[0]!.decomposition;
    assert.isDefined(decomp, res.decompResults[0]!.errors.join("\n"));

    // g only has x as argument
    expect(decomp.arguments).toHaveLength(1);
    const x = decomp.arguments[0]!;
    expect(x.id.shortName).toBe("x");
    expect(x.type).toBeInstanceOf(ConstructedType);
    expect(`${x.type}`).toBe("int");

    // `Additive` keeps g's own regions and adds the ones refined by `pos`, whose models also
    // give a value to `pos`'s argument
    const refined = decomp.regions.find((r) => r.model?.constants.size === 2);
    assert.isDefined(refined, "some regions should be refined by `pos`");
    const ids = [...refined.model!.constants.keys()].map((s) => s.id);
    // the regions have the same variable x, with different full names
    expect(ids.map((u) => u.shortName)).toEqual(["x", "x"]);
    expect(ids[0]!.fullName).not.toBe(ids[1]!.fullName);
  });
});
