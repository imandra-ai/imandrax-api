
# Proof format

This describes the machine readable proof format we use for all
proofs.
A proof is a streamed DAG of nodes containing proof steps. Each step defines new symbols, declares a new proof step, or declares a deep proof step.
declare a new proof step, or declare a new deep sequent-level proof step.

## References

Nodes in the proof DAG are associated with an _identifier_.
The identifier is an integer, a string, or a list of these
(but the list can only contain integers or strings, not other lists).

Once a node is defined, it can be referred by its identifier.

## JSON file
In `spec.json`, we define all types relevant to the proof DAG.

Sections of the json file:

- `wire_types`: wire-level types that are used to encode individual DAG
    nodes in a concrete serialization format (e.g. CBOR).
- `dag_terms`: Each item defines a term constructor, used to build terms (nodes of the DAG).
    Terms are typed, their types are described by `dag_types`.
- `dag_types`: The logical data types that are described by the DAG. Each
    term in the DAG has one of these types. Ultimately
    the goal of the proof DAG is to describe a _`DeepProofStep`_ (a DAG node proving a deep sequent)
    that corresponds to a theorem that we proved, i.e. its conclusion is the theorem's statement.
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
