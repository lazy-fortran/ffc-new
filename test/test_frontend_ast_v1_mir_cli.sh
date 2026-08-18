#!/usr/bin/env bash
set -euo pipefail

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/ffc-lower-frontend-ast-v1.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT

input_file="$work_dir/input.sx"
output_file="$work_dir/output.sx"
repeat_file="$work_dir/repeat.sx"
double_input_file="$work_dir/double-input.sx"
double_output_file="$work_dir/double-output.sx"
double_expected_file="$work_dir/double-expected.sx"
rejected_input="$work_dir/rejected.sx"
rejected_output="$work_dir/rejected-output.sx"
diagnostic_file="$work_dir/diagnostic.txt"

printf '%s' '(program-unit (root (program-root (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (declaration-count 1) (declaration (program-declaration (declaration-kind program) (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (variable-count 1) (variable (variable-declaration (type-spec real) (name x) (span (source-span (file unit.f90) (start-byte 10) (end-byte 24) (source-hash hash-unit))))))' >"$input_file"
printf '%s' '(mir-function (name main) (entry-block 0) (instruction-count 2) (instructions (instruction (id 0) (opcode add) (source-rule frontend-ast-v1/program) (result (id 1) (kind real) (type f32))) (instruction (id 1) (opcode return) (source-rule frontend-ast-v1/program) (result (id 1) (kind real) (type f32)))))' >"$output_file.expected"

fo exec ffc-lower-frontend-ast-v1 "$input_file" "$output_file"
cmp -s "$output_file.expected" "$output_file"
fo exec ffc-lower-frontend-ast-v1 "$input_file" "$repeat_file"
cmp -s "$output_file" "$repeat_file"

printf '%s' '(program-unit (root (program-root (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (declaration-count 1) (declaration (program-declaration (declaration-kind program) (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (variable-count 1) (variable (variable-declaration (type-spec double-precision) (name x) (span (source-span (file unit.f90) (start-byte 10) (end-byte 24) (source-hash hash-unit))))))' >"$double_input_file"
printf '%s' '(mir-function (name main) (entry-block 0) (instruction-count 2) (instructions (instruction (id 0) (opcode add) (source-rule frontend-ast-v1/program) (result (id 1) (kind real) (type f64))) (instruction (id 1) (opcode return) (source-rule frontend-ast-v1/program) (result (id 1) (kind real) (type f64)))))' >"$double_expected_file"
fo exec ffc-lower-frontend-ast-v1 "$double_input_file" "$double_output_file"
cmp -s "$double_expected_file" "$double_output_file"

printf '%s' '(program-unit (root (program-root (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (declaration-count 0) (declaration (program-declaration (declaration-kind program) (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (variable-count 1) (variable (variable-declaration (type-spec double-precision) (name x) (span (source-span (file unit.f90) (start-byte 10) (end-byte 24) (source-hash hash-unit))))))' >"$rejected_input"
if fo exec ffc-lower-frontend-ast-v1 "$rejected_input" "$rejected_output" 2>"$diagnostic_file"; then
    echo 'malformed AST-v1 count unexpectedly succeeded' >&2
    exit 1
fi
if [[ -e "$rejected_output" ]]; then
    echo 'malformed AST-v1 count created output' >&2
    exit 1
fi
grep -Fqx 'ffc-lower-frontend-ast-v1: invalid frontend-ast-v1 input: invalid-frontend-ast-v1-cardinality' \
    "$diagnostic_file"

printf '%s' '(program-unit (root (program-root (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (declaration-count 1) (declaration (program-declaration (declaration-kind program) (name main) (span (file unit.f90) (start-byte 0) (end-byte 64) (source-hash hash-unit)))) (variable-count 1) (variable (variable-declaration (type-spec unsupported) (name x) (span (source-span (file unit.f90) (start-byte 10) (end-byte 24) (source-hash hash-unit))))))' >"$rejected_input"
if fo exec ffc-lower-frontend-ast-v1 "$rejected_input" "$rejected_output" 2>"$diagnostic_file"; then
    echo 'unsupported AST-v1 type unexpectedly succeeded' >&2
    exit 1
fi
if [[ -e "$rejected_output" ]]; then
    echo 'unsupported AST-v1 type created output' >&2
    exit 1
fi
grep -Fqx 'ffc-lower-frontend-ast-v1: invalid frontend-ast-v1 input: unsupported-frontend-ast-v1-type-spec' \
    "$diagnostic_file"

printf '%s' '(program-unit' >"$rejected_input"
if fo exec ffc-lower-frontend-ast-v1 "$rejected_input" "$rejected_output" \
    2>"$diagnostic_file"; then
    echo 'malformed AST-v1 input unexpectedly succeeded' >&2
    exit 1
fi
if [[ -e "$rejected_output" ]]; then
    echo 'malformed AST-v1 input created output' >&2
    exit 1
fi
grep -Fqx 'ffc-lower-frontend-ast-v1: invalid frontend-ast-v1 input: malformed-frontend-ast-v0' \
    "$diagnostic_file"

echo 'frontend AST-v1 to MIR-v0 CLI process controls: ok'
