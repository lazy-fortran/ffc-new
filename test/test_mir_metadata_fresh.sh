#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
generated=$(mktemp)
trap 'rm -f "$generated"' EXIT
python3 "$repo_dir/tools/generate_mir_metadata.py" \
    --spec "$repo_dir/spec/mir_metadata.toml" --output "$generated"
cmp -s "$generated" "$repo_dir/src/ffc_mir_metadata.f90"
echo 'mir metadata generator freshness: ok'
