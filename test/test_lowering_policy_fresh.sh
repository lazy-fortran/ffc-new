#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
generated=$(mktemp)
trap 'rm -f "$generated"' EXIT
python3 "$repo_dir/tools/generate_lowering_policy.py" \
    --spec "$repo_dir/spec/lowering_policy.toml" --output "$generated"
cmp -s "$generated" "$repo_dir/src/ffc_lowering_policy.f90"
echo 'lowering policy generator freshness: ok'
