program test_frontend_ast_v2_init_xdiv_range
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_div, opcode_load, opcode_output, opcode_return, opcode_store, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_case(42_int32, 2_int32)
    call check_case(-42_int32, 10_int32)

    call assert_rejected(witness('42', '0'), 'zero divisor was accepted')
    call assert_rejected(witness('42', '11'), &
        'out-of-range divisor was accepted')
    call assert_rejected(replace_text(witness('42', '2'), '(right-operand 2)', &
        '(right-operand 2.0)'), 'real divisor was accepted')
    call assert_rejected(replace_text(witness('42', '2'), '(right-operand 2)', &
        '(right-operand )'), 'malformed divisor AST was accepted')
    call assert_rejected(replace_text(witness('42', '2'), &
        '(assignment-stmt (variable x)', '(assignment-stmt (variable y)'), &
        'wrong assignment AST shape was accepted')
    call assert_rejected(replace_text(witness('42', '2'), &
        '(source-hash init-division)', '(source-hash mutated)'), &
        'mutated source provenance was accepted')

    write (*, '(a)') 'frontend AST v2 initialized bounded-divisor MIR checks: ok'

contains

    subroutine check_case(initializer, divisor)
        integer(int32), intent(in) :: initializer, divisor
        integer(int32) :: expected_literals(9), expected_opcodes(9), expected_results(9)
        integer :: instruction_index
        character(len=32) :: initializer_literal, divisor_literal

        write (initializer_literal, '(i0)') initializer
        write (divisor_literal, '(i0)') divisor
        if (.not. ffc_lower_frontend_ast_v2_from_sx(&
            witness(trim(initializer_literal), trim(divisor_literal)), &
            body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'initialized division sequence was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), &
            'generated MIR is invalid')

        expected_literals = 0_int32
        expected_literals(1) = initializer
        expected_literals(4) = divisor
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, &
            opcode_div, opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, &
            6_int32, 6_int32, 6_int32]
        call assert_true(body%function%instruction_count == 9_int32, &
            'instruction count changed')
        do instruction_index = 1, 9
            call assert_true(body%instructions(instruction_index)%opcode == &
                expected_opcodes(instruction_index), 'opcode route changed')
            call assert_true(body%instructions(instruction_index)%literal_value == &
                expected_literals(instruction_index), 'literal transport changed')
            call assert_true(body%instructions(instruction_index)%result%id == &
                expected_results(instruction_index), 'result ID route changed')
            call assert_true(body%instructions(instruction_index)%result%kind == &
                value_kind_integer, 'result kind changed')
            call assert_equal(body%instructions(instruction_index)%result%type_name, &
                'i32', 'result type changed')
            if (instruction_index <= 6) then
                call assert_equal(body%instructions(instruction_index)%source_rule, &
                    'frontend-ast-v2/execution-part', 'execution source rule changed')
            else
                call assert_equal(body%instructions(instruction_index)%source_rule, &
                    'frontend-ast-v2/print-stmt', 'PRINT source rule changed')
            end if
            if (allocated(body%instructions(instruction_index)%storage_key)) then
                call assert_true(instruction_index == 2 .or. &
                    instruction_index == 3 .or. instruction_index == 6 .or. &
                    instruction_index == 7, 'unexpected storage key')
                call assert_equal(body%instructions(instruction_index)%storage_key, &
                    'x', 'storage key changed')
            else
                call assert_true(instruction_index /= 2 .and. &
                    instruction_index /= 3 .and. instruction_index /= 6 .and. &
                    instruction_index /= 7, 'storage key missing')
            end if
        end do
    end subroutine check_case

    subroutine assert_rejected(serialized, description)
        character(len=*), intent(in) :: serialized, description

        call assert_false(ffc_lower_frontend_ast_v2_from_sx(&
            serialized, body, message), description)
    end subroutine assert_rejected

    function witness(initializer, divisor) result(value)
        character(len=*), intent(in) :: initializer, divisor
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash init-division))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) '// &
            '(end-byte 70) (source-hash init-division))))) '// &
            '(variable-count 1) (variable (variable-declaration '// &
            '(type-spec integer) (name x) (span (source-span (file main.f90) '// &
            '(start-byte 10) (end-byte 20) (source-hash init-division))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand INITIAL) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash init-division))))) (assignment (assignment-stmt '// &
            '(variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator /) (left-operand x) '// &
            '(right-operand DIVISOR))) (span (source-span (file main.f90) '// &
            '(start-byte 32) (end-byte 42) (source-hash init-division)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind variable) (output-name x) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) '// &
            '(output-page 248) (source-hash init-division))))'
        value = replace_text(value, 'INITIAL', trim(initializer))
        value = replace_text(value, 'DIVISOR', trim(divisor))
    end function witness

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=12288) :: replaced
        integer :: location

        replaced = value
        location = index(replaced, old)
        if (location > 0) then
            replaced = replaced(:location - 1)//new//replaced(location + len(old):)
        end if
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

end program test_frontend_ast_v2_init_xdiv_range
