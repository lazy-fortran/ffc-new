program test_frontend_ast_v2_print_variable
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, &
        opcode_output, opcode_return, opcode_store
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'stored-variable PRINT was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'stored-variable MIR is invalid')
    call assert_true(body%function%instruction_count == 5_int32, 'stored-variable MIR count changed')
    call assert_true(body%instructions(1)%opcode == opcode_const .and. &
        body%instructions(1)%literal_value == 17, 'assignment constant changed')
    call assert_true(body%instructions(2)%opcode == opcode_store .and. &
        allocated(body%instructions(2)%storage_key) .and. &
        trim(body%instructions(2)%storage_key) == 'x', 'assignment storage changed')
    call assert_true(body%instructions(3)%opcode == opcode_load .and. &
        allocated(body%instructions(3)%storage_key) .and. &
        trim(body%instructions(3)%storage_key) == 'x', 'PRINT load storage changed')
    call assert_true(body%instructions(4)%opcode == opcode_output .and. &
        body%instructions(5)%opcode == opcode_return, 'PRINT output/return changed')
    call check_positive_initializer(0_int32)
    call check_positive_initializer(2047_int32)
    call assert_true(ffc_lower_frontend_ast_v2_from_sx(positive_23_sx(), body, message), &
        'stored-variable PRINT literal 23 was rejected')
    call assert_true(body%instructions(1)%literal_value == 23, &
        'stored-variable PRINT literal 23 was not transported')
    call assert_true(body%instructions(2)%opcode == opcode_store .and. &
        body%instructions(3)%opcode == opcode_load .and. &
        body%instructions(4)%opcode == opcode_output .and. &
        body%instructions(5)%opcode == opcode_return, &
        'stored-variable PRINT literal 23 MIR route changed')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(unsupported_literal_sx(), body, message), &
        'stored-variable PRINT arbitrary literal was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(missing_assignment_sx(), body, message), &
        'missing assignment was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(wrong_name_sx(), body, message), &
        'wrong PRINT variable was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(write_sx(), body, message), &
        'WRITE variable was accepted')
    write (*, '(a)') 'frontend AST v2 PRINT stored-variable checks: ok'

contains

    subroutine check_positive_initializer(expected)
        integer(int32), intent(in) :: expected
        character(len=32) :: literal

        write (literal, '(i0)') expected
        if (.not. ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
            'left-operand 17', 'left-operand '//trim(literal)), body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'positive stored-variable initializer was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), &
            'positive initializer MIR is invalid')
        call assert_true(body%function%instruction_count == 5_int32, &
            'positive initializer MIR count changed')
        call assert_true(body%instructions(1)%opcode == opcode_const .and. &
            body%instructions(1)%literal_value == expected, &
            'positive initializer constant changed')
        call assert_true(body%instructions(2)%opcode == opcode_store .and. &
            allocated(body%instructions(2)%storage_key) .and. &
            trim(body%instructions(2)%storage_key) == 'x', &
            'positive initializer store changed')
        call assert_true(body%instructions(3)%opcode == opcode_load .and. &
            allocated(body%instructions(3)%storage_key) .and. &
            trim(body%instructions(3)%storage_key) == 'x', 'positive initializer load changed')
        call assert_true(body%instructions(4)%opcode == opcode_output .and. &
            body%instructions(5)%opcode == opcode_return, 'positive initializer tail changed')
        call assert_true(trim(body%instructions(1)%source_rule) == &
            'frontend-ast-v2/execution-part', 'positive initializer source provenance changed')
        call assert_true(trim(body%instructions(3)%source_rule) == 'frontend-ast-v2/print-stmt', &
            'positive initializer PRINT provenance changed')
    end subroutine check_positive_initializer

    function positive_sx() result(value)
        character(len=8192) :: value

        value = envelope('(assignment-sequence (assignment-count 1) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) (left-operand 17) '// &
            '(right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash print-variable))))))', print_sx())
    end function positive_sx

    function missing_assignment_sx() result(value)
        character(len=8192) :: value

        value = envelope('(assignment-sequence (assignment-count 0))', print_sx())
    end function missing_assignment_sx

    function positive_23_sx() result(value)
        character(len=8192) :: value

        value = replace_text(positive_sx(), 'left-operand 17', 'left-operand 23')
    end function positive_23_sx

    function unsupported_literal_sx() result(value)
        character(len=8192) :: value

        value = replace_text(positive_sx(), 'left-operand 17', 'left-operand 2048')
    end function unsupported_literal_sx

    function wrong_name_sx() result(value)
        character(len=8192) :: value

        value = replace_text(positive_sx(), '(output-name x)', '(output-name y)')
    end function wrong_name_sx

    function write_sx() result(value)
        character(len=8192) :: value

        value = replace_text(positive_sx(), '(print-stmt ', '(write-stmt ')
    end function write_sx

    function print_sx() result(value)
        character(len=4096) :: value

        value = '(print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind variable) (output-name x) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) '// &
            '(output-page 248) (source-hash print-variable))'
    end function print_sx

    function envelope(sequence_sx, print_statement) result(value)
        character(len=*), intent(in) :: sequence_sx, print_statement
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 40) (source-hash print-variable))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 40) '// &
            '(source-hash print-variable))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file main.f90) (start-byte 10) (end-byte 20) '// &
            '(source-hash print-variable))))) (execution-part '//trim(sequence_sx)//' '// &
            trim(print_statement)//'))'
    end function envelope

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=8192) :: replaced
        integer :: location

        replaced = value
        location = index(replaced, old)
        if (location > 0) replaced = replaced(:location - 1)//new//replaced(location + len(old):)
    end function replace_text

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

end program test_frontend_ast_v2_print_variable
