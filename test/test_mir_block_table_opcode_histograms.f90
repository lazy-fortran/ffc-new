program test_mir_block_table_opcode_histograms
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_block_table_opcode_histograms, &
        mir_function_body_t, mir_instruction_t, mir_opcode_histogram_size, opcode_add, &
        opcode_branch, opcode_call, opcode_compare, opcode_const, opcode_div, opcode_load, &
        opcode_mul, opcode_output, opcode_pow, opcode_return, opcode_store, opcode_sub, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    integer(int32), allocatable :: histograms(:, :), expected(:, :)
    integer(int32), allocatable :: totals(:), expected_totals(:)
    integer(int32) :: block_count
    character(len=:), allocatable :: message

    call make_body(body)
    call make_table(table)
    allocate (histograms(mir_opcode_histogram_size, 5), expected(mir_opcode_histogram_size, 5))
    allocate (totals(5), expected_totals(5))
    call direct_histograms(body, table, expected, expected_totals)
    call assert_true(mir_function_block_table_opcode_histograms(body, table, histograms, &
        totals, block_count, message), 'valid whole-table query was rejected')
    call assert_equal_matrix(histograms, expected, 'whole-table histogram changed')
    call assert_true(all(totals == expected_totals), 'whole-table totals changed')
    call assert_equal_integer(block_count, 5_int32, 'block count changed')
    call assert_false(allocated(message), 'valid whole-table query produced a diagnostic')
    call assert_true(all(expected(:, 1) + expected(:, 2) + expected(:, 3) + expected(:, 4) + &
        expected(:, 5) > 0_int32), 'all opcode bins were not represented across the table')
    call assert_equal_integer(totals(2), 0_int32, 'empty range total changed')

    body%instructions(1)%opcode = opcode_pow
    call direct_histograms(body, table, expected, expected_totals)
    call assert_true(mir_function_block_table_opcode_histograms(body, table, histograms, &
        totals, block_count, message), 'retry after source mutation was rejected')
    call assert_equal_matrix(histograms, expected, 'source-order column isolation changed')
    call assert_equal_integer(totals(1), 3_int32, 'mutated first block total changed')

    histograms = 77_int32
    totals = 88_int32
    call assert_false(mir_function_block_table_opcode_histograms(body, table, &
        histograms(1:mir_opcode_histogram_size - 1, :), totals, block_count, message), &
        'short opcode dimension was accepted')
    call assert_cleared(histograms(1:mir_opcode_histogram_size - 1, :), totals, block_count, &
        'short opcode dimension was not cleared')
    call assert_equal(message, 'histogram output has insufficient opcode capacity', &
        'short opcode dimension diagnostic changed')

    histograms = 77_int32
    totals = 88_int32
    call assert_false(mir_function_block_table_opcode_histograms(body, table, &
        histograms(:, 1:4), totals, block_count, message), 'short histogram block dimension was accepted')
    call assert_cleared(histograms(:, 1:4), totals, block_count, &
        'short histogram block dimension was not cleared')
    call assert_equal(message, 'histogram output has insufficient block capacity', &
        'short histogram block diagnostic changed')

    histograms = 77_int32
    totals = 88_int32
    call assert_false(mir_function_block_table_opcode_histograms(body, table, histograms, &
        totals(1:4), block_count, message), 'short totals dimension was accepted')
    call assert_cleared(histograms, totals(1:4), block_count, 'short totals dimension was not cleared')
    call assert_equal(message, 'totals output has insufficient block capacity', &
        'short totals diagnostic changed')

    body%function%instruction_count = 17_int32
    call assert_rejected(body, table, 'malformed body', &
        'function instruction count does not match body')
    call make_body(body)
    body%instructions(6)%opcode = 0_int32
    call assert_rejected(body, table, 'malformed instruction', 'instruction opcode is outside mir-v0')
    call make_body(body)
    deallocate (table%ranges)
    call assert_rejected(body, table, 'unallocated table', 'block table ranges must be allocated')
    call make_table(table)
    table%ranges(3)%first_instruction = 4_int32
    call assert_rejected(body, table, 'non-contiguous table', 'block table ranges are not contiguous')
    call make_table(table)
    table%ranges(5)%instruction_count = 5_int32
    call assert_rejected(body, table, 'incomplete table', 'block table does not cover function body')

    call make_body(body)
    call make_table(table)
    histograms = 77_int32
    totals = 88_int32
    call assert_true(mir_function_block_table_opcode_histograms(body, table, histograms, &
        totals, block_count, message), 'successful retry was rejected')
    call direct_histograms(body, table, expected, expected_totals)
    call assert_equal_matrix(histograms, expected, 'successful retry histogram changed')
    call assert_true(all(totals == expected_totals), 'successful retry totals changed')
    call assert_equal_integer(block_count, 5_int32, 'successful retry block count changed')

    write (*, '(a)') 'mir block table opcode-histograms behavioral checks: ok'

contains

    subroutine direct_histograms(body, table, expected, expected_totals)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(out) :: expected(:, :), expected_totals(:)

        integer(int32) :: block_index, first_instruction, instruction_count
        integer(int32) :: offset, opcode

        expected = 0_int32
        expected_totals = 0_int32
        do block_index = 1, int(size(table%ranges), int32)
            first_instruction = table%ranges(block_index)%first_instruction
            instruction_count = table%ranges(block_index)%instruction_count
            do offset = 0_int32, instruction_count - 1_int32
                opcode = body%instructions(first_instruction + offset + 1_int32)%opcode
                expected(opcode, block_index) = expected(opcode, block_index) + 1_int32
                expected_totals(block_index) = expected_totals(block_index) + 1_int32
            end do
        end do
    end subroutine direct_histograms

    subroutine assert_rejected(body, table, description, expected_message)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        character(len=*), intent(in) :: description, expected_message

        histograms = 77_int32
        totals = 88_int32
        block_count = 99_int32
        call assert_false(mir_function_block_table_opcode_histograms(body, table, histograms, &
            totals, block_count, message), trim(description)//' was accepted')
        call assert_cleared(histograms, totals, block_count, trim(description)//' did not clear output')
        call assert_equal(message, expected_message, trim(description)//' diagnostic changed')
    end subroutine assert_rejected

    subroutine make_body(body)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), parameter :: opcodes(18) = [opcode_add, opcode_sub, opcode_mul, &
            opcode_div, opcode_load, opcode_store, opcode_compare, opcode_branch, opcode_call, &
            opcode_return, opcode_const, opcode_output, opcode_pow, opcode_add, opcode_load, &
            opcode_return, opcode_sub, opcode_const]
        integer(int32) :: index

        body%function%name = 'block-histograms'
        body%function%entry_block = 0_int32
        body%function%instruction_count = int(size(opcodes), int32)
        allocate (body%instructions(size(opcodes)))
        do index = 1, int(size(opcodes), int32)
            call set_instruction(body%instructions(index), index - 1_int32, opcodes(index))
        end do
    end subroutine make_body

    subroutine make_table(table)
        type(mir_block_table_t), intent(out) :: table

        allocate (table%ranges(5))
        table%ranges(1)%first_instruction = 0_int32
        table%ranges(1)%instruction_count = 3_int32
        table%ranges(2)%first_instruction = 3_int32
        table%ranges(2)%instruction_count = 0_int32
        table%ranges(3)%first_instruction = 3_int32
        table%ranges(3)%instruction_count = 5_int32
        table%ranges(4)%first_instruction = 8_int32
        table%ranges(4)%instruction_count = 4_int32
        table%ranges(5)%first_instruction = 12_int32
        table%ranges(5)%instruction_count = 6_int32
    end subroutine make_table

    subroutine set_instruction(instruction, id, opcode)
        type(mir_instruction_t), intent(out) :: instruction
        integer(int32), intent(in) :: id, opcode

        instruction%id = id
        instruction%opcode = opcode
        instruction%result%id = 1_int32
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = 'test/block-table-opcode-histograms'
    end subroutine set_instruction

    subroutine assert_cleared(actual, actual_totals, actual_block_count, description)
        integer(int32), intent(in) :: actual(:, :), actual_totals(:), actual_block_count
        character(len=*), intent(in) :: description

        call assert_true(all(actual == 0_int32), description)
        call assert_true(all(actual_totals == 0_int32), description)
        call assert_equal_integer(actual_block_count, 0_int32, description)
    end subroutine assert_cleared

    subroutine assert_equal_matrix(actual, expected_value, description)
        integer(int32), intent(in) :: actual(:, :), expected_value(:, :)
        character(len=*), intent(in) :: description

        call assert_true(all(actual == expected_value), description)
    end subroutine assert_equal_matrix

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

    subroutine assert_equal(actual, expected_value, description)
        character(len=*), intent(in) :: actual, expected_value, description

        call assert_true(trim(actual) == trim(expected_value), description)
    end subroutine assert_equal

    subroutine assert_equal_integer(actual, expected_value, description)
        integer(int32), intent(in) :: actual, expected_value
        character(len=*), intent(in) :: description

        call assert_true(actual == expected_value, description)
    end subroutine assert_equal_integer

end program test_mir_block_table_opcode_histograms
