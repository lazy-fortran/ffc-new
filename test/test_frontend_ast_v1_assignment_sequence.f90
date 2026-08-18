program test_frontend_ast_v1_assignment_sequence
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v1_from_sx
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_const, opcode_load, &
        opcode_return, opcode_store, mir_validate_function_body
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(7)
    integer(int32) :: expected_literals(7)
    integer :: instruction_index

    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_return]
    expected_literals = [7_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32]
    if (.not. ffc_lower_frontend_ast_v1_from_sx(sequence_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'exact assignment sequence was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'sequence MIR is invalid')
    call assert_equal(body%function%name, 'main', 'sequence function name changed')
    call assert_true(body%function%instruction_count == 7, 'sequence instruction count changed')
    do instruction_index = 1, 7
        call assert_true(body%instructions(instruction_index)%opcode == expected_opcodes(instruction_index), &
            'sequence opcode order changed')
        call assert_true(body%instructions(instruction_index)%literal_value == expected_literals(instruction_index), &
            'sequence literal shape changed')
    end do
    call assert_true(body%instructions(1)%result%id == 0 .and. &
        body%instructions(2)%result%id == 1 .and. body%instructions(3)%result%id == 2 .and. &
        body%instructions(4)%result%id == 3 .and. body%instructions(5)%result%id == 4 .and. &
        body%instructions(6)%result%id == 4 .and. body%instructions(7)%result%id == 4, &
        'sequence result IDs changed')
    call assert_storage(2, 'x')
    call assert_storage(3, 'x')
    call assert_storage(6, 'x')
    call assert_no_storage(1)
    call assert_no_storage(4)
    call assert_no_storage(5)
    call assert_no_storage(7)

    call assert_rejected(swapped_sx(), 'swapped sequence was accepted')
    call assert_rejected(missing_second_sx(), 'missing second assignment was accepted')
    call assert_rejected(wrong_variable_sx(), 'wrong variable was accepted')
    call assert_rejected(wrong_operator_sx(), 'wrong operator was accepted')
    write (*, '(a)') 'frontend AST v1 assignment sequence behavioral checks: ok'

contains

    subroutine assert_storage(index, expected)
        integer, intent(in) :: index
        character(len=*), intent(in) :: expected

        call assert_true(allocated(body%instructions(index)%storage_key), &
            'required storage key is missing')
        call assert_equal(body%instructions(index)%storage_key, expected, &
            'storage key changed')
    end subroutine assert_storage

    subroutine assert_no_storage(index)
        integer, intent(in) :: index

        call assert_true(.not. allocated(body%instructions(index)%storage_key), &
            'unexpected storage key was emitted')
    end subroutine assert_no_storage

    subroutine assert_rejected(value, description)
        character(len=*), intent(in) :: value, description

        call assert_true(.not. ffc_lower_frontend_ast_v1_from_sx(value, body, message), description)
    end subroutine assert_rejected

    function sequence_sx() result(value)
        character(len=4096) :: value

        value = '(assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand 7) (right-operand ))) (span (source-span (file sequence.f90) '// &
            '(start-byte 41) (end-byte 47) (source-hash l3-raw-program-two-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 48) '// &
            '(end-byte 58) (source-hash l3-raw-program-two-assignment-v1))))))'
    end function sequence_sx

    function swapped_sx() result(value)
        character(len=4096) :: value

        value = sequence_sx()
        value = replace_text(value, '(left-operand 7)', '(left-operand x)')
        value = replace_text(value, '(operator +) (left-operand x) (right-operand 1)', &
            '(operator ) (left-operand 7) (right-operand )')
    end function swapped_sx

    function missing_second_sx() result(value)
        character(len=4096) :: value

        value = '(assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand 7) (right-operand ))) (span (source-span (file sequence.f90) '// &
            '(start-byte 41) (end-byte 47) (source-hash l3-raw-program-two-assignment-v1))))))'
    end function missing_second_sx

    function wrong_variable_sx() result(value)
        character(len=4096) :: value

        value = replace_text(sequence_sx(), '(variable x)', '(variable y)')
    end function wrong_variable_sx

    function wrong_operator_sx() result(value)
        character(len=4096) :: value

        value = replace_text(sequence_sx(), '(operator +) (left-operand x)', &
            '(operator *) (left-operand x)')
    end function wrong_operator_sx

    function replace_text(input, old, new) result(output)
        character(len=*), intent(in) :: input, old, new
        character(len=4096) :: output
        integer :: position

        output = input
        position = index(output, old)
        if (position > 0) output = output(:position - 1)//new//output(position + len(old):)
    end function replace_text

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

end program test_frontend_ast_v1_assignment_sequence
