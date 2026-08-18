program test_frontend_ast_v2_execution_part
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_const, opcode_load, &
        opcode_return, opcode_store, mir_validate_function_body
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(7)
    integer(int32) :: expected_ids(7)
    integer(int32) :: expected_opcodes_5(19)
    integer(int32) :: expected_ids_5(19)
    integer(int32) :: expected_opcodes_6(23)
    integer(int32) :: expected_ids_6(23)
    integer :: instruction_index

    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_return]
    expected_ids = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 4_int32]
    if (.not. ffc_lower_frontend_ast_v2_from_sx(envelope_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'exact program-unit-v2 envelope was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'v2 MIR is invalid')
    call assert_equal(body%function%name, 'main', 'v2 function name changed')
    do instruction_index = 1, 7
        call assert_true(body%instructions(instruction_index)%opcode == &
            expected_opcodes(instruction_index), &
            'v2 opcode order changed')
        call assert_true(body%instructions(instruction_index)%result%id == &
            expected_ids(instruction_index), &
            'v2 SSA result ID changed')
        call assert_equal(body%instructions(instruction_index)%source_rule, &
            'frontend-ast-v2/execution-part', 'v2 source rule changed')
    end do
    call assert_true(body%instructions(1)%literal_value == 7 .and. &
        body%instructions(4)%literal_value == 1, 'v2 literals changed')
    call assert_storage(2)
    call assert_storage(3)
    call assert_storage(6)
    call assert_no_storage(1)
    call assert_no_storage(4)
    call assert_no_storage(5)
    call assert_no_storage(7)

    expected_opcodes_5 = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, &
        opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_return]
    expected_ids_5 = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, &
        7_int32, 8_int32, 8_int32, 10_int32, 11_int32, 12_int32, 12_int32, 14_int32, &
        15_int32, 16_int32, 16_int32, 16_int32]
    if (.not. ffc_lower_frontend_ast_v2_from_sx(envelope_sx(5), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'exact five-assignment program-unit-v2 envelope was rejected'
    end if
    do instruction_index = 1, 19
        call assert_true(body%instructions(instruction_index)%opcode == &
            expected_opcodes_5(instruction_index), 'v2 count-5 opcode order changed')
        call assert_true(body%instructions(instruction_index)%result%id == &
            expected_ids_5(instruction_index), 'v2 count-5 SSA result ID changed')
        call assert_equal(body%instructions(instruction_index)%source_rule, &
            'frontend-ast-v2/execution-part-5', 'v2 count-5 source rule changed')
    end do
    call assert_true(body%instructions(1)%literal_value == 7 .and. &
        body%instructions(4)%literal_value == 1 .and. &
        body%instructions(8)%literal_value == 1 .and. &
        body%instructions(12)%literal_value == 1 .and. &
        body%instructions(16)%literal_value == 1, 'v2 count-5 literals changed')
    call assert_storage_indices([2, 3, 6, 7, 10, 11, 14, 15, 18])
    call assert_no_storage_indices([1, 4, 5, 8, 9, 12, 13, 16, 17, 19])

    expected_opcodes_6 = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, &
        opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_return]
    expected_ids_6 = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, &
        7_int32, 8_int32, 8_int32, 10_int32, 11_int32, 12_int32, 12_int32, 14_int32, &
        15_int32, 16_int32, 16_int32, 18_int32, 19_int32, 20_int32, 20_int32, 20_int32]
    if (.not. ffc_lower_frontend_ast_v2_from_sx(envelope_sx(6), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'exact six-assignment program-unit-v2 envelope was rejected'
    end if
    do instruction_index = 1, 23
        call assert_true(body%instructions(instruction_index)%opcode == &
            expected_opcodes_6(instruction_index), 'v2 count-6 opcode order changed')
        call assert_true(body%instructions(instruction_index)%result%id == &
            expected_ids_6(instruction_index), 'v2 count-6 SSA result ID changed')
        call assert_equal(body%instructions(instruction_index)%source_rule, &
            'frontend-ast-v2/execution-part-6', 'v2 count-6 source rule changed')
    end do
    call assert_true(body%instructions(1)%literal_value == 7 .and. &
        body%instructions(4)%literal_value == 1 .and. &
        body%instructions(8)%literal_value == 1 .and. &
        body%instructions(12)%literal_value == 1 .and. &
        body%instructions(16)%literal_value == 1 .and. &
        body%instructions(20)%literal_value == 1, 'v2 count-6 literals changed')
    call assert_storage_indices([2, 3, 6, 7, 10, 11, 14, 15, 18, 19, 22])
    call assert_no_storage_indices([1, 4, 5, 8, 9, 12, 13, 16, 17, 20, 21, 23])

    call assert_rejected(replace_text(envelope_sx(), 'program-unit-v2', 'program-unit'), &
        'wrong envelope was accepted')
    call assert_rejected(replace_text(envelope_sx(), '(type-spec integer)', &
        '(type-spec real)'), 'wrong type was accepted')
    call assert_rejected(replace_text(envelope_sx(), '(left-operand x) (right-operand 1)', &
        '(left-operand 1) (right-operand x)'), 'wrong execution order was accepted')
    write (*, '(a)') 'frontend AST v2 execution-part behavioral checks: ok'

contains

    function envelope_sx(count) result(value)
        integer, intent(in), optional :: count
        character(len=8192) :: value

        if (present(count)) then
            if (count == 5) then
                value = envelope_sx_five()
                return
            else if (count == 6) then
                value = envelope_sx_six()
                return
            end if
        end if
        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 64) (source-hash v2-test))))) '// &
            '(declaration-count 1) (declaration (program-declaration '// &
            '(declaration-kind program) (name main) (span (source-span (file main.f90) '// &
            '(start-byte 0) (end-byte 12) (source-hash v2-test))))) '// &
            '(variable-count 1) (variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file main.f90) (start-byte 13) (end-byte 27) '// &
            '(source-hash v2-test))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand 7) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 28) (end-byte 34) '// &
            '(source-hash l3-raw-program-two-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 36) (end-byte 46) '// &
            '(source-hash l3-raw-program-two-assignment-v1))))))))'
    end function envelope_sx

    function envelope_sx_five() result(value)
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 100) (source-hash v2-test))))) '// &
            '(declaration-count 1) (declaration (program-declaration '// &
            '(declaration-kind program) (name main) (span (source-span (file main.f90) '// &
            '(start-byte 0) (end-byte 12) (source-hash v2-test))))) '// &
            '(variable-count 1) (variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file main.f90) (start-byte 13) (end-byte 27) '// &
            '(source-hash v2-test))))) '// &
            '(execution-part (assignment-sequence (assignment-count 5) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand 7) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 28) (end-byte 34) '// &
            '(source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 36) (end-byte 46) '// &
            '(source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 48) (end-byte 58) '// &
            '(source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 60) (end-byte 70) '// &
            '(source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 72) (end-byte 82) '// &
            '(source-hash l3-raw-program-five-assignment-v1))))))))'
    end function envelope_sx_five

    function envelope_sx_six() result(value)
        character(len=8192) :: value

        value = envelope_sx_five()
        value = replace_text(value, '(assignment-count 5)', '(assignment-count 6)')
        value = replace_text(value, 'l3-raw-program-five-assignment-v1', &
            'l3-raw-program-six-assignment-v1')
        value = replace_text(value, 'l3-raw-program-five-assignment-v1', &
            'l3-raw-program-six-assignment-v1')
        value = replace_text(value, 'l3-raw-program-five-assignment-v1', &
            'l3-raw-program-six-assignment-v1')
        value = replace_text(value, 'l3-raw-program-five-assignment-v1', &
            'l3-raw-program-six-assignment-v1')
        value = replace_text(value, 'l3-raw-program-five-assignment-v1', &
            'l3-raw-program-six-assignment-v1')
        value = replace_last(value, &
            '(span (source-span (file main.f90) (start-byte 72) (end-byte 82) '// &
            '(source-hash l3-raw-program-six-assignment-v1)))))', &
            '(span (source-span (file main.f90) (start-byte 72) (end-byte 82) '// &
            '(source-hash l3-raw-program-six-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator +) (left-operand x) (right-operand 1))) '// &
            '(span (source-span (file main.f90) (start-byte 84) (end-byte 94) '// &
            '(source-hash l3-raw-program-six-assignment-v1)))))')
    end function envelope_sx_six

    subroutine assert_storage_indices(indices)
        integer, intent(in) :: indices(:)
        integer :: index

        do index = 1, size(indices)
            call assert_storage(indices(index))
        end do
    end subroutine assert_storage_indices

    subroutine assert_no_storage_indices(indices)
        integer, intent(in) :: indices(:)
        integer :: index

        do index = 1, size(indices)
            call assert_no_storage(indices(index))
        end do
    end subroutine assert_no_storage_indices

    subroutine assert_storage(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), &
            'required v2 storage key is missing')
        call assert_equal(body%instructions(index)%storage_key, 'x', &
            'v2 storage key changed')
    end subroutine assert_storage

    subroutine assert_no_storage(index)
        integer, intent(in) :: index

        call assert_true(.not. allocated(body%instructions(index)%storage_key), &
            'unexpected v2 storage key')
    end subroutine assert_no_storage

    subroutine assert_rejected(value, description)
        character(len=*), intent(in) :: value, description

        call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(value, body, message), description)
    end subroutine assert_rejected

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=8192) :: replaced
        integer :: start

        replaced = value
        start = index(replaced, old)
        if (start > 0) replaced = replaced(:start - 1)//new//replaced(start + len(old):)
    end function replace_text

    function replace_last(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=8192) :: replaced
        integer :: start, next, search_start

        replaced = value
        start = 0
        search_start = 1
        next = index(value(search_start:len_trim(value)), old)
        do while (next > 0)
            start = search_start + next - 1
            search_start = start + 1
            if (search_start > len_trim(value)) exit
            next = index(value(search_start:len_trim(value)), old)
        end do
        if (start > 0) then
            replaced = value(:start - 1)//new//value(start + len(old):)
        end if
    end function replace_last

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

end program test_frontend_ast_v2_execution_part
