/**
 * Make `toEqual` compare library objects by value, as the library does
 *
 * - objects with an `equals` method (uids, types, terms, rationals, ...) compare with it
 * - `ValueMap`s and `ValueSet`s compare their entries by value, in any order
 * - other library objects (those with a `raw` field) compare their other fields, of the same class
 *
 * A comparison with a plain object, as in `toMatchObject({ ... })`, is left to vitest.
 *
 * Registered for every test file, see `vitest.config.ts`.
 */

import { expect } from "vitest";

import { ValueMap, ValueSet } from "../lib/mir.js";

type Obj = Record<string, unknown>;
type Tester = Parameters<typeof expect.addEqualityTesters>[0][number];

function hasEquals(x: object): x is { equals(o: unknown): boolean } {
  return typeof (x as { equals?: unknown }).equals === "function";
}

/** An instance of a library class, not a plain object, array or builtin collection */
function isLibObject(x: unknown): x is Obj {
  return (
    typeof x === "object" &&
    x !== null &&
    Object.getPrototypeOf(x) !== Object.prototype &&
    (hasEquals(x) || Object.hasOwn(x, "raw"))
  );
}

const libEquality: Tester = function (a, b, testers) {
  if (a instanceof ValueSet && b instanceof ValueSet) {
    return a.size === b.size && [...a].every((x) => b.has(x));
  }
  if (a instanceof ValueMap && b instanceof ValueMap) {
    return (
      a.size === b.size && [...a].every(([k, v]) => b.has(k) && this.equals(v, b.get(k), testers))
    );
  }
  if (!isLibObject(a) || !isLibObject(b)) {
    return undefined;
  }
  if (hasEquals(a)) {
    return a.equals(b);
  }
  if (Object.getPrototypeOf(a) !== Object.getPrototypeOf(b)) {
    return false;
  }
  const keys = Object.keys(a).filter((k) => k !== "raw");
  return (
    keys.length === Object.keys(b).filter((k) => k !== "raw").length &&
    keys.every((k) => this.equals(a[k], b[k], testers))
  );
};

expect.addEqualityTesters([libEquality]);
