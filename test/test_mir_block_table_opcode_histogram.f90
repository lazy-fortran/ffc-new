program test_mir_block_table_opcode_histogram
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_block_table_opcode_histogram_at, &
        mir_function_body_t, mir_instruction_t, mir_opcode_histogram_size, &
        mir_validate_function_block_table, opcode_add, opcode_branch, opcode_call, &
        opcode_compare, opcode_const, opcode_div, opcode_load, opcode_mul, opcode_output, &
        opcode_pow, opcode_return, opcode_store, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    integer(int32) :: histogram(mir_opcode_histogram_size)
    integer(int32) :: total
    character(len=:), allocatable :: message

    call make_body(body)
    call make_table(table)
    call assert_true(mir_validate_function_block_table(body, table, message), &
        'valid block table was rejected')
    call assert_histogram(body, table, 2_int32, 'all opcode bins', .true.)
    call assert_histogram(body, table, 1_int32, 'empty selected range', .true.)

    body%instructions(1)%opcode = opcode_pow
    body%instructions(16)%opcode = opcode_const
    call assert_histogram(body, table, 2_int32, 'selected-range isolation', .true.)

    call make_body(body)
    call make_table(table)
    histogram = 77_int32
    total = 88_int32
    call assert_false(mir_function_block_table_opcode_histogram_at(body, table, -1_int32, &
        histogram, total, message), 'negative block index was accepted')
    call assert_cleared(histogram, total, 'negative block index failure did not clear output')
    call assert_equal(message, 'block index must be non-negative', &
        'negative block index diagnostic changed')

    histogram = 77_int32
    total = 88_int32
    call assert_false(mir_function_block_table_opcode_histogram_at(body, table, 4_int32, &
        histogram, total, message), 'out-of-range block index was accepted')
    call assert_cleared(histogram, total, 'out-of-range block failure did not clear output')
    call assert_equal(message, 'block index is outside block table', &
        'out-of-range block diagnostic changed')

    body%function%instruction_count = 15_int32
    call assert_rejected(body, table, 'malformed body count', &
        'function instruction count does not match body')

    call make_body(body)
    body%instructions(6)%opcode = 0_int32
    call assert_rejected(body, table, 'invalid opcode', 'instruction opcode is outside mir-v0')

    call make_body(body)
    call make_table(table)
    deallocate (table%ranges)
    call assert_rejected(body, table, 'unallocated table', 'block table ranges must be allocated')

    call make_table(table)
    deallocate (table%ranges)
    allocate (table%ranges(0))
    call assert_rejected(body, table, 'empty table', 'block table must contain at least one range')

    call make_table(table)
    table%ranges(3)%first_instruction = 3_int32
    call assert_rejected(body, table, 'non-contiguous table', 'block table ranges are not contiguous')

    call make_table(table)
    table%ranges(4)%instruction_count = 0_int32
    call assert_rejected(body, table, 'incomplete table', 'block table does not cover function body')

    write (*, '(a)') 'mir block table opcode-histogram behavioral checks: ok'

contains

    subroutine assert_histogram(body, table, block_index, description, expected_valid)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(in) :: block_index
        character(len=*), intent(in) :: description
        logical, intent(in) :: expected_valid

        integer(int32) :: expected(mir_opcode_histogram_size)
        integer(int32) :: expected_total

        call direct_histogram(body, table, block_index, expected, expected_total)
        call assert_true(mir_function_block_table_opcode_histogram_at(body, table, block_index, &
            histogram, total, message) .eqv. expected_valid, trim(description)//' validity changed')
        call assert_true(all(histogram == expected), trim(description)//' histogram changed')
        call assert_equal_integer(total, expected_total, trim(description)//' total changed')
        call assert_false(allocated(message), trim(description)//' produced a diagnostic')
    end subroutine assert_histogram

    subroutine direct_histogram(body, table, block_index, expected, expected_total)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(in) :: block_index
        integer(int32), intent(out) :: expected(mir_opcode_histogram_size)
        integer(int32), intent(out) :: expected_total

        integer(int32) :: first_instruction, instruction_count, offset, opcode

        expected = 0_int32
        expected_total = 0_int32
        first_instruction = table%ranges(block_index + 1_int32)%first_instruction
        instruction_count = table%ranges(block_index + 1_int32)%instruction_count
        do offset = 0_int32, instruction_count - 1_int32
            opcode = body%instructions(first_instruction + offset + 1_int32)%opcode
            expected(opcode) = expected(opcode) + 1_int32
            expected_total = expected_total + 1_int32
        end do
    end subroutine direct_histogram

    subroutine assert_rejected(body, table, description, expected_message)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        character(len=*), intent(in) :: description, expected_message

        histogram = 77_int32
        total = 88_int32
        call assert_false(mir_function_block_table_opcode_histogram_at(body, table, 2_int32, &
            histogram, total, message), trim(description)//' was accepted')
        call assert_cleared(histogram, total, trim(description)//' did not clear output')
        call assert_equal(message, expected_message, trim(description)//' diagnostic changed')
    end subroutine assert_rejected

    subroutine make_body(body)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), parameter :: opcodes(16) = [opcode_add, opcode_sub, opcode_add, &
            opcode_sub, opcode_mul, opcode_div, opcode_load, opcode_store, opcode_compare, &
            opcode_branch, opcode_call, opcode_return, opcode_const, opcode_output, opcode_pow, &
            opcode_return]
        integer(int32) :: index

        body%function%name = 'block-histogram'
        body%function%entry_block = 0_int32
        body%function%instruction_count = int(size(opcodes), int32)
        allocate (body%instructions(size(opcodes)))
        do index = 1, int(size(opcodes), int32)
            call set_instruction(body%instructions(index), index - 1_int32, opcodes(index))
        end do
    end subroutine make_body

    subroutine make_table(table)
        type(mir_block_table_t), intent(out) :: table

        allocate (table%ranges(4))
        table%ranges(1)%first_instruction = 0_int32
        table%ranges(1)%instruction_count = 2_int32
        table%ranges(2)%first_instruction = 2_int32
        table%ranges(2)%instruction_count = 0_int32
        table%ranges(3)%first_instruction = 2_int32
        table%ranges(3)%instruction_count = 13_int32
        table%ranges(4)%first_instruction = 15_int32
        table%ranges(4)%instruction_count = 1_int32
    end subroutine make_table

    subroutine set_instruction(instruction, id, opcode)
        type(mir_instruction_t), intent(out) :: instruction
        integer(int32), intent(in) :: id, opcode

        instruction%id = id
        instruction%opcode = opcode
        instruction%result%id = 1_int32
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = 'test/block-table-opcode-histogram'
    end subroutine set_instruction

    subroutine assert_cleared(actual, actual_total, description)
        integer(int32), intent(in) :: actual(:), actual_total
        character(len=*), intent(in) :: description

        call assert_true(all(actual == 0_int32), description)
        call assert_equal_integer(actual_total, 0_int32, description)
    end subroutine assert_cleared

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

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

    subroutine assert_equal_integer(actual, expected, description)
        integer(int32), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal_integer

end program test_mir_block_table_opcode_histogram
