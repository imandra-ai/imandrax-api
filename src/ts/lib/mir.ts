/**
 * MIR, the intermediate representation ImandraX produces from IML
 *
 * Results describe code in MIR: types, terms, function and type declarations, rewrite and
 * instantiation rules, models, and the symbol database that names refer to.
 *
 * @module
 */

// Note [General Principles when Transforming OCaml Bindings to TypeScript]
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// The classes here wrap the generated lib types (`./raw/types.js`) following these principles:
// - use more readable names
// - variants without fields -> string-literal union
// - variant -> discriminated union of classes, each with a `kind` field, so a `switch` on
//   `kind` narrows the type and the compiler checks that every case is handled
// - records wrapping a variant -> one abstract base class for the record's fields, classes
//   extending the base class, plus the union
// - `'term` / `'ty` type parameters are specialized with MIR term and type
// - tuples -> objects with named fields (e.g. `Binder`, `NamedTerm`); association lists keyed by
//   unique names or uids -> `ReadonlyMap`s
// - the conversions from lib (`ofLib`, `*OfLib`) are `@internal`, left out of the `.d.ts` files
// - Some classes irrelevant to users are skipped, e.g.: Anchor, SubAnchor
//
// They are classes rather than plain objects because they keep the lib object in `raw`,
// convert their fields lazily (see Note [Lib memo]), and have `equals` and `toString`.
//
// Note: all `toString` in there are purely for debugging purposes. There is no MIR
// text format; MIR is only exchanged in byte-serialized form and there is no
// parser that would turn text into MIR data structures. The reason is that
// during the transition from IML to MIR there are a number of processes that
// ensure the resulting MIR has the right properties (e.g. content hashed
// functions, lifted lambdas, correct types, inferred type variables, ...), and
// those processes are not replicated on the client side.
//
//
// Note [Value equality]
// ~~~~~~~~~~~~~~~~~~~~~
// `Uid`, `Type`, `AppliedSymbol` and `PatternHead` are wrapper objects, and two distinct
// objects can stand for the same thing: the uid of a symbol in a term and the uid keying its
// declaration in `DB.decls` are equal but not the same object. JS `Map` and `Set` compare keys
// by identity, so with a plain `Map`, `db.decls.get(term.symbol.id)` would miss, and JS has no
// hook to override that (no `hashCode`/`__hash__`).
//
// So these classes have an `equals` method, and the maps and sets keyed by them (`DB.decls`,
// `Model.constants`, `TypeDefinition.clique`, ...) are `ValueMap`s and `ValueSet`s. They key
// their entries by a structural string (`uidKey`, `typeKey`, ..., see "Structural keys"),
// computed once per object, so their `get` and `has` find an entry from any equal key.
//
// Identity is not enough even with Note [Lib memo]: the memo gives one client object per lib
// object, but the same uid can come as distinct lib objects (from another response, or a node
// the decoder did not share), and users can build keys themselves (`new Uid(...)`).
//
//
// Note [Lib memo]
// ~~~~~~~~~~~~~~~
// The twine decoder returns one lib object for every reference to a shared term or type, so lib
// data is a graph. Without a memo, `termOfLib` and `typeOfLib` would convert a shared node once
// per path to it, expanding the graph into a tree: the work and the memory grow with the number
// of paths rather than the number of nodes.
//
// `termMemo` and `typeMemo` map each lib object, by identity, to its converted object, so every
// conversion of a lib object returns the same client object, whichever data holds it (a
// decomposition, a report, a model, ...).
//
// They are `WeakMap`s, so they keep nothing alive: an entry goes with its lib object, even though
// the client object refers back to it through `raw`. Lib objects belong to one decoder, so client
// objects are never shared between artifacts.

import { UnexpectedResponseError } from "./errors.js";
import * as lib from "./raw/types.js";
import * as twine from "./raw/twine.js";

function unexpected(what: string, x: unknown): never {
  const name = (x as { constructor?: { name?: string } } | undefined)?.constructor?.name;
  throw new UnexpectedResponseError(`unexpected ${what}: ${name ?? String(x)}`);
}

/*
Structural keys
===============
*/

/** An unambiguous string made of a tag and parts, with each part prefixed by its length */
function k(tag: string, ...parts: readonly string[]): string {
  let s = tag + "(";
  for (const p of parts) {
    s += `${p.length}:${p}`;
  }
  return s + ")";
}

function memoized<T extends object>(cache: WeakMap<T, string>, x: T, f: (x: T) => string): string {
  let key = cache.get(x);
  if (key === undefined) {
    key = f(x);
    cache.set(x, key);
  }
  return key;
}

function builtinDataKindKey(x: lib.Builtin_data_kind): string {
  if (x instanceof lib.Builtin_data_kind_Logic_core) return k("L", x.logic_core_name);
  if (x instanceof lib.Builtin_data_kind_Special) return k("S", x.tag);
  if (x instanceof lib.Builtin_data_kind_Tactic) return k("T", x.tac_name);
  if (x instanceof lib.Builtin_data_kind_Decomp) return k("D", x.decomp_name);
  return unexpected("builtin data kind", x);
}

function rawUidKey(x: lib.Uid): string {
  const v = x.view;
  if (v instanceof lib.Uid_view_Generative) {
    const gen = v.gen_kind instanceof lib.Uid_gen_kind_To_be_rewritten ? "T" : "L";
    return k("G", x.name, v.id.toString(), gen);
  }
  if (v instanceof lib.Uid_view_Persistent) return k("P", x.name);
  if (v instanceof lib.Uid_view_Cname) {
    const c = v.cname;
    return k("C", x.name, c.name, chashStr(c.chash), c.is_key ? "1" : "0");
  }
  if (v instanceof lib.Uid_view_Builtin) return k("B", x.name, builtinDataKindKey(v.kind));
  return unexpected("uid view", v);
}

const uidKeys = new WeakMap<Uid, string>();
function uidKey(u: Uid): string {
  return memoized(uidKeys, u, (u) => rawUidKey(u.raw));
}

const typeKeys = new WeakMap<TypeBase, string>();
function typeKey(t: Type): string {
  return memoized(typeKeys, t, () => {
    switch (t.kind) {
      case "variable":
        return k("V", uidKey(t.name));
      case "arrow":
        return k("A", typeKey(t.domain), typeKey(t.codomain));
      case "tuple":
        return k("T", ...t.elements.map(typeKey));
      case "constructed":
        return k("C", uidKey(t.ctor), ...t.arguments.map(typeKey));
    }
  });
}

function typeSchemaKey(s: TypeSchema): string {
  return k("S", k("", ...s.parameters.map(uidKey)), typeKey(s.type));
}

function typedSymbolKey(s: TypedSymbol): string {
  return k("TS", uidKey(s.id), typeSchemaKey(s.typeSchema));
}

const appliedSymbolKeys = new WeakMap<AppliedSymbol, string>();
function appliedSymbolKey(s: AppliedSymbol): string {
  return memoized(appliedSymbolKeys, s, (s) =>
    k("AS", typedSymbolKey(s.symbol), k("", ...s.typeArguments.map(typeKey)), typeKey(s.type)),
  );
}

function patternHeadKey(h: PatternHead): string {
  switch (h.kind) {
    case "symbol":
      return k("S", uidKey(h.uid));
    case "type":
      return k("T", typeKey(h.type));
    case "datatypeOp":
      return k("D");
  }
}

/*
Value maps and sets
===================
*/

/**
 * A map whose keys are compared by value, through a structural string
 *
 * Setting a key equal to an existing one replaces the value, and keeps the existing key and its
 * position.
 */
export class ValueMap<K, V> implements ReadonlyMap<K, V> {
  readonly #canon = new Map<string, K>();
  readonly #inner = new Map<K, V>();
  readonly #keyOf: (k: K) => string;

  constructor(keyOf: (k: K) => string, entries: Iterable<readonly [K, V]> = []) {
    this.#keyOf = keyOf;
    for (const [key, v] of entries) {
      this.set(key, v);
    }
  }

  /** Set the value of `key`; mutates the map, so only for code building it */
  set(key: K, v: V): this {
    const s = this.#keyOf(key);
    let c = this.#canon.get(s);
    if (c === undefined) {
      c = key;
      this.#canon.set(s, c);
    }
    this.#inner.set(c, v);
    return this;
  }

  /** Remove `key`; mutates the map, so only for code building it */
  delete(key: K): boolean {
    const s = this.#keyOf(key);
    const c = this.#canon.get(s);
    if (c === undefined) return false;
    this.#canon.delete(s);
    return this.#inner.delete(c);
  }

  get(key: K): V | undefined {
    const c = this.#canon.get(this.#keyOf(key));
    return c === undefined ? undefined : this.#inner.get(c);
  }

  has(key: K): boolean {
    return this.#canon.has(this.#keyOf(key));
  }

  get size(): number {
    return this.#inner.size;
  }

  forEach(f: (value: V, key: K, map: ReadonlyMap<K, V>) => void, thisArg?: unknown): void {
    this.#inner.forEach((v, key) => f.call(thisArg, v, key, this));
  }

  entries(): MapIterator<[K, V]> {
    return this.#inner.entries();
  }

  keys(): MapIterator<K> {
    return this.#inner.keys();
  }

  values(): MapIterator<V> {
    return this.#inner.values();
  }

  [Symbol.iterator](): MapIterator<[K, V]> {
    return this.#inner.entries();
  }

  get [Symbol.toStringTag](): string {
    return "ValueMap";
  }
}

/**
 * The read-only view of a `ValueSet`
 *
 * Not a `ReadonlySet`, which also has the set operations of ES2025 (`union`, `isSubsetOf`, ...).
 */
export interface ReadonlyValueSet<T> extends Iterable<T> {
  readonly size: number;
  has(x: T): boolean;
  forEach(f: (value: T, value2: T, set: ReadonlyValueSet<T>) => void, thisArg?: unknown): void;
  entries(): SetIterator<[T, T]>;
  keys(): SetIterator<T>;
  values(): SetIterator<T>;
}

/** A set whose elements are compared by value, through a structural string */
export class ValueSet<T> implements ReadonlyValueSet<T> {
  readonly #canon = new Map<string, T>();
  readonly #inner = new Set<T>();
  readonly #keyOf: (x: T) => string;

  constructor(keyOf: (x: T) => string, elements: Iterable<T> = []) {
    this.#keyOf = keyOf;
    for (const x of elements) {
      this.add(x);
    }
  }

  /** Add `x`, if no equal element is in the set; mutates the set, so only for code building it */
  add(x: T): this {
    const s = this.#keyOf(x);
    if (!this.#canon.has(s)) {
      this.#canon.set(s, x);
      this.#inner.add(x);
    }
    return this;
  }

  /** Remove the element equal to `x`, if any; mutates the set, so only for code building it */
  delete(x: T): boolean {
    const s = this.#keyOf(x);
    const c = this.#canon.get(s);
    if (c === undefined) return false;
    this.#canon.delete(s);
    return this.#inner.delete(c);
  }

  has(x: T): boolean {
    return this.#canon.has(this.#keyOf(x));
  }

  get size(): number {
    return this.#inner.size;
  }

  forEach(f: (value: T, value2: T, set: ReadonlyValueSet<T>) => void, thisArg?: unknown): void {
    this.#inner.forEach((x) => f.call(thisArg, x, x, this));
  }

  entries(): SetIterator<[T, T]> {
    return this.#inner.entries();
  }

  keys(): SetIterator<T> {
    return this.#inner.keys();
  }

  values(): SetIterator<T> {
    return this.#inner.values();
  }

  [Symbol.iterator](): SetIterator<T> {
    return this.#inner.values();
  }

  get [Symbol.toStringTag](): string {
    return "ValueSet";
  }
}

/** A set of uids, compared by value as `Uid.equals` does */
export function uidSet(uids: Iterable<Uid> = []): ValueSet<Uid> {
  return new ValueSet(uidKey, uids);
}

/** A map keyed by uids, compared by value as `Uid.equals` does */
export function uidMap<V>(entries: Iterable<readonly [Uid, V]> = []): ValueMap<Uid, V> {
  return new ValueMap(uidKey, entries);
}

/**
 * A map keyed by variables, compared by value as `Variable.equals` does
 *
 * @internal
 */
export function variableMap<V>(entries: Iterable<readonly [Variable, V]>): ValueMap<Variable, V> {
  return new ValueMap((v: Variable) => uidKey(v.id), entries);
}

function uidSetOfLib(xs: Iterable<lib.Uid>): ValueSet<Uid> {
  return uidSet(Array.from(xs, (u) => new Uid(u)));
}

/*
Numbers
=======
*/

function bigAbs(x: bigint): bigint {
  return x < 0n ? -x : x;
}

// Used by `Rational` to reduce to lowest terms with it, so that `equals` can compare `num` and `den`
// directly (1/2 equals 2/4) and `toString` prints one form.
// Rationals decoded from the server are already reduced, so it only matters for a
// `Rational` built by a user.
function gcd(a: bigint, b: bigint): bigint {
  a = bigAbs(a);
  b = bigAbs(b);
  while (b !== 0n) {
    [a, b] = [b, a % b];
  }
  return a;
}

/** An exact rational number, in lowest terms with a positive denominator */
export class Rational {
  /** The numerator */
  readonly num: bigint;
  /** The denominator, always positive */
  readonly den: bigint;

  /** `num / den`, reduced; throws a `RangeError` if `den` is zero */
  constructor(num: bigint, den: bigint = 1n) {
    if (den === 0n) {
      throw new RangeError(`Rational(${num}, 0)`);
    }
    let g = gcd(num, den);
    if (den < 0n) {
      g = -g;
    }
    this.num = num / g;
    this.den = den / g;
  }

  /** Whether `other` is a rational equal to this one */
  equals(other: unknown): boolean {
    return other instanceof Rational && this.num === other.num && this.den === other.den;
  }

  /** `num/den`, or just `num` if the denominator is 1 */
  toString(): string {
    return this.den === 1n ? `${this.num}` : `${this.num}/${this.den}`;
  }
}

/** A float as JS prints it, with `.0` added to integral values, e.g. `1.0`, `1e+21`, `Infinity` */
function floatStr(x: number): string {
  const s = String(x);
  return Number.isInteger(x) && !s.includes("e") ? `${s}.0` : s;
}

/*
Uids and names
==============
*/

/**
 * A unique identifier of a symbol, type or variable
 *
 * Besides its name, a uid can have a suffix telling apart uids with the same name: a generative
 * id for local variables, or the hash of its definition for content-addressed uids (see `cname`).
 * Builtin uids (see `builtinKind`) and persistent uids are named by their name alone.
 * `shortName` is the name and `fullName` the name with its suffix.
 *
 * Uids are compared by value with `equals`.
 */
export class Uid {
  constructor(readonly raw: lib.Uid) {}

  /** The name without its disambiguating suffix */
  get shortName(): string {
    return this.raw.name;
  }

  /** The name with its disambiguating suffix (generative id or content hash), if any */
  get fullName(): string {
    const v = this.raw.view;
    if (v instanceof lib.Uid_view_Generative) {
      const suffix = v.gen_kind instanceof lib.Uid_gen_kind_To_be_rewritten ? "[temp]" : "";
      return `${this.raw.name}/${v.id}${suffix}`;
    }
    if (v instanceof lib.Uid_view_Cname) {
      return `${this.raw.name}/${chashStr(v.cname.chash)}`;
    }
    return this.raw.name;
  }

  /** The content-addressed name, for uids named by the hash of their definition; `undefined` for other uids */
  get cname(): Cname | undefined {
    const v = this.raw.view;
    return v instanceof lib.Uid_view_Cname ? Cname.ofLib(v.cname) : undefined;
  }

  /** What a builtin uid stands for, e.g. a logic core symbol or a tactic; `undefined` for other uids */
  get builtinKind(): BuiltinDataKind | undefined {
    const v = this.raw.view;
    return v instanceof lib.Uid_view_Builtin ? builtinDataKindOfLib(v.kind) : undefined;
  }

  /** Whether `other` is a uid equal to this one: same name and same suffix, kind and hash */
  equals(other: unknown): boolean {
    return other instanceof Uid && uidKey(this) === uidKey(other);
  }

  toString(): string {
    return this.fullName;
  }
}

/** A content-addressed name */
export class Cname {
  constructor(
    readonly name: string,
    readonly chash: Uint8Array,
    /**
     * Is this cname a key (ie a toplevel definition)? Or, if [false], is it just a symbol defined
     * as part of another symbol (cstor, label, etc)
     */
    readonly isKey: boolean,
    readonly raw: lib.Cname,
  ) {}

  /** @internal */
  static ofLib(x: lib.Cname): Cname {
    return new Cname(x.name, x.chash, x.is_key, x);
  }

  /** The name with an abbreviated hash, for display */
  get abbrev(): string {
    return `${this.name}/${chashStr(this.chash.subarray(0, 6))}`;
  }

  /** Whether `other` is a cname with the same name, hash and `isKey` */
  equals(other: unknown): boolean {
    return (
      other instanceof Cname &&
      this.name === other.name &&
      this.isKey === other.isKey &&
      chashStr(this.chash) === chashStr(other.chash)
    );
  }

  toString(): string {
    return `${this.name}/${chashStr(this.chash)}`;
  }
}

/** A content hash as the server prints it: URI-safe base64, without padding */
function chashStr(chash: Uint8Array): string {
  let s = "";
  for (const b of chash) {
    s += String.fromCharCode(b);
  }
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// `Upto.t` has the single constructor `N_steps of int`, so it is represented by that number of
// steps.

/**
 * The number of steps of a library `Upto`
 *
 * @internal
 */
export function uptoOfLib(x: lib.Upto): number {
  if (x instanceof lib.Upto_N_steps) {
    return Number(x.arg);
  }
  return unexpected("upto", x);
}

/*
Constants
=========
*/

export class FloatConst {
  readonly kind = "float";
  constructor(
    readonly value: number,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return floatStr(this.value);
  }
}

export class StringConst {
  readonly kind = "string";
  constructor(
    readonly value: string,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return `"${this.value}"`;
  }
}

export class IntConst {
  readonly kind = "int";
  constructor(
    readonly value: bigint,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return `${this.value}`;
  }
}

export class RationalConst {
  readonly kind = "rational";
  constructor(
    readonly value: Rational,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return `${this.value.num}/${this.value.den}`;
  }
}

export class RealApproxConst {
  readonly kind = "realApprox";
  constructor(
    readonly value: string,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return this.value;
  }
}

export class UidConst {
  readonly kind = "uid";
  constructor(
    readonly uid: Uid,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return this.uid.shortName;
  }
}

export class BoolConst {
  readonly kind = "bool";
  constructor(
    readonly value: boolean,
    readonly raw: lib.Const,
  ) {}

  toString(): string {
    return this.value ? "true" : "false";
  }
}

export type Const =
  FloatConst | StringConst | IntConst | RationalConst | RealApproxConst | UidConst | BoolConst;

/** @internal */
export function constOfLib(x: lib.Const): Const {
  if (x instanceof lib.Const_Const_float) return new FloatConst(x.arg, x);
  if (x instanceof lib.Const_Const_string) return new StringConst(x.arg, x);
  if (x instanceof lib.Const_Const_z) return new IntConst(x.arg, x);
  if (x instanceof lib.Const_Const_q) return new RationalConst(new Rational(x.arg[0], x.arg[1]), x);
  if (x instanceof lib.Const_Const_real_approx) return new RealApproxConst(x.arg, x);
  if (x instanceof lib.Const_Const_uid) return new UidConst(new Uid(x.arg), x);
  if (x instanceof lib.Const_Const_bool) return new BoolConst(x.arg, x);
  return unexpected("constant", x);
}

/*
Builtins
========
*/

export class LogicCoreBuiltin {
  readonly kind = "logicCore";
  constructor(
    readonly name: string,
    readonly raw: lib.Builtin_data_kind,
  ) {}
}

export class SpecialBuiltin {
  readonly kind = "special";
  constructor(
    readonly tag: string,
    readonly raw: lib.Builtin_data_kind,
  ) {}
}

export class TacticBuiltin {
  readonly kind = "tactic";
  constructor(
    readonly name: string,
    readonly raw: lib.Builtin_data_kind,
  ) {}
}

export class DecompBuiltin {
  readonly kind = "decomp";
  constructor(
    readonly name: string,
    readonly raw: lib.Builtin_data_kind,
  ) {}
}

export type BuiltinDataKind = LogicCoreBuiltin | SpecialBuiltin | TacticBuiltin | DecompBuiltin;

/** @internal */
export function builtinDataKindOfLib(x: lib.Builtin_data_kind): BuiltinDataKind {
  if (x instanceof lib.Builtin_data_kind_Logic_core)
    return new LogicCoreBuiltin(x.logic_core_name, x);
  if (x instanceof lib.Builtin_data_kind_Special) return new SpecialBuiltin(x.tag, x);
  if (x instanceof lib.Builtin_data_kind_Tactic) return new TacticBuiltin(x.tac_name, x);
  if (x instanceof lib.Builtin_data_kind_Decomp) return new DecompBuiltin(x.decomp_name, x);
  return unexpected("builtin data kind", x);
}

export class BuiltinFunction {
  constructor(
    readonly id: Uid,
    readonly kind: BuiltinDataKind,
    readonly leftAssociative: boolean,
    readonly commutative: boolean,
    readonly connective: boolean,
    readonly raw: lib.Builtin_Fun,
  ) {}

  /** @internal */
  static ofLib(x: lib.Builtin_Fun): BuiltinFunction {
    return new BuiltinFunction(
      new Uid(x.id),
      builtinDataKindOfLib(x.kind),
      x.lassoc,
      x.commutative,
      x.connective,
      x,
    );
  }
}

export class BuiltinSort {
  constructor(
    readonly id: Uid,
    readonly kind: BuiltinDataKind,
    readonly raw: lib.Builtin_Ty,
  ) {}

  /** @internal */
  static ofLib(x: lib.Builtin_Ty): BuiltinSort {
    return new BuiltinSort(new Uid(x.id), builtinDataKindOfLib(x.kind), x);
  }
}

/*
Triggers
========
*/

export class NoTrigger {
  readonly kind = "none";
  constructor(readonly raw: lib.As_trigger) {}

  toString(): string {
    return "none";
  }
}

export class AnonymousTrigger {
  readonly kind = "anonymous";
  constructor(readonly raw: lib.As_trigger) {}

  toString(): string {
    return "anon";
  }
}

export class NamedTrigger {
  readonly kind = "named";
  constructor(
    readonly index: number,
    readonly raw: lib.As_trigger,
  ) {}

  toString(): string {
    return `${this.index}`;
  }
}

export class RewriteTrigger {
  readonly kind = "rewrite";
  constructor(readonly raw: lib.As_trigger) {}

  toString(): string {
    return "rw";
  }
}

export type AsTrigger = NoTrigger | AnonymousTrigger | NamedTrigger | RewriteTrigger;

/** @internal */
export function asTriggerOfLib(x: lib.As_trigger): AsTrigger {
  if (x instanceof lib.As_trigger_Trig_none) return new NoTrigger(x);
  if (x instanceof lib.As_trigger_Trig_anon) return new AnonymousTrigger(x);
  if (x instanceof lib.As_trigger_Trig_named) return new NamedTrigger(Number(x.arg), x);
  if (x instanceof lib.As_trigger_Trig_rw) return new RewriteTrigger(x);
  return unexpected("trigger", x);
}

/*
Types
=====
*/

/** A type; compared by value with `equals` */
export abstract class TypeBase {
  abstract readonly kind: Type["kind"];

  constructor(readonly raw: lib.Mir_Type) {}

  /** Whether `other` is a type equal to this one, structurally */
  equals(other: unknown): boolean {
    return other instanceof TypeBase && typeKey(this as unknown as Type) === typeKey(other as Type);
  }

  toString(): string {
    return "<type>";
  }
}

/** Converted types, by lib type; see Note [Lib memo] */
const typeMemo = new WeakMap<lib.Mir_Type, Type>();

/** @internal */
export function typeOfLib(x: lib.Mir_Type): Type {
  let ty = typeMemo.get(x);
  if (ty === undefined) {
    ty = typeOfLibUncached(x);
    typeMemo.set(x, ty);
  }
  return ty;
}

function typeOfLibUncached(x: lib.Mir_Type): Type {
  const v = x.view;
  if (v instanceof lib.Ty_view_view_Var) return new TypeVariable(new Uid(v.arg), x);
  if (v instanceof lib.Ty_view_view_Arrow) {
    const [, tl, tr] = v.args;
    return new ArrowType(typeOfLib(tl), typeOfLib(tr), x);
  }
  if (v instanceof lib.Ty_view_view_Tuple) return new TupleType(v.arg.map(typeOfLib), x);
  if (v instanceof lib.Ty_view_view_Constr) {
    const [c, ts] = v.args;
    return new ConstructedType(new Uid(c), ts.map(typeOfLib), x);
  }
  return unexpected("type", v);
}

export class TypeVariable extends TypeBase {
  readonly kind = "variable";
  constructor(
    readonly name: Uid,
    raw: lib.Mir_Type,
  ) {
    super(raw);
  }

  override toString(): string {
    return `${this.name}`;
  }
}

/** A function type `a -> b` */
export class ArrowType extends TypeBase {
  readonly kind = "arrow";
  constructor(
    readonly domain: Type,
    readonly codomain: Type,
    raw: lib.Mir_Type,
  ) {
    super(raw);
  }

  override toString(): string {
    return `${this.domain} -> ${this.codomain}`;
  }
}

/** A tuple type `a * b * ...` */
export class TupleType extends TypeBase {
  readonly kind = "tuple";
  constructor(
    /** The component types */
    readonly elements: readonly Type[],
    raw: lib.Mir_Type,
  ) {
    super(raw);
  }

  override toString(): string {
    return this.elements.map((t) => `${t}`).join(" * ");
  }
}

/**
 * A type constructor applied to type arguments, e.g. `int list`
 *
 * The field is `ctor`: classes cannot have a field named `constructor`.
 */
export class ConstructedType extends TypeBase {
  readonly kind = "constructed";
  /** The type constructor */
  readonly ctor: Uid;
  readonly arguments: readonly Type[];

  constructor(ctor: Uid, args: readonly Type[], raw: lib.Mir_Type) {
    super(raw);
    this.ctor = ctor;
    this.arguments = args;
  }

  override toString(): string {
    let elems = this.arguments.map((t) => `${t}`).join(" ");
    if (elems.length > 0) {
      elems += " ";
    }
    return `${elems}${this.ctor}`;
  }
}

/** A type */
export type Type = TypeVariable | ArrowType | TupleType | ConstructedType;

export class ConstructorDefinition {
  readonly name: Uid;
  /** for inline records; same length as [args] */
  readonly labels: readonly Uid[] | undefined;
  readonly arguments: readonly Type[];
  readonly doc: string | undefined;
  readonly raw: lib.Ty_view_adt_row<lib.Uid, lib.Mir_Type>;

  constructor(
    name: Uid,
    labels: readonly Uid[] | undefined,
    args: readonly Type[],
    doc: string | undefined,
    raw: lib.Ty_view_adt_row<lib.Uid, lib.Mir_Type>,
  ) {
    this.name = name;
    this.labels = labels;
    this.arguments = args;
    this.doc = doc;
    this.raw = raw;
  }

  /** @internal */
  static ofLib(x: lib.Ty_view_adt_row<lib.Uid, lib.Mir_Type>): ConstructorDefinition {
    return new ConstructorDefinition(
      new Uid(x.c),
      x.labels === undefined ? undefined : x.labels.map((l) => new Uid(l)),
      x.args.map(typeOfLib),
      x.doc,
      x,
    );
  }

  toString(): string {
    if (this.arguments.length === 0) {
      return `${this.name}`;
    }
    if (this.labels !== undefined) {
      const n = Math.min(this.labels.length, this.arguments.length);
      const fs: string[] = [];
      for (let i = 0; i < n; i++) {
        fs.push(`${this.labels[i]} : ${this.arguments[i]}`);
      }
      return `${this.name} of {${fs.join("; ")}}`;
    }
    return `${this.name} of ${this.arguments.map((t) => `${t}`).join(" * ")}`;
  }
}

export class FieldDefinition {
  constructor(
    readonly name: Uid,
    readonly type: Type,
    readonly doc: string | undefined,
    readonly raw: lib.Ty_view_rec_row<lib.Uid, lib.Mir_Type>,
  ) {}

  /** @internal */
  static ofLib(x: lib.Ty_view_rec_row<lib.Uid, lib.Mir_Type>): FieldDefinition {
    return new FieldDefinition(new Uid(x.f), typeOfLib(x.ty), x.doc, x);
  }

  toString(): string {
    return `${this.name} : ${this.type}`;
  }
}

type RawTypeDecl = lib.Ty_view_decl<lib.Uid, lib.Mir_Type, lib.Void>;

export class AlgebraicTypeKind {
  readonly kind = "algebraic";
  constructor(
    readonly constructors: readonly ConstructorDefinition[],
    readonly raw: RawTypeDecl,
  ) {}
}

export class RecordTypeKind {
  readonly kind = "record";
  constructor(
    readonly fields: readonly FieldDefinition[],
    readonly raw: RawTypeDecl,
  ) {}
}

export class SkolemTypeKind {
  readonly kind = "skolem";
  constructor(readonly raw: RawTypeDecl) {}
}

export class BuiltinTypeKind {
  readonly kind = "builtin";
  constructor(
    readonly sort: BuiltinSort,
    readonly raw: RawTypeDecl,
  ) {}
}

export class OtherTypeKind {
  readonly kind = "other";
  constructor(readonly raw: RawTypeDecl) {}
}

// `Alias` is left out: its target has the empty type `Void.t` in type definitions
export type TypeKind =
  AlgebraicTypeKind | RecordTypeKind | SkolemTypeKind | BuiltinTypeKind | OtherTypeKind;

/** @internal */
export function typeKindOfLib(x: RawTypeDecl): TypeKind {
  if (x instanceof lib.Ty_view_decl_Algebraic) {
    return new AlgebraicTypeKind(
      x.arg.map((r) => ConstructorDefinition.ofLib(r)),
      x,
    );
  }
  if (x instanceof lib.Ty_view_decl_Record) {
    return new RecordTypeKind(
      x.arg.map((r) => FieldDefinition.ofLib(r)),
      x,
    );
  }
  if (x instanceof lib.Ty_view_decl_Alias) {
    throw new UnexpectedResponseError("unexpected alias in a type definition");
  }
  if (x instanceof lib.Ty_view_decl_Skolem) return new SkolemTypeKind(x);
  if (x instanceof lib.Ty_view_decl_Builtin)
    return new BuiltinTypeKind(BuiltinSort.ofLib(x.arg), x);
  if (x instanceof lib.Ty_view_decl_Other) return new OtherTypeKind(x);
  return unexpected("type declaration", x);
}

export class TypeDefinition {
  constructor(
    /** The type's name */
    readonly name: Uid,
    /** The type variables the type is parameterized over */
    readonly parameters: readonly Uid[],
    /** How the type is defined: algebraic, record, skolem, builtin, ... */
    readonly kind: TypeKind,
    /** The mutually recursive types this type belongs to, if any */
    readonly clique: ReadonlyValueSet<Uid> | undefined,
    /** The timeout for checking the definition, if any */
    readonly timeout: number | undefined,
    readonly raw: lib.Mir_Type_def,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Type_def): TypeDefinition {
    return new TypeDefinition(
      new Uid(x.name),
      x.params.map((p) => new Uid(p)),
      typeKindOfLib(x.decl),
      x.clique === undefined ? undefined : uidSetOfLib(x.clique),
      x.timeout === undefined ? undefined : Number(x.timeout),
      x,
    );
  }

  toString(): string {
    const params = this.parameters.map((p) => `${p} `).join("");
    const head = `type ${params}${this.name}`;
    const kind = this.kind;
    if (kind instanceof AlgebraicTypeKind) {
      return `${head} = ${kind.constructors.map((c) => `${c}`).join(" | ")}`;
    }
    if (kind instanceof RecordTypeKind) {
      return `${head} = {${kind.fields.map((f) => `${f}`).join("; ")}}`;
    }
    return head;
  }
}

/**
 * A variable, with its type
 *
 * Variables are equal when their ids are, as in OCaml's `Var.equal`: see `equals`.
 */
// Note: from `Imandrax_api_mir.Var.t`; class name collide with Var of term, thus it's called Variable
export class Variable {
  constructor(
    readonly id: Uid,
    readonly type: Type,
    readonly raw: lib.Mir_Var,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Var): Variable {
    return new Variable(new Uid(x.id), typeOfLib(x.ty), x);
  }

  /** Whether `other` is a variable with an equal id */
  equals(other: unknown): boolean {
    return other instanceof Variable && this.id.equals(other.id);
  }

  toString(): string {
    return this.id.shortName;
  }
}

export class TypeSchema {
  constructor(
    readonly parameters: readonly Uid[],
    readonly type: Type,
    readonly raw: lib.Mir_Type_schema,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Type_schema): TypeSchema {
    return new TypeSchema(
      x.params.map((p) => new Uid(p)),
      typeOfLib(x.ty),
      x,
    );
  }

  /** Whether `other` is a type schema with equal parameters and type */
  equals(other: unknown): boolean {
    return other instanceof TypeSchema && typeSchemaKey(this) === typeSchemaKey(other);
  }
}

/** A symbol together with its type schema */
export class TypedSymbol {
  constructor(
    readonly id: Uid,
    readonly typeSchema: TypeSchema,
    readonly raw: lib.Mir_Typed_symbol,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Typed_symbol): TypedSymbol {
    return new TypedSymbol(new Uid(x.id), TypeSchema.ofLib(x.ty), x);
  }

  /** Whether `other` is a typed symbol with an equal id and type schema */
  equals(other: unknown): boolean {
    return other instanceof TypedSymbol && typedSymbolKey(this) === typedSymbolKey(other);
  }
}

/** A symbol instantiated at a concrete type */
export class AppliedSymbol {
  constructor(
    /** The underlying typed symbol */
    readonly symbol: TypedSymbol,
    readonly typeArguments: readonly Type[],
    /** The type at which the symbol is used */
    readonly type: Type,
    readonly raw: lib.Mir_Applied_symbol,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Applied_symbol): AppliedSymbol {
    return new AppliedSymbol(TypedSymbol.ofLib(x.sym), x.args.map(typeOfLib), typeOfLib(x.ty), x);
  }

  /** The symbol's unique identifier */
  get id(): Uid {
    return this.symbol.id;
  }

  /** Whether `other` is an applied symbol with an equal symbol, type arguments and type */
  equals(other: unknown): boolean {
    return other instanceof AppliedSymbol && appliedSymbolKey(this) === appliedSymbolKey(other);
  }

  toString(): string {
    return `${this.id} : ${this.type}`;
  }
}

/*
Terms
=====
*/

/** A term */
export abstract class TermBase {
  abstract readonly kind: Term["kind"];

  constructor(
    readonly type: Type,
    readonly raw: lib.Mir_Term,
  ) {}

  /** The immediate subterms of this term */
  get subterms(): Term[] {
    return [];
  }

  /** Iterate over this term and all of its subterms, recursively, parents before children */
  *[Symbol.iterator](): Generator<Term, void, undefined> {
    const stack: Term[] = [this as unknown as Term];
    while (stack.length > 0) {
      const t = stack.pop()!;
      yield t;
      const subs = t.subterms;
      for (let i = subs.length - 1; i >= 0; i--) {
        stack.push(subs[i]!);
      }
    }
  }

  /** Call `f` on this term and on all of its subterms, recursively, parents before children */
  iter(f: (t: Term) => void): void {
    for (const t of this) {
      f(t);
    }
  }

  /**
   * This term as a plain JS value, e.g. the value of a constant in a model
   *
   * Integers map to `bigint`, booleans and strings to themselves, reals to `Rational`, floats to
   * `number`, lists and tuples to arrays (unit to `[]`), records to a `Map` by field name, uid
   * constants to their `Uid`, and other constructors to `Constructed`, including the elements
   * a model makes up for abstract types.
   *
   * @throws RangeError if the term is not a value, e.g. a variable, a function application
   *   (which is how `Map.t` and `Set.t` values look), or an irrational real
   */
  toJs(db?: DB): JsValue {
    return toJsImpl(this as unknown as Term, db);
  }

  toString(): string {
    return "<term>";
  }
}

/** Converted terms, by lib term; see Note [Lib memo] */
const termMemo = new WeakMap<lib.Mir_Term, Term>();

/** @internal */
export function termOfLib(x: lib.Mir_Term): Term {
  let t = termMemo.get(x);
  if (t === undefined) {
    t = termOfLibUncached(x);
    termMemo.set(x, t);
  }
  return t;
}

function termOfLibUncached(x: lib.Mir_Term): Term {
  const ty = typeOfLib(x.ty);
  const v = x.view;
  if (v instanceof lib.Mir_Term_view_Const) return new Constant(constOfLib(v.arg), ty, x);
  if (v instanceof lib.Mir_Term_view_If) {
    const [c, a, b] = v.args;
    return new If(termOfLib(c), termOfLib(a), termOfLib(b), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Apply) {
    return new Apply(termOfLib(v.f), v.l.map(termOfLib), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Var) return new Var(Variable.ofLib(v.arg), ty, x);
  if (v instanceof lib.Mir_Term_view_Sym) return new SymbolTerm(AppliedSymbol.ofLib(v.arg), ty, x);
  if (v instanceof lib.Mir_Term_view_Construct) {
    return new Construct(
      AppliedSymbol.ofLib(v.c),
      v.args.map(termOfLib),
      v.labels === undefined ? undefined : v.labels.map((l) => new Uid(l)),
      ty,
      x,
    );
  }
  if (v instanceof lib.Mir_Term_view_Destruct) {
    return new Destruct(AppliedSymbol.ofLib(v.c), Number(v.i), termOfLib(v.t), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Is_a) {
    return new IsA(AppliedSymbol.ofLib(v.c), termOfLib(v.t), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Tuple) return new Tuple(v.l.map(termOfLib), ty, x);
  if (v instanceof lib.Mir_Term_view_Field) {
    return new Field(AppliedSymbol.ofLib(v.f), termOfLib(v.t), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Tuple_field) {
    return new TupleField(Number(v.i), termOfLib(v.t), ty, x);
  }
  if (v instanceof lib.Mir_Term_view_Record) {
    return new RecordTerm(
      v.rows.map(([f, t]) => ({ field: AppliedSymbol.ofLib(f), value: termOfLib(t) })),
      v.rest === undefined ? undefined : termOfLib(v.rest),
      ty,
      x,
    );
  }
  if (v instanceof lib.Mir_Term_view_Case) {
    return new Case(
      termOfLib(v.u),
      v.cases.map(([c, t]) => ({ ctor: AppliedSymbol.ofLib(c), rhs: termOfLib(t) })),
      v.default_ === undefined ? undefined : termOfLib(v.default_),
      ty,
      x,
    );
  }
  if (v instanceof lib.Mir_Term_view_Sequence) {
    const [prefix, last] = v.args;
    return new Sequence(prefix.map(termOfLib), termOfLib(last), ty, x);
  }
  return unexpected("term", v);
}

export class Constant extends TermBase {
  readonly kind = "constant";
  constructor(
    readonly value: Const,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override toString(): string {
    return `${this.value}`;
  }
}

/** A conditional `if c then a else b` */
export class If extends TermBase {
  readonly kind = "if";
  constructor(
    readonly condition: Term,
    /** The term evaluated if the condition is true */
    readonly thenBranch: Term,
    /** The term evaluated if the condition is false */
    readonly elseBranch: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [this.condition, this.thenBranch, this.elseBranch];
  }

  override toString(): string {
    return `if ${this.condition} then ${this.thenBranch} else ${this.elseBranch}`;
  }
}

/** A function application */
export class Apply extends TermBase {
  readonly kind = "apply";
  /** The function being applied */
  readonly function: Term;

  /** The arguments the function is applied to */
  readonly arguments: readonly Term[];

  constructor(fn: Term, args: readonly Term[], type: Type, raw: lib.Mir_Term) {
    super(type, raw);
    this.arguments = args;
    this.function = fn;
  }

  override get subterms(): Term[] {
    return [this.function, ...this.arguments];
  }

  override toString(): string {
    const elems = [this.function, ...this.arguments].map((t) => `${t}`).join(" ");
    return this.arguments.length === 0 ? elems : `(${elems})`;
  }
}

/** A local variable, e.g. a function argument */
export class Var extends TermBase {
  readonly kind = "var";
  /** The variable, with its type */
  readonly var: Variable;

  constructor(v: Variable, type: Type, raw: lib.Mir_Term) {
    super(type, raw);
    this.var = v;
  }

  override toString(): string {
    return this.var.id.shortName;
  }
}

/**
 * Turn a library variable into a `Var` term
 *
 * @internal
 */
export function varTermOfVar(x: lib.Mir_Var): Var {
  const raw = new lib.Mir_Term(new lib.Mir_Term_view_Var(x), x.ty, undefined);
  return new Var(Variable.ofLib(x), typeOfLib(x.ty), raw);
}

/** A reference to a declared symbol, e.g. a function, by its uid */
export class SymbolTerm extends TermBase {
  readonly kind = "symbol";
  constructor(
    /** The symbol, instantiated at its type */
    readonly symbol: AppliedSymbol,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override toString(): string {
    return this.symbol.id.fullName;
  }
}

/**
 * A constructor applied to arguments
 *
 * The field is `ctor`: classes cannot have a field named `constructor`.
 */
export class Construct extends TermBase {
  readonly kind = "construct";
  /** The constructor */
  readonly ctor: AppliedSymbol;
  /** The constructor's arguments */
  readonly arguments: readonly Term[];
  /** The argument labels, if the constructor takes labeled (record) arguments */
  readonly labels: readonly Uid[] | undefined;

  constructor(
    ctor: AppliedSymbol,
    args: readonly Term[],
    labels: readonly Uid[] | undefined,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
    this.ctor = ctor;
    this.arguments = args;
    this.labels = labels;
  }

  override get subterms(): Term[] {
    return [...this.arguments];
  }

  override toString(): string {
    const name = this.ctor.id.shortName;
    const args = this.arguments;
    if (args.length === 0) {
      return name;
    }
    const labels = this.labels;
    if (labels !== undefined) {
      const n = Math.min(labels.length, args.length);
      const fields: string[] = [];
      for (let i = 0; i < n; i++) {
        fields.push(`${labels[i]!.fullName} = ${args[i]}`);
      }
      return `${name} {${fields.join("; ")}}`;
    }
    if (args.length === 1) {
      return `${name} ${args[0]}`;
    }
    return `${name} (${args.map((a) => `${a}`).join(", ")})`;
  }
}

/** A destructor term. (The `index`-th argument of a term built with `ctor`.) */
export class Destruct extends TermBase {
  readonly kind = "destruct";
  constructor(
    /** The constructor whose argument is extracted */
    readonly ctor: AppliedSymbol,
    /** The position of the extracted argument */
    readonly index: number,
    /** The term the argument is extracted from */
    readonly term: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [this.term];
  }

  override toString(): string {
    return `Destruct(${this.ctor.id.shortName}, ${this.index}, ${this.term})`;
  }
}

/** A test whether a term was built with `ctor` */
export class IsA extends TermBase {
  readonly kind = "isA";
  constructor(
    /** The constructor tested for */
    readonly ctor: AppliedSymbol,
    /** The term being tested */
    readonly term: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [this.term];
  }

  override toString(): string {
    return `Is_a(${this.ctor.id.shortName}, ${this.term})`;
  }
}

export class Tuple extends TermBase {
  readonly kind = "tuple";
  constructor(
    /** The tuple's elements */
    readonly elements: readonly Term[],
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  /** The number of elements */
  get length(): number {
    return this.elements.length;
  }

  override get subterms(): Term[] {
    return [...this.elements];
  }

  override toString(): string {
    return `(${this.elements.map((e) => `${e}`).join(", ")})`;
  }
}

/** An access to a field of a record */
export class Field extends TermBase {
  readonly kind = "field";
  constructor(
    /** The field being accessed */
    readonly field: AppliedSymbol,
    /** The record whose field is accessed */
    readonly term: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [this.term];
  }

  override toString(): string {
    return `${this.term}.${this.field.id.shortName}`;
  }
}

/** An access to a component of a tuple, by its position */
export class TupleField extends TermBase {
  readonly kind = "tupleField";
  constructor(
    /** The position of the accessed component */
    readonly index: number,
    /** The tuple whose component is accessed */
    readonly term: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [this.term];
  }

  override toString(): string {
    return `${this.term}.${this.index}`;
  }
}

/** A field of a `RecordTerm`, and its value */
export interface RecordRow {
  readonly field: AppliedSymbol;
  readonly value: Term;
}

/** A record */
export class RecordTerm extends TermBase {
  readonly kind = "record";
  constructor(
    /** The record's fields and their values */
    readonly rows: readonly RecordRow[],
    /** The record being updated in `{rest with ...}`, if any */
    readonly rest: Term | undefined,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    const ts: Term[] = this.rest === undefined ? [] : [this.rest];
    return [...ts, ...this.rows.map((r) => r.value)];
  }

  override toString(): string {
    const fields = this.rows.map((r) => `${r.field.id.shortName} = ${r.value}`).join("; ");
    if (this.rest !== undefined) {
      return `{${this.rest} with ${fields}}`;
    }
    return `{${fields}}`;
  }
}

/** A match arm of a `Case`: the constructor, and the term for that case */
export interface CaseArm {
  readonly ctor: AppliedSymbol;
  readonly rhs: Term;
}

/** A pattern match on `scrutinee` */
export class Case extends TermBase {
  readonly kind = "case";
  /** The term being matched on */
  readonly scrutinee: Term;
  /** The match arms, each a constructor and the term for that case */
  readonly cases: readonly CaseArm[];
  /** The term for the wildcard case `_`, if any */
  readonly default: Term | undefined;

  constructor(
    scrutinee: Term,
    cases: readonly CaseArm[],
    default_: Term | undefined,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
    this.scrutinee = scrutinee;
    this.cases = cases;
    this.default = default_;
  }

  override get subterms(): Term[] {
    const ts = [this.scrutinee, ...this.cases.map((c) => c.rhs)];
    if (this.default !== undefined) {
      ts.push(this.default);
    }
    return ts;
  }

  override toString(): string {
    const arms = this.cases.map((c) => `| ${c.ctor.id.shortName} -> ${c.rhs}`);
    if (this.default !== undefined) {
      arms.push(`| _ -> ${this.default}`);
    }
    return `match ${this.scrutinee} with ${arms.join(" ")}`;
  }
}

/** A sequence `t1; ...; tn; last` */
export class Sequence extends TermBase {
  readonly kind = "sequence";
  constructor(
    /** The terms evaluated before `last` */
    readonly prefix: readonly Term[],
    /** The final term, whose value is the value of the sequence */
    readonly last: Term,
    type: Type,
    raw: lib.Mir_Term,
  ) {
    super(type, raw);
  }

  override get subterms(): Term[] {
    return [...this.prefix, this.last];
  }

  override toString(): string {
    return [...this.prefix, this.last].map((t) => `${t}`).join("; ");
  }
}

/** A term */
export type Term =
  | Constant
  | If
  | Apply
  | Var
  | SymbolTerm
  | Construct
  | Destruct
  | IsA
  | Tuple
  | Field
  | TupleField
  | RecordTerm
  | Case
  | Sequence;

/*
Terms as JS values
==================
*/

/**
 * A constructor applied to arguments, as a JS value: `Some 3` is `new Constructed("Some", [3n])`
 *
 * The arguments of a constructor with an inline record, as in `A { x: int }` may be turned into a
 * single (one-element) argument containing a `Map` by providing the optional `db` argument to
 * `Term.toJs`.
 */
export class Constructed {
  constructor(
    /** The constructor's name */
    readonly name: string,
    /** The constructor's arguments */
    readonly args: readonly JsValue[] = [],
  ) {}
}

/**
 * A term's value as plain JS data, see `Term.toJs`
 *
 * Tuples and lists are both arrays, and maps are `Map`s.
 */
export type JsValue =
  | boolean
  | bigint
  | Rational
  | number
  | string
  | Uid
  | Constructed
  | readonly JsValue[]
  | ReadonlyMap<string, JsValue>;

function toJsImpl(t: Term, db?: DB): JsValue {
  if (t instanceof Constant) {
    const v = t.value;
    switch (v.kind) {
      case "bool":
      case "int":
      case "rational":
      case "float":
      case "string":
        return v.value;
      case "uid":
        return v.uid;
      case "realApprox":
        throw new RangeError(`The irrational real ${v.value} has no exact JS value`);
    }
  }
  if (t instanceof Construct) {
    const c = t.ctor;
    const name = c.id.shortName;
    if (t.arguments.length === 0 && name === "()") {
      return [];
    }
    if (name === "::" || name === "[]") {
      // A list is a chain of `::` as deep as it is long: walk it in a loop, not a call per element
      const xs: JsValue[] = [];
      let u: Term = t;
      while (u instanceof Construct && u.ctor.id.shortName === "::") {
        xs.push(toJsImpl(u.arguments[0]!, db));
        u = u.arguments[1]!;
      }
      if (!(u instanceof Construct && u.ctor.id.shortName === "[]")) {
        throw new RangeError(`Not a value: the list ends with ${u}`);
      }
      return xs;
    }
    const args = t.arguments;
    const labels = t.labels;
    if (labels === undefined) {
      if (c.type instanceof ArrowType && db !== undefined) {
        // Attempt to expand inline records if we have a DB.
        let outType: Type = c.type;
        while (outType instanceof ArrowType) {
          outType = outType.codomain;
        }
        if (outType instanceof ConstructedType) {
          const q = db.findType(outType.ctor);
          if (q !== undefined && q.kind instanceof AlgebraicTypeKind) {
            for (const cnstr of q.kind.constructors) {
              if (
                cnstr.name.equals(c.id) &&
                cnstr.labels !== undefined &&
                cnstr.labels.length === args.length
              ) {
                const fields = new Map<string, JsValue>();
                cnstr.labels.forEach((l, i) => fields.set(l.shortName, toJsImpl(args[i]!, db)));
                return new Constructed(cnstr.name.shortName, [fields]);
              }
            }
          }
        }
      }
      return new Constructed(
        name,
        args.map((a) => toJsImpl(a, db)),
      );
    }
    if (labels.length !== args.length) {
      // labels and arguments must pair up exactly
      throw new RangeError(
        `Not a value: ${labels.length} labels for ${args.length} arguments in ${t}`,
      );
    }
    const fields = new Map<string, JsValue>();
    labels.forEach((l, i) => fields.set(l.shortName, toJsImpl(args[i]!, db)));
    return new Constructed(name, [fields]);
  }
  if (t instanceof Tuple) {
    return t.elements.map((e) => toJsImpl(e, db));
  }
  if (t instanceof RecordTerm && t.rest === undefined) {
    const fields = new Map<string, JsValue>();
    for (const { field, value } of t.rows) {
      fields.set(field.id.shortName, toJsImpl(value, db));
    }
    return fields;
  }
  throw new RangeError(`Not a value: ${t}`);
}

/*
Sequents
========
*/

/** A term with bound variables, `fun variables -> body` */
export interface Binder {
  readonly variables: readonly Variable[];
  readonly body: Term;
}

/** @internal */
export function binderOfLib(x: readonly [readonly lib.Mir_Var[], lib.Mir_Term]): Binder {
  const [vs, t] = x;
  return { variables: vs.map((v) => Variable.ofLib(v)), body: termOfLib(t) };
}

/** @internal */
export function namedHypothesesOfLib(
  xs: readonly (readonly [string, lib.Mir_Term])[],
): ReadonlyMap<string, Term> {
  return new Map(xs.map(([n, t]) => [n, termOfLib(t)]));
}

/** A hypothesis or conclusion of a sequent, with its name if it has one */
export interface NamedTerm {
  readonly name: string | undefined;
  readonly term: Term;
}

export class Sequent {
  constructor(
    /** The hypotheses, each with an optional name */
    readonly hypotheses: readonly NamedTerm[],
    /** The conclusions, each with an optional name */
    readonly conclusions: readonly NamedTerm[],
    readonly raw: lib.Mir_Sequent,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Sequent): Sequent {
    return new Sequent(
      x.hyps.map(([name, t]) => ({ name, term: termOfLib(t) })),
      x.concls.map(([name, t]) => ({ name, term: termOfLib(t) })),
      x,
    );
  }

  /** The hypotheses, without their names */
  get hypothesisTerms(): readonly Term[] {
    return this.hypotheses.map((h) => h.term);
  }

  /** The conclusions, without their names */
  get conclusionTerms(): readonly Term[] {
    return this.conclusions.map((c) => c.term);
  }

  /** The hypothesis named `name`, if any */
  findHypothesis(name: string): NamedTerm | undefined {
    return this.hypotheses.find((h) => h.name === name);
  }

  /** The conclusion named `name`, if any */
  findConclusion(name: string): NamedTerm | undefined {
    return this.conclusions.find((c) => c.name === name);
  }

  /** The hypothesis named `name`, or else the conclusion named `name`, if any */
  findTerm(name: string): NamedTerm | undefined {
    return this.findHypothesis(name) ?? this.findConclusion(name);
  }

  toString(): string {
    // As OCaml's `Sequent.pp_seq`: unnamed hypotheses and conclusions are numbered by position
    const hyps = this.hypotheses.map(({ name, term }, i) =>
      name !== undefined ? `${name}: ${term}` : `H${i}. ${term}`,
    );
    let concls: string[];
    if (this.conclusions.length === 0) {
      concls = ["false"];
    } else if (this.conclusions.length === 1) {
      const { name, term } = this.conclusions[0]!;
      concls = [name !== undefined ? `${name}: ${term}` : `${term}`];
    } else {
      concls = this.conclusions.map(({ name, term }, i) =>
        name !== undefined ? `${name}: ${term}` : `C${i}. ${term}`,
      );
    }
    return [...hyps, "|" + "-".repeat(70), ...concls.map((c) => ` ${c}`)].join("\n");
  }
}

/** A single item in a trigger */
export interface PreTrigger {
  readonly term: Term;
  readonly asTrigger: AsTrigger;
}

function preTriggerOfLib(x: lib.Mir_Pre_trigger): PreTrigger {
  const [t, a] = x;
  return { term: termOfLib(t), asTrigger: asTriggerOfLib(a) };
}

/*
Hints
=====
*/

/** The admission data for a particular function. */
export class Admission {
  constructor(
    /** Subset of variables that participate in termination. */
    readonly measuredSubset: readonly string[],
    /** Name of the measure function (takes subset of arguments, returns an ordinal) */
    readonly measureFunction: Uid | undefined,
    readonly raw: lib.Common_Admission,
  ) {}

  /** @internal */
  static ofLib(x: lib.Common_Admission): Admission {
    return new Admission(
      [...x.measured_subset],
      x.measure_fun === undefined ? undefined : new Uid(x.measure_fun),
      x,
    );
  }
}

type RawValidationStrategy = lib.Common_Hints_validation_strategy<lib.Mir_Term, lib.Mir_Type>;

/** Validate using this tactic for POs */
export class Validate {
  readonly kind = "validate";
  constructor(
    /** The tactic, `fun variables -> body`, if any */
    readonly tactic: Binder | undefined,
    readonly raw: RawValidationStrategy,
  ) {}
}

/** Admitted, or builtin. */
export class NoValidate {
  readonly kind = "noValidate";
  constructor(readonly raw: RawValidationStrategy) {}
}

/** How to validate a function */
export type ValidationStrategy = Validate | NoValidate;

/** @internal */
export function validationStrategyOfLib(x: RawValidationStrategy): ValidationStrategy {
  if (x instanceof lib.Common_Hints_validation_strategy_VS_validate) {
    return new Validate(x.tactic === undefined ? undefined : binderOfLib(x.tactic), x);
  }
  if (x instanceof lib.Common_Hints_validation_strategy_VS_no_validate) {
    return new NoValidate(x);
  }
  return unexpected("validation strategy", x);
}

export class Hints {
  constructor(
    readonly validationStrategy: ValidationStrategy,
    readonly unrollDefinition: number | undefined,
    /** local enables */
    readonly enable: readonly Uid[],
    /** local disables */
    readonly disable: readonly Uid[],
    /** timeout for POs */
    readonly timeout: number | undefined,
    readonly admission: Admission | undefined,
    readonly decomp: Term | undefined,
    readonly raw: lib.Mir_Hints,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Hints): Hints {
    return new Hints(
      validationStrategyOfLib(x.f_validate_strat),
      x.f_unroll_def === undefined ? undefined : Number(x.f_unroll_def),
      x.f_enable.map((u) => new Uid(u)),
      x.f_disable.map((u) => new Uid(u)),
      x.f_timeout === undefined ? undefined : Number(x.f_timeout),
      x.f_admission === undefined ? undefined : Admission.ofLib(x.f_admission),
      x.f_decomp === undefined ? undefined : termOfLib(x.f_decomp),
      x,
    );
  }
}

/*
Tactics
=======
*/

/** The default tactic for termination proofs */
export class DefaultTerminationTactic {
  readonly kind = "defaultTermination";
  constructor(
    /** The maximum number of proof steps */
    readonly maxSteps: number,
    /** The function basis of the termination proof */
    readonly basis: ReadonlyValueSet<Uid>,
    readonly raw: lib.Mir_Tactic,
  ) {}

  toString(): string {
    const basis =
      "{" +
      [...this.basis]
        .map((u) => u.fullName)
        .sort()
        .join(", ") +
      "}";
    return `DefaultTerminationTactic(max_steps=${this.maxSteps}, basis=${basis})`;
  }
}

/** The default tactic for theorems */
export class DefaultTheoremTactic {
  readonly kind = "defaultTheorem";
  constructor(
    /** The maximum number of proof steps */
    readonly maxSteps: number,
    /** The bound for bounded verification, if any */
    readonly upto: number | undefined,
    readonly raw: lib.Mir_Tactic,
  ) {}

  toString(): string {
    const upto = this.upto === undefined ? "None" : `${this.upto} steps`;
    return `DefaultTheoremTactic(max_steps=${this.maxSteps}, upto=${upto})`;
  }
}

/** The default tactic for tests */
export class DefaultTestTactic {
  readonly kind = "defaultTest";
  constructor(
    /** The number of test steps, if limited */
    readonly numSteps: number | undefined,
    /** The random seed, if fixed */
    readonly seed: bigint | undefined,
    readonly raw: lib.Mir_Tactic,
  ) {}

  toString(): string {
    const show = (x: number | bigint | undefined) => (x === undefined ? "None" : `${x}`);
    return `DefaultTestTactic(num_steps=${show(this.numSteps)}, seed=${show(this.seed)})`;
  }
}

/** A tactic given as a term */
export class TermTactic {
  readonly kind = "term";
  constructor(
    /** The variables bound in the tactic term */
    readonly variables: readonly Variable[],
    /** The tactic term */
    readonly term: Term,
    readonly raw: lib.Mir_Tactic,
  ) {}

  toString(): string {
    return `${this.term}`;
  }
}

/** A tactic used to discharge a proof obligation */
export type Tactic =
  DefaultTerminationTactic | DefaultTheoremTactic | DefaultTestTactic | TermTactic;

/** @internal */
export function tacticOfLib(t: lib.Mir_Tactic): Tactic {
  if (t instanceof lib.Common_Tactic_t_poly_Default_termination) {
    return new DefaultTerminationTactic(Number(t.max_steps), uidSetOfLib(t.basis), t);
  }
  if (t instanceof lib.Common_Tactic_t_poly_Default_thm) {
    return new DefaultTheoremTactic(
      Number(t.max_steps),
      t.upto === undefined ? undefined : uptoOfLib(t.upto),
      t,
    );
  }
  if (t instanceof lib.Common_Tactic_t_poly_Default_test) {
    return new DefaultTestTactic(
      t.num_steps === undefined ? undefined : Number(t.num_steps),
      t.seed,
      t,
    );
  }
  if (t instanceof lib.Common_Tactic_t_poly_Term) {
    const [vs, term] = t.arg;
    return new TermTactic(
      vs.map((v) => Variable.ofLib(v)),
      termOfLib(term),
      t,
    );
  }
  return unexpected("tactic", t);
}

/*
Functions
=========
*/

export class DefinedFunctionKind {
  readonly kind = "defined";
  constructor(
    readonly isMacro: boolean,
    readonly fromLambda: boolean,
    readonly raw: lib.Common_Fun_def_fun_kind,
  ) {}
}

export class BuiltinFunctionKind {
  readonly kind = "builtin";
  constructor(
    readonly builtin: BuiltinFunction,
    readonly raw: lib.Common_Fun_def_fun_kind,
  ) {}
}

export class OpaqueFunctionKind {
  readonly kind = "opaque";
  constructor(readonly raw: lib.Common_Fun_def_fun_kind) {}
}

export type FunctionKind = DefinedFunctionKind | BuiltinFunctionKind | OpaqueFunctionKind;

/** @internal */
export function functionKindOfLib(x: lib.Common_Fun_def_fun_kind): FunctionKind {
  if (x instanceof lib.Common_Fun_def_fun_kind_Fun_defined) {
    return new DefinedFunctionKind(x.is_macro, x.from_lambda, x);
  }
  if (x instanceof lib.Common_Fun_def_fun_kind_Fun_builtin) {
    return new BuiltinFunctionKind(BuiltinFunction.ofLib(x.arg), x);
  }
  if (x instanceof lib.Common_Fun_def_fun_kind_Fun_opaque) return new OpaqueFunctionKind(x);
  return unexpected("function kind", x);
}

export class FunctionDefinition {
  readonly name: Uid;
  /** The type variables the function's type is generic over */
  readonly typeParameters: readonly Uid[];
  readonly type: Type;
  /** The function's parameters */
  readonly arguments: readonly Variable[];
  /** The function's body */
  readonly body: Term;
  /** The mutually recursive functions this function belongs to, if any */
  readonly clique: ReadonlyValueSet<Uid> | undefined;
  /** Whether the function is defined, builtin or opaque */
  readonly kind: FunctionKind;
  /** Prover hints attached to the definition */
  readonly hints: Hints;
  readonly raw: lib.Mir_Fun_def;

  constructor(
    name: Uid,
    typeParameters: readonly Uid[],
    type: Type,
    args: readonly Variable[],
    body: Term,
    clique: ReadonlyValueSet<Uid> | undefined,
    kind: FunctionKind,
    hints: Hints,
    raw: lib.Mir_Fun_def,
  ) {
    this.name = name;
    this.typeParameters = typeParameters;
    this.type = type;
    this.arguments = args;
    this.body = body;
    this.clique = clique;
    this.kind = kind;
    this.hints = hints;
    this.raw = raw;
  }

  /** @internal */
  static ofLib(x: lib.Mir_Fun_def): FunctionDefinition {
    return new FunctionDefinition(
      new Uid(x.f_name),
      x.f_ty.params.map((p) => new Uid(p)),
      typeOfLib(x.f_ty.ty),
      x.f_args.map((a) => Variable.ofLib(a)),
      termOfLib(x.f_body),
      x.f_clique === undefined ? undefined : uidSetOfLib(x.f_clique),
      functionKindOfLib(x.f_kind),
      Hints.ofLib(x.f_hints),
      x,
    );
  }

  toString(): string {
    return definitionStr("let", this);
  }
}

/** `<keyword> <name> <args> = <body>` */
function definitionStr(keyword: string, f: FunctionDefinition): string {
  const args = f.arguments.map((a) => ` ${a}`).join("");
  return `${keyword} ${f.name}${args} = ${f.body}`;
}

/*
Theorems, rule specs and verify statements
==========================================
*/

/** A theorem, entered with [theorem foo x y = <formula using x,y>] */
export class Theorem {
  /** corresponding (boolean) function */
  readonly function: FunctionDefinition;

  constructor(
    fn: FunctionDefinition,
    /** rewrite rule? */
    readonly rewriting: boolean,
    /** apply permutative rewrite rule restrictions? */
    readonly permRestrict: boolean,
    /** forward chaining rule? */
    readonly forwardChaining: boolean,
    /** elimination rule? */
    readonly elimination: boolean,
    /** generalization rule? */
    readonly generalization: boolean,
    readonly triggers: readonly PreTrigger[],
    readonly isAxiom: boolean,
    /** The proof, `fun variables -> body` */
    readonly by: Binder,
    /** Named hypotheses available for the proof, by name */
    readonly namedHypotheses: ReadonlyMap<string, Term>,
    readonly raw: lib.Mir_Theorem,
  ) {
    this.function = fn;
  }

  /** The theorem's name, that of its `function` */
  get name(): Uid {
    return this.function.name;
  }

  /** @internal */
  static ofLib(x: lib.Mir_Theorem): Theorem {
    return new Theorem(
      FunctionDefinition.ofLib(x.thm_link),
      x.thm_rewriting,
      x.thm_perm_restrict,
      x.thm_fc,
      x.thm_elim,
      x.thm_gen,
      x.thm_triggers.map(preTriggerOfLib),
      x.thm_is_axiom,
      binderOfLib(x.thm_by),
      namedHypothesesOfLib(x.thm_named_hypotheses),
      x,
    );
  }
}

type RawRuleSpec = lib.Common_Rule_spec_t_poly<lib.Mir_Term, lib.Mir_Type>;

/** A rule_spec, entered with `rule_spec foo x y = <formula using x,y>` */
export class RuleSpec {
  /** forward chaining rule? */
  readonly forwardChaining: boolean;
  /** rewrite rule? */
  readonly rewriting: boolean;
  /** apply permutative rewrite rule restrictions? */
  readonly permRestrict: boolean;
  /** corresponding (boolean) function */
  readonly function: FunctionDefinition;
  /** explicit rule triggers */
  readonly triggers: readonly PreTrigger[];
  readonly raw: RawRuleSpec;

  constructor(
    forwardChaining: boolean,
    rewriting: boolean,
    permRestrict: boolean,
    fn: FunctionDefinition,
    triggers: readonly PreTrigger[],
    raw: RawRuleSpec,
  ) {
    this.forwardChaining = forwardChaining;
    this.rewriting = rewriting;
    this.permRestrict = permRestrict;
    this.function = fn;
    this.triggers = triggers;
    this.raw = raw;
  }

  /** The rule spec's name, that of its `function` */
  get name(): Uid {
    return this.function.name;
  }

  /** @internal */
  static ofLib(x: RawRuleSpec): RuleSpec {
    return new RuleSpec(
      x.rule_spec_fc,
      x.rule_spec_rewriting,
      x.rule_spec_perm_restrict,
      FunctionDefinition.ofLib(x.rule_spec_link),
      x.rule_spec_triggers.map(preTriggerOfLib),
      x,
    );
  }
}

export type VerifyKind = "verify" | "instance" | "test";

/** @internal */
export function verifyKindOfLib(x: lib.Common_Verify_kind): VerifyKind {
  if (x instanceof lib.Common_Verify_kind_K_verify) return "verify";
  if (x instanceof lib.Common_Verify_kind_K_instance) return "instance";
  if (x instanceof lib.Common_Verify_kind_K_test) return "test";
  return unexpected("verify kind", x);
}

type RawVerify = lib.Common_Verify_t_poly<lib.Mir_Term, lib.Mir_Type>;

/** A [verify (fun x y -> <formula using x,y>)] event, for nameless theorems. */
export class Verify {
  /** nameless function representing the property to check */
  readonly function: FunctionDefinition;

  constructor(
    fn: FunctionDefinition,
    /** simplify first? */
    readonly simplify: boolean,
    /** nonlinear real arithmetic? */
    readonly nonlinear: boolean,
    readonly upto: number | undefined,
    readonly kind: VerifyKind,
    /** arithmetic terms to minimize in models */
    readonly minimize: readonly Term[],
    /** The proof, `fun variables -> body`, if any */
    readonly by: Binder | undefined,
    readonly raw: RawVerify,
  ) {
    this.function = fn;
  }

  /** The verify statement's name, that of its `function` */
  get name(): Uid {
    return this.function.name;
  }

  /** @internal */
  static ofLib(x: RawVerify): Verify {
    return new Verify(
      FunctionDefinition.ofLib(x.verify_link),
      x.verify_simplify,
      x.verify_nonlin,
      x.verify_upto === undefined ? undefined : uptoOfLib(x.verify_upto),
      verifyKindOfLib(x.verify_kind),
      x.verify_minimize.map(termOfLib),
      x.verify_by === undefined ? undefined : binderOfLib(x.verify_by),
      x,
    );
  }
}

/*
Declarations
============
*/

/** @internal */
export function declarationOfLib(x: lib.Mir_Decl): Declaration {
  if (x instanceof lib.Common_Decl_t_poly_Fun) {
    return new FunctionDeclaration(FunctionDefinition.ofLib(x.arg), x);
  }
  if (x instanceof lib.Common_Decl_t_poly_Ty)
    return new TypeDeclaration(TypeDefinition.ofLib(x.arg), x);
  if (x instanceof lib.Common_Decl_t_poly_Theorem)
    return new TheoremDeclaration(Theorem.ofLib(x.arg), x);
  if (x instanceof lib.Common_Decl_t_poly_Rule_spec) {
    return new RuleSpecDeclaration(RuleSpec.ofLib(x.arg), x);
  }
  if (x instanceof lib.Common_Decl_t_poly_Verify)
    return new VerifyDeclaration(Verify.ofLib(x.arg), x);
  return unexpected("declaration", x);
}

export class FunctionDeclaration {
  readonly kind = "function";
  /** The function defined */
  readonly function: FunctionDefinition;

  constructor(
    fn: FunctionDefinition,
    readonly raw: lib.Mir_Decl,
  ) {
    this.function = fn;
  }

  get id(): Uid {
    return this.function.name;
  }

  toString(): string {
    return `${this.function}`;
  }
}

export class TypeDeclaration {
  readonly kind = "type";
  constructor(
    /** The type defined */
    readonly type: TypeDefinition,
    readonly raw: lib.Mir_Decl,
  ) {}

  get id(): Uid {
    return this.type.name;
  }

  toString(): string {
    return `${this.type}`;
  }
}

export class TheoremDeclaration {
  readonly kind = "theorem";
  constructor(
    /** The theorem */
    readonly theorem: Theorem,
    readonly raw: lib.Mir_Decl,
  ) {}

  /** The linked function */
  get function(): FunctionDefinition {
    return this.theorem.function;
  }

  get id(): Uid {
    return this.function.name;
  }

  toString(): string {
    return definitionStr("theorem", this.function);
  }
}

export class RuleSpecDeclaration {
  readonly kind = "ruleSpec";
  constructor(
    /** The rule spec */
    readonly ruleSpec: RuleSpec,
    readonly raw: lib.Mir_Decl,
  ) {}

  /** The linked function */
  get function(): FunctionDefinition {
    return this.ruleSpec.function;
  }

  get id(): Uid {
    return this.function.name;
  }

  toString(): string {
    return definitionStr("rule_spec", this.function);
  }
}

export class VerifyDeclaration {
  readonly kind = "verify";
  constructor(
    /** The verify declaration */
    readonly verify: Verify,
    readonly raw: lib.Mir_Decl,
  ) {}

  /** The linked function */
  get function(): FunctionDefinition {
    return this.verify.function;
  }

  get id(): Uid {
    return this.function.name;
  }

  toString(): string {
    return definitionStr("verify", this.function);
  }
}

/**
 * A declaration: a function, type, theorem, rule spec or verify declaration
 *
 * Every variant has `id`, the identifier of the declaration (for theorems etc., the linked
 * function's), and `kind`, the kind of declaration: `function`, `type`, `theorem`, `ruleSpec` or
 * `verify`.
 */
export type Declaration =
  | FunctionDeclaration
  | TypeDeclaration
  | TheoremDeclaration
  | RuleSpecDeclaration
  | VerifyDeclaration;

/** The uid a declaration is stored under (for theorems etc., the linked function's) */
function declUid(d: lib.Mir_Decl): Uid {
  if (d instanceof lib.Common_Decl_t_poly_Fun) return new Uid(d.arg.f_name);
  if (d instanceof lib.Common_Decl_t_poly_Ty) return new Uid(d.arg.name);
  if (d instanceof lib.Common_Decl_t_poly_Theorem) return new Uid(d.arg.thm_link.f_name);
  if (d instanceof lib.Common_Decl_t_poly_Rule_spec) return new Uid(d.arg.rule_spec_link.f_name);
  if (d instanceof lib.Common_Decl_t_poly_Verify) return new Uid(d.arg.verify_link.f_name);
  return unexpected("declaration", d);
}

/*
Patterns and rules
==================
*/

/** @internal */
export function patternHeadOfLib(x: lib.Mir_Pattern_head): PatternHead {
  if (x instanceof lib.Common_Pattern_head_t_poly_PH_id) return new SymbolHead(new Uid(x.arg), x);
  if (x instanceof lib.Common_Pattern_head_t_poly_PH_ty) return new TypeHead(typeOfLib(x.arg), x);
  if (x instanceof lib.Common_Pattern_head_t_poly_PH_datatype_op) return new DatatypeOpHead(x);
  return unexpected("pattern head", x);
}

/** starts with function symbol */
export class SymbolHead {
  readonly kind = "symbol";
  constructor(
    /** The symbol's uid */
    readonly uid: Uid,
    readonly raw: lib.Mir_Pattern_head,
  ) {}

  /** Whether `other` is a pattern head equal to this one */
  equals(other: unknown): boolean {
    return isPatternHead(other) && patternHeadKey(this) === patternHeadKey(other);
  }

  toString(): string {
    return `${this.uid}`;
  }
}

/** The pattern is just a variable, so its head is its type */
export class TypeHead {
  readonly kind = "type";
  constructor(
    readonly type: Type,
    readonly raw: lib.Mir_Pattern_head,
  ) {}

  /** Whether `other` is a pattern head equal to this one */
  equals(other: unknown): boolean {
    return isPatternHead(other) && patternHeadKey(this) === patternHeadKey(other);
  }

  toString(): string {
    return `${this.type}`;
  }
}

/** starts with destruct/is-a */
export class DatatypeOpHead {
  readonly kind = "datatypeOp";
  constructor(readonly raw: lib.Mir_Pattern_head) {}

  /** Whether `other` is a pattern head equal to this one */
  equals(other: unknown): boolean {
    return isPatternHead(other) && patternHeadKey(this) === patternHeadKey(other);
  }

  toString(): string {
    return "<datatype op>";
  }
}

/** The head of a rule pattern: a symbol, a type, or a datatype operation */
export type PatternHead = SymbolHead | TypeHead | DatatypeOpHead;

function isPatternHead(x: unknown): x is PatternHead {
  return x instanceof SymbolHead || x instanceof TypeHead || x instanceof DatatypeOpHead;
}

/** A first-order pattern */
export abstract class FoPatternBase {
  abstract readonly kind: FoPattern["kind"];

  constructor(
    readonly type: Type,
    readonly raw: lib.Mir_Fo_pattern,
  ) {}
}

export class AnyPattern extends FoPatternBase {
  readonly kind = "any";
}

export class BoolPattern extends FoPatternBase {
  readonly kind = "bool";
  constructor(
    readonly value: boolean,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
  }
}

export class ConstPattern extends FoPatternBase {
  readonly kind = "const";
  constructor(
    readonly value: Const,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
  }
}

/** free variable to match */
export class VarPattern extends FoPatternBase {
  readonly kind = "var";
  constructor(
    readonly variable: Variable,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
  }
}

/** function applied to args */
export class ApplyPattern extends FoPatternBase {
  readonly kind = "apply";
  readonly function: AppliedSymbol;

  readonly arguments: readonly FoPattern[];

  constructor(fn: AppliedSymbol, args: readonly FoPattern[], type: Type, raw: lib.Mir_Fo_pattern) {
    super(type, raw);
    this.arguments = args;
    this.function = fn;
  }
}

/**
 * constructor, tuple, record…
 *
 * The field is `ctor`: classes cannot have a field named `constructor`.
 */
export class ConstructPattern extends FoPatternBase {
  readonly kind = "construct";
  readonly ctor: AppliedSymbol | undefined;
  readonly arguments: readonly FoPattern[];
  readonly labels: readonly Uid[] | undefined;

  constructor(
    ctor: AppliedSymbol | undefined,
    args: readonly FoPattern[],
    labels: readonly Uid[] | undefined,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
    this.ctor = ctor;
    this.arguments = args;
    this.labels = labels;
  }
}

export class DestructPattern extends FoPatternBase {
  readonly kind = "destruct";
  constructor(
    readonly ctor: AppliedSymbol | undefined,
    readonly index: number,
    readonly pattern: FoPattern,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
  }
}

export class IsAPattern extends FoPatternBase {
  readonly kind = "isA";
  constructor(
    readonly ctor: AppliedSymbol,
    readonly pattern: FoPattern,
    type: Type,
    raw: lib.Mir_Fo_pattern,
  ) {
    super(type, raw);
  }
}

/** A first-order pattern */
export type FoPattern =
  | AnyPattern
  | BoolPattern
  | ConstPattern
  | VarPattern
  | ApplyPattern
  | ConstructPattern
  | DestructPattern
  | IsAPattern;

/** @internal */
export function foPatternOfLib(x: lib.Mir_Fo_pattern): FoPattern {
  const ty = typeOfLib(x.ty);
  const v = x.view;
  if (v instanceof lib.Common_Fo_pattern_view_FO_any) return new AnyPattern(ty, x);
  if (v instanceof lib.Common_Fo_pattern_view_FO_bool) return new BoolPattern(v.arg, ty, x);
  if (v instanceof lib.Common_Fo_pattern_view_FO_const)
    return new ConstPattern(constOfLib(v.arg), ty, x);
  if (v instanceof lib.Common_Fo_pattern_view_FO_var)
    return new VarPattern(Variable.ofLib(v.arg), ty, x);
  if (v instanceof lib.Common_Fo_pattern_view_FO_app) {
    const [f, args] = v.args;
    return new ApplyPattern(AppliedSymbol.ofLib(f), args.map(foPatternOfLib), ty, x);
  }
  if (v instanceof lib.Common_Fo_pattern_view_FO_cstor) {
    return new ConstructPattern(
      v.c === undefined ? undefined : AppliedSymbol.ofLib(v.c),
      v.args.map(foPatternOfLib),
      v.labels === undefined ? undefined : v.labels.map((l) => new Uid(l)),
      ty,
      x,
    );
  }
  if (v instanceof lib.Common_Fo_pattern_view_FO_destruct) {
    return new DestructPattern(
      v.c === undefined ? undefined : AppliedSymbol.ofLib(v.c),
      Number(v.i),
      foPatternOfLib(v.u),
      ty,
      x,
    );
  }
  if (v instanceof lib.Common_Fo_pattern_view_FO_is_a) {
    return new IsAPattern(AppliedSymbol.ofLib(v.c), foPatternOfLib(v.u), ty, x);
  }
  return unexpected("pattern", v);
}

export class RewriteRule {
  constructor(
    /** name of theorem that gives this rewrite rule */
    readonly name: Uid,
    /** head symbol of LHS */
    readonly head: PatternHead,
    readonly lhs: FoPattern,
    readonly rhs: Term,
    readonly guard: readonly Term[],
    /** all variables of the rule (LHS + triggers) */
    readonly variables: readonly Variable[],
    /** additional triggers */
    readonly triggers: readonly FoPattern[],
    /** should we apply `permutative rule` restrictions? */
    readonly permRestrict: boolean,
    /** if this matches scrutinee term, rewrite aborts */
    readonly loopBreak: FoPattern | undefined,
    readonly raw: lib.Mir_Rewrite_rule,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Rewrite_rule): RewriteRule {
    return new RewriteRule(
      new Uid(x.rw_name),
      patternHeadOfLib(x.rw_head),
      foPatternOfLib(x.rw_lhs),
      termOfLib(x.rw_rhs),
      x.rw_guard.map(termOfLib),
      x.rw_vars.map((v) => Variable.ofLib(v)),
      x.rw_triggers.map(foPatternOfLib),
      x.rw_perm_restrict,
      x.rw_loop_break === undefined ? undefined : foPatternOfLib(x.rw_loop_break),
      x,
    );
  }
}

export class Trigger {
  constructor(
    /** Root of the pattern */
    readonly head: PatternHead,
    readonly patterns: readonly FoPattern[],
    /** Name of the instantiation rule */
    readonly instantiationRuleName: Uid,
    readonly raw: lib.Mir_Trigger,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Trigger): Trigger {
    return new Trigger(
      patternHeadOfLib(x.trigger_head),
      x.trigger_patterns.map(foPatternOfLib),
      new Uid(x.trigger_instantiation_rule_name),
      x,
    );
  }
}

export type InstantiationRuleKind = "forwardChaining" | "generalization";

/** @internal */
export function instantiationRuleKindOfLib(
  x: lib.Common_Instantiation_rule_kind,
): InstantiationRuleKind {
  if (x instanceof lib.Common_Instantiation_rule_kind_IR_forward_chaining) return "forwardChaining";
  if (x instanceof lib.Common_Instantiation_rule_kind_IR_generalization) return "generalization";
  return unexpected("instantiation rule kind", x);
}

export class InstantiationRule {
  readonly function: FunctionDefinition;

  constructor(
    fn: FunctionDefinition,
    readonly triggers: readonly Trigger[],
    readonly kind: InstantiationRuleKind,
    readonly raw: lib.Mir_Instantiation_rule,
  ) {
    this.function = fn;
  }

  /** @internal */
  static ofLib(x: lib.Mir_Instantiation_rule): InstantiationRule {
    return new InstantiationRule(
      FunctionDefinition.ofLib(x.ir_from),
      x.ir_triggers.map((t) => Trigger.ofLib(t)),
      instantiationRuleKindOfLib(x.ir_kind),
      x,
    );
  }
}

/**
 * An elimination rule
 *
 * Elimination rules are equal when their names are, as in OCaml's `Elimination_rule.equal`: see
 * `equals`.
 */
export class EliminationRule {
  constructor(
    /** name of theorem giving rise to this elim rule */
    readonly name: Uid,
    /** elimination hypotheses */
    readonly guard: readonly Term[],
    /** the `body' of the rule, at the theorem level */
    readonly lhs: Term,
    /** the RHS / elimination variable */
    readonly rhs: Variable,
    /** destructor terms of the rule, as patterns */
    readonly destructors: readonly FoPattern[],
    /** destructor terms of the rule, as terms */
    readonly destructorTerms: readonly Term[],
    readonly raw: lib.Mir_Elimination_rule,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Elimination_rule): EliminationRule {
    return new EliminationRule(
      new Uid(x.er_name),
      x.er_guard.map(termOfLib),
      termOfLib(x.er_lhs),
      Variable.ofLib(x.er_rhs),
      x.er_dests.map(foPatternOfLib),
      x.er_dest_tms.map(termOfLib),
      x,
    );
  }

  /** Whether `other` is an elimination rule with an equal name */
  equals(other: unknown): boolean {
    return other instanceof EliminationRule && this.name.equals(other.name);
  }
}

/*
Models
======
*/

type RawFi = lib.Common_Model_fi<lib.Mir_Term, lib.Mir_Type>;

/** The interpretation of a function in a model: a list of cases and a default */
export class FunctionInterpretation {
  /** The function's parameters */
  readonly arguments: readonly Variable[];
  /** The function's return type */
  readonly returnType: Type;
  /** The cases, in order */
  readonly cases: readonly FunctionInterpretationCase[];
  /** The function's value if none of the cases fires */
  readonly else: Term;
  readonly raw: RawFi;

  constructor(
    args: readonly Variable[],
    returnType: Type,
    cases: readonly FunctionInterpretationCase[],
    else_: Term,
    raw: RawFi,
  ) {
    this.arguments = args;
    this.returnType = returnType;
    this.cases = cases;
    this.else = else_;
    this.raw = raw;
  }

  /** @internal */
  static ofLib(x: RawFi): FunctionInterpretation {
    return new FunctionInterpretation(
      x.fi_args.map((a) => Variable.ofLib(a)),
      typeOfLib(x.fi_ty_ret),
      x.fi_cases.map(
        ([gs, rhs]) => new FunctionInterpretationCase(gs.map(termOfLib), termOfLib(rhs)),
      ),
      termOfLib(x.fi_else),
      x,
    );
  }
}

/**
 * For inputs with `sigma` the substitution mapping the function's `arguments` to them, if
 * every `sigma(guard)` holds, the function is equal to `sigma(rhs)`
 */
export class FunctionInterpretationCase {
  constructor(
    /** The conditions under which the case fires */
    readonly guards: readonly Term[],
    /** The function's value when the case fires */
    readonly rhs: Term,
  ) {}
}

type RawTyDef = lib.Common_Model_ty_def<lib.Mir_Term, lib.Mir_Type>;

/** interpretation of the type as a finite domain */
export class FiniteTypeInterpretation {
  readonly kind = "finite";
  constructor(
    readonly elements: readonly Term[],
    readonly raw: RawTyDef,
  ) {}
}

/** Interpretation of the type as an alias to [unit] */
export class UnitAliasTypeInterpretation {
  readonly kind = "unitAlias";
  constructor(
    readonly type: Type,
    readonly raw: RawTyDef,
  ) {}
}

/** The interpretation of a type in a model */
export type TypeInterpretation = FiniteTypeInterpretation | UnitAliasTypeInterpretation;

/** @internal */
export function typeInterpretationOfLib(x: RawTyDef): TypeInterpretation {
  if (x instanceof lib.Common_Model_ty_def_Ty_finite) {
    return new FiniteTypeInterpretation(x.arg.map(termOfLib), x);
  }
  if (x instanceof lib.Common_Model_ty_def_Ty_alias_unit) {
    return new UnitAliasTypeInterpretation(typeOfLib(x.arg), x);
  }
  return unexpected("type interpretation", x);
}

/** A model, e.g. a counter-model or an instance */
export class Model {
  constructor(
    /** The interpretations of types */
    readonly types: ReadonlyMap<Type, TypeInterpretation>,
    /** The values of constants */
    readonly constants: ReadonlyMap<AppliedSymbol, Term>,
    /** The interpretations of functions */
    readonly functions: ReadonlyMap<AppliedSymbol, FunctionInterpretation>,
    /** Can it be entirely represented into OCaml? Not the case if it contains irrational reals */
    readonly representable: boolean,
    /** Indicates whether the model has been completed */
    readonly completed: boolean,
    /** Types that had new ones substituted during model extraction, by the substituted type's uid */
    readonly typeSubstitution: ReadonlyMap<Uid, Type>,
    readonly raw: lib.Mir_Model,
  ) {}

  /** @internal */
  static ofLib(x: lib.Mir_Model): Model {
    return new Model(
      new ValueMap(
        typeKey,
        x.tys.map(([t, d]) => [typeOfLib(t), typeInterpretationOfLib(d)] as const),
      ),
      new ValueMap(
        appliedSymbolKey,
        x.consts.map(([s, t]) => [AppliedSymbol.ofLib(s), termOfLib(t)] as const),
      ),
      new ValueMap(
        appliedSymbolKey,
        x.funs.map(([s, f]) => [AppliedSymbol.ofLib(s), FunctionInterpretation.ofLib(f)] as const),
      ),
      x.representable,
      x.completed,
      uidMap(x.ty_subst.map(([u, t]) => [new Uid(u), typeOfLib(t)] as const)),
      x,
    );
  }

  /**
   * The constants' values as plain JS data, by short name, e.g. `Map { "x" => 3n, "ys" => [] }`
   *
   * Constants whose short names clash are keyed by full name instead.
   *
   * @throws RangeError if a constant's value is not a value, see `Term.toJs`
   */
  toJs(): Map<string, JsValue> {
    const counts = new Map<string, number>();
    for (const s of this.constants.keys()) {
      counts.set(s.id.shortName, (counts.get(s.id.shortName) ?? 0) + 1);
    }
    const out = new Map<string, JsValue>();
    for (const [s, t] of this.constants) {
      const name = counts.get(s.id.shortName) === 1 ? s.id.shortName : s.id.fullName;
      out.set(name, t.toJs());
    }
    return out;
  }

  toString(): string {
    const show = (m: ReadonlyMap<unknown, unknown>) =>
      `{${[...m].map(([k, v]) => `${k}: ${v}`).join(", ")}}`;
    return `types: ${show(this.types)} constants: ${show(this.constants)} functions: ${show(this.functions)}`;
  }
}

/*
Decompositions
==============
*/

type RawRegionStatus = lib.Common_Region_status<lib.Mir_Term, lib.Mir_Type>;

export class UnknownStatus {
  readonly kind = "unknown";
  constructor(readonly raw: RawRegionStatus) {}
}

export class FeasibleStatus {
  readonly kind = "feasible";
  constructor(
    readonly model: Model,
    readonly raw: RawRegionStatus,
  ) {}
}

/** Trying to assess feasibility failed, eg with a timeout */
export class FeasibilityCheckFailedStatus {
  readonly kind = "feasibilityCheckFailed";
  constructor(
    readonly message: string,
    readonly raw: RawRegionStatus,
  ) {}
}

export type RegionStatus = UnknownStatus | FeasibleStatus | FeasibilityCheckFailedStatus;

/** @internal */
export function regionStatusOfLib(x: RawRegionStatus): RegionStatus {
  if (x instanceof lib.Common_Region_status_Unknown) return new UnknownStatus(x);
  if (x instanceof lib.Common_Region_status_Feasible)
    return new FeasibleStatus(Model.ofLib(x.arg), x);
  if (x instanceof lib.Common_Region_status_Feasibility_check_failed) {
    return new FeasibilityCheckFailedStatus(x.arg, x);
  }
  return unexpected("region status", x);
}

function metaOfLib(m: lib.Common_Region_meta<lib.Mir_Term>): RegionMeta {
  if (m instanceof lib.Common_Region_meta_Null) return null;
  if (m instanceof lib.Common_Region_meta_Bool) return m.arg;
  if (m instanceof lib.Common_Region_meta_Int) return m.arg;
  if (m instanceof lib.Common_Region_meta_Real) return new Rational(m.arg[0], m.arg[1]);
  if (m instanceof lib.Common_Region_meta_String) return m.arg;
  if (m instanceof lib.Common_Region_meta_Assoc) {
    return new Map(m.arg.map(([key, v]) => [key, metaOfLib(v)] as const));
  }
  if (m instanceof lib.Common_Region_meta_Term) return termOfLib(m.arg);
  if (m instanceof lib.Common_Region_meta_List) return m.arg.map(metaOfLib);
  return unexpected("region metadata", m);
}

/** `m`, which the server sends as a term */
function metaTerm(m: RegionMeta): Term {
  if (!(m instanceof TermBase)) {
    throw new UnexpectedResponseError(`expected a term in region metadata, got ${m}`);
  }
  return m as Term;
}

/** A region decomposition of a function */
export class Decomposition {
  /** The identifier of the decomposed function */
  readonly id: Uid;
  /** The decomposed function's parameters */
  readonly arguments: readonly Variable[];
  /** The regions */
  readonly regions: readonly Region[];
  readonly raw: lib.Mir_Fun_decomp;

  constructor(
    id: Uid,
    args: readonly Variable[],
    regions: readonly Region[],
    raw: lib.Mir_Fun_decomp,
  ) {
    this.id = id;
    this.arguments = args;
    this.regions = regions;
    this.raw = raw;
  }

  /** @internal */
  static ofLib(d: lib.Mir_Fun_decomp): Decomposition {
    return new Decomposition(
      new Uid(d.f_id),
      d.f_args.map((a) => Variable.ofLib(a)),
      d.regions.map((r) => Region.ofLib(r)),
      d,
    );
  }

  /** The regions, one per line */
  toString(): string {
    return this.regions.map((r) => `${r}`).join("\n");
  }
}

/** A region of the input space, given by constraints, and the result in it */
export class Region {
  constructor(
    /** The constraints on the inputs that define the region */
    readonly constraints: readonly Term[],
    /** The function's result for inputs in the region */
    readonly invariant: Term,
    /** Metadata attached to the region, by name */
    readonly meta: ReadonlyMap<string, RegionMeta>,
    /** Whether the region is known to be feasible */
    readonly status: RegionStatus,
    readonly raw: lib.Mir_Region_Region,
  ) {}

  /** @internal */
  static ofLib(r: lib.Mir_Region_Region): Region {
    return new Region(
      r.constraints.map(termOfLib),
      termOfLib(r.invariant),
      new Map(r.meta.map(([key, v]) => [key, metaOfLib(v)] as const)),
      regionStatusOfLib(r.status),
      r,
    );
  }

  /**
   * The model of the region's constraints, if the region was proved feasible
   *
   * Note: Pruning a decomposition checks each region's feasibility.
   * The model can bind more variables than the decomposed function's arguments,
   * e.g. after `enumerate_all`. Use UID to disambiguate variables with the same
   * short names.
   */
  get model(): Model | undefined {
    return this.status instanceof FeasibleStatus ? this.status.model : undefined;
  }

  /** The function's result on `model`, if the region was proved feasible */
  get modelEval(): Term | undefined {
    const m = this.meta.get("model_eval");
    return m === undefined || m === null ? undefined : metaTerm(m);
  }

  /**
   * The variables' values in `model` as plain JS data, if the region was proved feasible
   *
   * @param db The labels of inline records can be left out; pass the decomposition
   *   task's `db` to restore them.
   * @throws RangeError if a variable's value is not a value, see `Term.toJs`
   */
  sample(db?: DB): ReadonlyMap<Uid, JsValue> | undefined {
    const m = this.model;
    if (m === undefined) {
      return undefined;
    }
    return uidMap([...m.constants].map(([s, t]) => [s.symbol.id, t.toJs(db)] as const));
  }

  /**
   * `modelEval` as plain JS data, if the region was proved feasible
   *
   * @param db The labels of inline records can be left out; pass the decomposition
   *   task's `db` to restore them.
   * @throws RangeError if the result is not a value, see `Term.toJs`
   * @throws UnexpectedResponseError if the server sent something other than a term
   */
  sampleOutput(db?: DB): JsValue | undefined {
    const t = this.modelEval;
    return t === undefined ? undefined : t.toJs(db);
  }

  /** The constraints in IML syntax, if requested with `stringResults: true` */
  get constraintsStr(): readonly string[] | undefined {
    const cs = this.#strMeta("constraints");
    if (cs === undefined || cs === null) {
      return undefined;
    }
    if (Array.isArray(cs) && cs.every((c) => typeof c === "string")) {
      return cs as readonly string[];
    }
    throw new UnexpectedResponseError(`expected the region's constraints as strings, got ${cs}`);
  }

  /** The invariant in IML syntax, if requested with `stringResults: true` */
  get invariantStr(): string | undefined {
    const s = this.#strMeta("invariant");
    if (s === undefined || s === null) {
      return undefined;
    }
    if (typeof s === "string") {
      return s;
    }
    throw new UnexpectedResponseError(`expected the region's invariant as a string, got ${s}`);
  }

  #strMeta(key: string): RegionMeta | undefined {
    const m = this.meta.get("str");
    return m instanceof Map ? (m as ReadonlyMap<string, RegionMeta>).get(key) : undefined;
  }

  toString(): string {
    const constraints = this.constraints.map((c) => `${c}`).join("; ");
    let status: string;
    switch (this.status.kind) {
      case "unknown":
        status = "unknown";
        break;
      case "feasible":
        status = "feasible";
        break;
      case "feasibilityCheckFailed":
        status = `feasibility check failed: ${this.status.message}`;
        break;
    }
    return `constraints: [${constraints}] invariant: ${this.invariant} status: ${status}`;
  }
}

/**
 * A metadata value attached to a region
 *
 * `null` stands for the server's `Null`, rationals for reals.
 */
export type RegionMeta =
  | null
  | boolean
  | bigint
  | Rational
  | string
  | Term
  | ReadonlyMap<string, RegionMeta>
  | readonly RegionMeta[];

/*
Database
========
*/

/**
 * A database of symbols
 *
 * Its contents are converted on first access.
 */
export class DB {
  readonly raw: lib.Mir_Db_ser;
  // TS `private` rather than `#`: unit tests seed `rawTys` directly, as there is no encoder to
  // build the serialized operations a DB is replayed from
  private readonly storage: ReadonlyMap<string, Uint8Array>;
  private readonly disabledUids: ValueSet<Uid> = uidSet();
  private readonly rawTys: ValueMap<Uid, lib.Mir_Type_def> = uidMap();
  private readonly rawFuns: ValueMap<Uid, lib.Mir_Fun_def> = uidMap();
  private readonly rawDecls: ValueMap<Uid, lib.Mir_Decl> = uidMap();
  private readonly rawRwRules = new ValueMap<PatternHead, lib.Mir_Rewrite_rule[]>(patternHeadKey);
  private readonly rawFc = new ValueMap<PatternHead, lib.Mir_Trigger[]>(patternHeadKey);
  private readonly rawElim = new ValueMap<PatternHead, lib.Mir_Elimination_rule[]>(patternHeadKey);
  private readonly rawGen = new ValueMap<PatternHead, lib.Mir_Trigger[]>(patternHeadKey);
  private readonly rawAdmission: ValueMap<Uid, lib.Common_Admission> = uidMap();
  private readonly rawThmAsRw: ValueMap<Uid, lib.Mir_Rewrite_rule[]> = uidMap();
  private readonly rawThmAsFc: ValueMap<Uid, lib.Mir_Instantiation_rule[]> = uidMap();
  private readonly rawThmAsElim: ValueMap<Uid, lib.Mir_Elimination_rule[]> = uidMap();
  private readonly rawThmAsGen: ValueMap<Uid, lib.Mir_Instantiation_rule> = uidMap();
  private readonly rawInstRules: ValueMap<Uid, lib.Mir_Instantiation_rule> = uidMap();
  private readonly rawRuleSpecFc: ValueMap<Uid, lib.Mir_Trigger[]> = uidMap();
  private readonly rawRuleSpecRwRules: ValueMap<Uid, lib.Mir_Rewrite_rule[]> = uidMap();
  private readonly cache = new Map<string, unknown>();

  /**
   * @param ds The serialized database: a series of operations, each stored in `storage`
   * @param storage The artifact's storage, by key
   */
  constructor(ds: lib.Mir_Db_ser, storage: ReadonlyMap<string, Uint8Array>) {
    // ds is a series of serialized DB operations; we reconstruct a concrete
    // database by replaying all the operations.
    this.raw = ds;
    this.storage = storage;
    for (const op of ds.ops) {
      const bs = storage.get(op.key);
      if (bs === undefined) {
        throw new UnexpectedResponseError(
          `missing storage entry for MIR database operation ${op.key}`,
        );
      }
      const instruction = twine.decodeEntrypoint(new twine.Decoder(bs), (d, off) =>
        lib.Common_Db_op_t_poly_of_twine(
          d,
          (d, off) => lib.Mir_Term_of_twine(d, off),
          (d, off) => lib.Mir_Type_of_twine(d, off),
          off,
        ),
      );
      this.replay(instruction);
    }
  }

  private replay(instruction: lib.Common_Db_op_t_poly<lib.Mir_Term, lib.Mir_Type>): void {
    const push = <K, V>(m: ValueMap<K, V[]>, key: K, ...vs: V[]) => {
      const xs = m.get(key);
      if (xs === undefined) {
        m.set(key, [...vs]);
      } else {
        xs.push(...vs);
      }
    };
    const i = instruction;
    if (i instanceof lib.Common_Db_op_t_poly_Op_enable) {
      for (const uid of i.arg) this.disabledUids.delete(new Uid(uid));
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_disable) {
      for (const uid of i.arg) this.disabledUids.add(new Uid(uid));
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_decls) {
      for (const d of i.arg) {
        const uid = declUid(d);
        this.rawDecls.set(uid, d);
        if (d instanceof lib.Common_Decl_t_poly_Fun) {
          this.rawFuns.set(uid, d.arg);
        } else if (d instanceof lib.Common_Decl_t_poly_Ty) {
          this.rawTys.set(uid, d.arg);
        } else if (d instanceof lib.Common_Decl_t_poly_Theorem) {
          this.rawFuns.set(uid, d.arg.thm_link);
        } else if (d instanceof lib.Common_Decl_t_poly_Rule_spec) {
          // nothing else to record
        } else if (d instanceof lib.Common_Decl_t_poly_Verify) {
          this.rawFuns.set(uid, d.arg.verify_link);
        }
      }
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_rw) {
      push(this.rawRwRules, patternHeadOfLib(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_fc_trigger) {
      push(this.rawFc, patternHeadOfLib(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_elim) {
      push(this.rawElim, patternHeadOfLib(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_gen_trigger) {
      push(this.rawGen, patternHeadOfLib(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_count_fun) {
      // ignored in imandrax
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_set_admission) {
      this.rawAdmission.set(new Uid(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_set_thm_as_rw) {
      this.rawThmAsRw.set(new Uid(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_set_thm_as_fc) {
      this.rawThmAsFc.set(new Uid(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_set_thm_as_elim) {
      this.rawThmAsElim.set(new Uid(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_set_thm_as_gen) {
      this.rawThmAsGen.set(new Uid(i.args[0]), i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_instantiation_rule) {
      this.rawInstRules.set(new Uid(i.arg.ir_from.f_name), i.arg);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers) {
      push(this.rawRuleSpecFc, new Uid(i.args[0]), ...i.args[1]);
    } else if (i instanceof lib.Common_Db_op_t_poly_Op_add_rule_spec_rw) {
      push(this.rawRuleSpecRwRules, new Uid(i.args[0]), ...i.args[1]);
    } else {
      throw new UnexpectedResponseError("unknown MIR database operation");
    }
  }

  private cached<T>(name: string, f: () => T): T {
    if (!this.cache.has(name)) {
      this.cache.set(name, f());
    }
    return this.cache.get(name) as T;
  }

  private static convert<K, R, V>(
    m: ValueMap<K, R>,
    keyOf: (k: K) => string,
    f: (r: R) => V,
  ): ReadonlyMap<K, V> {
    return new ValueMap(
      keyOf,
      [...m].map(([key, r]) => [key, f(r)] as const),
    );
  }

  private get tys(): ReadonlyMap<Uid, TypeDefinition> {
    return this.cached("tys", () =>
      DB.convert(this.rawTys, uidKey, (t) => TypeDefinition.ofLib(t)),
    );
  }

  private get funs(): ReadonlyMap<Uid, FunctionDefinition> {
    return this.cached("funs", () =>
      DB.convert(this.rawFuns, uidKey, (f) => FunctionDefinition.ofLib(f)),
    );
  }

  /** Uids of disabled symbols */
  get disabled(): ReadonlyValueSet<Uid> {
    return this.disabledUids;
  }

  /** All declarations, by uid */
  get decls(): ReadonlyMap<Uid, Declaration> {
    return this.cached("decls", () => DB.convert(this.rawDecls, uidKey, declarationOfLib));
  }

  /** Rewrite rules, by their pattern head */
  get rwRules(): ReadonlyMap<PatternHead, readonly RewriteRule[]> {
    return this.cached("rwRules", () =>
      DB.convert(this.rawRwRules, patternHeadKey, (rs) => rs.map((r) => RewriteRule.ofLib(r))),
    );
  }

  /** Forward-chaining triggers, by their pattern head */
  get fc(): ReadonlyMap<PatternHead, readonly Trigger[]> {
    return this.cached("fc", () =>
      DB.convert(this.rawFc, patternHeadKey, (ts) => ts.map((t) => Trigger.ofLib(t))),
    );
  }

  /** Elimination rules, by their pattern head */
  get elim(): ReadonlyMap<PatternHead, readonly EliminationRule[]> {
    return this.cached("elim", () =>
      DB.convert(this.rawElim, patternHeadKey, (rs) => rs.map((r) => EliminationRule.ofLib(r))),
    );
  }

  /** Generalization triggers, by their pattern head */
  get gen(): ReadonlyMap<PatternHead, readonly Trigger[]> {
    return this.cached("gen", () =>
      DB.convert(this.rawGen, patternHeadKey, (ts) => ts.map((t) => Trigger.ofLib(t))),
    );
  }

  /** Admission information, by function uid */
  get admission(): ReadonlyMap<Uid, Admission> {
    return this.cached("admission", () =>
      DB.convert(this.rawAdmission, uidKey, (a) => Admission.ofLib(a)),
    );
  }

  /** Rewrite rules derived from each theorem, by theorem uid */
  get thmAsRw(): ReadonlyMap<Uid, readonly RewriteRule[]> {
    return this.cached("thmAsRw", () =>
      DB.convert(this.rawThmAsRw, uidKey, (rs) => rs.map((r) => RewriteRule.ofLib(r))),
    );
  }

  /** Forward-chaining rules derived from each theorem, by theorem uid */
  get thmAsFc(): ReadonlyMap<Uid, readonly InstantiationRule[]> {
    return this.cached("thmAsFc", () =>
      DB.convert(this.rawThmAsFc, uidKey, (rs) => rs.map((r) => InstantiationRule.ofLib(r))),
    );
  }

  /** Elimination rules derived from each theorem, by theorem uid */
  get thmAsElim(): ReadonlyMap<Uid, readonly EliminationRule[]> {
    return this.cached("thmAsElim", () =>
      DB.convert(this.rawThmAsElim, uidKey, (rs) => rs.map((r) => EliminationRule.ofLib(r))),
    );
  }

  /** The generalization rule derived from each theorem, by theorem uid */
  get thmAsGen(): ReadonlyMap<Uid, InstantiationRule> {
    return this.cached("thmAsGen", () =>
      DB.convert(this.rawThmAsGen, uidKey, (r) => InstantiationRule.ofLib(r)),
    );
  }

  /** Instantiation rules, by the uid of the function they come from */
  get instRules(): ReadonlyMap<Uid, InstantiationRule> {
    return this.cached("instRules", () =>
      DB.convert(this.rawInstRules, uidKey, (r) => InstantiationRule.ofLib(r)),
    );
  }

  /** Forward-chaining triggers of each rule spec, by uid */
  get ruleSpecFc(): ReadonlyMap<Uid, readonly Trigger[]> {
    return this.cached("ruleSpecFc", () =>
      DB.convert(this.rawRuleSpecFc, uidKey, (ts) => ts.map((t) => Trigger.ofLib(t))),
    );
  }

  /** Rewrite rules of each rule spec, by uid */
  get ruleSpecRwRules(): ReadonlyMap<Uid, readonly RewriteRule[]> {
    return this.cached("ruleSpecRwRules", () =>
      DB.convert(this.rawRuleSpecRwRules, uidKey, (rs) => rs.map((r) => RewriteRule.ofLib(r))),
    );
  }

  toString(): string {
    const uids = (us: Iterable<Uid>) => [...us].map((u) => `${u}`).sort();
    const counts = (entries: Iterable<readonly [Uid | PatternHead, { length: number }]>) =>
      [...entries].map(([u, xs]) => `${u}: ${xs.length}`).sort();
    const sections: [string, string[]][] = [
      ["disabled", uids(this.disabled)],
      ["rw_rules", counts(this.rwRules)],
      ["fc", counts(this.fc)],
      ["elim", counts(this.elim)],
      ["gen", counts(this.gen)],
      ["admission", uids(this.admission.keys())],
      ["thm_as_rw", counts(this.thmAsRw)],
      ["thm_as_fc", counts(this.thmAsFc)],
      ["thm_as_elim", counts(this.thmAsElim)],
      ["thm_as_gen", uids(this.thmAsGen.keys())],
      ["inst_rules", uids(this.instRules.keys())],
      ["rule_spec_fc", counts(this.ruleSpecFc)],
      ["rule_spec_rw_rules", counts(this.ruleSpecRwRules)],
    ];
    const lines = [`decls: ${this.decls.size}`];
    for (const [name, items] of sections) {
      lines.push(items.length > 0 ? `${name}:` : `${name}: {}`);
      lines.push(...items.map((x) => `  ${x}`));
    }
    return lines.join("\n");
  }

  /** The declaration with uid `x`, or `undefined` */
  findDeclaration(x: Uid): Declaration | undefined {
    return this.decls.get(x);
  }

  /** All declarations whose full name matches `regex` from its start */
  findDeclarationRe(regex: string): ReadonlyMap<Uid, Declaration> {
    return matchingFullNames(this.decls, regex);
  }

  /** The type definition with uid `x`, or `undefined` */
  findType(x: Uid): TypeDefinition | undefined {
    return this.tys.get(x);
  }

  /** All types whose full name matches `regex` from its start */
  findTypeRe(regex: string): ReadonlyMap<Uid, TypeDefinition> {
    return matchingFullNames(this.tys, regex);
  }

  /** The function definition with uid `x`, or `undefined` */
  findFunction(x: Uid): FunctionDefinition | undefined {
    return this.funs.get(x);
  }

  /** All functions whose full name matches `regex` from its start */
  findFunctionRe(regex: string): ReadonlyMap<Uid, FunctionDefinition> {
    return matchingFullNames(this.funs, regex);
  }
}

/**
 * The entries of `m` whose key's full name matches `regex` from its start (a sticky match; the
 * regex is in JS syntax)
 */
function matchingFullNames<V>(m: ReadonlyMap<Uid, V>, regex: string): ReadonlyMap<Uid, V> {
  const rx = new RegExp(regex, "y");
  return uidMap(
    [...m].filter(([id]) => {
      rx.lastIndex = 0;
      return rx.test(id.fullName);
    }),
  );
}
