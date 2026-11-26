import { Client } from "@imandra/imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

// 1. Load IML definitions into the session
await client.evalSrc("let f x = if x > 0 then x + 1 else 0");

// 2. Prove a property for all inputs
const prop1 = await client.verifySrc("fun x -> f x >= 0");
console.log(prop1.proved); // true

// 3. Try to prove a wrong property, and get a counterexample
const prop2 = await client.verifySrc("fun x -> f x > x");
console.log(prop2.refuted); // true
console.log(prop2.counterExample?.src); // module M = struct let x = 0 end

// 4. Find an input satisfying a goal
const inst = await client.instanceSrc("fun x -> f x = 43");
console.log(inst.instance?.src); // module M = struct let x = 42 end
