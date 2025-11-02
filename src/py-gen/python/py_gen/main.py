"""Test the AST deserializer with out.json"""

from py_gen.ast_deserialize import load_from_json_string

# Load and deserialize
with open('out.json') as f:
    json_str = f.read()

stmts = load_from_json_string(json_str)

# Print results
print(f'Loaded {len(stmts)} statements:')
for i, stmt in enumerate(stmts):
    print(f'\n{i + 1}. {stmt.__class__.__name__}')
    print(f'   {stmt}')
