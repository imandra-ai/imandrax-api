/**
 * Whether uids print by short name or by full name (the default)
 *
 * @module
 */

export type UidStyle = "short" | "full";

const UID_STYLES: readonly UidStyle[] = ["short", "full"];

// The global style and the one `withUidStyle` overrides it with are kept apart, so that a
// `setUidStyle` inside `withUidStyle` still holds after it.
let globalStyle: UidStyle = "full";
let scopedStyle: UidStyle | undefined;

function checkUidStyle(style: UidStyle): void {
  if (!UID_STYLES.includes(style)) {
    throw new RangeError(`uid style must be one of ${UID_STYLES.join(", ")}, not ${String(style)}`);
  }
}

/** The style in effect: the one of an enclosing `withUidStyle`, else the global one */
export function getUidStyle(): UidStyle {
  return scopedStyle ?? globalStyle;
}

function isPromiseLike(x: unknown): x is PromiseLike<unknown> {
  return (
    (typeof x === "object" || typeof x === "function") &&
    x !== null &&
    typeof (x as { then?: unknown }).then === "function"
  );
}

/** Set the style globally; `withUidStyle` overrides it while its function runs */
export function setUidStyle(style: UidStyle): void {
  checkUidStyle(style);
  globalStyle = style;
}

/**
 * Run `f` with the style overridden, and return its result
 *
 * `f` must be synchronous: an `await` inside it would let other code run with the style
 * overridden. Passing a function that returns a promise is a type error, and throws a `TypeError`.
 */
export function withUidStyle<T>(
  style: UidStyle,
  f: () => T extends PromiseLike<unknown> ? never : T,
): T {
  checkUidStyle(style);
  const previous = scopedStyle;
  scopedStyle = style;
  let result: unknown;
  try {
    result = f();
  } finally {
    scopedStyle = previous;
  }
  if (isPromiseLike(result)) {
    throw new TypeError("withUidStyle takes a synchronous function, not one returning a promise");
  }
  return result as T;
}
