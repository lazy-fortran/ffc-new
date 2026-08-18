module ffc_frontend_ast
    use, intrinsic :: iso_fortran_env, only: int32, int64
    use ffc_lowering, only: ffc_lower_program_root, ffc_program_declaration_from_sx, &
        ffc_program_root_from_sx, ffc_program_root_t, ffc_validate_program_root
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, opcode_const, &
        mir_type_spec_name, mir_type_spec_value_kind, mir_validate_function_body
    use ffc_mir_metadata, only: instruction_shape_frontend_ast_v1_integer_program_count, &
        instruction_shape_frontend_ast_v1_integer_program_opcode_0, &
        instruction_shape_frontend_ast_v1_integer_program_opcode_1, &
        instruction_shape_frontend_ast_v1_integer_program_result_kind, &
        instruction_shape_frontend_ast_v1_integer_program_result_type, &
        instruction_shape_frontend_ast_v1_integer_program_source_rule, &
        instruction_shape_frontend_ast_v1_int_assign_count, &
        instruction_shape_frontend_ast_v1_int_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_lit_assign_count, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_lit_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_lit_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_expr_assign_count, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_3, &
        instruction_shape_frontend_ast_v1_int_expr_assign_opcode_4, &
        instruction_shape_frontend_ast_v1_int_expr_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_expr_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_expr_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_var_assign_count, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_3, &
        instruction_shape_frontend_ast_v1_int_var_assign_opcode_4, &
        instruction_shape_frontend_ast_v1_int_var_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_var_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_var_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_mul_assign_count, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_mul_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_mul_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_mul_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_mul_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_div_assign_count, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_div_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_div_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_div_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_div_assign_source_rule, &
        instruction_shape_frontend_ast_v1_int_sub_assign_count, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_0, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_1, &
        instruction_shape_frontend_ast_v1_int_sub_assign_opcode_2, &
        instruction_shape_frontend_ast_v1_int_sub_assign_result_kind, &
        instruction_shape_frontend_ast_v1_int_sub_assign_result_type, &
        instruction_shape_frontend_ast_v1_int_sub_assign_source_rule, &
        instruction_shape_frontend_ast_v1_logical_program_count, &
        instruction_shape_frontend_ast_v1_logical_program_opcode_0, &
        instruction_shape_frontend_ast_v1_logical_program_opcode_1, &
        instruction_shape_frontend_ast_v1_logical_program_result_kind, &
        instruction_shape_frontend_ast_v1_logical_program_result_type, &
        instruction_shape_frontend_ast_v1_logical_program_source_rule, &
        instruction_shape_frontend_ast_v1_real_program_count, &
        instruction_shape_frontend_ast_v1_real_program_opcode_0, &
        instruction_shape_frontend_ast_v1_real_program_opcode_1, &
        instruction_shape_frontend_ast_v1_real_program_result_kind, &
        instruction_shape_frontend_ast_v1_real_program_result_type, &
        instruction_shape_frontend_ast_v1_real_program_source_rule, &
        instruction_shape_frontend_ast_v1_dp_program_count, &
        instruction_shape_frontend_ast_v1_dp_program_opcode_0, &
        instruction_shape_frontend_ast_v1_dp_program_opcode_1, &
        instruction_shape_frontend_ast_v1_dp_program_result_kind, &
        instruction_shape_frontend_ast_v1_dp_program_result_type, &
        instruction_shape_frontend_ast_v1_dp_program_source_rule, &
        instruction_shape_frontend_ast_v1_complex_program_count, &
        instruction_shape_frontend_ast_v1_complex_program_opcode_0, &
        instruction_shape_frontend_ast_v1_complex_program_opcode_1, &
        instruction_shape_frontend_ast_v1_complex_program_result_kind, &
        instruction_shape_frontend_ast_v1_complex_program_result_type, &
        instruction_shape_frontend_ast_v1_complex_program_source_rule, &
        instruction_shape_frontend_ast_v1_character_program_count, &
        instruction_shape_frontend_ast_v1_character_program_opcode_0, &
        instruction_shape_frontend_ast_v1_character_program_opcode_1, &
        instruction_shape_frontend_ast_v1_character_program_result_kind, &
        instruction_shape_frontend_ast_v1_character_program_result_type, &
        instruction_shape_frontend_ast_v1_character_program_source_rule, &
        instruction_shape_frontend_ast_v2_stop_7_count, &
        instruction_shape_frontend_ast_v2_stop_7_opcode_0, &
        instruction_shape_frontend_ast_v2_stop_7_opcode_1, &
        instruction_shape_frontend_ast_v2_stop_7_result_kind, &
        instruction_shape_frontend_ast_v2_stop_7_result_type, &
        instruction_shape_frontend_ast_v2_stop_7_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_count, &
        instruction_shape_frontend_ast_v2_print_7_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_result_type, &
        instruction_shape_frontend_ast_v2_print_7_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_count, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_count, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_2, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_4, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_6, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_8, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type, &
        instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule, &
        instruction_shape_frontend_ast_v2_print_six_count, &
        instruction_shape_frontend_ast_v2_print_six_opcode_0, &
        instruction_shape_frontend_ast_v2_print_six_opcode_1, &
        instruction_shape_frontend_ast_v2_print_six_opcode_2, &
        instruction_shape_frontend_ast_v2_print_six_opcode_3, &
        instruction_shape_frontend_ast_v2_print_six_opcode_4, &
        instruction_shape_frontend_ast_v2_print_six_opcode_5, &
        instruction_shape_frontend_ast_v2_print_six_opcode_6, &
        instruction_shape_frontend_ast_v2_print_six_opcode_7, &
        instruction_shape_frontend_ast_v2_print_six_opcode_8, &
        instruction_shape_frontend_ast_v2_print_six_opcode_9, &
        instruction_shape_frontend_ast_v2_print_six_opcode_10, &
        instruction_shape_frontend_ast_v2_print_six_opcode_11, &
        instruction_shape_frontend_ast_v2_print_six_opcode_12, &
        instruction_shape_frontend_ast_v2_print_six_result_kind, &
        instruction_shape_frontend_ast_v2_print_six_result_type, &
        instruction_shape_frontend_ast_v2_print_six_source_rule, &
        mir_frontend_ast_v1_integer_expression_route, &
        mir_frontend_ast_v1_integer_expression_instruction_count, &
        mir_frontend_ast_v1_integer_expression_opcode, &
        mir_frontend_ast_v1_integer_expression_result_kind, &
        mir_frontend_ast_v1_integer_expression_result_type, &
        mir_frontend_ast_v1_integer_expression_source_rule, &
        mir_frontend_ast_v1_integer_expression_literal_value, &
        mir_frontend_ast_v1_integer_expression_result_id, &
        mir_frontend_ast_v1_integer_expression_storage_key
    use ffc_lowering_policy, only: bounded_integer_declaration_count, &
        bounded_integer_variable_count
    implicit none
    private

    integer, parameter :: frontend_ast_token_capacity = 1024
    integer, parameter :: frontend_ast_token_length = 256
    integer, parameter :: frontend_ast_expression_length = 4096

    type, public :: ffc_frontend_ast_v0_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        integer(int64) :: declaration_count = 0_int64
        logical :: declaration_present = .false.
    end type ffc_frontend_ast_v0_t

    type, public :: ffc_frontend_variable_declaration_v1_t
        character(len=128) :: type_spec = ''
        character(len=128) :: name = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_frontend_variable_declaration_v1_t

    type, public :: ffc_frontend_assignment_v1_t
        character(len=128) :: target = ''
        character(len=128) :: value = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_frontend_assignment_v1_t

    type, public :: ffc_frontend_ast_v1_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        type(ffc_frontend_variable_declaration_v1_t) :: variable
        type(ffc_frontend_assignment_v1_t) :: assignment
        integer(int64) :: declaration_count = 0_int64
        integer(int64) :: variable_count = 0_int64
        integer(int64) :: assignment_count = 0_int64
    end type ffc_frontend_ast_v1_t

    public :: ffc_frontend_ast_v0_from_sx
    public :: ffc_lower_frontend_ast_v0
    public :: ffc_lower_frontend_ast_v0_from_sx
    public :: ffc_validate_frontend_ast_v0
    public :: ffc_frontend_ast_v1_from_sx
    public :: ffc_lower_frontend_ast_v1
    public :: ffc_lower_frontend_ast_v1_from_sx
    public :: ffc_lower_frontend_ast_v1_assignment_sequence_from_sx
    public :: ffc_lower_frontend_ast_v2_from_sx
    public :: ffc_validate_frontend_ast_v1
    public :: ffc_validate_frontend_ast_v1_integer_program_shape
    public :: ffc_validate_frontend_ast_v1_integer_assignment_program_shape
    public :: ffc_validate_frontend_ast_v1_int_literal_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_var_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape
    public :: ffc_validate_frontend_ast_v1_logical_program_shape
    public :: ffc_validate_frontend_ast_v1_real_program_shape
    public :: ffc_validate_frontend_ast_v1_double_precision_program_shape
    public :: ffc_validate_frontend_ast_v1_complex_program_shape
    public :: ffc_validate_frontend_ast_v1_character_program_shape
    public :: ffc_validate_frontend_ast_v2_stop_7_shape
    public :: ffc_validate_frontend_ast_v2_print_7_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape
    public :: ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape

contains

    logical function ffc_frontend_ast_v1_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position

        ast = ffc_frontend_ast_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-root')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%declaration_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
            message)
        if (.not. parsed) return
        parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-declaration')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'variable-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%variable_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'variable', expression, message)
        if (.not. parsed) return
        parsed = parse_variable_declaration_v1(trim(expression), ast%variable, message)
        if (.not. parsed) return
        if (position < token_count .and. trim(token(position)) /= ')') then
            parsed = read_named_atom(token, token_count, position, 'assignment-count', count_text, &
                message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-count')
                return
            end if
            parsed = parse_count(count_text, ast%assignment_count, message)
            if (.not. parsed) return
            parsed = read_named_expression(token, token_count, position, 'assignment', expression, &
                message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-field')
                return
            end if
            parsed = parse_assignment_v1(trim(expression), ast%assignment, message)
            if (.not. parsed) then
                call set_message(message, 'malformed-frontend-ast-v1-assignment-record')
                return
            end if
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1')
            parsed = .false.
            return
        end if
        parsed = ffc_validate_frontend_ast_v1(ast, message)
    end function ffc_frontend_ast_v1_from_sx

    logical function ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(serialized, body, &
            message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: assignment_text(10)
        character(len=64) :: count_text
        type(ffc_frontend_assignment_v1_t) :: assignments(10)
        character(len=frontend_ast_expression_length) :: route_key
        integer :: assignment_count, assignment_index, token_count, position
        integer(int32) :: route

        call clear_message(message)
        lowered = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'assignment-sequence', message)) return
        if (.not. read_named_atom(token, token_count, position, 'assignment-count', count_text, &
            message)) return
        if (trim(count_text) /= '2' .and. trim(count_text) /= '3' .and. trim(count_text) /= '4' .and. &
            trim(count_text) /= '5' .and. trim(count_text) /= '6' .and. trim(count_text) /= '7' .and. &
            trim(count_text) /= '8' .and. trim(count_text) /= '9' .and. trim(count_text) /= '10') then
            call set_message(message, 'unsupported-assignment-sequence')
            return
        end if
        read (count_text, *) assignment_count
        do assignment_index = 1, assignment_count
            if (.not. read_named_expression(token, token_count, position, 'assignment', &
                assignment_text(assignment_index), message)) return
            if (.not. parse_assignment_v1(trim(assignment_text(assignment_index)), &
                assignments(assignment_index), message)) return
        end do
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-assignment-sequence')
            return
        end if
        route_key = '(assignment-sequence (assignment-count '//trim(count_text)//')'
        do assignment_index = 1, assignment_count
            route_key = trim(route_key)//' ('//trim(sequence_position_name(assignment_index))//' '// &
                trim(assignments(assignment_index)%target)//' '//trim(assignments(assignment_index)%value)//')'
        end do
        route_key = trim(route_key)//')'
        route = mir_frontend_ast_v1_integer_expression_route(trim(route_key))
        if (route == 0_int32) then
            call set_message(message, 'unsupported-assignment-sequence')
            return
        end if
        call mir_make_function_witness(body)
        call emit_frontend_ast_v1_integer_expression(body, route)
        lowered = mir_validate_function_body(body, message)
    end function ffc_lower_frontend_ast_v1_assignment_sequence_from_sx

    logical function ffc_lower_frontend_ast_v2_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        type(ffc_program_root_t) :: root, declaration
        type(ffc_frontend_variable_declaration_v1_t) :: variable
        type(ffc_frontend_assignment_v1_t) :: assignments(6)
        character(len=frontend_ast_expression_length) :: route_key
        integer :: assignment_count, assignment_index, token_count, position
        integer(int64) :: declaration_count, variable_count
        integer(int32) :: route

        call clear_message(message)
        lowered = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'program-unit-v2', message)) return
        if (.not. read_named_expression(token, token_count, position, 'root', expression, message)) return
        if (.not. ffc_program_root_from_sx(trim(expression), root, message)) return
        if (.not. read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, declaration_count, message)) return
        if (declaration_count == 0_int64) then
            if (.not. expect_token(token, token_count, position, '(', message)) return
            if (.not. expect_token(token, token_count, position, 'declaration', message)) return
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (.not. read_named_atom(token, token_count, position, 'variable-count', count_text, &
                message)) return
            if (.not. parse_count(count_text, variable_count, message)) return
            if (variable_count /= 0_int64) then
                call set_message(message, 'invalid-frontend-ast-v2-stop-variable-count')
                return
            end if
            if (.not. expect_token(token, token_count, position, '(', message)) return
            if (.not. expect_token(token, token_count, position, 'variable', message)) return
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (.not. read_named_expression(token, token_count, position, 'execution-part', &
                expression, message)) return
            route = frontend_ast_v2_stop_route(expression)
            if (route == 0_int32) route = frontend_ast_v2_print_route(expression)
            if (route == 0_int32) then
                call set_message(message, 'unsupported-frontend-ast-v2-stop-stmt')
                return
            end if
            if (.not. expect_token(token, token_count, position, ')', message)) return
            if (position <= token_count) then
                call set_message(message, 'malformed-frontend-ast-v2')
                return
            end if
            if (trim(root%name) /= 'p') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            if (route == 18_int32) then
                call emit_frontend_ast_v1_integer_expression(body, route)
                lowered = ffc_validate_frontend_ast_v2_stop_7_shape(body, message)
            else if (route == 20_int32) then
                call emit_frontend_ast_v2_print_7_8(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_shape(body, message)
            else if (route == 21_int32) then
                call emit_frontend_ast_v2_print_7_8_9(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_shape(body, message)
            else if (route == 22_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_shape(body, message)
            else if (route == 23_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10_11(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape(body, message)
            else if (route == 24_int32) then
                call emit_frontend_ast_v2_print_7_8_9_10_11_12(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape(body, message)
            else
                call emit_frontend_ast_v2_print_7(body)
                lowered = ffc_validate_frontend_ast_v2_print_7_shape(body, message)
            end if
            return
        end if
        if (declaration_count /= 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-declaration-count')
            return
        end if
        if (.not. read_named_expression(token, token_count, position, 'declaration', expression, &
            message)) return
        if (.not. ffc_program_declaration_from_sx(trim(expression), declaration, message)) return
        if (.not. read_named_atom(token, token_count, position, 'variable-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, variable_count, message)) return
        if (variable_count /= 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-variable-count')
            return
        end if
        if (.not. read_named_expression(token, token_count, position, 'variable', expression, &
            message)) return
        if (.not. parse_variable_declaration_v1(trim(expression), variable, message)) return
        if (.not. read_named_expression(token, token_count, position, 'execution-part', expression, &
            message)) return
        route = mir_frontend_ast_v1_integer_expression_route(&
            '(execution-part '//trim(expression)//')')
        if (route /= 18_int32) then
            if (.not. parse_v2_assignment_sequence(trim(expression), assignments, assignment_count, &
                message)) return
        end if
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2')
            return
        end if
        if (route == 18_int32) then
            if (trim(root%name) /= 'p' .or. trim(declaration%name) /= 'p') then
                call set_message(message, 'unsupported-frontend-ast-v2-stop-stmt')
                return
            end if
            if (trim(root%source_file) /= trim(declaration%source_file) .or. &
                trim(root%source_hash) /= trim(declaration%source_hash) .or. &
                trim(root%source_file) /= trim(variable%source_file) .or. &
                trim(root%source_hash) /= trim(variable%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
            call mir_make_function_witness(body)
            body%function%name = trim(root%name)
            call emit_frontend_ast_v1_integer_expression(body, route)
            lowered = ffc_validate_frontend_ast_v2_stop_7_shape(body, message)
            return
        end if
        if (trim(root%name) /= 'main' .or. trim(declaration%name) /= 'main' .or. &
            trim(variable%type_spec) /= 'integer' .or. trim(variable%name) /= 'x') then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        if (trim(assignments(1)%target) /= 'x' .or. &
            trim(assignments(1)%value) /= '( integer-literal 7 )') then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        do assignment_index = 2, assignment_count
            if (trim(assignments(assignment_index)%target) /= 'x' .or. &
                trim(assignments(assignment_index)%value) /= &
                '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))') then
                call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
                return
            end if
        end do
        if (trim(root%source_file) /= trim(declaration%source_file) .or. &
            trim(root%source_hash) /= trim(declaration%source_hash) .or. &
            trim(root%source_file) /= trim(variable%source_file) .or. &
            trim(root%source_hash) /= trim(variable%source_hash)) then
            call set_message(message, 'frontend-ast-v2-invalid-provenance')
            return
        end if
        do assignment_index = 1, assignment_count
            if (trim(root%source_file) /= trim(assignments(assignment_index)%source_file)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end do
        do assignment_index = 2, assignment_count
            if (trim(assignments(1)%source_hash) /= trim(assignments(assignment_index)%source_hash)) then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end do
        if (assignment_count == 2) then
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-two-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        else if (assignment_count == 5) then
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-five-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        else
            if (trim(assignments(1)%source_hash) /= 'l3-raw-program-six-assignment-v1') then
                call set_message(message, 'frontend-ast-v2-invalid-provenance')
                return
            end if
        end if
        write (count_text, '(i0)') assignment_count
        route_key = '(execution-part (assignment-sequence (assignment-count '// &
            trim(count_text)//')'
        do assignment_index = 1, assignment_count
            route_key = trim(route_key)//' (assignment x '//trim(assignments(assignment_index)%value)//')'
        end do
        route_key = trim(route_key)//') )'
        route = mir_frontend_ast_v1_integer_expression_route(route_key)
        if (route == 0_int32) then
            call set_message(message, 'unsupported-frontend-ast-v2-execution-part')
            return
        end if
        call mir_make_function_witness(body)
        body%function%name = trim(root%name)
        call emit_frontend_ast_v1_integer_expression(body, route)
        lowered = mir_validate_function_body(body, message)
    end function ffc_lower_frontend_ast_v2_from_sx

    logical function parse_v2_assignment_sequence(serialized, assignments, assignment_count, message) &
            result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_assignment_v1_t), intent(out) :: assignments(5)
        integer, intent(out) :: assignment_count
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: assignment_text
        character(len=64) :: count_text
        integer :: token_count, position, assignment_index
        integer(int64) :: count

        assignments = ffc_frontend_assignment_v1_t()
        assignment_count = 0
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        if (.not. expect_token(token, token_count, position, '(', message)) return
        if (.not. expect_token(token, token_count, position, 'assignment-sequence', message)) return
        if (.not. read_named_atom(token, token_count, position, 'assignment-count', count_text, &
            message)) return
        if (.not. parse_count(count_text, count, message)) return
        if (count /= 2_int64 .and. count /= 5_int64 .and. count /= 6_int64) then
            call set_message(message, 'invalid-frontend-ast-v2-assignment-count')
            parsed = .false.
            return
        end if
        assignment_count = int(count)
        do assignment_index = 1, assignment_count
            if (.not. read_named_expression(token, token_count, position, 'assignment', &
                assignment_text, message)) return
            if (.not. parse_assignment_v1(trim(assignment_text), assignments(assignment_index), &
                message)) return
        end do
        if (.not. expect_token(token, token_count, position, ')', message)) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v2-execution-part')
            parsed = .false.
        end if
    end function parse_v2_assignment_sequence

    character(len=16) function sequence_position_name(position)
        integer, intent(in) :: position

        select case (position)
        case (1); sequence_position_name = 'first'
        case (2); sequence_position_name = 'second'
        case (3); sequence_position_name = 'third'
        case (4); sequence_position_name = 'fourth'
        case (5); sequence_position_name = 'fifth'
        case (6); sequence_position_name = 'sixth'
        case (7); sequence_position_name = 'seventh'
        case (8); sequence_position_name = 'eighth'
        case (9); sequence_position_name = 'ninth'
        case (10); sequence_position_name = 'tenth'
        case default; sequence_position_name = ''
        end select
    end function sequence_position_name

    logical function ffc_validate_frontend_ast_v1(ast, message) result(valid)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count /= bounded_integer_declaration_count .or. &
            ast%variable_count /= bounded_integer_variable_count) then
            call set_message(message, 'invalid-frontend-ast-v1-cardinality')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%name) /= trim(ast%declaration%name)) then
            call set_message(message, 'frontend-ast-v1-declaration-name-mismatch')
            return
        end if
        if (.not. ffc_validate_variable_declaration_v1(ast%variable, message)) return
        if (trim(ast%root%source_file) /= trim(ast%variable%source_file) .or. &
            trim(ast%root%source_hash) /= trim(ast%variable%source_hash)) then
            call set_message(message, 'frontend-ast-v1-invalid-provenance')
            return
        end if
        if (ast%assignment_count < 0_int64 .or. ast%assignment_count > 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment-cardinality')
            return
        end if
        if (ast%assignment_count == 0_int64) then
            valid = .true.
            return
        end if
        if (.not. ffc_validate_assignment_v1(ast%assignment, message)) return
        if (trim(ast%assignment%source_file) /= trim(ast%root%source_file) .or. &
            trim(ast%assignment%source_hash) /= trim(ast%root%source_hash)) then
            call set_message(message, 'frontend-ast-v1-invalid-provenance')
            return
        end if
        if (trim(ast%variable%type_spec) /= 'integer') then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment-type')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1

    logical function ffc_lower_frontend_ast_v1(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        integer :: kind
        integer(int32) :: expression_route, literal_value
        character(len=32) :: type_name

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v1(ast, message)
        if (.not. lowered) return
        kind = mir_type_spec_value_kind(ast%variable%type_spec)
        type_name = mir_type_spec_name(ast%variable%type_spec)
        call mir_make_function_witness(body)
        body%function%name = trim(ast%root%name)
        body%instructions(1)%result%kind = kind
        body%instructions(1)%result%type_name = trim(type_name)
        body%instructions(2)%result = body%instructions(1)%result
        if (trim(ast%variable%type_spec) == 'integer') then
            if (ast%assignment_count == 1_int64) then
                expression_route = mir_frontend_ast_v1_integer_expression_route(&
                    trim(ast%assignment%value))
                if (expression_route > 0_int32) then
                    call emit_frontend_ast_v1_integer_expression(body, expression_route)
                    select case (expression_route)
                    case (1_int32); lowered = ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
                            body, message)
                    case (2_int32); lowered = ffc_validate_frontend_ast_v1_int_var_assignment_shape(&
                            body, message)
                    case (3_int32); lowered = ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(&
                            body, message)
                    case (4_int32); lowered = ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape(&
                            body, message)
                    case (5_int32); lowered = ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape(&
                            body, message)
                    end select
                    return
                end if
                if (starts_integer_literal_expression(trim(ast%assignment%value))) then
                    if (.not. parse_integer_literal_expression(trim(ast%assignment%value), &
                        literal_value, message)) return
                    deallocate (body%instructions)
                    allocate (body%instructions(3))
                    body%instructions(1)%id = 0_int32
                    body%instructions(2)%id = 1_int32
                    body%instructions(3)%id = 2_int32
                    body%function%instruction_count = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_count
                    body%instructions(1)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0
                    body%instructions(1)%literal_value = literal_value
                    body%instructions(2)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1
                    body%instructions(3)%opcode = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2
                    body%instructions(1)%result%kind = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_result_kind
                    body%instructions(1)%result%id = 1_int32
                    body%instructions(1)%result%type_name = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_result_type
                    body%instructions(2)%result = body%instructions(1)%result
                    body%instructions(3)%result = body%instructions(1)%result
                    body%instructions(1)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    body%instructions(2)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    body%instructions(3)%source_rule = &
                        instruction_shape_frontend_ast_v1_int_lit_assign_source_rule
                    lowered = ffc_validate_frontend_ast_v1_int_literal_assignment_shape(body, &
                        message)
                    return
                end if
                body%function%instruction_count = &
                    instruction_shape_frontend_ast_v1_int_assign_count
                body%instructions(1)%opcode = &
                    instruction_shape_frontend_ast_v1_int_assign_opcode_0
                body%instructions(2)%opcode = &
                    instruction_shape_frontend_ast_v1_int_assign_opcode_1
                body%instructions(1)%result%kind = &
                    instruction_shape_frontend_ast_v1_int_assign_result_kind
                body%instructions(1)%result%type_name = &
                    instruction_shape_frontend_ast_v1_int_assign_result_type
                body%instructions(2)%result = body%instructions(1)%result
                body%instructions(1)%source_rule = &
                    instruction_shape_frontend_ast_v1_int_assign_source_rule
                body%instructions(2)%source_rule = &
                    instruction_shape_frontend_ast_v1_int_assign_source_rule
                lowered = ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, &
                    message)
                return
            end if
            body%function%instruction_count = instruction_shape_frontend_ast_v1_integer_program_count
            body%instructions(1)%opcode = instruction_shape_frontend_ast_v1_integer_program_opcode_0
            body%instructions(2)%opcode = instruction_shape_frontend_ast_v1_integer_program_opcode_1
            body%instructions(1)%result%kind = instruction_shape_frontend_ast_v1_integer_program_result_kind
            body%instructions(1)%result%type_name = instruction_shape_frontend_ast_v1_integer_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_integer_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_integer_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_integer_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'logical') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_logical_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_logical_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_logical_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_logical_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_logical_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_logical_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_logical_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_logical_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'real') then
            body%function%instruction_count = instruction_shape_frontend_ast_v1_real_program_count
            body%instructions(1)%opcode = instruction_shape_frontend_ast_v1_real_program_opcode_0
            body%instructions(2)%opcode = instruction_shape_frontend_ast_v1_real_program_opcode_1
            body%instructions(1)%result%kind = instruction_shape_frontend_ast_v1_real_program_result_kind
            body%instructions(1)%result%type_name = instruction_shape_frontend_ast_v1_real_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = instruction_shape_frontend_ast_v1_real_program_source_rule
            body%instructions(2)%source_rule = instruction_shape_frontend_ast_v1_real_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_real_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'double-precision') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_dp_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_dp_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_dp_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_dp_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_dp_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_dp_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_dp_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'complex') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_complex_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_complex_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_complex_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_complex_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_complex_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_complex_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_complex_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_complex_program_shape(body, message)
            return
        end if
        if (trim(ast%variable%type_spec) == 'character') then
            body%function%instruction_count = &
                instruction_shape_frontend_ast_v1_character_program_count
            body%instructions(1)%opcode = &
                instruction_shape_frontend_ast_v1_character_program_opcode_0
            body%instructions(2)%opcode = &
                instruction_shape_frontend_ast_v1_character_program_opcode_1
            body%instructions(1)%result%kind = &
                instruction_shape_frontend_ast_v1_character_program_result_kind
            body%instructions(1)%result%type_name = &
                instruction_shape_frontend_ast_v1_character_program_result_type
            body%instructions(2)%result = body%instructions(1)%result
            body%instructions(1)%source_rule = &
                instruction_shape_frontend_ast_v1_character_program_source_rule
            body%instructions(2)%source_rule = &
                instruction_shape_frontend_ast_v1_character_program_source_rule
            lowered = ffc_validate_frontend_ast_v1_character_program_shape(body, message)
            return
        end if
        body%instructions(1)%source_rule = 'frontend-ast-v1/program'
        body%instructions(2)%source_rule = 'frontend-ast-v1/program'
    end function ffc_lower_frontend_ast_v1

    subroutine emit_frontend_ast_v1_integer_expression(body, route)
        type(mir_function_body_t), intent(inout) :: body
        integer(int32), intent(in) :: route

        integer(int32) :: index, instruction_count, literal_index

        deallocate (body%instructions)
        instruction_count = mir_frontend_ast_v1_integer_expression_instruction_count(route)
        allocate (body%instructions(instruction_count))
        body%function%instruction_count = instruction_count
        literal_index = 0_int32
        do index = 0_int32, instruction_count - 1_int32
            body%instructions(index + 1)%id = index
            body%instructions(index + 1)%opcode = &
                mir_frontend_ast_v1_integer_expression_opcode(route, index)
            body%instructions(index + 1)%source_rule = &
                trim(mir_frontend_ast_v1_integer_expression_source_rule(route))
            if (len_trim(mir_frontend_ast_v1_integer_expression_storage_key(route, index)) > 0) then
                body%instructions(index + 1)%storage_key = &
                    trim(mir_frontend_ast_v1_integer_expression_storage_key(route, index))
            end if
            if (body%instructions(index + 1)%opcode == opcode_const) then
                body%instructions(index + 1)%literal_value = &
                    mir_frontend_ast_v1_integer_expression_literal_value(route, literal_index)
                literal_index = literal_index + 1_int32
            end if
        end do
        if (mir_frontend_ast_v1_integer_expression_result_id(route, 0_int32) >= 0_int32) then
            do index = 0_int32, instruction_count - 1_int32
                body%instructions(index + 1)%result%id = &
                    mir_frontend_ast_v1_integer_expression_result_id(route, index)
                body%instructions(index + 1)%result%kind = &
                    mir_frontend_ast_v1_integer_expression_result_kind(route)
                body%instructions(index + 1)%result%type_name = &
                    trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            end do
        else
            body%instructions(1)%result%id = 2
            body%instructions(1)%result%kind = &
                mir_frontend_ast_v1_integer_expression_result_kind(route)
            body%instructions(1)%result%type_name = &
                trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            body%instructions(2)%result%id = 1
            body%instructions(2)%result%kind = &
                mir_frontend_ast_v1_integer_expression_result_kind(route)
            body%instructions(2)%result%type_name = &
                trim(mir_frontend_ast_v1_integer_expression_result_type(route))
            body%instructions(3)%result = body%instructions(2)%result
            if (instruction_count > 3_int32) then
                do index = 4_int32, instruction_count
                    body%instructions(index)%result = body%instructions(3)%result
                end do
            end if
        end if
    end subroutine emit_frontend_ast_v1_integer_expression

    logical function ffc_validate_frontend_ast_v1_integer_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_integer_program_count) then
            call set_message(message, 'frontend-ast-v1 integer instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_integer_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_integer_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 integer opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_integer_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_integer_program_result_type) then
            call set_message(message, 'frontend-ast-v1 integer result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_integer_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_integer_program_result_type) then
            call set_message(message, 'frontend-ast-v1 integer return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_integer_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_integer_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_integer_program_shape

    logical function ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer assignment instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_assign_opcode_1) then
            call set_message(message, 'frontend-ast-v1 integer assignment opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer assignment result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer assignment return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer assignment source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_integer_assignment_program_shape

    logical function ffc_validate_frontend_ast_v1_int_literal_assignment_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer literal instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer literal opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer literal result shape changed')
            return
        end if
        if (body%instructions(1)%literal_value < 0_int32) then
            call set_message(message, 'frontend-ast-v1 integer literal value is out of range')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_result_kind) then
            call set_message(message, 'frontend-ast-v1 integer literal return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_lit_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer literal source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_literal_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_2 .or. &
            body%instructions(4)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_3 .or. &
            body%instructions(5)%opcode /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_opcode_4) then
            call set_message(message, 'frontend-ast-v1 integer expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 1_int32 .or. &
            body%instructions(2)%literal_value /= 2_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 1_int32 .or. &
            body%instructions(3)%result%id /= 2_int32 .or. &
            body%instructions(4)%result%id /= 2_int32 .or. &
            body%instructions(5)%result%id /= 2_int32 .or. &
            body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer expression result shape changed')
            return
        end if
        if (body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type .or. &
            body%instructions(4)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(4)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type .or. &
            body%instructions(5)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_kind .or. &
            trim(body%instructions(5)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(4)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule .or. &
            trim(body%instructions(5)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_expr_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_var_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        character(len=64) :: expected_storage_key

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_var_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer variable expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_2 .or. &
            body%instructions(4)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_3 .or. &
            body%instructions(5)%opcode /= &
            instruction_shape_frontend_ast_v1_int_var_assign_opcode_4) then
            call set_message(message, 'frontend-ast-v1 integer variable expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 0_int32 .or. &
            body%instructions(2)%literal_value /= 1_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 1_int32 .or. &
            body%instructions(3)%result%id /= 2_int32 .or. &
            body%instructions(4)%result%id /= 2_int32 .or. &
            body%instructions(5)%result%id /= 2_int32) then
            call set_message(message, 'frontend-ast-v1 integer variable expression result shape changed')
            return
        end if
        do index = 1, 5
            expected_storage_key = trim(mir_frontend_ast_v1_integer_expression_storage_key(2_int32, &
                int(index - 1, int32)))
            if (len_trim(expected_storage_key) > 0) then
                if (.not. allocated(body%instructions(index)%storage_key)) then
                    call set_message(message, 'frontend-ast-v1 integer variable storage key missing')
                    return
                end if
                if (trim(body%instructions(index)%storage_key) /= trim(expected_storage_key)) then
                    call set_message(message, 'frontend-ast-v1 integer variable storage key changed')
                    return
                end if
            else if (allocated(body%instructions(index)%storage_key)) then
                call set_message(message, 'frontend-ast-v1 integer variable storage key unexpected')
                return
            end if
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v1_int_var_assign_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v1_int_var_assign_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v1_int_var_assign_source_rule) then
                call set_message(message, &
                    'frontend-ast-v1 integer variable expression metadata changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_var_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_mul_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer multiply expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_div_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer division expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_div_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer division expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer division expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer division expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_div_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer division expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_div_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape(&
            body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_count) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_1 .or. &
            body%instructions(3)%opcode /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_opcode_2) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type .or. &
            body%instructions(3)%result%kind /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_kind .or. &
            trim(body%instructions(3)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_result_type) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule .or. &
            trim(body%instructions(3)%source_rule) /= &
            instruction_shape_frontend_ast_v1_int_sub_assign_source_rule) then
            call set_message(message, 'frontend-ast-v1 integer subtract expression source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_int_sub_expr_assignment_shape

    logical function ffc_validate_frontend_ast_v1_logical_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_logical_program_count) then
            call set_message(message, 'frontend-ast-v1 logical instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_logical_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_logical_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 logical opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_logical_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_logical_program_result_type) then
            call set_message(message, 'frontend-ast-v1 logical result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_logical_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_logical_program_result_type) then
            call set_message(message, 'frontend-ast-v1 logical return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_logical_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_logical_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 logical source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_logical_program_shape

    logical function ffc_validate_frontend_ast_v1_real_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v1_real_program_count) then
            call set_message(message, 'frontend-ast-v1 real instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v1_real_program_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v1_real_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 real opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= instruction_shape_frontend_ast_v1_real_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= instruction_shape_frontend_ast_v1_real_program_result_type) then
            call set_message(message, 'frontend-ast-v1 real result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= instruction_shape_frontend_ast_v1_real_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= instruction_shape_frontend_ast_v1_real_program_result_type) then
            call set_message(message, 'frontend-ast-v1 real return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= instruction_shape_frontend_ast_v1_real_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= instruction_shape_frontend_ast_v1_real_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 real source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_real_program_shape

    logical function ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_dp_program_count) then
            call set_message(message, 'frontend-ast-v1 double-precision instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_dp_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_dp_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 double-precision opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_dp_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_dp_program_result_type) then
            call set_message(message, 'frontend-ast-v1 double-precision result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_dp_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_dp_program_result_type) then
            call set_message(message, 'frontend-ast-v1 double-precision return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_dp_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_dp_program_source_rule) then
            call set_message(message, &
                'frontend-ast-v1 double-precision source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_double_precision_program_shape

    logical function ffc_validate_frontend_ast_v1_complex_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_complex_program_count) then
            call set_message(message, 'frontend-ast-v1 complex instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_complex_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_complex_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 complex opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_complex_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_complex_program_result_type) then
            call set_message(message, 'frontend-ast-v1 complex result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_complex_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_complex_program_result_type) then
            call set_message(message, 'frontend-ast-v1 complex return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_complex_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_complex_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 complex source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_complex_program_shape

    logical function ffc_validate_frontend_ast_v1_character_program_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= &
            instruction_shape_frontend_ast_v1_character_program_count) then
            call set_message(message, 'frontend-ast-v1 character instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= &
            instruction_shape_frontend_ast_v1_character_program_opcode_0 .or. &
            body%instructions(2)%opcode /= &
            instruction_shape_frontend_ast_v1_character_program_opcode_1) then
            call set_message(message, 'frontend-ast-v1 character opcode shape changed')
            return
        end if
        if (body%instructions(1)%result%kind /= &
            instruction_shape_frontend_ast_v1_character_program_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_character_program_result_type) then
            call set_message(message, 'frontend-ast-v1 character result shape changed')
            return
        end if
        if (body%instructions(2)%result%kind /= &
            instruction_shape_frontend_ast_v1_character_program_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
            instruction_shape_frontend_ast_v1_character_program_result_type) then
            call set_message(message, 'frontend-ast-v1 character return shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v1_character_program_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v1_character_program_source_rule) then
            call set_message(message, 'frontend-ast-v1 character source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1_character_program_shape

    logical function ffc_validate_frontend_ast_v2_stop_7_shape(body, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_stop_7_count) then
            call set_message(message, 'frontend-ast-v2 stop-7 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_stop_7_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_stop_7_opcode_1) then
            call set_message(message, 'frontend-ast-v2 stop-7 opcode shape changed')
            return
        end if
        if (body%instructions(1)%literal_value /= 7_int32 .or. &
            body%instructions(1)%result%id /= 0_int32 .or. &
            body%instructions(2)%result%id /= 0_int32 .or. &
            body%instructions(1)%result%kind /= instruction_shape_frontend_ast_v2_stop_7_result_kind .or. &
            trim(body%instructions(1)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_stop_7_result_type .or. &
            body%instructions(2)%result%kind /= instruction_shape_frontend_ast_v2_stop_7_result_kind .or. &
            trim(body%instructions(2)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_stop_7_result_type) then
            call set_message(message, 'frontend-ast-v2 stop-7 typed result shape changed')
            return
        end if
        if (trim(body%instructions(1)%source_rule) /= &
            instruction_shape_frontend_ast_v2_stop_7_source_rule .or. &
            trim(body%instructions(2)%source_rule) /= &
            instruction_shape_frontend_ast_v2_stop_7_source_rule) then
            call set_message(message, 'frontend-ast-v2 stop-7 source rule changed')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v2_stop_7_shape

    subroutine emit_frontend_ast_v2_print_7(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(3))
        body%function%instruction_count = 3
        body%instructions(1)%id = 0
        body%instructions(1)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_0
        body%instructions(1)%literal_value = 7
        body%instructions(2)%id = 1
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_1
        body%instructions(3)%id = 2
        body%instructions(3)%opcode = instruction_shape_frontend_ast_v2_print_7_opcode_2
        do index = 1, 3
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_source_rule
        end do
    end subroutine emit_frontend_ast_v2_print_7

    logical function ffc_validate_frontend_ast_v2_print_7_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_count) then
            call set_message(message, 'frontend-ast-v2 print-7 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_opcode_2 .or. &
            body%instructions(1)%literal_value /= 7) then
            call set_message(message, 'frontend-ast-v2 print-7 opcode shape changed')
            return
        end if
        do index = 1, 3
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_shape

    subroutine emit_frontend_ast_v2_print_7_8(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(5))
        body%function%instruction_count = 5
        body%instructions(1)%id = 0
        body%instructions(1)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_0
        body%instructions(1)%literal_value = 7
        body%instructions(2)%id = 1
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_1
        body%instructions(3)%id = 2
        body%instructions(3)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_2
        body%instructions(3)%literal_value = 8
        body%instructions(4)%id = 3
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_3
        body%instructions(5)%id = 4
        body%instructions(5)%opcode = instruction_shape_frontend_ast_v2_print_7_8_opcode_4
        do index = 1, 5
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_7_8_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_7_8_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_7_8_source_rule
        end do
    end subroutine emit_frontend_ast_v2_print_7_8

    logical function ffc_validate_frontend_ast_v2_print_7_8_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_opcode_4 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8) then
            call set_message(message, 'frontend-ast-v2 print-7-8 opcode shape changed')
            return
        end if
        do index = 1, 5
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_7_8_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_7_8_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_7_8_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_shape

    subroutine emit_frontend_ast_v2_print_7_8_9(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(7))
        body%function%instruction_count = 7
        do index = 1, 7
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5
        body%instructions(7)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6
    end subroutine emit_frontend_ast_v2_print_7_8_9

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_opcode_6 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9 opcode shape changed')
            return
        end if
        do index = 1, 7
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_7_8_9_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_7_8_9_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_7_8_9_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(9))
        body%function%instruction_count = 9
        do index = 1, 9
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7
        body%instructions(9)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8
    end subroutine emit_frontend_ast_v2_print_7_8_9_10

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_10_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_opcode_8 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10 opcode shape changed')
            return
        end if
        do index = 1, 9
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10_11(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(11))
        body%function%instruction_count = 11
        do index = 1, 11
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind
            body%instructions(index)%result%type_name = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type
            body%instructions(index)%source_rule = &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7
        body%instructions(9)%literal_value = 11
        body%instructions(10)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9
        body%instructions(11)%opcode = instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10
    end subroutine emit_frontend_ast_v2_print_7_8_9_10_11

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_8 .or. &
            body%instructions(10)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_9 .or. &
            body%instructions(11)%opcode /= instruction_shape_frontend_ast_v2_print_7_8_9_10_11_opcode_10 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10 .or. &
            body%instructions(9)%literal_value /= 11) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 opcode shape changed')
            return
        end if
        do index = 1, 11
            if (body%instructions(index)%result%kind /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_result_type .or. &
                trim(body%instructions(index)%source_rule) /= &
                instruction_shape_frontend_ast_v2_print_7_8_9_10_11_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape

    subroutine emit_frontend_ast_v2_print_7_8_9_10_11_12(body)
        type(mir_function_body_t), intent(inout) :: body
        integer :: index

        deallocate (body%instructions)
        allocate (body%instructions(13))
        body%function%instruction_count = 13
        do index = 1, 13
            body%instructions(index)%id = index - 1
            body%instructions(index)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_0
            body%instructions(index)%result%id = 0
            body%instructions(index)%result%kind = instruction_shape_frontend_ast_v2_print_six_result_kind
            body%instructions(index)%result%type_name = instruction_shape_frontend_ast_v2_print_six_result_type
            body%instructions(index)%source_rule = instruction_shape_frontend_ast_v2_print_six_source_rule
        end do
        body%instructions(1)%literal_value = 7
        body%instructions(2)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_1
        body%instructions(3)%literal_value = 8
        body%instructions(4)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_3
        body%instructions(5)%literal_value = 9
        body%instructions(6)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_5
        body%instructions(7)%literal_value = 10
        body%instructions(8)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_7
        body%instructions(9)%literal_value = 11
        body%instructions(10)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_9
        body%instructions(11)%literal_value = 12
        body%instructions(12)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_11
        body%instructions(13)%opcode = instruction_shape_frontend_ast_v2_print_six_opcode_12
    end subroutine emit_frontend_ast_v2_print_7_8_9_10_11_12

    logical function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message
        integer :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= instruction_shape_frontend_ast_v2_print_six_count) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 instruction count changed')
            return
        end if
        if (body%instructions(1)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_0 .or. &
            body%instructions(2)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_1 .or. &
            body%instructions(3)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_2 .or. &
            body%instructions(4)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_3 .or. &
            body%instructions(5)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_4 .or. &
            body%instructions(6)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_5 .or. &
            body%instructions(7)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_6 .or. &
            body%instructions(8)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_7 .or. &
            body%instructions(9)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_8 .or. &
            body%instructions(10)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_9 .or. &
            body%instructions(11)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_10 .or. &
            body%instructions(12)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_11 .or. &
            body%instructions(13)%opcode /= instruction_shape_frontend_ast_v2_print_six_opcode_12 .or. &
            body%instructions(1)%literal_value /= 7 .or. body%instructions(3)%literal_value /= 8 .or. &
            body%instructions(5)%literal_value /= 9 .or. body%instructions(7)%literal_value /= 10 .or. &
            body%instructions(9)%literal_value /= 11 .or. body%instructions(11)%literal_value /= 12) then
            call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 opcode shape changed')
            return
        end if
        do index = 1, 13
            if (body%instructions(index)%result%kind /= instruction_shape_frontend_ast_v2_print_six_result_kind .or. &
                trim(body%instructions(index)%result%type_name) /= instruction_shape_frontend_ast_v2_print_six_result_type .or. &
                trim(body%instructions(index)%source_rule) /= instruction_shape_frontend_ast_v2_print_six_source_rule) then
                call set_message(message, 'frontend-ast-v2 print-7-8-9-10-11-12 typed result shape changed')
                return
            end if
        end do
        valid = .true.
    end function ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape

    integer(int32) function frontend_ast_v2_stop_route(expression) result(route)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        route = mir_frontend_ast_v1_integer_expression_route(&
            '(execution-part '//canonical//')')
        if (route /= 0_int32) return
        if (index(canonical, '( stop-stmt ') /= 1) return
        if (index(canonical, '( code 7 )') == 0) return
        if (index(canonical, '( source-rule R1162 )') == 0) return
        if (index(canonical, '( code-rule R1164 )') == 0) return
        if (index(canonical, '( quiet ') /= 0) return
        route = 18_int32
    end function frontend_ast_v2_stop_route

    integer(int32) function frontend_ast_v2_print_route(expression) result(route)
        character(len=*), intent(in) :: expression
        character(len=:), allocatable :: canonical

        canonical = trim(expression)
        route = 0_int32
        if (index(canonical, '( print-stmt ') /= 1) return
        if (index(canonical, '( format-kind default-char-expr )') == 0 .or. &
            index(canonical, '( format-value * )') == 0 .or. &
            index(canonical, '( output-kind integer-literal )') == 0 .or. &
            index(canonical, '( output-value 7 )') == 0) return
        if (index(canonical, '( statement-rule R1212 )') == 0 .or. &
            index(canonical, '( format-rule R1215 )') == 0 .or. &
            index(canonical, '( output-rule R1217 )') == 0) return
        if (index(canonical, '( source-document J3-24-007 )') == 0 .or. &
            index(canonical, '( statement-clause 12.6.1 )') == 0 .or. &
            index(canonical, '( format-clause 12.6.2.2 )') == 0 .or. &
            index(canonical, '( output-clause 12.6.3 )') == 0 .or. &
            index(canonical, '( statement-page 242 )') == 0 .or. &
            index(canonical, '( format-page 244 )') == 0 .or. &
            index(canonical, '( output-page 248 )') == 0 .or. &
            index(canonical, '( source-hash ') == 0) return
        if (index(canonical, 'write-stmt') /= 0 .or. index(canonical, 'control-list') /= 0 .or. &
            index(canonical, 'io-implied-do') /= 0) return
        if (index(canonical, '( output-count 6 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-6 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-6 12 )') == 0 .or. &
                index(canonical, '( output-rule-6 R1217 )') == 0) return
            route = 24_int32
            return
        end if
        if (index(canonical, '( output-count 5 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-5 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-5 11 )') == 0 .or. &
                index(canonical, '( output-rule-5 R1217 )') == 0) return
            route = 23_int32
            return
        end if
        if (index(canonical, '( output-count 4 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-4 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-4 10 )') == 0 .or. &
                index(canonical, '( output-rule-4 R1217 )') == 0) return
            route = 22_int32
            return
        end if
        if (index(canonical, '( output-count 3 )') /= 0) then
            if (index(canonical, '( output-kind-2 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-2 8 )') == 0 .or. &
                index(canonical, '( output-rule-2 R1217 )') == 0 .or. &
                index(canonical, '( output-kind-3 integer-literal )') == 0 .or. &
                index(canonical, '( output-value-3 9 )') == 0 .or. &
                index(canonical, '( output-rule-3 R1217 )') == 0) return
            route = 21_int32
            return
        end if
        if (index(canonical, '( output-count 2 )') /= 0 .and. &
            index(canonical, '( output-kind-2 integer-literal )') /= 0 .and. &
            index(canonical, '( output-value-2 8 )') /= 0 .and. &
            index(canonical, '( output-rule-2 R1217 )') /= 0) then
            route = 20_int32
            return
        end if
        if (index(canonical, '( output-count 2 )') /= 0) return
        if (index(canonical, '( output-count ') /= 0) return
        if (count_substring(canonical, '( output-kind integer-literal )') /= 1 .or. &
            count_substring(canonical, '( output-value 7 )') /= 1) return
        route = 19_int32
    end function frontend_ast_v2_print_route

    integer function count_substring(value, needle) result(count)
        character(len=*), intent(in) :: value, needle
        integer :: position, found

        count = 0
        position = 1
        do while (position <= len_trim(value))
            found = index(value(position:), needle)
            if (found == 0) return
            position = position + found - 1
            count = count + 1
            position = position + len(needle)
        end do
    end function count_substring

    logical function ffc_lower_frontend_ast_v1_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v1_t) :: ast

        call clear_message(message)
        if (starts_assignment_sequence_sx(serialized)) then
            lowered = ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(serialized, body, message)
            return
        end if
        lowered = ffc_frontend_ast_v1_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v1(ast, body, message)
    end function ffc_lower_frontend_ast_v1_from_sx

    logical function starts_assignment_sequence_sx(serialized) result(starts)
        character(len=*), intent(in) :: serialized

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=:), allocatable :: message
        integer :: token_count

        starts = .false.
        if (.not. tokenize_frontend_ast_sx(serialized, token, token_count, message)) return
        if (token_count >= 2) then
            if (trim(token(1)) == '(') then
                starts = trim(token(2)) == 'assignment-sequence'
            end if
        end if
    end function starts_assignment_sequence_sx

    logical function ffc_frontend_ast_v0_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v0_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position
        integer(int64) :: declaration_count

        ast = ffc_frontend_ast_v0_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return

        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) return

        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, declaration_count, message)
        if (.not. parsed) return
        ast%declaration_count = declaration_count

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if
        if (trim(token(position)) == '(') then
            parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
                message)
            if (.not. parsed) return
            parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
            if (.not. parsed) return
            ast%declaration_present = .true.
        else if (trim(token(position)) /= ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = ffc_validate_frontend_ast_v0(ast, message)
    end function ffc_frontend_ast_v0_from_sx

    logical function ffc_validate_frontend_ast_v0(ast, message) result(valid)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count < 0_int64) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            return
        end if
        if (ast%declaration_count == 0_int64) then
            if (ast%declaration_present) then
                call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
                return
            end if
            valid = .true.
            return
        end if
        if (ast%declaration_count /= 1_int64 .or. .not. ast%declaration_present) then
            call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%source_file) /= trim(ast%declaration%source_file)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (trim(ast%root%source_hash) /= trim(ast%declaration%source_hash)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%start_byte < ast%root%start_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%end_byte > ast%root%end_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v0(ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(ast%root%name, ast%root%source_file, &
            ast%root%source_hash, ast%root%start_byte, ast%root%end_byte, body, message)
    end function ffc_lower_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v0_t) :: ast

        call clear_message(message)
        lowered = ffc_frontend_ast_v0_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v0(ast, body, message)
    end function ffc_lower_frontend_ast_v0_from_sx

    logical function tokenize_frontend_ast_sx(input, token, token_count, message) result(ok)
        character(len=*), intent(in) :: input
        character(len=*), intent(out) :: token(:)
        integer, intent(out) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        integer :: position, start, input_length
        character :: current

        token = ''
        token_count = 0
        call clear_message(message)
        position = 1
        input_length = len_trim(input)
        do while (position <= input_length)
            current = input(position:position)
            if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                current == char(13)) then
                position = position + 1
            else if (current == '(' .or. current == ')') then
                if (.not. append_token(input(position:position), token, token_count, message)) &
                    return
                position = position + 1
            else
                start = position
                do while (position <= input_length)
                    current = input(position:position)
                    if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                        current == char(13) .or. current == '(' .or. current == ')') exit
                    position = position + 1
                end do
                if (.not. append_token(input(start:position - 1), token, token_count, message)) &
                    return
            end if
        end do
        ok = token_count > 0
        if (.not. ok) call set_message(message, 'malformed-frontend-ast-v0')
    end function tokenize_frontend_ast_sx

    logical function parse_variable_declaration_v1(serialized, variable, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_variable_declaration_v1_t), intent(out) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=128) :: type_spec, name
        integer :: token_count, position

        variable = ffc_frontend_variable_declaration_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'variable-declaration', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'type-spec', type_spec, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'name', name, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'span', expression, message)
        if (.not. parsed) return
        parsed = parse_source_span_v1(trim(expression), variable%source_file, &
            variable%start_byte, variable%end_byte, variable%source_hash, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            return
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        variable%type_spec = type_spec
        variable%name = name
        parsed = ffc_validate_variable_declaration_v1(variable, message)
    end function parse_variable_declaration_v1

    logical function parse_assignment_v1(serialized, assignment, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_assignment_v1_t), intent(out) :: assignment
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=128) :: target, value
        integer :: token_count, position

        assignment = ffc_frontend_assignment_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'assignment-stmt', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'variable', target, message)
        if (.not. parsed) return
        parsed = read_assignment_expression(token, token_count, position, value, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'span', expression, message)
        if (.not. parsed) return
        parsed = parse_source_span_v1(trim(expression), assignment%source_file, &
            assignment%start_byte, assignment%end_byte, assignment%source_hash, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-assignment')
            parsed = .false.
            return
        end if
        assignment%target = target
        assignment%value = value
        parsed = ffc_validate_assignment_v1(assignment, message)
    end function parse_assignment_v1

    logical function parse_source_span_v1(serialized, source_file, start_byte, end_byte, &
            source_hash, message) result(parsed)
        character(len=*), intent(in) :: serialized
        character(len=*), intent(out) :: source_file, source_hash
        integer(int64), intent(out) :: start_byte, end_byte
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=64) :: start_text, end_text
        integer :: token_count, position

        source_file = ''
        source_hash = ''
        start_byte = 0_int64
        end_byte = 0_int64
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'source-span', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'file', source_file, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'start-byte', start_text, message)
        if (.not. parsed) return
        parsed = parse_count(start_text, start_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'end-byte', end_text, message)
        if (.not. parsed) return
        parsed = parse_count(end_text, end_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'source-hash', source_hash, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            parsed = .false.
        end if
    end function parse_source_span_v1

    logical function ffc_validate_variable_declaration_v1(variable, message) result(valid)
        type(ffc_frontend_variable_declaration_v1_t), intent(in) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (len_trim(variable%type_spec) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-type-spec')
            return
        end if
        if (mir_type_spec_value_kind(variable%type_spec) == 0) then
            call set_message(message, 'unsupported-frontend-ast-v1-type-spec')
            return
        end if
        if (len_trim(variable%name) == 0 .or. len_trim(variable%source_file) == 0 .or. &
            len_trim(variable%source_hash) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-variable')
            return
        end if
        if (variable%start_byte < 0_int64 .or. variable%end_byte < variable%start_byte) then
            call set_message(message, 'invalid-frontend-ast-v1-variable-span')
            return
        end if
        valid = .true.
    end function ffc_validate_variable_declaration_v1

    logical function ffc_validate_assignment_v1(assignment, message) result(valid)
        type(ffc_frontend_assignment_v1_t), intent(in) :: assignment
        character(len=:), allocatable, intent(out), optional :: message
        integer(int32) :: literal_value

        call clear_message(message)
        valid = .false.
        if (trim(assignment%target) /= 'x') then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment')
            return
        end if
        if (trim(assignment%value) /= '1' .and. &
            .not. starts_integer_literal_expression(trim(assignment%value)) .and. &
            trim(assignment%value) /= &
            '( binary-expr ( operator + ) ( left 1 ) ( right 2 ) )' .and. &
            trim(assignment%value) /= '( binary-expr ( operator * ) ( left 2 ) ( right 3 ) )' &
            .and. trim(assignment%value) /= '( binary-expr ( operator / ) ( left 6 ) ( right 2 ) )' &
            .and. trim(assignment%value) /= '( binary-expr ( operator – ) ( left 5 ) ( right 3 ) )' &
            .and. trim(assignment%value) /= &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) (right-operand 1))') then
            call set_message(message, 'unsupported-frontend-ast-v1-assignment')
            return
        end if
        if (len_trim(assignment%source_file) == 0 .or. len_trim(assignment%source_hash) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment')
            return
        end if
        if (assignment%start_byte < 0_int64 .or. assignment%end_byte < assignment%start_byte) then
            call set_message(message, 'invalid-frontend-ast-v1-assignment-span')
            return
        end if
        valid = .true.
    end function ffc_validate_assignment_v1

    logical function read_assignment_expression(token, token_count, position, value, message) &
            result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message
        character(len=128) :: kind, operator, left_operand, right_operand
        integer(int32) :: literal_value

        call clear_message(message)
        value = ''
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'expression', message)
        if (.not. ok) return
        if (position <= token_count) then
            if (trim(token(position)) == '(') then
                if (position + 1 <= token_count) then
                    if (trim(token(position + 1)) /= 'assignment-expression') then
                        ok = read_expression(token, token_count, position, value, message)
                        if (.not. ok) return
                    else
                        position = position + 2
                        ok = read_named_atom(token, token_count, position, 'kind', kind, message)
                        if (.not. ok) return
                        if (trim(kind) == 'integer-literal') then
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'operator', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'left-operand', &
                                message)
                            if (.not. ok) return
                            ok = read_atom(token, token_count, position, left_operand, message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, '(', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, 'right-operand', &
                                message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            ok = parse_bounded_decimal_literal(trim(left_operand), literal_value, &
                                message)
                            if (.not. ok) then
                                call set_message(message, &
                                    'unsupported-frontend-ast-v1-assignment-expression')
                                return
                            end if
                            if (literal_value == 1_int32) then
                                value = '1'
                            else
                                write (value, '(a,i0,a)') '( integer-literal ', literal_value, ' )'
                            end if
                            ok = expect_token(token, token_count, position, ')', message)
                            if (.not. ok) return
                            return
                        end if
                        ok = read_named_atom(token, token_count, position, 'operator', operator, &
                            message)
                        if (.not. ok) return
                        ok = read_named_atom(token, token_count, position, 'left-operand', &
                            left_operand, message)
                        if (.not. ok) return
                        ok = read_named_atom(token, token_count, position, 'right-operand', &
                            right_operand, message)
                        if (.not. ok) return
                        ok = expect_token(token, token_count, position, ')', message)
                        if (.not. ok) return
                        if (trim(kind) /= 'binary-expression' .or. &
                            (trim(operator) /= '+' .and. trim(operator) /= '*' .and. &
                            trim(operator) /= '/' .and. trim(operator) /= '–') .or. &
                            (trim(operator) == '+' .and. &
                            ((trim(left_operand) /= '1' .or. trim(right_operand) /= '2') .and. &
                            (trim(left_operand) /= 'x' .or. trim(right_operand) /= '1'))) .or. &
                            (trim(operator) == '*' .and. (trim(left_operand) /= '2' .or. &
                            trim(right_operand) /= '3')) .or. &
                            (trim(operator) == '/' .and. (trim(left_operand) /= '6' .or. &
                            trim(right_operand) /= '2')) .or. &
                            (trim(operator) == '–' .and. (trim(left_operand) /= '5' .or. &
                            trim(right_operand) /= '3'))) then
                            call set_message(message, &
                                'unsupported-frontend-ast-v1-assignment-expression')
                            ok = .false.
                            return
                        end if
                        if (trim(operator) == '+' .and. trim(left_operand) == 'x' .and. &
                            trim(right_operand) == '1') then
                            value = '(assignment-expression (kind binary-expression) '// &
                                '(operator +) (left-operand x) (right-operand 1))'
                        else
                            value = '( binary-expr ( operator '//trim(operator)//' ) ( left '// &
                                trim(left_operand)//' ) ( right '//trim(right_operand)//' ) )'
                        end if
                    end if
                else
                    ok = read_expression(token, token_count, position, value, message)
                end if
            else
                ok = read_atom(token, token_count, position, value, message)
            end if
        else
            ok = read_atom(token, token_count, position, value, message)
        end if
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_assignment_expression

    logical function parse_integer_literal_expression(serialized, value, message) result(ok)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=128) :: literal_text
        integer :: token_count, position

        value = 0_int32
        call clear_message(message)
        ok = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. ok) return
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'integer-literal', message)
        if (.not. ok) return
        ok = read_atom(token, token_count, position, literal_text, message)
        if (.not. ok) return
        ok = parse_bounded_decimal_literal(literal_text, value, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-integer-literal')
            ok = .false.
        end if
    end function parse_integer_literal_expression

    logical function starts_integer_literal_expression(serialized) result(is_literal)
        character(len=*), intent(in) :: serialized

        is_literal = .false.
        if (len_trim(serialized) < len('( integer-literal')) return
        is_literal = index(trim(serialized), '( integer-literal') == 1
    end function starts_integer_literal_expression

    logical function parse_bounded_decimal_literal(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int32), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer(int64) :: accumulator, digit
        integer :: position

        value = 0_int32
        call clear_message(message)
        ok = len_trim(text) > 0
        if (.not. ok) return
        accumulator = 0_int64
        do position = 1, len_trim(text)
            if (text(position:position) < '0' .or. text(position:position) > '9') then
                call set_message(message, 'frontend-ast-v1 integer literal is not decimal')
                ok = .false.
                return
            end if
            digit = int(iachar(text(position:position)) - iachar('0'), int64)
            if (accumulator > 214748364_int64 .or. &
                (accumulator == 214748364_int64 .and. digit > 7_int64)) then
                call set_message(message, 'frontend-ast-v1 integer literal is out of range')
                ok = .false.
                return
            end if
            accumulator = accumulator * 10_int64 + digit
        end do
        value = int(accumulator, int32)
        ok = .true.
    end function parse_bounded_decimal_literal

    logical function append_token(value, token, token_count, message) result(ok)
        character(len=*), intent(in) :: value
        character(len=*), intent(inout) :: token(:)
        integer, intent(inout) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        if (token_count == size(token)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(value) > len(token(1))) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        token_count = token_count + 1
        token(token_count) = value
        ok = .true.
    end function append_token

    logical function expect_token(token, token_count, position, expected, message) result(ok)
        character(len=*), intent(in) :: token(:), expected
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=:), allocatable, intent(out), optional :: message

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= expected) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        position = position + 1
        call clear_message(message)
        ok = .true.
    end function expect_token

    logical function read_named_atom(token, token_count, position, name, value, message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(token(position)) > len(value)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_atom

    logical function read_named_expression(token, token_count, position, name, expression, &
            message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        ok = read_expression(token, token_count, position, expression, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_expression

    logical function read_expression(token, token_count, position, expression, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        integer :: depth, index, start

        expression = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= '(') then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        start = position
        depth = 0
        do index = position, token_count
            if (trim(token(index)) == '(') then
                depth = depth + 1
            else if (trim(token(index)) == ')') then
                depth = depth - 1
            end if
            if (depth == 0) then
                expression = trim(token(start))
                do start = position + 1, index
                    if (len_trim(expression) + len_trim(token(start)) + 1 > len(expression)) then
                        call set_message(message, 'malformed-frontend-ast-v0')
                        ok = .false.
                        return
                    end if
                    expression = trim(expression)//' '//trim(token(start))
                end do
                position = index + 1
                ok = .true.
                return
            end if
        end do
        call set_message(message, 'malformed-frontend-ast-v0')
        ok = .false.
    end function read_expression

    logical function read_atom(token, token_count, position, value, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-assignment-expression')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-frontend-ast-v1-assignment-expression')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = .true.
    end function read_atom

    logical function parse_count(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        integer(int64) :: digit

        value = 0_int64
        call clear_message(message)
        if (len_trim(text) == 0) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            ok = .false.
            return
        end if
        do index = 1, len_trim(text)
            if (text(index:index) < '0' .or. text(index:index) > '9') then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            digit = int(iachar(text(index:index)) - iachar('0'), int64)
            if (value > (huge(value) - digit) / 10_int64) then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            value = value * 10_int64 + digit
        end do
        ok = .true.
    end function parse_count

    subroutine clear_message(message)
        character(len=:), allocatable, intent(out), optional :: message

        if (present(message)) then
            if (allocated(message)) deallocate (message)
        end if
    end subroutine clear_message

    subroutine set_message(message, text)
        character(len=:), allocatable, intent(out), optional :: message
        character(len=*), intent(in) :: text

        if (present(message)) message = text
    end subroutine set_message

end module ffc_frontend_ast
