program test_frontend_ast_v2_initialized_variable_counter2_subtract
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, opcode_output, &
        opcode_return, opcode_store, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(9)
    integer :: instruction_index

    if (.not. ffc_lower_frontend_ast_v2_from_sx(witness(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'raw counter_2 subtraction source was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_sub, &
        opcode_store, opcode_load, opcode_output, opcode_return]
    call assert_true(body%function%instruction_count == 9_int32, 'instruction count changed')
    do instruction_index = 1, 9
        call assert_true(body%instructions(instruction_index)%opcode == expected_opcodes(instruction_index), &
            'opcode sequence changed')
        call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, &
            'result kind changed')
    end do
    call assert_true(body%instructions(1)%literal_value == 42_int32, 'initializer literal changed')
    call assert_storage(2)
    call assert_storage(3)
    call assert_storage(6)
    call assert_storage(7)

    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness(), &
        '(operator -) (left-operand counter_2)', '(operator *) (left-operand counter_2)'), body, message), &
        'wrong subtraction operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness(), &
        '(name counter_2)', '(name counter_3)'), body, message), 'wrong variable name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness(), &
        '(right-operand 1)', '(right-operand 0)'), body, message), 'mutated subtrahend was accepted')

    write (*, '(a)') 'frontend AST v2 raw counter_2 subtraction MIR checks: ok'

contains

    function witness() result(value)
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 100) (source-hash counter2-sub))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 100) '// &
            '(source-hash counter2-sub))))) (variable-count 1) (variable (variable-declaration '// &
            '(type-spec integer) (name counter_2) (span (source-span (file main.f90) '// &
            '(start-byte 10) (end-byte 25) (source-hash counter2-sub))))) (execution-part '// &
            '(assignment-sequence (assignment-count 2) (assignment (assignment-stmt '// &
            '(variable counter_2) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand 42) (right-operand ))) (span (source-span (file main.f90) '// &
            '(start-byte 30) (end-byte 47) (source-hash counter2-sub))))) (assignment (assignment-stmt '// &
            '(variable counter_2) (expression (assignment-expression (kind binary-expression) '// &
            '(operator -) (left-operand counter_2) (right-operand 1))) (span (source-span (file main.f90) '// &
            '(start-byte 48) (end-byte 70) (source-hash counter2-sub)))))) (print-stmt '// &
            '(format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name counter_2) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash counter2-sub))))'
    end function witness

    subroutine assert_storage(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'storage key missing')
        call assert_true(trim(body%instructions(index)%storage_key) == 'counter_2', 'storage key changed')
    end subroutine assert_storage

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

end program test_frontend_ast_v2_initialized_variable_counter2_subtract
