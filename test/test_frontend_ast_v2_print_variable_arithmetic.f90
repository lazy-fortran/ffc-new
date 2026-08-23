program test_frontend_ast_v2_print_variable_arithmetic
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_div, &
        opcode_load, opcode_output, opcode_return, opcode_store, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_witness('(operator –)', '23', opcode_sub, 'subtraction')
    call check_witness('(operator /)', '24', opcode_div, 'division')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_all(replace_all( &
        witness('(operator –)', '23', 'print-variable-subtraction-expression'), &
        '(operator –)', '(operator *)'), '(right-operand 2)', '(right-operand 11)'), body, message), &
        'wrong subtraction operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_all( &
        witness('(operator /)', '24', 'print-variable-division-expression'), &
        '(right-operand 2)', '(right-operand 11)'), body, message), 'out-of-range division operand was accepted')
    write (*, '(a)') 'frontend AST v2 variable subtraction/division PRINT checks: ok'

contains

    subroutine check_witness(operator, initial, expected_opcode, name)
        character(len=*), intent(in) :: operator, initial, name
        integer(int32), intent(in) :: expected_opcode

        integer(int32) :: expected_opcodes(9), expected_results(9)
        integer :: index, initial_value

        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, expected_opcode, &
            opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 6_int32, 6_int32]
        read (initial, *) initial_value
        if (.not. ffc_lower_frontend_ast_v2_from_sx(witness(operator, initial, &
            'print-variable-'//trim(name)//'-expression'), body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'source-backed arithmetic PRINT sequence was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
        call assert_true(body%function%instruction_count == 9_int32, 'instruction count changed')
        do index = 1, 9
            call assert_true(body%instructions(index)%opcode == expected_opcodes(index), 'opcode changed for '//name)
            call assert_true(body%instructions(index)%result%id == expected_results(index), 'result ID changed')
            call assert_true(body%instructions(index)%result%kind == value_kind_integer, 'result kind changed')
            call assert_equal(body%instructions(index)%result%type_name, 'i32', 'result type changed')
            if (index <= 6) then
                call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v2/execution-part', &
                    'execution source rule changed')
            else
                call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v2/print-stmt', &
                    'PRINT source rule changed')
            end if
        end do
        call assert_true(body%instructions(1)%literal_value == initial_value, 'initial constant changed')
        call assert_true(body%instructions(4)%literal_value == 2_int32, 'right constant changed')
        call assert_storage(2)
        call assert_storage(3)
        call assert_storage(6)
        call assert_storage(7)
    end subroutine check_witness

    function witness(operator, initial, source_hash) result(value)
        character(len=*), intent(in) :: operator, initial, source_hash
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 70) (source-hash SOURCEHASH))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash SOURCEHASH))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash SOURCEHASH))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand INITIAL) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash SOURCEHASH))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) OPERATOR (left-operand x) (right-operand 2))) '// &
            '(span (source-span (file main.f90) (start-byte 32) (end-byte 42) '// &
            '(source-hash SOURCEHASH)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name x) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash SOURCEHASH))))'
        value = replace_all(value, 'SOURCEHASH', trim(source_hash))
        value = replace_all(value, 'INITIAL', trim(initial))
        value = replace_all(value, 'OPERATOR', trim(operator))
    end function witness

    function replace_all(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=12288) :: replaced
        integer :: location, start

        replaced = value
        start = 1
        do
            location = index(replaced(start:), old)
            if (location == 0) return
            location = location + start - 1
            replaced = replaced(:location - 1)//new//replaced(location + len(old):)
            start = location + len(new)
        end do
    end function replace_all

    subroutine assert_storage(instruction_index)
        integer, intent(in) :: instruction_index

        call assert_true(allocated(body%instructions(instruction_index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(instruction_index)%storage_key, 'x', 'storage key changed')
    end subroutine assert_storage

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

end program test_frontend_ast_v2_print_variable_arithmetic
