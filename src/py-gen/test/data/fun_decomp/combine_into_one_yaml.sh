#!/bin/bash

# Combine yamls into one for easy side-by-side review
combine_yamls() {
  if [[ -f combined.local.yaml ]]; then
      rm combined.local.yaml
      echo "Removed existing combined.local.yaml"
  fi
  yq eval-all '[.]' *.yaml > combined.local.yaml
  echo "Combined YAML files into combined.local.yaml"
}

# Run function by name
"$@"
