program test_mir_opcode_histogram
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_opcode_histogram_at, &
        mir_instruction_t, mir_opcode_histogram_size, opcode_add, opcode_branch, &
        opcode_call, opcode_compare, opcode_div, opcode_load, opcode_mul, opcode_output, &
        opcode_return, opcode_store, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    integer(int32) :: histogram(mir_opcode_histogram_size)
    integer(int32) :: expected(mir_opcode_histogram_size)
    integer(int32) :: total
    character(len=:), allocatable :: message

    call make_empty_body(body)
    expected = 0_int32
    call assert_histogram(body, expected, 0_int32, 'empty body')

    call make_body(body, [opcode_add, opcode_add, opcode_return, opcode_add, opcode_return])
    expected = [3_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, 0_int32, &
        0_int32, 0_int32, 2_int32, 0_int32, 0_int32]
    call assert_histogram(body, expected, 5_int32, 'repeated opcodes')

    call make_body(body, [opcode_add, opcode_sub, opcode_mul, opcode_div, opcode_load, &
        opcode_store, opcode_compare, opcode_branch, opcode_call, opcode_return, opcode_output])
    expected = [1_int32, 1_int32, 1_int32, 1_int32, 1_int32, 1_int32, 1_int32, &
        1_int32, 1_int32, 1_int32, 0_int32, 1_int32]
    call assert_histogram(body, expected, 11_int32, 'all opcodes')

    call make_body(body, [opcode_add, opcode_return])
    histogram = 77_int32
    total = 88_int32
    body%function%instruction_count = 3_int32
    call assert_false(mir_function_opcode_histogram_at(body, histogram, total, message), &
        'malformed body was accepted')
    call assert_zero_histogram(histogram, 'malformed body left stale histogram output')
    call assert_equal_integer(total, 0_int32, 'malformed body left stale total output')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    call make_body(body, [opcode_add, opcode_return])
    histogram = 77_int32
    total = 88_int32
    body%instructions(1)%opcode = 0_int32
    call assert_false(mir_function_opcode_histogram_at(body, histogram, total, message), &
        'invalid opcode body was accepted')
    call assert_zero_histogram(histogram, 'invalid opcode left stale histogram output')
    call assert_equal_integer(total, 0_int32, 'invalid opcode left stale total output')

    write (*, '(a)') 'mir opcode-histogram behavioral checks: ok'

contains

    subroutine make_empty_body(body)
        type(mir_function_body_t), intent(out) :: body

        body%function%name = 'empty'
        body%function%entry_block = 0_int32
        allocate (body%instructions(0))
        body%function%instruction_count = 0_int32
    end subroutine make_empty_body

    subroutine make_body(body, opcodes)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), intent(in) :: opcodes(:)
        integer :: index

        body%function%name = 'histogram'
        body%function%entry_block = 0_int32
        allocate (body%instructions(size(opcodes)))
        body%function%instruction_count = int(size(opcodes), int32)
        do index = 1, size(opcodes)
            call make_instruction(body%instructions(index), index - 1, opcodes(index))
        end do
    end subroutine make_body

    subroutine make_instruction(instruction, id, opcode)
        type(mir_instruction_t), intent(out) :: instruction
        integer, intent(in) :: id
        integer(int32), intent(in) :: opcode

        instruction%id = int(id, int32)
        instruction%opcode = opcode
        instruction%result%id = int(id + 1, int32)
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = 'test/opcode-histogram'
    end subroutine make_instruction

    subroutine assert_histogram(body, expected_histogram, expected_total, description)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: expected_histogram(:)
        integer(int32), intent(in) :: expected_total
        character(len=*), intent(in) :: description

        call assert_true(mir_function_opcode_histogram_at(body, histogram, total, message), &
            trim(description)//' was rejected')
        call assert_true(all(histogram == expected_histogram), &
            trim(description)//' histogram changed')
        call assert_equal_integer(total, expected_total, trim(description)//' total changed')
        call assert_false(allocated(message), trim(description)//' produced a diagnostic')
    end subroutine assert_histogram

    subroutine assert_zero_histogram(actual, description)
        integer(int32), intent(in) :: actual(:)
        character(len=*), intent(in) :: description

        call assert_true(all(actual == 0_int32), description)
    end subroutine assert_zero_histogram

    subroutine assert_true(condition, description)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: description

        if (.not. condition) error stop description
    end subroutine assert_true

    subroutine assert_false(condition, description)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: description

        call assert_true(.not. condition, description)
    end subroutine assert_false

    subroutine assert_equal(actual, expected_value, description)
        character(len=*), intent(in) :: actual, expected_value, description

        call assert_true(trim(actual) == trim(expected_value), description)
    end subroutine assert_equal

    subroutine assert_equal_integer(actual, expected_value, description)
        integer(int32), intent(in) :: actual, expected_value
        character(len=*), intent(in) :: description

        call assert_true(actual == expected_value, description)
    end subroutine assert_equal_integer

end program test_mir_opcode_histogram
