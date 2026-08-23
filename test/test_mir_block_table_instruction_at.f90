program test_mir_block_table_instruction_at
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_block_table_instruction_at, &
        mir_function_body_t, mir_instruction_t, mir_validate_function_block_table, &
        opcode_add, opcode_mul, opcode_return, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    type(mir_instruction_t) :: instruction
    character(len=:), allocatable :: message

    body%function%name = 'main'
    body%function%entry_block = 0_int32
    body%function%instruction_count = 5_int32
    allocate (body%instructions(5))
    call set_instruction(body%instructions(1), 0_int32, opcode_add)
    call set_instruction(body%instructions(2), 1_int32, opcode_sub)
    call set_instruction(body%instructions(3), 2_int32, opcode_mul)
    call set_instruction(body%instructions(4), 3_int32, opcode_add)
    call set_instruction(body%instructions(5), 4_int32, opcode_return)

    allocate (table%ranges(3))
    table%ranges(1)%first_instruction = 0_int32
    table%ranges(1)%instruction_count = 2_int32
    table%ranges(2)%first_instruction = 2_int32
    table%ranges(2)%instruction_count = 0_int32
    table%ranges(3)%first_instruction = 2_int32
    table%ranges(3)%instruction_count = 3_int32
    call assert_true(mir_validate_function_block_table(body, table, message), &
        'valid three-block table was rejected')

    call assert_true(mir_function_block_table_instruction_at(body, table, 0_int32, &
        1_int32, instruction, message), 'first block instruction was not queryable')
    call assert_equal_integer(instruction%id, 1_int32, 'first block instruction id changed')
    call assert_equal_integer(instruction%opcode, opcode_sub, &
        'first block instruction opcode changed')
    call assert_true(mir_function_block_table_instruction_at(body, table, 2_int32, &
        2_int32, instruction, message), 'third block instruction was not queryable')
    call assert_equal_integer(instruction%id, 4_int32, 'third block instruction id changed')
    call assert_equal_integer(instruction%opcode, opcode_return, &
        'third block instruction opcode changed')

    deallocate (table%ranges)
    allocate (table%ranges(2))
    table%ranges(1)%first_instruction = 0_int32
    table%ranges(1)%instruction_count = 2_int32
    table%ranges(2)%first_instruction = 2_int32
    table%ranges(2)%instruction_count = 3_int32
    call assert_true(mir_function_block_table_instruction_at(body, table, 1_int32, &
        2_int32, instruction, message), 'second block instruction was not queryable')
    call assert_equal_integer(instruction%id, 4_int32, 'second block instruction id changed')
    call assert_equal_integer(instruction%opcode, opcode_return, &
        'second block instruction opcode changed')

    deallocate (table%ranges)
    allocate (table%ranges(3))
    table%ranges(1)%first_instruction = 0_int32
    table%ranges(1)%instruction_count = 2_int32
    table%ranges(2)%first_instruction = 2_int32
    table%ranges(2)%instruction_count = 0_int32
    table%ranges(3)%first_instruction = 2_int32
    table%ranges(3)%instruction_count = 3_int32

    instruction%id = 99_int32
    instruction%opcode = 99_int32
    call assert_false(mir_function_block_table_instruction_at(body, table, 1_int32, &
        0_int32, instruction, message), 'zero-length block accepted an instruction')
    call assert_cleared(instruction, 'zero-length block failure did not clear output')
    call assert_equal(message, 'instruction index is outside block', &
        'zero-length block diagnostic changed')

    call assert_false(mir_function_block_table_instruction_at(body, table, -1_int32, &
        0_int32, instruction, message), 'negative block index was accepted')
    call assert_cleared(instruction, 'negative block failure did not clear output')
    call assert_equal(message, 'block index must be non-negative', &
        'negative block diagnostic changed')
    call assert_false(mir_function_block_table_instruction_at(body, table, 3_int32, &
        0_int32, instruction, message), 'out-of-range block index was accepted')
    call assert_equal(message, 'block index is outside block table', &
        'out-of-range block diagnostic changed')
    call assert_false(mir_function_block_table_instruction_at(body, table, 0_int32, &
        -1_int32, instruction, message), 'negative instruction index was accepted')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative instruction diagnostic changed')
    call assert_false(mir_function_block_table_instruction_at(body, table, 0_int32, &
        2_int32, instruction, message), 'out-of-range instruction index was accepted')
    call assert_equal(message, 'instruction index is outside block', &
        'out-of-range instruction diagnostic changed')

    table%ranges(3)%instruction_count = 2_int32
    instruction%id = 99_int32
    instruction%opcode = 99_int32
    call assert_false(mir_function_block_table_instruction_at(body, table, 2_int32, &
        0_int32, instruction, message), 'malformed table was accepted')
    call assert_cleared(instruction, 'malformed table failure did not clear output')
    call assert_equal(message, 'block table does not cover function body', &
        'malformed table diagnostic changed')

    write (*, '(a)') 'mir block table instruction-at behavioral checks: ok'

contains

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

    subroutine assert_cleared(instruction, description)
        type(mir_instruction_t), intent(in) :: instruction
        character(len=*), intent(in) :: description

        call assert_equal_integer(instruction%id, 0_int32, description)
        call assert_equal_integer(instruction%opcode, 0_int32, description)
    end subroutine assert_cleared

    subroutine set_instruction(instruction, id, opcode)
        use ffc_mir, only: mir_instruction_t
        type(mir_instruction_t), intent(out) :: instruction
        integer(int32), intent(in) :: id, opcode

        instruction%id = id
        instruction%opcode = opcode
        instruction%result%id = 1_int32
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = 'test/rule'
    end subroutine set_instruction

end program test_mir_block_table_instruction_at
