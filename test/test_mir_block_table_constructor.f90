program test_mir_block_table_constructor
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_block_table_t, mir_function_body_t, &
        mir_make_function_block_table_from_lengths, mir_validate_function_block_table, &
        mir_instruction_t, opcode_add, opcode_return, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(mir_block_table_t) :: table
    integer(int32), allocatable :: empty_lengths(:)
    character(len=:), allocatable :: message
    logical :: ok

    call make_body(body, 4_int32)
    call check_partition(body, [4_int32], 'single block')
    call check_partition(body, [1_int32, 3_int32], 'two blocks')
    call check_partition(body, [2_int32, 1_int32, 1_int32], 'three blocks')

    call reset_table(table)
    allocate (table%ranges(1))
    table%ranges(1)%first_instruction = 17_int32
    table%ranges(1)%instruction_count = 17_int32
    allocate (empty_lengths(0))
    ok = mir_make_function_block_table_from_lengths(body, empty_lengths, table, message)
    call assert_false(ok, 'empty partition was accepted')
    call assert_false(allocated(table%ranges), 'empty partition did not clear output')
    call assert_equal(message, 'block partition must contain at least one block', &
        'empty partition diagnostic changed')

    call reset_table(table)
    allocate (table%ranges(1))
    ok = mir_make_function_block_table_from_lengths(body, [0_int32, 4_int32], table, message)
    call assert_false(ok, 'empty block was accepted')
    call assert_false(allocated(table%ranges), 'empty block did not clear output')

    call reset_table(table)
    allocate (table%ranges(1))
    ok = mir_make_function_block_table_from_lengths(body, [2_int32, -1_int32], table, message)
    call assert_false(ok, 'negative block length was accepted')
    call assert_false(allocated(table%ranges), 'negative length did not clear output')

    call reset_table(table)
    allocate (table%ranges(1))
    ok = mir_make_function_block_table_from_lengths(body, [1_int32, 2_int32], table, message)
    call assert_false(ok, 'incomplete partition was accepted')
    call assert_false(allocated(table%ranges), 'incomplete partition did not clear output')
    call assert_equal(message, 'block partition does not cover function body', &
        'incomplete partition diagnostic changed')

    call reset_table(table)
    allocate (table%ranges(1))
    ok = mir_make_function_block_table_from_lengths(body, [3_int32, 2_int32], table, message)
    call assert_false(ok, 'overlong partition was accepted')
    call assert_false(allocated(table%ranges), 'overlong partition did not clear output')
    call assert_equal(message, 'block partition exceeds function body', &
        'overlong partition diagnostic changed')

    allocate (table%ranges(1))
    body%function%instruction_count = 3_int32
    ok = mir_make_function_block_table_from_lengths(body, [1_int32, 3_int32], table, message)
    call assert_false(ok, 'malformed MIR body was accepted')
    call assert_false(allocated(table%ranges), 'malformed body did not clear output')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    call make_body(body, 4_int32)
    call reset_table(table)
    allocate (table%ranges(2))
    table%ranges(1)%first_instruction = 0_int32
    table%ranges(1)%instruction_count = 2_int32
    table%ranges(2)%first_instruction = 3_int32
    table%ranges(2)%instruction_count = 1_int32
    call assert_false(mir_validate_function_block_table(body, table, message), &
        'non-contiguous partition control was accepted')

    write (*, '(a)') 'mir block table constructor matrix: ok'

contains

    subroutine check_partition(body, lengths, description)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: lengths(:)
        character(len=*), intent(in) :: description

        integer(int32) :: expected_first, index

        call assert_true(mir_make_function_block_table_from_lengths(body, lengths, table, message), &
            description // ' was rejected')
        call assert_equal_integer(int(size(table%ranges), int32), int(size(lengths), int32), &
            description // ' count changed')
        expected_first = 0_int32
        do index = 1, int(size(lengths), int32)
            call assert_equal_integer(table%ranges(index)%first_instruction, expected_first, &
                description // ' prefix start changed')
            call assert_equal_integer(table%ranges(index)%instruction_count, lengths(index), &
                description // ' length changed')
            expected_first = expected_first + lengths(index)
        end do
        call assert_equal_integer(expected_first, body%function%instruction_count, &
            description // ' oracle coverage changed')
        call assert_true(mir_validate_function_block_table(body, table, message), &
            description // ' result did not validate')
    end subroutine check_partition

    subroutine make_body(body, instruction_count)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), intent(in) :: instruction_count
        integer(int32) :: index

        body%function%name = 'main'
        body%function%entry_block = 0_int32
        body%function%instruction_count = instruction_count
        allocate (body%instructions(instruction_count))
        do index = 1, instruction_count
            call set_instruction(body%instructions(index), index - 1_int32, &
                merge(opcode_return, opcode_add, index == instruction_count), 'matrix')
        end do
    end subroutine make_body

    subroutine set_instruction(instruction, id, opcode, source_rule)
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

    subroutine reset_table(table)
        type(mir_block_table_t), intent(inout) :: table

        if (allocated(table%ranges)) deallocate (table%ranges)
    end subroutine reset_table

end program test_mir_block_table_constructor
