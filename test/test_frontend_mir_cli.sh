#!/usr/bin/env bash
set -euo pipefail

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/ffc-lower-frontend-v0.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT

input_file="$work_dir/input.sx"
output_file="$work_dir/output.sx"
repeat_file="$work_dir/repeat.sx"
rejected_input="$work_dir/rejected.sx"
rejected_output="$work_dir/rejected-output.sx"
diagnostic_file="$work_dir/diagnostic.txt"

printf '%s\n' '(frontend-result (status accepted) (root-kind program) (diagnostic-count 0))' >"$input_file"
printf '%s' '(mir-function (name main) (entry-block 0) (instruction-count 2) (instructions (instruction (id 0) (opcode add) (source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32))) (instruction (id 1) (opcode return) (source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32)))))' >"$output_file.expected"

fo exec ffc-lower-frontend-v0 "$input_file" "$output_file"
cmp -s "$output_file.expected" "$output_file"
fo exec ffc-lower-frontend-v0 "$input_file" "$repeat_file"
cmp -s "$output_file" "$repeat_file"

printf '%s\n' '(frontend-result (status rejected) (root-kind none) (diagnostic-count 1))' >"$rejected_input"
if fo exec ffc-lower-frontend-v0 "$rejected_input" "$rejected_output" \
    2>"$diagnostic_file"; then
    echo 'rejected frontend input unexpectedly succeeded' >&2
    exit 1
fi
if [[ -e "$rejected_output" ]]; then
    echo 'rejected frontend input created output' >&2
    exit 1
fi
grep -Fqx 'ffc-lower-frontend-v0: invalid frontend-v0 input: frontend-v0 status must be accepted' \
    "$diagnostic_file"

echo 'frontend to MIR CLI process controls: ok'
