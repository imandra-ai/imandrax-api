import { Client } from "imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

await client.evalSrc(`
let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
`);

const res = await client.decompose("fee", { prune: true, stringResults: true });
if (res.decomposition === undefined) throw new Error(`decomposition failed: ${res.errors.join("\n")}`);

for (const region of res.decomposition.regions) {
  // The sample input is keyed by each variable's unique ID; key it by name instead
  const input = Object.fromEntries([...(region.sample() ?? [])].map(([uid, v]) => [uid.shortName, v]));
  console.log(region.constraintsStr?.join(" && "), "|", region.invariantStr, "|", input, "|", region.sampleOutput());
}
// amount >= 100 | amount / 20 | { amount: 100n } | 5n
// amount >= 0 && amount <= 99 | 5 | { amount: 0n } | 5n
// amount <= (-1) | 0 | { amount: -1n } | 0n
