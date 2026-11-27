import { Client } from "@imandra/imandrax-api";
import { setUidStyle, withUidStyle } from "@imandra/imandrax-api/uid_print_style";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

await client.evalSrc("let classify x = if x < 0 then -1 else 1");
const res = await client.decompose("classify");
if (res.decomposition === undefined)
  throw new Error(`decomposition failed: ${res.errors.join("\n")}`);

const region = res.decomposition.regions[0]!;
// Printed as is, `res.decomposition.id` is `classify/<hash>`

// Short names within the function
console.log(withUidStyle("short", () => `${res.decomposition!.id}`)); // classify

// Short names from now on, everywhere
setUidStyle("short");
console.log(`${region.constraints[0]}`); // (>= x 0)

setUidStyle("full"); // Back to the default
