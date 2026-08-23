program test_frontend_ast_v1_assignment_sequence
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v1_from_sx, &
        ffc_lower_frontend_ast_v1_assignment_sequence_from_sx
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_const, opcode_load, &
        opcode_return, opcode_store, mir_validate_function_body
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(11)
    integer(int32) :: expected_literals(11)
    integer :: instruction_index

    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_return]
    expected_literals = [7_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, &
        1_int32, 0_int32, 0_int32, 0_int32]
    if (.not. ffc_lower_frontend_ast_v1_from_sx(sequence_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'exact assignment sequence was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'sequence MIR is invalid')
    call assert_equal(body%function%name, 'main', 'sequence function name changed')
    call assert_true(body%function%instruction_count == 11, 'sequence instruction count changed')
    do instruction_index = 1, 11
        call assert_true(body%instructions(instruction_index)%opcode == expected_opcodes(instruction_index), &
            'sequence opcode order changed')
        call assert_true(body%instructions(instruction_index)%literal_value == expected_literals(instruction_index), &
            'sequence literal shape changed')
    end do
    call assert_true(body%instructions(1)%result%id == 0 .and. &
        body%instructions(2)%result%id == 1 .and. body%instructions(3)%result%id == 2 .and. &
        body%instructions(4)%result%id == 3 .and. body%instructions(5)%result%id == 4 .and. &
        body%instructions(6)%result%id == 4 .and. body%instructions(7)%result%id == 6 .and. &
        body%instructions(8)%result%id == 7 .and. body%instructions(9)%result%id == 8 .and. &
        body%instructions(10)%result%id == 8 .and. body%instructions(11)%result%id == 8, &
        'sequence result IDs changed')
    call assert_storage(2, 'x')
    call assert_storage(3, 'x')
    call assert_storage(6, 'x')
    call assert_storage(7, 'x')
    call assert_storage(10, 'x')
    call assert_no_storage(1)
    call assert_no_storage(4)
    call assert_no_storage(5)
    call assert_no_storage(8)
    call assert_no_storage(9)
    call assert_no_storage(11)

    call assert_rejected(wrong_order_sx(), 'wrong-order sequence was accepted')
    call assert_rejected(missing_third_sx(), 'missing-third sequence was accepted')
    call assert_rejected(wrong_operator_sx(), 'wrong-operator sequence was accepted')
    call assert_count4()
    call assert_count5()
    call assert_count6()
    call assert_generated_count(7)
    call assert_generated_count(8)
    call assert_generated_count(9)
    call assert_generated_count(10)
    call assert_generic_novel()
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

        value = '(assignment-sequence (assignment-count 3) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand 7) (right-operand ))) (span (source-span (file sequence.f90) '// &
            '(start-byte 41) (end-byte 47) (source-hash l3-raw-program-three-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 48) '// &
            '(end-byte 58) (source-hash l3-raw-program-three-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 59) '// &
            '(end-byte 69) (source-hash l3-raw-program-three-assignment-v1))))))'
    end function sequence_sx

    function wrong_order_sx() result(value)
        character(len=4096) :: value

        value = sequence_sx()
        value = replace_text(value, '(kind integer-literal)', '(kind binary-expression)')
    end function wrong_order_sx

    function missing_third_sx() result(value)
        character(len=4096) :: value

        value = '(assignment-sequence (assignment-count 3) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand 7) (right-operand ))) (span (source-span (file sequence.f90) '// &
            '(start-byte 41) (end-byte 47) (source-hash l3-raw-program-three-assignment-v1)))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 48) '// &
            '(end-byte 58) (source-hash l3-raw-program-three-assignment-v1))))))'
    end function missing_third_sx

    function wrong_operator_sx() result(value)
        character(len=4096) :: value

        value = replace_text(sequence_sx(), '(operator +) (left-operand x)', &
            '(operator *) (left-operand x)')
    end function wrong_operator_sx

    subroutine assert_count4()
        integer(int32) :: opcodes(15)
        integer(int32) :: literals(15)
        integer(int32) :: result_ids(15)
        integer :: index

        opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, &
            opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, &
            opcode_add, opcode_store, opcode_return]
        literals = [7_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 1_int32, &
            0_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32]
        result_ids = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 7_int32, &
            8_int32, 8_int32, 10_int32, 11_int32, 12_int32, 12_int32, 12_int32]
        if (.not. ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(sequence4_sx(), body, message)) then
            error stop 'four-assignment sequence was rejected'
        end if
        call assert_true(body%function%instruction_count == 15, 'four-assignment instruction count changed')
        do index = 1, 15
            call assert_true(body%instructions(index)%opcode == opcodes(index), &
                'four-assignment opcode order changed')
            call assert_true(body%instructions(index)%literal_value == literals(index), &
                'four-assignment literal shape changed')
            call assert_true(body%instructions(index)%result%id == result_ids(index), &
                'four-assignment result IDs changed')
            call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v1/storage-sequence-4', &
                'four-assignment source rule changed')
        end do
        call assert_storage4(2)
        call assert_storage4(3)
        call assert_storage4(6)
        call assert_storage4(7)
        call assert_storage4(10)
        call assert_storage4(11)
        call assert_storage4(14)
    end subroutine assert_count4

    subroutine assert_count5()
        integer(int32) :: opcodes(19)
        integer(int32) :: literals(19)
        integer(int32) :: result_ids(19)
        integer :: index

        opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, &
            opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, &
            opcode_add, opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_return]
        literals = [7_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 1_int32, &
            0_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 1_int32, 0_int32, &
            0_int32, 0_int32]
        result_ids = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 7_int32, &
            8_int32, 8_int32, 10_int32, 11_int32, 12_int32, 12_int32, 14_int32, 15_int32, &
            16_int32, 16_int32, 16_int32]
        if (.not. ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(sequence5_sx(), body, message)) then
            error stop 'five-assignment sequence was rejected'
        end if
        call assert_true(body%function%instruction_count == 19, 'five-assignment instruction count changed')
        do index = 1, 19
            call assert_true(body%instructions(index)%opcode == opcodes(index), &
                'five-assignment opcode order changed')
            call assert_true(body%instructions(index)%literal_value == literals(index), &
                'five-assignment literal shape changed')
            call assert_true(body%instructions(index)%result%id == result_ids(index), &
                'five-assignment result IDs changed')
            call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v1/storage-sequence-5', &
                'five-assignment source rule changed')
        end do
        do index = 2, 18
            if (mod(index - 2, 4) <= 1) call assert_storage5(index)
        end do
        call assert_no_storage5(1)
        call assert_no_storage5(4)
        call assert_no_storage5(5)
        call assert_no_storage5(8)
        call assert_no_storage5(9)
        call assert_no_storage5(12)
        call assert_no_storage5(13)
        call assert_no_storage5(16)
        call assert_no_storage5(17)
        call assert_no_storage5(19)
        call assert_rejected(sequence5_wrong_count_sx(), 'wrong count-five sequence was accepted')
    end subroutine assert_count5

    subroutine assert_count6()
        integer(int32) :: opcodes(23)
        integer(int32) :: literals(23)
        integer(int32) :: result_ids(23)
        integer :: index

        opcodes = [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, &
            opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, opcode_add, &
            opcode_store, opcode_load, opcode_const, opcode_add, opcode_store, opcode_load, opcode_const, &
            opcode_add, opcode_store, opcode_return]
        literals = [7_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 1_int32, 0_int32, &
            0_int32, 0_int32, 1_int32, 0_int32, 0_int32, 0_int32, 1_int32, 0_int32, 0_int32, &
            0_int32, 1_int32, 0_int32, 0_int32, 0_int32]
        result_ids = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, 6_int32, 7_int32, &
            8_int32, 8_int32, 10_int32, 11_int32, 12_int32, 12_int32, 14_int32, 15_int32, &
            16_int32, 16_int32, 18_int32, 19_int32, 20_int32, 20_int32, 20_int32]
        if (.not. ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(sequence6_sx(), body, message)) then
            error stop 'six-assignment sequence was rejected'
        end if
        call assert_true(body%function%instruction_count == 23, 'six-assignment instruction count changed')
        do index = 1, 23
            call assert_true(body%instructions(index)%opcode == opcodes(index), 'six-assignment opcode order changed')
            call assert_true(body%instructions(index)%literal_value == literals(index), 'six-assignment literal shape changed')
            call assert_true(body%instructions(index)%result%id == result_ids(index), 'six-assignment result IDs changed')
            call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v1/storage-sequence-6', &
                'six-assignment source rule changed')
            if (body%instructions(index)%opcode == opcode_load .or. body%instructions(index)%opcode == opcode_store) then
                call assert_true(allocated(body%instructions(index)%storage_key), 'six-assignment storage key missing')
                call assert_equal(body%instructions(index)%storage_key, 'x', 'six-assignment storage key changed')
            else
                call assert_true(.not. allocated(body%instructions(index)%storage_key), &
                    'six-assignment storage key was unexpected')
            end if
        end do
    end subroutine assert_count6

    subroutine assert_generated_count(assignment_count)
        integer, intent(in) :: assignment_count

        integer :: index, instruction_count
        integer(int32) :: expected_opcode, expected_result_id
        character(len=64) :: expected_source_rule

        instruction_count = 4 * assignment_count - 1
        write (expected_source_rule, '(a,i0)') 'frontend-ast-v1/storage-sequence-', assignment_count
        if (.not. ffc_lower_frontend_ast_v1_assignment_sequence_from_sx( &
            sequence_n_sx(assignment_count), body, message)) then
            error stop 'generated assignment sequence was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'generated sequence MIR is invalid')
        call assert_true(body%function%instruction_count == instruction_count, &
            'generated sequence instruction count changed')
        do index = 1, instruction_count
            expected_opcode = generated_opcode(index, assignment_count)
            expected_result_id = generated_result_id(index, assignment_count)
            call assert_true(body%instructions(index)%opcode == expected_opcode, &
                'generated sequence opcode shape changed')
            call assert_true(body%instructions(index)%result%id == expected_result_id, &
                'generated sequence result IDs changed')
            call assert_equal(body%instructions(index)%source_rule, expected_source_rule, &
                'generated sequence source rule changed')
            if (expected_opcode == opcode_load .or. expected_opcode == opcode_store) then
                call assert_true(allocated(body%instructions(index)%storage_key), &
                    'generated sequence storage key missing')
                call assert_equal(body%instructions(index)%storage_key, 'x', &
                    'generated sequence storage key changed')
            else
                call assert_true(.not. allocated(body%instructions(index)%storage_key), &
                    'generated sequence storage key was unexpected')
            end if
        end do
        call assert_rejected(replace_text(sequence_n_sx(assignment_count), '(operator +)', '(operator *)'), &
            'mutated generated sequence was accepted')
        call assert_rejected(replace_text(sequence_n_sx(assignment_count), &
            '(assignment-count '//trim(adjustl(itoa(assignment_count)))//')', &
            '(assignment-count '//trim(adjustl(itoa(assignment_count + 1)))//')'), &
            'wrong-count generated sequence was accepted')
    end subroutine assert_generated_count

    subroutine assert_generic_novel()
        integer :: index

        if (.not. ffc_lower_frontend_ast_v1_assignment_sequence_from_sx(novel_sequence_sx(), body, message)) then
            error stop 'novel generic assignment sequence was rejected'
        end if
        call assert_true(body%function%instruction_count == 11, 'novel sequence instruction count changed')
        call assert_true(body%instructions(1)%literal_value == 42, 'novel sequence literal changed')
        do index = 2, 10
            if (body%instructions(index)%opcode == opcode_load .or. &
                body%instructions(index)%opcode == opcode_store) then
                call assert_storage(index, 'y')
            end if
        end do
        body%instructions(6)%id = 99_int32
        call assert_true(.not. mir_validate_function_body(body, message), &
            'corrupted generic sequence MIR was accepted')
        call assert_rejected(replace_text(novel_sequence_sx(), '(right-operand 1)', '(right-operand 2048)'), &
            'corrupted intermediate assignment was accepted')
    end subroutine assert_generic_novel

    function novel_sequence_sx() result(value)
        character(len=4096) :: value

        value = replace_text(replace_text(replace_text(replace_text(sequence_sx(), '(variable x)', '(variable y)'), &
            '(variable x)', '(variable y)'), '(variable x)', '(variable y)'), '(left-operand 7)', '(left-operand 42)')
    end function novel_sequence_sx

    integer(int32) function generated_opcode(index, assignment_count)
        integer, intent(in) :: index, assignment_count

        if (index == 1) then
            generated_opcode = opcode_const
        else if (index == 2) then
            generated_opcode = opcode_store
        else if (index == 4 * assignment_count - 1) then
            generated_opcode = opcode_return
        else
            select case (mod(index - 3, 4))
            case (0); generated_opcode = opcode_load
            case (1); generated_opcode = opcode_const
            case (2); generated_opcode = opcode_add
            case default; generated_opcode = opcode_store
            end select
        end if
    end function generated_opcode

    integer(int32) function generated_result_id(index, assignment_count)
        integer, intent(in) :: index, assignment_count

        if (index == 1) then
            generated_result_id = 0_int32
        else if (index == 2) then
            generated_result_id = 1_int32
        else if (index == 4 * assignment_count - 1) then
            generated_result_id = 4 * assignment_count - 4
        else if (mod(index - 3, 4) == 3) then
            generated_result_id = index - 2
        else
            generated_result_id = index - 1
        end if
    end function generated_result_id

    function sequence_n_sx(assignment_count) result(value)
        integer, intent(in) :: assignment_count
        character(len=16384) :: value
        character(len=32) :: count_text
        integer :: index

        write (count_text, '(i0)') assignment_count
        value = '(assignment-sequence (assignment-count '//trim(count_text)//')'
        value = trim(value)//' (assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) (left-operand 7) '// &
            '(right-operand ))) (span (source-span (file sequence.f90) (start-byte 0) '// &
            '(end-byte 1) (source-hash generated-sequence-v1)))))'
        do index = 2, assignment_count
            value = trim(value)//' (assignment (assignment-stmt (variable x) (expression '// &
                '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
                '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 0) '// &
                '(end-byte 1) (source-hash generated-sequence-v1)))))'
        end do
        value = trim(value)//')'
    end function sequence_n_sx

    function itoa(value) result(text)
        integer, intent(in) :: value
        character(len=16) :: text

        write (text, '(i0)') value
    end function itoa

    subroutine assert_storage5(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'five-assignment storage key missing')
        call assert_equal(body%instructions(index)%storage_key, 'x', 'five-assignment storage key changed')
    end subroutine assert_storage5

    subroutine assert_no_storage5(index)
        integer, intent(in) :: index

        call assert_true(.not. allocated(body%instructions(index)%storage_key), &
            'five-assignment storage key was unexpected')
    end subroutine assert_no_storage5

    subroutine assert_storage4(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'four-assignment storage key missing')
        call assert_equal(body%instructions(index)%storage_key, 'x', 'four-assignment storage key changed')
    end subroutine assert_storage4

    function sequence4_sx() result(value)
        character(len=4096) :: value

        value = '(assignment-sequence (assignment-count 4) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) (left-operand 7) '// &
            '(right-operand ))) (span (source-span (file sequence.f90) (start-byte 41) '// &
            '(end-byte 47) (source-hash l3-raw-program-four-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 48) '// &
            '(end-byte 58) (source-hash l3-raw-program-four-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 59) '// &
            '(end-byte 69) (source-hash l3-raw-program-four-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 70) '// &
            '(end-byte 80) (source-hash l3-raw-program-four-assignment-v1))))))'
    end function sequence4_sx

    function sequence5_sx() result(value)
        character(len=4096) :: value

        value = '(assignment-sequence (assignment-count 5) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind integer-literal) (operator ) (left-operand 7) '// &
            '(right-operand ))) (span (source-span (file sequence.f90) (start-byte 41) '// &
            '(end-byte 47) (source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 48) '// &
            '(end-byte 58) (source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 59) '// &
            '(end-byte 69) (source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 70) '// &
            '(end-byte 80) (source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 81) '// &
            '(end-byte 91) (source-hash l3-raw-program-five-assignment-v1))))))'
    end function sequence5_sx

    function sequence5_wrong_count_sx() result(value)
        character(len=4096) :: value

        value = replace_text(sequence5_sx(), '(assignment-count 5)', '(assignment-count 4)')
    end function sequence5_wrong_count_sx

    function sequence6_sx() result(value)
        character(len=8192) :: value

        value = replace_text(sequence5_sx(), '(assignment-count 5)', '(assignment-count 6)')
        value = replace_text(value, '(end-byte 91) (source-hash l3-raw-program-five-assignment-v1))))))', &
            '(end-byte 91) (source-hash l3-raw-program-five-assignment-v1))))) '// &
            '(assignment (assignment-stmt (variable x) (expression '// &
            '(assignment-expression (kind binary-expression) (operator +) (left-operand x) '// &
            '(right-operand 1))) (span (source-span (file sequence.f90) (start-byte 92) '// &
            '(end-byte 102) (source-hash l3-raw-program-five-assignment-v1))))))')
    end function sequence6_sx

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
