program test_frontend_ast_v2_init_xmul_range
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_load, opcode_mul, opcode_output, opcode_return, opcode_store, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_case(42_int32, 3_int32)
    call check_case(-42_int32, 10_int32)

    call assert_rejected(witness('42', '0', '*'), 'zero multiplier was accepted')
    call assert_rejected(witness('42', '11', '*'), &
        'out-of-range multiplier was accepted')
    call assert_rejected(replace_text(witness('42', '3', '*'), '(right-operand 3)', &
        '(right-operand 3.0)'), 'real multiplier was accepted')
    call assert_rejected(replace_text(replace_text(witness('42', '3', '*'), '(operator *)', &
        '(operator /)'), '(right-operand 3)', '(right-operand 11)'), &
        'wrong multiplier operator was accepted')
    call assert_rejected(replace_text(witness('42', '3', '*'), '(right-operand 3)', &
        '(right-operand )'), 'malformed multiplier AST was accepted')

    write (*, '(a)') 'frontend AST v2 initialized bounded-multiplier MIR checks: ok'

contains

    subroutine check_case(initializer, multiplier)
        integer(int32), intent(in) :: initializer, multiplier
        integer(int32) :: expected_literals(9), expected_opcodes(9), expected_results(9)
        integer :: instruction_index
        character(len=32) :: initializer_literal, multiplier_literal

        write (initializer_literal, '(i0)') initializer
        write (multiplier_literal, '(i0)') multiplier
        call assert_true(ffc_lower_frontend_ast_v2_from_sx(&
            witness(trim(initializer_literal), trim(multiplier_literal), '*'), &
            body, message), 'initialized multiplication sequence was rejected')
        call assert_true(mir_validate_function_body(body, message), &
            'generated MIR is invalid')

        expected_literals = 0_int32
        expected_literals(1) = initializer
        expected_literals(4) = multiplier
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, &
            opcode_mul, opcode_store, opcode_load, opcode_output, opcode_return]
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
                    instruction_index == 7, &
                    'unexpected storage key')
                call assert_equal(body%instructions(instruction_index)%storage_key, &
                    'x', 'storage key changed')
            else
                call assert_true(instruction_index /= 2 .and. &
                    instruction_index /= 3 .and. instruction_index /= 6 .and. &
                    instruction_index /= 7, &
                    'storage key missing')
            end if
        end do
    end subroutine check_case

    subroutine assert_rejected(serialized, description)
        character(len=*), intent(in) :: serialized, description

        call assert_false(ffc_lower_frontend_ast_v2_from_sx(&
            serialized, body, message), description)
    end subroutine assert_rejected

    function witness(initializer, multiplier, operator) result(value)
        character(len=*), intent(in) :: initializer, multiplier, operator
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash init-multiplication))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) '// &
            '(end-byte 70) (source-hash init-multiplication))))) '// &
            '(variable-count 1) (variable (variable-declaration '// &
            '(type-spec integer) (name x) (span (source-span (file main.f90) '// &
            '(start-byte 10) (end-byte 20) (source-hash init-multiplication))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand INITIAL) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash init-multiplication))))) (assignment '// &
            '(assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator OPERATOR) (left-operand x) '// &
            '(right-operand MULTIPLIER))) (span (source-span (file main.f90) '// &
            '(start-byte 32) (end-byte 42) (source-hash init-multiplication)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind variable) (output-name x) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) '// &
            '(output-page 248) (source-hash init-multiplication))))'
        value = replace_text(value, 'INITIAL', trim(initializer))
        value = replace_text(value, 'MULTIPLIER', trim(multiplier))
        value = replace_text(value, 'OPERATOR', trim(operator))
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

end program test_frontend_ast_v2_init_xmul_range
