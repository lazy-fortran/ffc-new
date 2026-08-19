program test_frontend_ast_v2_init_xpow_range
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_load, opcode_output, opcode_pow, opcode_return, opcode_store, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_case(3_int32, 2_int32)
    call check_case(-3_int32, 3_int32)

    call assert_rejected(witness('3', '-1', '**'), &
        'negative exponent was accepted')
    call assert_rejected(replace_text(witness('3', '2', '**'), &
        '(right-operand 2)', '(right-operand 2.0)'), &
        'real exponent was accepted')
    call assert_rejected(replace_text(witness('3', '2', '**'), &
        '(operator **)', '(operator *)'), &
        'wrong power operator was accepted')
    call assert_rejected(replace_text(witness('3', '2', '**'), &
        '(assignment-stmt (variable x)', '(assignment-stmt (variable y)'), &
        'wrong assignment AST shape was accepted')
    call assert_rejected(replace_text(witness('3', '2', '**'), &
        '(source-hash init-power)', '(source-hash mutated)'), &
        'mutated source provenance was accepted')
    call assert_rejected(replace_nth_text(witness('3', '2', '**'), &
        '(source-hash init-power)', '(source-hash mutated)', 5), &
        'mutated power-assignment provenance was accepted')

    write (*, '(a)') 'frontend AST v2 initialized generic-power MIR checks: ok'

contains

    subroutine check_case(initializer, exponent)
        integer(int32), intent(in) :: initializer, exponent
        integer(int32) :: expected_literals(9), expected_opcodes(9), expected_results(9)
        integer :: instruction_index
        character(len=32) :: initializer_literal, exponent_literal

        write (initializer_literal, '(i0)') initializer
        write (exponent_literal, '(i0)') exponent
        call assert_true(ffc_lower_frontend_ast_v2_from_sx(&
            witness(trim(initializer_literal), trim(exponent_literal), '**'), &
            body, message), 'initialized power sequence was rejected')
        call assert_true(mir_validate_function_body(body, message), &
            'generated MIR is invalid')

        expected_literals = 0_int32
        expected_literals(1) = initializer
        expected_literals(4) = exponent
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, &
            opcode_pow, opcode_store, opcode_load, opcode_output, opcode_return]
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

    function witness(initializer, exponent, operator) result(value)
        character(len=*), intent(in) :: initializer, exponent, operator
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash init-power))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) '// &
            '(end-byte 70) (source-hash init-power))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file main.f90) (start-byte 10) (end-byte 20) '// &
            '(source-hash init-power))))) (execution-part '// &
            '(assignment-sequence (assignment-count 2) (assignment '// &
            '(assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand INITIAL) '// &
            '(right-operand ))) (span (source-span (file main.f90) '// &
            '(start-byte 25) (end-byte 31) (source-hash init-power))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator OPERATOR) '// &
            '(left-operand x) (right-operand EXPONENT))) (span (source-span '// &
            '(file main.f90) (start-byte 32) (end-byte 42) '// &
            '(source-hash init-power)))))) (print-stmt '// &
            '(format-kind default-char-expr) (format-value *) '// &
            '(output-kind variable) (output-name x) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) '// &
            '(output-page 248) (source-hash init-power))))'
        value = replace_text(value, 'INITIAL', trim(initializer))
        value = replace_text(value, 'EXPONENT', trim(exponent))
        value = replace_text(value, 'OPERATOR', trim(operator))
    end function witness

    character(len=12288) function replace_text(value, needle, replacement)
        character(len=*), intent(in) :: value, needle, replacement
        integer :: found

        replace_text = value
        found = index(replace_text, needle)
        if (found > 0) then
            replace_text = replace_text(:found - 1)//replacement// &
                replace_text(found + len(needle):)
        end if
    end function replace_text

    character(len=12288) function replace_nth_text(value, needle, replacement, &
            occurrence)
        character(len=*), intent(in) :: value, needle, replacement
        integer, intent(in) :: occurrence
        integer :: found, match, start

        replace_nth_text = value
        start = 1
        do match = 1, occurrence
            found = index(replace_nth_text(start:), needle)
            if (found == 0) return
            found = start + found - 1
            if (match == occurrence) then
                replace_nth_text = replace_nth_text(:found - 1)//replacement// &
                    replace_nth_text(found + len(needle):)
                return
            end if
            start = found + len(needle)
        end do
    end function replace_nth_text

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

end program test_frontend_ast_v2_init_xpow_range
