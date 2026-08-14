program test_mir_block_table
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_block_table_range_at, &
        mir_function_body_t, mir_make_function_block_table, &
        mir_validate_function_block_table, opcode_add, opcode_mul, opcode_return, opcode_sub, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    character(len=:), allocatable :: message
    integer(int32) :: first_instruction, instruction_count
    logical :: ok

    body%function%name = 'main'
    body%function%entry_block = 0_int32
    body%function%instruction_count = 4_int32
    allocate (body%instructions(4))
    call set_instruction(body%instructions(1), 0_int32, opcode_add, 'first')
    call set_instruction(body%instructions(2), 1_int32, opcode_sub, 'first')
    call set_instruction(body%instructions(3), 2_int32, opcode_mul, 'second')
    call set_instruction(body%instructions(4), 3_int32, opcode_return, 'second')
    call assert_true(mir_validate_function_block_table(body, table, message) .eqv. .false., &
        'uninitialized table unexpectedly validated')

    allocate (table%ranges(2))
    table%ranges(1)%first_instruction = 0_int32
    table%ranges(1)%instruction_count = 2_int32
    table%ranges(2)%first_instruction = 2_int32
    table%ranges(2)%instruction_count = 2_int32
    call assert_true(mir_validate_function_block_table(body, table, message), &
        'independent multi-block table was rejected')
    call assert_true(mir_function_block_table_range_at(body, table, 1_int32, &
        first_instruction, instruction_count, message), 'second block was not queryable')
    call assert_equal_integer(first_instruction, 2_int32, 'second block start changed')
    call assert_equal_integer(instruction_count, 2_int32, 'second block length changed')
    first_instruction = 99_int32
    instruction_count = 99_int32
    call assert_false(mir_function_block_table_range_at(body, table, -1_int32, &
        first_instruction, instruction_count, message), 'negative table index was accepted')
    call assert_equal_integer(first_instruction, 0_int32, 'negative index start was not cleared')
    call assert_equal_integer(instruction_count, 0_int32, 'negative index length was not cleared')
    call assert_equal(message, 'block index must be non-negative', &
        'negative table index diagnostic changed')
    call assert_false(mir_function_block_table_range_at(body, table, 2_int32, &
        first_instruction, instruction_count, message), 'out-of-range table index was accepted')
    call assert_equal(message, 'block index is outside block table', &
        'out-of-range table index diagnostic changed')

    call assert_true(mir_make_function_block_table(body, table, message), &
        'legacy body was not converted to a block table')
    call assert_equal_integer(int(size(table%ranges), int32), 1_int32, &
        'legacy body did not retain one block')

    table%ranges(1)%instruction_count = 3_int32
    first_instruction = 99_int32
    instruction_count = 99_int32
    call assert_false(mir_function_block_table_range_at(body, table, 0_int32, &
        first_instruction, instruction_count, message), 'incomplete table was accepted')
    call assert_equal_integer(first_instruction, 0_int32, 'failed query start was not cleared')
    call assert_equal_integer(instruction_count, 0_int32, &
        'failed query length was not cleared')
    call assert_equal(message, 'block table does not cover function body', &
        'incomplete table diagnostic changed')

    ok = mir_make_function_block_table(body, table, message)
    call assert_true(ok, 'legacy body table construction failed')
    table%ranges(1)%first_instruction = 1_int32
    call assert_false(mir_validate_function_block_table(body, table, message), &
        'non-contiguous table was accepted')
    call assert_equal(message, 'block table ranges are not contiguous', &
        'non-contiguous table diagnostic changed')

    body%function%instruction_count = 3_int32
    ok = mir_make_function_block_table(body, table, message)
    call assert_false(ok, 'malformed body was converted to a block table')
    call assert_false(allocated(table%ranges), 'failed table construction did not clear output')
    call assert_false(mir_validate_function_block_table(body, table, message), &
        'malformed MIR body was accepted by block table validation')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    write (*, '(a)') 'mir block table behavioral checks: ok'

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

    subroutine set_instruction(instruction, id, opcode, source_rule)
        use ffc_mir, only: mir_instruction_t
        type(mir_instruction_t), intent(out) :: instruction
        integer(int32), intent(in) :: id, opcode
        character(len=*), intent(in) :: source_rule

        instruction%id = id
        instruction%opcode = opcode
        instruction%result%id = 1_int32
        instruction%result%kind = value_kind_integer
        instruction%result%type_name = 'i32'
        instruction%source_rule = source_rule
    end subroutine set_instruction

end program test_mir_block_table
