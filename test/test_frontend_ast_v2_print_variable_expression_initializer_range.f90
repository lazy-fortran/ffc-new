program test_frontend_ast_v2_init_xplus1_range
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_add, opcode_const, &
        opcode_load, opcode_output, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: initializers(2), addends(2)
    integer :: initializer_index, addend_index

    initializers = [-42_int32, 42_int32]
    addends = [2_int32, 10_int32]
    do initializer_index = 1, size(initializers)
        do addend_index = 1, size(addends)
            call check_case(initializers(initializer_index), addends(addend_index))
        end do
    end do
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('42', '0'), body, message), &
        'zero addend was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('42', '11'), body, message), &
        'out-of-range addend was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42', '2'), &
        '(kind integer-literal)', '(kind real-literal)'), body, message), 'real initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42', '2'), &
        '(right-operand 2)', '(right-operand 2.0)'), body, message), 'real addend was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('-101', '2'), body, message), &
        'out-of-range negative initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(witness('2048', '2'), body, message), &
        'out-of-range positive initializer was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42', '2'), &
        '(operator +)', '(operator *)'), body, message), 'wrong AST operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42', '2'), &
        '(right-operand 2)', '(right-operand x)'), body, message), 'wrong AST right shape was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('42', '2'), &
        '(assignment-stmt (variable x)', '(assignment-stmt (variable y)'), body, message), &
        'wrong AST assignment name was accepted')
    write (*, '(a)') 'frontend AST v2 initialized bounded-addend MIR checks: ok'

contains

    subroutine check_case(expected, addend)
        integer(int32), intent(in) :: expected, addend
        character(len=32) :: literal
        character(len=32) :: addend_literal
        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: instruction_index

        write (literal, '(i0)') expected
        write (addend_literal, '(i0)') addend
        if (.not. ffc_lower_frontend_ast_v2_from_sx(witness(trim(literal), trim(addend_literal)), &
            body, message)) then
            error stop 'bounded initialized x+1 sequence was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        call assert_true(body%function%instruction_count == 9, 'instruction count changed')
        do instruction_index = 1, 9
            call assert_true(body%instructions(instruction_index)%opcode == expected_opcodes(instruction_index), &
                'opcode route changed')
            call assert_true(body%instructions(instruction_index)%result%id == expected_results(instruction_index), &
                'result ID route changed')
            call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, &
                'result kind changed')
            call assert_equal(body%instructions(instruction_index)%result%type_name, 'i32', &
                'result type changed')
        end do
        call assert_true(body%instructions(1)%literal_value == expected .and. &
            body%instructions(4)%literal_value == addend, 'literal transport changed')
        call assert_storage(2)
        call assert_storage(3)
        call assert_storage(6)
        call assert_storage(7)
        call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v2/execution-part', &
            'initializer source rule changed')
        call assert_equal(body%instructions(6)%source_rule, 'frontend-ast-v2/execution-part', &
            'assignment source rule changed')
        call assert_equal(body%instructions(7)%source_rule, 'frontend-ast-v2/print-stmt', &
            'PRINT source rule changed')
    end subroutine check_case

    subroutine assert_storage(instruction_index)
        integer, intent(in) :: instruction_index

        call assert_true(allocated(body%instructions(instruction_index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(instruction_index)%storage_key, 'x', 'storage key changed')
    end subroutine assert_storage

    function witness(literal, addend) result(value)
        character(len=*), intent(in) :: literal, addend
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 70) (source-hash init-range))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash init-range))))) (variable-count 1) (variable (variable-declaration '// &
            '(type-spec integer) (name x) (span (source-span (file main.f90) (start-byte 10) '// &
            '(end-byte 20) (source-hash init-range))))) (execution-part (assignment-sequence '// &
            '(assignment-count 2) (assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind LITERAL-KIND) (operator ) (left-operand LITERAL) '// &
            '(right-operand ))) (span (source-span (file main.f90) (start-byte 25) '// &
            '(end-byte 31) (source-hash init-range))))) (assignment (assignment-stmt (variable x) '// &
            '(expression (assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand ADDEND))) (span (source-span (file main.f90) (start-byte 32) '// &
            '(end-byte 42) (source-hash init-range)))))) (print-stmt (format-kind default-char-expr) '// &
            '(format-value *) (output-kind variable) (output-name x) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) (source-hash init-range))))'
        value = replace_text(value, 'LITERAL-KIND', 'integer-literal')
        value = replace_text(value, 'LITERAL', trim(literal))
        value = replace_text(value, 'ADDEND', trim(addend))
    end function witness

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=12288) :: replaced
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

end program test_frontend_ast_v2_init_xplus1_range
