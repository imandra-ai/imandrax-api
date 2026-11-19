import { Client } from "imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

const res = await client.evalSrc(`
let f x = if x > 0 then x + 1 else 0

theorem f_nonneg x = f x >= 0
theorem f_increasing x = f x > x
instance (fun x -> f x = 43)

let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
[@@decomp top () |>> prune]
`);

// For a theorem, `instance` means a counterexample was found
for (const po of res.poResults) {
  console.log(po.origin.fromSym, po.outcome);
}
// f_nonneg proof
// f_increasing instance
// _instance_6_1 instance

for (const d of res.decompResults) {
  console.log(d.success, d.decomposition?.regions.length);
}
// true 3

// Task data and results are fetched on first use
const result = await res.poResults[0]!.task.result();
console.log(result.proved); // true
