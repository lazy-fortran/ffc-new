program test_frontend_ast_v2_print_variable_signed_initializer
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, &
        opcode_output, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_initializer(-5_int32)
    call check_initializer(-100_int32)
    call check_initializer(-42_int32)
    call check_initializer(42_int32)
    call check_initializer(0_int32)
    call check_initializer(2047_int32)
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('-101'), body, message), &
        'out-of-range negative initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('-'), body, message), &
        'malformed negative initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('2048'), body, message), &
        'out-of-range positive initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('-5'), &
        '(kind integer-literal)', '(kind real-literal)'), body, message), &
        'wrong-kind initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42'), &
        '(name x)', '(name y)'), body, message), 'mutated variable fact was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42'), &
        '(output-name x)', '(output-name y)'), body, message), 'mutated PRINT fact was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42'), &
        '(source-hash signed-init)', '(source-hash mutated)'), body, message), &
        'mutated provenance fact was accepted')
    write (*, '(a)') 'frontend AST v2 signed variable initializer checks: ok'

contains

    subroutine check_initializer(expected)
        integer(int32), intent(in) :: expected
        character(len=32) :: literal

        write (literal, '(i0)') expected
        if (.not. ffc_lower_frontend_ast_v2_from_sx(witness(trim(literal)), body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'bounded initializer was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'initializer MIR is invalid')
        call assert_true(body%function%instruction_count == 5_int32, 'initializer MIR count changed')
        call assert_true(body%instructions(1)%opcode == opcode_const .and. &
            body%instructions(1)%literal_value == expected, 'initializer constant changed')
        call assert_true(body%instructions(2)%opcode == opcode_store .and. &
            allocated(body%instructions(2)%storage_key) .and. trim(body%instructions(2)%storage_key) == 'x', &
            'initializer store changed')
        call assert_true(body%instructions(3)%opcode == opcode_load .and. &
            allocated(body%instructions(3)%storage_key) .and. trim(body%instructions(3)%storage_key) == 'x', &
            'PRINT load changed')
        call assert_true(body%instructions(4)%opcode == opcode_output .and. &
            body%instructions(5)%opcode == opcode_return, 'PRINT output sequence changed')
        call assert_true(body%instructions(1)%result%kind == value_kind_integer .and. &
            trim(body%instructions(1)%result%type_name) == 'i32', 'initializer type changed')
        call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v2/execution-part', &
            'initializer source provenance changed')
        call assert_equal(body%instructions(2)%source_rule, 'frontend-ast-v2/execution-part', &
            'store source provenance changed')
        call assert_equal(body%instructions(3)%source_rule, 'frontend-ast-v2/print-stmt', &
            'PRINT source provenance changed')
        call assert_equal(body%instructions(4)%source_rule, 'frontend-ast-v2/print-stmt', &
            'output source provenance changed')
        call assert_equal(body%instructions(5)%source_rule, 'frontend-ast-v2/print-stmt', &
            'return source provenance changed')
    end subroutine check_initializer

    function witness(literal) result(value)
        character(len=*), intent(in) :: literal
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 40) (source-hash signed-init))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 40) '// &
            '(source-hash signed-init))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash signed-init))))) '// &
            '(execution-part (assignment-sequence (assignment-count 1) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand LITERAL) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash signed-init)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name x) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash signed-init))))'
        value = replace_text(value, 'LITERAL', trim(literal))
    end function witness

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

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

end program test_frontend_ast_v2_print_variable_signed_initializer
