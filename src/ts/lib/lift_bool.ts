/** Internal: `LiftBool` as requests send it */

import * as simplePb from "./raw/proto/simple_api.js";
import type { LiftBool } from "./tasks.js";

/** `x` as the protobuf enum that requests take */
export function liftBoolToPb(x: LiftBool | undefined): simplePb.LiftBool | undefined {
  switch (x) {
    case undefined:
      return undefined;
    case "default":
      return simplePb.LiftBool.Default;
    case "nestedEqualities":
      return simplePb.LiftBool.NestedEqualities;
    case "equalities":
      return simplePb.LiftBool.Equalities;
    case "all":
      return simplePb.LiftBool.All;
  }
}
