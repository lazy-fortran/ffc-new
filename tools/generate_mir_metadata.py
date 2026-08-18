#!/usr/bin/env python3
"""Generate the Fortran mir-v0 metadata module from its TOML specification."""

from __future__ import annotations

import argparse
import pathlib
import tomllib


def read_entries(data: dict, key: str) -> list[dict[str, int | str]]:
    entries = data.get(key, [])
    values = [entry["value"] for entry in entries]
    if values != list(range(1, len(values) + 1)):
        raise ValueError(f"{key} values must be contiguous starting at one")
    if len({entry["name"] for entry in entries}) != len(entries):
        raise ValueError(f"{key} names must be unique")
    return entries


def read_opcodes(data: dict) -> list[dict[str, int | str]]:
    entries = data.get("opcodes", [])
    values = [entry["value"] for entry in entries]
    if len(set(values)) != len(values) or any(value < 1 for value in values):
        raise ValueError("opcode values must be unique and positive")
    if len({entry["name"] for entry in entries}) != len(entries):
        raise ValueError("opcode names must be unique")
    return entries


def read_source_rules(data: dict) -> list[dict[str, str]]:
    entries = data.get("source_rules", [])
    names = [entry["name"] for entry in entries]
    values = [entry["value"] for entry in entries]
    if len(set(names)) != len(names):
        raise ValueError("source_rules names must be unique")
    if len(set(values)) != len(values):
        raise ValueError("source_rules values must be unique")
    return entries


def read_instruction_shapes(
    data: dict, opcodes: list[dict[str, int | str]], kinds: list[dict[str, int | str]],
    source_rules: list[dict[str, str]],
) -> list[dict[str, object]]:
    entries = data.get("instruction_shapes", [])
    opcode_names = {entry["name"] for entry in opcodes}
    kind_names = {entry["name"] for entry in kinds}
    source_rule_values = {entry["value"] for entry in source_rules}
    names = [entry["name"] for entry in entries]
    if len(set(names)) != len(names):
        raise ValueError("instruction_shapes names must be unique")
    for entry in entries:
        if not entry["opcodes"]:
            raise ValueError("instruction shape must contain instructions")
        if any(opcode not in opcode_names for opcode in entry["opcodes"]):
            raise ValueError("instruction shape contains an unknown opcode")
        if entry["result_kind"] not in kind_names:
            raise ValueError("instruction shape contains an unknown result kind")
        if entry["source_rule"] not in source_rule_values:
            raise ValueError("instruction shape contains an unknown source rule")
    return entries


def read_integer_expression_routes(
    data: dict,
    instruction_shapes: list[dict[str, object]],
    source_rules: list[dict[str, str]],
) -> list[dict[str, object]]:
    routes = data.get("integer_expression_routes", [])
    shape_names = {entry["name"] for entry in instruction_shapes}
    names = [entry["name"] for entry in routes]
    expressions = [entry["expression"] for entry in routes]
    if len(set(names)) != len(names) or len(set(expressions)) != len(expressions):
        raise ValueError("integer expression route names and expressions must be unique")
    for route in routes:
        if route["shape"] not in shape_names:
            raise ValueError("integer expression route contains an unknown shape")
        if "literal_values" in route and any(
            not isinstance(value, int) for value in route["literal_values"]
        ):
            raise ValueError("integer expression route literal values must be integers")
        if "result_ids" in route and any(
            not isinstance(value, int) for value in route["result_ids"]
        ):
            raise ValueError("integer expression route result ids must be integers")
        shape = next(shape for shape in instruction_shapes if shape["name"] == route["shape"])
        if "literal_values" in route and len(route["literal_values"]) != shape["opcodes"].count("const"):
            raise ValueError("integer expression route literal values must match const opcodes")
        if "result_ids" in route and len(route["result_ids"]) != len(shape["opcodes"]):
            raise ValueError("integer expression route result ids must match instruction count")
        if "storage_keys" in route:
            if len(route["storage_keys"]) != len(shape["opcodes"]):
                raise ValueError("integer expression route storage keys must match instruction count")
            if any(not isinstance(value, str) for value in route["storage_keys"]):
                raise ValueError("integer expression route storage keys must be strings")
            if any(value and any(character.isspace() for character in value) for value in route["storage_keys"]):
                raise ValueError("integer expression route storage keys must be SX atoms")
        if "source_rules" in route:
            if len(route["source_rules"]) != len(shape["opcodes"]):
                raise ValueError("integer expression route source rules must match instruction count")
            source_rule_values = {entry["value"] for entry in source_rules}
            if any(value not in source_rule_values for value in route["source_rules"]):
                raise ValueError("integer expression route contains an unknown source rule")
    return routes


def shape_symbol(shape: str, suffix: str) -> str:
    """Return a legal Fortran identifier for a generated shape member."""
    compact_shape = shape.replace("double_precision", "dp")
    return f"instruction_shape_{compact_shape}_{suffix}"


def fortran_case_literal(expression: str) -> list[str]:
    """Render a long route expression as a wrapped Fortran character literal."""
    chunk_length = 88
    chunks = [expression[index:index + chunk_length] for index in range(0, len(expression), chunk_length)]
    if len(chunks) == 1:
        return [f"        case ('{chunks[0]}');"]
    lines = [f"        case ('{chunks[0]}'// &"]
    lines.extend(f"                '{chunk}'// &" for chunk in chunks[1:-1])
    lines.append(f"                '{chunks[-1]}');")
    return lines


def generate(spec_path: pathlib.Path) -> str:
    with spec_path.open("rb") as stream:
        data = tomllib.load(stream)
    kinds = read_entries(data, "value_kinds")
    opcodes = read_opcodes(data)
    source_rules = read_source_rules(data)
    type_specs = data.get("type_specs", [])
    instruction_shapes = read_instruction_shapes(data, opcodes, kinds, source_rules)
    integer_expression_routes = read_integer_expression_routes(data, instruction_shapes, source_rules)
    shapes_by_name = {entry["name"]: entry for entry in instruction_shapes}
    kind_names = {entry["name"] for entry in kinds}
    type_spec_names = {entry["name"] for entry in type_specs}
    if len(type_spec_names) != len(type_specs):
        raise ValueError("type_specs names must be unique")
    for entry in type_specs:
        if entry["kind"] not in kind_names:
            raise ValueError(f"unknown type-spec kind: {entry['kind']}")
    lines = [
        "! Generated by tools/generate_mir_metadata.py; do not edit.",
        "module ffc_mir_metadata",
        "    use, intrinsic :: iso_fortran_env, only: int32",
        "    implicit none",
        "    private",
        "",
    ]
    for group, entries in (("value_kind", kinds), ("opcode", opcodes)):
        for entry in entries:
            lines.append(
                f"    integer(int32), parameter, public :: {group}_{entry['name']} = "
                f"{entry['value']}_int32"
            )
        lines.append("")
    for entry in source_rules:
        lines.append(
            f"    character(len={len(entry['value'])}), parameter, public :: "
            f"source_rule_{entry['name']} = '{entry['value']}'"
        )
    lines.append("")
    for entry in instruction_shapes:
        shape = entry["name"]
        lines.append(
            f"    integer(int32), parameter, public :: {shape_symbol(shape, 'count')} = "
            f"{len(entry['opcodes'])}_int32"
        )
        for index, opcode in enumerate(entry["opcodes"]):
            lines.append(
                f"    integer(int32), parameter, public :: "
                f"{shape_symbol(shape, f'opcode_{index}')} = opcode_{opcode}"
            )
        lines.append(
            f"    integer(int32), parameter, public :: "
            f"{shape_symbol(shape, 'result_kind')} = "
            f"value_kind_{entry['result_kind']}"
        )
        lines.append(
            f"    character(len={len(entry['result_type'])}), parameter, public :: "
            f"{shape_symbol(shape, 'result_type')} = '{entry['result_type']}'"
        )
        lines.append(
            f"    character(len={len(entry['source_rule'])}), parameter, public :: "
            f"{shape_symbol(shape, 'source_rule')} = '{entry['source_rule']}'"
        )
        lines.append("")
    lines += [
        "    integer(int32), parameter, public :: mir_opcode_histogram_size = &",
        f"        {max(entry['value'] for entry in opcodes)}_int32",
        "",
        "    public :: mir_opcode_name, mir_opcode_value",
        "    public :: mir_value_kind_name, mir_value_kind_value",
        "    public :: mir_type_spec_value_kind, mir_type_spec_name",
        "    public :: mir_source_rule_name, mir_source_rule_value",
        "    public :: mir_frontend_ast_v1_integer_expression_route",
        "    public :: mir_frontend_ast_v1_integer_expression_instruction_count",
        "    public :: mir_frontend_ast_v1_integer_expression_opcode",
        "    public :: mir_frontend_ast_v1_integer_expression_result_kind",
        "    public :: mir_frontend_ast_v1_integer_expression_result_type",
        "    public :: mir_frontend_ast_v1_integer_expression_source_rule",
        "    public :: mir_frontend_ast_v1_integer_expression_source_rule_at",
        "    public :: mir_frontend_ast_v1_integer_expression_literal_value",
        "    public :: mir_frontend_ast_v1_integer_expression_result_id",
        "    public :: mir_frontend_ast_v1_integer_expression_storage_key",
        "",
        "contains",
        "",
        "    character(len=32) function mir_opcode_name(opcode)",
        "        integer(int32), intent(in) :: opcode",
        "",
        "        select case (opcode)",
    ]
    for entry in opcodes:
        lines.append(
            f"        case (opcode_{entry['name']}); mir_opcode_name = '{entry['name']}'"
        )
    lines += [
        "        case default; mir_opcode_name = ''",
        "        end select",
        "    end function mir_opcode_name",
        "",
        "    integer(int32) function mir_opcode_value(name)",
        "        character(len=*), intent(in) :: name",
        "",
        "        select case (trim(name))",
    ]
    for entry in opcodes:
        lines.append(
            f"        case ('{entry['name']}'); mir_opcode_value = opcode_{entry['name']}"
        )
    lines += [
        "        case default; mir_opcode_value = 0_int32",
        "        end select",
        "    end function mir_opcode_value",
        "",
        "    character(len=32) function mir_value_kind_name(kind)",
        "        integer(int32), intent(in) :: kind",
        "",
        "        select case (kind)",
    ]
    for entry in kinds:
        lines.append(
            f"        case (value_kind_{entry['name']}); mir_value_kind_name = '{entry['name']}'"
        )
    lines += [
        "        case default; mir_value_kind_name = ''",
        "        end select",
        "    end function mir_value_kind_name",
        "",
        "    integer(int32) function mir_value_kind_value(name)",
        "        character(len=*), intent(in) :: name",
        "",
        "        select case (trim(name))",
    ]
    for entry in kinds:
        lines.append(
            f"        case ('{entry['name']}'); mir_value_kind_value = value_kind_{entry['name']}"
        )
    lines += [
        "        case default; mir_value_kind_value = 0_int32",
        "        end select",
        "    end function mir_value_kind_value",
        "",
        "    integer(int32) function mir_type_spec_value_kind(type_spec)",
        "        character(len=*), intent(in) :: type_spec",
        "",
        "        select case (trim(type_spec))",
    ]
    for entry in type_specs:
        lines.append(
            f"        case ('{entry['name']}'); mir_type_spec_value_kind = "
            f"value_kind_{entry['kind']}"
        )
    lines += [
        "        case default; mir_type_spec_value_kind = 0_int32",
        "        end select",
        "    end function mir_type_spec_value_kind",
        "",
        "    character(len=32) function mir_type_spec_name(type_spec)",
        "        character(len=*), intent(in) :: type_spec",
        "",
        "        select case (trim(type_spec))",
    ]
    for entry in type_specs:
        lines.append(
            f"        case ('{entry['name']}'); mir_type_spec_name = '{entry['type_name']}'"
        )
    lines += [
        "        case default; mir_type_spec_name = ''",
        "        end select",
        "    end function mir_type_spec_name",
        "",
        "    character(len=64) function mir_source_rule_name(source_rule)",
        "        character(len=*), intent(in) :: source_rule",
        "",
        "        select case (trim(source_rule))",
    ]
    for entry in source_rules:
        lines.append(
            f"        case (source_rule_{entry['name']}); "
            f"mir_source_rule_name = '{entry['name']}'"
        )
    lines += [
        "        case default; mir_source_rule_name = ''",
        "        end select",
        "    end function mir_source_rule_name",
        "",
        "    character(len=64) function mir_source_rule_value(name)",
        "        character(len=*), intent(in) :: name",
        "",
        "        select case (trim(name))",
    ]
    for entry in source_rules:
        lines.append(
            f"        case ('{entry['name']}'); mir_source_rule_value = "
            f"source_rule_{entry['name']}"
        )
    lines += [
        "        case default; mir_source_rule_value = ''",
        "        end select",
        "    end function mir_source_rule_value",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_route(expression)",
        "        character(len=*), intent(in) :: expression",
        "",
        "        select case (trim(expression))",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        route_case = fortran_case_literal(route["expression"])
        route_case[-1] += f" mir_frontend_ast_v1_integer_expression_route = {index}_int32"
        lines.extend(route_case)
    lines += [
        "        case default; mir_frontend_ast_v1_integer_expression_route = 0_int32",
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_route",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_instruction_count(route)",
        "        integer(int32), intent(in) :: route",
        "",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        shape = shapes_by_name[route["shape"]]
        lines.append(
            f"        case ({index}_int32); mir_frontend_ast_v1_integer_expression_instruction_count = "
            f"{shape_symbol(route['shape'], 'count')}"
        )
    lines += [
        "        case default; mir_frontend_ast_v1_integer_expression_instruction_count = 0_int32",
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_instruction_count",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_opcode(route, index)",
        "        integer(int32), intent(in) :: route, index",
        "",
        "        mir_frontend_ast_v1_integer_expression_opcode = 0_int32",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        shape = shapes_by_name[route["shape"]]
        lines.append(f"        case ({index}_int32)")
        lines.append("            select case (index)")
        for opcode_index in range(len(shape["opcodes"])):
            lines.append(
                f"            case ({opcode_index}_int32); "
                f"mir_frontend_ast_v1_integer_expression_opcode = "
                f"{shape_symbol(route['shape'], f'opcode_{opcode_index}')}"
            )
        lines.append("            end select")
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_opcode",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_result_kind(route)",
        "        integer(int32), intent(in) :: route",
        "",
        "        mir_frontend_ast_v1_integer_expression_result_kind = 0_int32",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(
            f"        case ({index}_int32); mir_frontend_ast_v1_integer_expression_result_kind = "
            f"{shape_symbol(route['shape'], 'result_kind')}"
        )
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_result_kind",
        "",
        "    character(len=32) function mir_frontend_ast_v1_integer_expression_result_type(route)",
        "        integer(int32), intent(in) :: route",
        "",
        "        mir_frontend_ast_v1_integer_expression_result_type = ''",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(
            f"        case ({index}_int32); mir_frontend_ast_v1_integer_expression_result_type = "
            f"{shape_symbol(route['shape'], 'result_type')}"
        )
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_result_type",
        "",
        "    character(len=64) function mir_frontend_ast_v1_integer_expression_source_rule(route)",
        "        integer(int32), intent(in) :: route",
        "",
        "        mir_frontend_ast_v1_integer_expression_source_rule = ''",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(
            f"        case ({index}_int32); mir_frontend_ast_v1_integer_expression_source_rule = "
            f"{shape_symbol(route['shape'], 'source_rule')}"
        )
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_source_rule",
        "",
        "    character(len=64) function mir_frontend_ast_v1_integer_expression_source_rule_at(route, index)",
        "        integer(int32), intent(in) :: route, index",
        "",
        "        mir_frontend_ast_v1_integer_expression_source_rule_at = &",
        "            mir_frontend_ast_v1_integer_expression_source_rule(route)",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        if "source_rules" not in route:
            continue
        lines.append(f"        case ({index}_int32)")
        lines.append("            select case (index)")
        for source_index, source_rule in enumerate(route["source_rules"]):
            lines.append(
                f"            case ({source_index}_int32); "
                f"mir_frontend_ast_v1_integer_expression_source_rule_at = '{source_rule}'"
            )
        lines.append("            end select")
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_source_rule_at",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_literal_value(route, index)",
        "        integer(int32), intent(in) :: route, index",
        "",
        "        mir_frontend_ast_v1_integer_expression_literal_value = 0_int32",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(f"        case ({index}_int32)")
        lines.append("            select case (index)")
        for literal_index, literal in enumerate(route.get("literal_values", [])):
            lines.append(
                f"            case ({literal_index}_int32); "
                f"mir_frontend_ast_v1_integer_expression_literal_value = {literal}_int32"
            )
        lines.append("            end select")
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_literal_value",
        "",
        "    integer(int32) function mir_frontend_ast_v1_integer_expression_result_id(route, index)",
        "        integer(int32), intent(in) :: route, index",
        "",
        "        mir_frontend_ast_v1_integer_expression_result_id = -1_int32",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(f"        case ({index}_int32)")
        lines.append("            select case (index)")
        for result_index, result_id in enumerate(route.get("result_ids", [])):
            lines.append(
                f"            case ({result_index}_int32); "
                f"mir_frontend_ast_v1_integer_expression_result_id = {result_id}_int32"
            )
        lines.append("            end select")
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_result_id",
        "",
        "    character(len=64) function mir_frontend_ast_v1_integer_expression_storage_key(route, index)",
        "        integer(int32), intent(in) :: route, index",
        "",
        "        mir_frontend_ast_v1_integer_expression_storage_key = ''",
        "        select case (route)",
    ]
    for index, route in enumerate(integer_expression_routes, start=1):
        lines.append(f"        case ({index}_int32)")
        lines.append("            select case (index)")
        for storage_index, storage_key in enumerate(route.get("storage_keys", [])):
            lines.append(
                f"            case ({storage_index}_int32); "
                f"mir_frontend_ast_v1_integer_expression_storage_key = '{storage_key}'"
            )
        lines.append("            end select")
    lines += [
        "        end select",
        "    end function mir_frontend_ast_v1_integer_expression_storage_key",
        "",
        "end module ffc_mir_metadata",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=pathlib.Path, default=pathlib.Path("spec/mir_metadata.toml"))
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(generate(args.spec), encoding="utf-8")


if __name__ == "__main__":
    main()
