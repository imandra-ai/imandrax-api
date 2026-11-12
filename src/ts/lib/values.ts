/**
 * Values produced by evaluating an IML expression
 *
 * This module exports classes named `String` and `Record`, as Python's `evaluation_values` does;
 * import it as a namespace (`import * as values from ...`) to keep the builtins in reach.
 *
 * @module
 */

import { UnexpectedResponseError } from "./errors.js";
import * as mir from "./mir.js";
import * as lib from "./raw/types.js";

type View = lib.Eval_Value_view<lib.Eval_Value, lib.Eval_Value_erased_closure>;

/** The boolean `true`. */
export class True_ {
  readonly kind = "true";
  constructor(readonly raw: View) {}

  toString(): string {
    return "true";
  }
}

/** The boolean `false`. */
export class False_ {
  readonly kind = "false";
  constructor(readonly raw: View) {}

  toString(): string {
    return "false";
  }
}

/** An integer, stored in `value`. */
export class Int {
  readonly kind = "int";
  constructor(
    readonly value: bigint,
    readonly raw: View,
  ) {}

  toString(): string {
    return `${this.value}`;
  }
}

/** A real number, stored exactly as a `Rational` in `value`. */
export class Real {
  readonly kind = "real";
  constructor(
    readonly value: mir.Rational,
    readonly raw: View,
  ) {}

  toString(): string {
    return `${this.value}`;
  }
}

/** A string, stored in `value`. */
export class String {
  readonly kind = "string";
  constructor(
    readonly value: string,
    readonly raw: View,
  ) {}

  toString(): string {
    return `"${this.value}"`;
  }
}

/**
 * A data constructor applied to arguments, e.g. `Some 3` or `None`.
 *
 * `name` is the constructor's name, `index` its position among the type's constructors, and
 * `args` its arguments.
 */
export class Constructor {
  readonly kind = "constructor";
  constructor(
    readonly name: string,
    readonly index: number,
    readonly args: readonly Value[],
    readonly raw: View,
  ) {}

  /** For pretty-printing */
  private asList(): readonly Value[] | undefined {
    const elements: Value[] = [];
    let v: Value = this;
    for (;;) {
      if (v instanceof Constructor && v.name === "::" && v.args.length === 2) {
        elements.push(v.args[0]!);
        v = v.args[1]!;
      } else if (v instanceof Constructor && v.name === "[]" && v.args.length === 0) {
        return elements;
      } else {
        return undefined;
      }
    }
  }

  toString(): string {
    const elements = this.asList();
    if (elements !== undefined) {
      return "[" + elements.map((e) => `${e}`).join("; ") + "]";
    }
    if (this.args.length === 0) {
      return this.name;
    }
    return `${this.name} (${this.args.map((a) => `${a}`).join(", ")})`;
  }
}

/** A tuple; `elements` holds its components in order. */
export class Tuple {
  readonly kind = "tuple";
  constructor(
    readonly elements: readonly Value[],
    readonly raw: View,
  ) {}

  toString(): string {
    return `(${this.elements.map((e) => `${e}`).join(", ")})`;
  }
}

/** A record; `name` identifies the record type and `fields` maps field names to values. */
export class Record {
  readonly kind = "record";
  constructor(
    readonly name: string,
    readonly fields: ReadonlyMap<string, Value>,
    readonly raw: View,
  ) {}

  toString(): string {
    return "{" + [...this.fields].map(([k, x]) => `${k} = ${x}`).join("; ") + "}";
  }
}

/** A quoted term: a MIR function, `fun variables -> body` */
export class QuotedTerm {
  readonly kind = "quotedTerm";
  constructor(
    readonly variables: readonly mir.Variable[],
    readonly body: mir.Term,
    readonly raw: View,
  ) {}

  toString(): string {
    return "<quoted term>";
  }
}

/** A unique identifier, stored in `uid` and printed by name. */
export class Uid {
  readonly kind = "uid";
  constructor(
    readonly uid: mir.Uid,
    readonly raw: View,
  ) {}

  toString(): string {
    return this.uid.shortName;
  }
}

/** A function value; its code is not sent to the client, so it prints as `<closure missing=n>`. */
export class Closure {
  readonly kind = "closure";
  constructor(
    readonly missing: number,
    readonly raw: View,
  ) {}

  toString(): string {
    return `<closure missing=${this.missing}>`;
  }
}

/**
 * A custom value.
 *
 * The library cannot decode custom values yet (decoding raises an error), so this class is
 * currently never produced.
 */
export class Custom {
  readonly kind = "custom";
  constructor(
    readonly value: lib.Eval__Value_Custom_value,
    readonly raw: View,
  ) {}

  toString(): string {
    return "<custom>";
  }
}

/** An ordinal, stored in `value`. */
export class Ordinal {
  readonly kind = "ordinal";
  constructor(
    readonly value: OrdinalExpr,
    readonly raw: View,
  ) {}

  toString(): string {
    return `${this.value}`;
  }
}

/** A value produced by evaluation */
export type Value =
  | True_
  | False_
  | Int
  | Real
  | String
  | Constructor
  | Tuple
  | Record
  | QuotedTerm
  | Uid
  | Closure
  | Custom
  | Ordinal;

export function valueOfLib(x: View): Value {
  if (x instanceof lib.Eval_Value_view_V_true) return new True_(x);
  if (x instanceof lib.Eval_Value_view_V_false) return new False_(x);
  if (x instanceof lib.Eval_Value_view_V_int) return new Int(x.arg, x);
  if (x instanceof lib.Eval_Value_view_V_real) return new Real(new mir.Rational(x.arg[0], x.arg[1]), x);
  if (x instanceof lib.Eval_Value_view_V_string) return new String(x.arg, x);
  if (x instanceof lib.Eval_Value_view_V_cstor) {
    const [descriptor, args] = x.args;
    return new Constructor(
      descriptor.cd_name.name,
      Number(descriptor.cd_idx),
      args.map((a) => valueOfLib(a.v)),
      x,
    );
  }
  if (x instanceof lib.Eval_Value_view_V_tuple) {
    return new Tuple(
      x.arg.map((e) => valueOfLib(e.v)),
      x,
    );
  }
  if (x instanceof lib.Eval_Value_view_V_record) {
    const [descriptor, values] = x.args;
    // as Python's `zip`, which stops at the shorter of the two
    const n = Math.min(descriptor.rd_fields.length, values.length);
    const fields = new Map<string, Value>();
    for (let i = 0; i < n; i++) {
      fields.set(descriptor.rd_fields[i]!.name, valueOfLib(values[i]!.v));
    }
    return new Record(descriptor.rd_name.name, fields, x);
  }
  if (x instanceof lib.Eval_Value_view_V_quoted_term) {
    const [params, body] = x.arg;
    return new QuotedTerm(
      params.map((v) => mir.Variable.ofLib(v)),
      mir.termOfLib(body),
      x,
    );
  }
  if (x instanceof lib.Eval_Value_view_V_uid) return new Uid(new mir.Uid(x.arg), x);
  if (x instanceof lib.Eval_Value_view_V_closure) return new Closure(Number(x.arg.missing), x);
  if (x instanceof lib.Eval_Value_view_V_custom) return new Custom(x.arg, x);
  if (x instanceof lib.Eval_Value_view_V_ordinal) return new Ordinal(ordinalExprOfLib(x.arg), x);
  throw new UnexpectedResponseError(`unexpected value: ${(x as object).constructor.name}`);
}

export class IntOrdinal {
  readonly kind = "int";
  constructor(
    readonly value: bigint,
    readonly raw: lib.Eval_Ordinal,
  ) {}

  toString(): string {
    return `${this.value}`;
  }
}

/** `coefficient·ω^exponent + rest` */
export class ConsOrdinal {
  readonly kind = "cons";
  constructor(
    readonly exponent: OrdinalExpr,
    readonly coefficient: bigint,
    readonly rest: OrdinalExpr,
    readonly raw: lib.Eval_Ordinal,
  ) {}

  /** Cantor normal form, e.g. `2·ω^3 + ω + 5` */
  toString(): string {
    // as OCaml's `Ordinal.pp`
    const coefficient = this.coefficient === 1n ? "" : `${this.coefficient}·`;
    let power: string;
    if (this.exponent instanceof IntOrdinal) {
      power = this.exponent.value === 1n ? "" : `^${this.exponent}`;
    } else {
      power = `^(${this.exponent})`;
    }
    const rest =
      this.rest instanceof IntOrdinal && this.rest.value === 0n ? "" : ` + ${this.rest}`;
    return `${coefficient}ω${power}${rest}`;
  }
}

/** Ordinal type. */
export type OrdinalExpr = IntOrdinal | ConsOrdinal;

export function ordinalExprOfLib(x: lib.Eval_Ordinal): OrdinalExpr {
  if (x instanceof lib.Eval_Ordinal_Int) return new IntOrdinal(x.arg, x);
  if (x instanceof lib.Eval_Ordinal_Cons) {
    const [a, n, b] = x.args;
    return new ConsOrdinal(ordinalExprOfLib(a), n, ordinalExprOfLib(b), x);
  }
  throw new UnexpectedResponseError(`unexpected ordinal: ${(x as object).constructor.name}`);
}
