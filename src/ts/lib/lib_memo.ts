/**
 * A memo for converting lib objects to API objects, so shared lib objects convert once
 *
 * @module
 */

// Note [Lib memo]
// ~~~~~~~~~~~~~~~
// The twine decoder returns one lib object for every reference to a shared term or type, so lib
// data is a graph.
//
// Without a memo, `termOfLib` and `typeOfLib` would convert a shared node once per path to it,
// expanding the graph into a tree: the work and the memory grow with the number of paths rather
// than the number of nodes.
//
// The memo maps a lib object, by identity, to the converted object. It is active for the
// duration of the outermost conversion that uses it:
// - `termOfLib` and `typeOfLib` open a memo when none is active, so one call shares within its
//   own term;
// - conversions of data holding many terms (e.g. `Decomposition.ofLib`) use `withLibMemo`, so
//   terms shared between their parts convert once too.
//
// Conversions are synchronous, so a module-level variable plays the role of Python's context
// variable: no other conversion can run while one is in progress.
//
// A memo is per conversion, not global: a global one would keep lib and client objects alive
// after the result is dropped, and would share client objects between artifacts.

import type * as lib from "./raw/types.js";
import type { Term, Type } from "./mir.js";

/** The API objects converted so far in one conversion */
export interface LibMemo {
  /** Converted terms, keyed by lib term */
  readonly terms: Map<lib.Mir_Term, Term>;
  /** Converted types, keyed by lib type */
  readonly types: Map<lib.Mir_Type, Type>;
}

let active: LibMemo | undefined = undefined;

/** The memo of the conversion in progress, `undefined` outside of one */
export function activeLibMemo(): LibMemo | undefined {
  return active;
}

/** Run `f` with a lib memo, unless one is already active */
export function withLibMemo<R>(f: () => R): R {
  if (active !== undefined) {
    return f();
  }
  active = { terms: new Map(), types: new Map() };
  try {
    return f();
  } finally {
    active = undefined;
  }
}
