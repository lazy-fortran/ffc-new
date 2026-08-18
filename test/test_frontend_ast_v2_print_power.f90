program test_frontend_ast_v2_print_power
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, &
        opcode_output, opcode_pow, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(9), expected_results(9)
    integer :: instruction_index

    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_pow, &
        opcode_store, opcode_load, opcode_output, opcode_return]
    expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
    if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'source-backed power PRINT sequence was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
    call assert_true(body%function%instruction_count == 9_int32, 'instruction count changed')
    do instruction_index = 1, 9
        call assert_true(body%instructions(instruction_index)%opcode == expected_opcodes(instruction_index), 'opcode changed')
        call assert_true(body%instructions(instruction_index)%result%id == expected_results(instruction_index), 'result ID changed')
        call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, 'result kind changed')
        call assert_equal(body%instructions(instruction_index)%result%type_name, 'i32', 'result type changed')
        if (instruction_index <= 6) then
            call assert_equal(body%instructions(instruction_index)%source_rule, 'frontend-ast-v2/execution-part', &
                'execution source rule changed')
        else
            call assert_equal(body%instructions(instruction_index)%source_rule, 'frontend-ast-v2/print-stmt', &
                'PRINT source rule changed')
        end if
    end do
    call assert_true(body%instructions(1)%literal_value == 2 .and. &
        body%instructions(4)%literal_value == 3, 'constant transport changed')
    call assert_storage(2)
    call assert_storage(3)
    call assert_storage(6)
    call assert_storage(7)

    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(name main)', '(name wrong)'), body, message), 'wrong program name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(output-name x)', '(output-name y)'), body, message), 'wrong output name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(operator **)', '(operator *)'), body, message), 'wrong operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(print-stmt (format-kind', '(write-stmt (format-kind'), body, message), &
        'WRITE neighbour was accepted')

    if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_value_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'second source-backed power PRINT sequence was rejected'
    end if
    call assert_true(body%instructions(1)%literal_value == 3 .and. &
        body%instructions(4)%literal_value == 2, 'second constant transport changed')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_value_sx(), &
        '(name main)', '(name wrong)'), body, message), 'second wrong program name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_value_sx(), &
        '(output-name x)', '(output-name y)'), body, message), 'second wrong output name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_value_sx(), &
        '(operator **)', '(operator *)'), body, message), 'second wrong operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_value_sx(), &
        '(print-stmt (format-kind', '(write-stmt (format-kind'), body, message), &
        'second WRITE neighbour was accepted')
    write (*, '(a)') 'frontend AST v2 variable power PRINT checks: ok'

contains

    function positive_sx() result(value)
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 70) (source-hash print-variable-power))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash print-variable-power))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash print-variable-power))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand 2) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash print-variable-power))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator **) (left-operand x) (right-operand 3))) '// &
            '(span (source-span (file main.f90) (start-byte 32) (end-byte 42) '// &
            '(source-hash print-variable-power)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name x) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-variable-power))))'
    end function positive_sx

    function positive_value_sx() result(value)
        character(len=12288) :: value

        value = positive_sx()
        value = replace_all(value, 'left-operand 2', 'left-operand 3')
        value = replace_all(value, 'right-operand 3', 'right-operand 2')
        value = replace_all(value, 'print-variable-power', 'print-variable-power-value')
    end function positive_value_sx

    subroutine assert_storage(instruction_index)
        integer, intent(in) :: instruction_index

        call assert_true(allocated(body%instructions(instruction_index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(instruction_index)%storage_key, 'x', 'storage key changed')
    end subroutine assert_storage

    character(len=12288) function replace_text(value, needle, replacement)
        character(len=*), intent(in) :: value, needle, replacement
        integer :: found

        replace_text = value
        found = index(replace_text, needle)
        if (found > 0) replace_text = replace_text(:found - 1)//replacement// &
            replace_text(found + len(needle):)
    end function replace_text

    character(len=12288) function replace_all(value, needle, replacement)
        character(len=*), intent(in) :: value, needle, replacement
        integer :: found, start

        replace_all = value
        start = 1
        do
            found = index(replace_all(start:), needle)
            if (found == 0) exit
            found = start + found - 1
            replace_all = replace_all(:found - 1)//replacement//replace_all(found + len(needle):)
            start = found + len(replacement)
        end do
    end function replace_all

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_false(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        call assert_true(.not. value, description)
    end subroutine assert_false

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

end program test_frontend_ast_v2_print_power
