#!/usr/bin/env bash
set -euo pipefail

# Script to generate cram test cases from YAML files
# Usage: ./gen_model_test.sh

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DATA_DIR="$SCRIPT_DIR/../data/fun_decomp"

# Directories to exclude (space-separated list)
EXCLUDE_DIRS=""

# Print setup helper
cat <<'EOF'
Setup: Define helper function
  $ fence() { printf '```python\n'; cat; printf '```'; }
  $ run_test() { (
  >    cd $DUNE_SOURCEROOT/src/py-gen && \
  >    py-gen-parse-fun-decomp "test/data/fun_decomp/$1" - \
  >    | uv run py-gen - \
  >    | fence
  > ); }

EOF

# Build find command with exclusions
find_cmd="find \"$TEST_DATA_DIR\""
for exclude_dir in $EXCLUDE_DIRS; do
    find_cmd="$find_cmd -path \"$TEST_DATA_DIR/$exclude_dir\" -prune -o"
done
find_cmd="$find_cmd -type f -name \"*.yaml\" -print"

# Find all YAML files and generate test cases
eval "$find_cmd" | sort | while read -r yaml_file; do
    # Get relative path from test/data/
    rel_path="${yaml_file#$SCRIPT_DIR/../data/fun_decomp/}"

    # Extract test name from YAML and capitalize first letter
    test_name=$(yq -r '.name' "$yaml_file" 2>/dev/null || basename "$yaml_file" .yaml)

    # Generate test case
    cat <<EOF
${test_name}
  \$ run_test ${rel_path}
  expected output

EOF
done
