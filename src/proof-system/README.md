
# Proof format

This describes, in a machine readable way, the proof format we use for all
proofs.
A proof is a streamed DAG of steps, each of which can define new symbols,
declare a new proof step, or declare a new meta-proof step.

## References

Nodes in the proof DAG are associated with an _identifier_.
In practice the identifier can be a integer, string, or a list of these
(but the list can only contain integers or strings, not other lists).

Once a node is defined, it can be referred to using a _reference_.

## JSON file
In `spec.json`, we define all types relevant to the proof DAG.

Sections of the json file:

- `wire_types`: wire-level types that are used to encode individual DAG
nods in a concrete serialization format (e.g. CBOR).
- `dag_terms`: Each item defines a term constructor, used to build terms.
    Terms appear in some of the commands. Terms are typed, their types
    are described by `dag_types`.
- `dag_types`: The logical data types that are described by the DAG. Each
    term in the DAG has one of these types. Ultimately
    the goal of the proof DAG is to describe a `MProofStep` that corresponds
    to a theorem that we proved, ie its conclusion is the theorem's statement.
- `dag_type_defs`: Additional type definitions that are not built by terms.
- `commands`: Each command defines a node in the DAG, or defines some
    pervasively available object (e.g. a type definition). Commands
    for which field `defines_node` is true must carry a proper identifier
    on the wire, and associate this identifier to whatever it is they define.

    The proof DAG is made of a stream of commands.
- `builtin_symbols`: Symbols that are predefined in the logic, as well as their type.
    A type symbol is described as returning type `Type` (which otherwise doesn't exist in the logic).
    These exist, in a way, as if they were commands implicitly
    defined prior to the actual proof.

## CBOR

CBOR can be used to describe individual commands.

The recommended framing is to prefix each CBOR object by its size in bytes, as
a little-endian u32.

Mapping to wire types:

- `int`: CBOR int
- `bool`: CBOR bool
- `identifier`: CBOR int|string|list(int|string).
- `ref`: CBOR tag(7, <identifier>) at use point.
- `string`: CBOR text
- `bytes`: CBOR blob
- `list`: CBOR array
- `tuple`: CBOR array
