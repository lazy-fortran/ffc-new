program test_mir_block_table_opcode_count
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_block_table_opcode_count_at, &
        mir_function_body_t, mir_instruction_t, mir_validate_function_block_table, &
        opcode_add, opcode_mul, opcode_pow, opcode_return, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    integer(int32) :: count
    character(len=:), allocatable :: message

    call make_body(body)
    call make_table(table)
    call assert_true(mir_validate_function_block_table(body, table, message), &
        'valid block table was rejected')

    call assert_count(body, table, 0_int32, opcode_add, 1_int32, &
        'first block add count changed')
    call assert_count(body, table, 2_int32, opcode_mul, 1_int32, &
        'third block multiply count changed')
    call assert_count(body, table, 3_int32, opcode_return, 1_int32, &
        'fourth block return count changed')
    call assert_count(body, table, 1_int32, opcode_add, 0_int32, &
        'zero-length block did not return zero')

    body%instructions(7)%opcode = opcode_add
    call assert_count(body, table, 0_int32, opcode_add, 1_int32, &
        'instruction outside selected block affected its count')

    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, -1_int32, &
        opcode_add, count, message), 'negative block index was accepted')
    call assert_equal_integer(count, 0_int32, 'negative block index did not clear output')
    call assert_equal(message, 'block index must be non-negative', &
        'negative block diagnostic changed')

    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 4_int32, &
        opcode_add, count, message), 'out-of-range block index was accepted')
    call assert_equal_integer(count, 0_int32, 'out-of-range block did not clear output')
    call assert_equal(message, 'block index is outside block table', &
        'out-of-range block diagnostic changed')

    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 0_int32, &
        0_int32, count, message), 'low invalid opcode was accepted')
    call assert_equal_integer(count, 0_int32, 'low invalid opcode did not clear output')
    call assert_equal(message, 'opcode is outside mir-v0', 'low opcode diagnostic changed')

    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 0_int32, &
        opcode_pow + 1_int32, count, message), 'high invalid opcode was accepted')
    call assert_equal_integer(count, 0_int32, 'high invalid opcode did not clear output')

    body%function%instruction_count = 6_int32
    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 0_int32, &
        opcode_add, count, message), 'malformed body was accepted')
    call assert_equal_integer(count, 0_int32, 'malformed body did not clear output')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    call make_body(body)
    call make_table(table)
    table%ranges(3)%first_instruction = 4_int32
    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 0_int32, &
        opcode_add, count, message), 'non-contiguous table was accepted')
    call assert_equal_integer(count, 0_int32, 'non-contiguous table did not clear output')
    call assert_equal(message, 'block table ranges are not contiguous', &
        'non-contiguous table diagnostic changed')

    table%ranges(3)%first_instruction = 2_int32
    table%ranges(4)%instruction_count = 1_int32
    count = 99_int32
    call assert_false(mir_function_block_table_opcode_count_at(body, table, 0_int32, &
        opcode_add, count, message), 'incomplete table was accepted')
    call assert_equal_integer(count, 0_int32, 'incomplete table did not clear output')
    call assert_equal(message, 'block table does not cover function body', &
        'incomplete table diagnostic changed')

    write (*, '(a)') 'mir block table opcode-count behavioral checks: ok'

contains

    subroutine assert_count(body, table, block_index, opcode, expected, description)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(in) :: block_index, opcode, expected
        character(len=*), intent(in) :: description

        integer(int32) :: count

        call assert_true(mir_function_block_table_opcode_count_at(body, table, block_index, &
            opcode, count, message), description)
        call assert_equal_integer(count, expected, description)
        call assert_false(allocated(message), description // ' produced a diagnostic')
        call assert_equal_integer(direct_count(body, table, block_index, opcode), expected, &
            description // ' direct oracle changed')
    end subroutine assert_count

    integer(int32) function direct_count(body, table, block_index, opcode) result(count)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(in) :: block_index, opcode

        integer(int32) :: first_instruction, instruction_count, offset

        first_instruction = table%ranges(block_index + 1_int32)%first_instruction
        instruction_count = table%ranges(block_index + 1_int32)%instruction_count
        count = 0_int32
        do offset = 0_int32, instruction_count - 1_int32
            if (body%instructions(first_instruction + offset + 1_int32)%opcode == opcode) then
                count = count + 1_int32
            end if
        end do
    end function direct_count

    subroutine make_body(body)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), parameter :: opcodes(7) = [ &
            opcode_add, opcode_sub, opcode_add, opcode_mul, opcode_return, opcode_sub, &
            opcode_return]
        integer(int32) :: index

        body%function%name = 'block-count'
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
        table%ranges(3)%instruction_count = 3_int32
        table%ranges(4)%first_instruction = 5_int32
        table%ranges(4)%instruction_count = 2_int32
    end subroutine make_table

    subroutine set_instruction(instruction, id, opcode)
        type(mir_instruction_t), intent(out) :: instruction
        integer(int32), intent(in) :: id, opcode

        instruction%id = id
        instruction%opcode = opcode
        instruction%result%id = 1_int32
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = 'test/block-table-opcode-count'
    end subroutine set_instruction

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

    subroutine assert_equal_integer(actual, expected, description)
        integer(int32), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal_integer

end program test_mir_block_table_opcode_count
