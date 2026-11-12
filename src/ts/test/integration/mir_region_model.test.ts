import { describe, expect, test } from "vitest";

import type { AppliedSymbol, Decomposition, Model, Term, Variable } from "../../lib/index.js";
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
    const dres = res.decompResults[0]!;
    expect(dres.decomposition, dres.errors.join("\n")).toBeDefined();

    const decomp: Decomposition = dres.decomposition!;

    expect(decomp.arguments, "g should only has x as arguments").toHaveLength(1);
    const x: Variable = decomp.arguments[0]!;
    // Python's `repr` of `{"short_name": ..., "type": ...}`, with the type's `repr`, `<ConstructedType int>`
    expect(`{'short_name': '${x.id.shortName}', 'type': <${x.type.constructor.name} ${x.type}>}`).toBe(
      "{'short_name': 'x', 'type': <ConstructedType int>}",
    );

    const models: (Model | undefined)[] = decomp.regions.map((r) => r.model);
    const fstModel = models[0];
    expect(fstModel).toBeDefined();

    const consts: ReadonlyMap<AppliedSymbol, Term> = fstModel!.constants;
    expect(consts.size).toBe(2);
    const [[x_], [x__]] = [...consts];
    expect([x_!.id.shortName, x__!.id.shortName], "Regions have the same variable x ...").toEqual(["x", "x"]);
    expect(x_!.id.fullName, "... with different full name").not.toBe(x__!.id.fullName);
  });
});
