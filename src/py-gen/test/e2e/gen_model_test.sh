#!/usr/bin/env bash
set -euo pipefail

# Script to generate cram test cases from YAML files
# Usage: ./gen_model_test.sh

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DATA_DIR="$SCRIPT_DIR/../data/model"

# Print setup helper
cat <<'EOF'
Setup: Define helper function
  $ fence() { printf '```python\n'; cat; printf '```'; }
  $ run_test() { (
  >    cd $DUNE_SOURCEROOT/src/py-gen && \
  >    py-gen-parse-model "test/data/$1" - \
  >    | uv run py-gen - \
  >    | fence
  > ); }

EOF

# Find all YAML files and generate test cases
find "$TEST_DATA_DIR" -type f -name "*.yaml" | sort | while read -r yaml_file; do
    # Get relative path from test/data/
    rel_path="${yaml_file#$SCRIPT_DIR/../data/}"

    # Extract test name from YAML and capitalize first letter
    test_name=$(yq -r '.name' "$yaml_file" 2>/dev/null || basename "$yaml_file" .yaml)

    # Generate test case
    cat <<EOF
${test_name}
  \$ run_test ${rel_path}

EOF
done
