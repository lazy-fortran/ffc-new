program test_mir_opcode_count_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_opcode_count_at, &
        mir_instruction_t, opcode_add, opcode_branch, opcode_call, opcode_compare, &
        opcode_div, opcode_load, opcode_mul, opcode_return, opcode_store, opcode_sub, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    integer(int32) :: count
    integer(int32) :: opcode
    integer(int32), parameter :: expected(10) = [ &
        2_int32, 1_int32, 1_int32, 1_int32, 1_int32, 1_int32, 1_int32, 1_int32, &
        1_int32, 1_int32]
    character(len=:), allocatable :: message

    call make_body(body)
    do opcode = opcode_add, opcode_return
        call assert_true(mir_function_opcode_count_at(body, opcode, count, message), &
            'valid opcode count query failed')
        call assert_equal_integer(count, expected(opcode), 'opcode count changed')
        call assert_false(allocated(message), 'successful query produced a diagnostic')
    end do

    count = 99_int32
    call assert_false(mir_function_opcode_count_at(body, 0_int32, count, message), &
        'opcode below mir-v0 was accepted')
    call assert_equal_integer(count, 0_int32, 'invalid opcode query did not clear output')
    call assert_equal(message, 'opcode is outside mir-v0', 'invalid opcode diagnostic changed')

    count = 99_int32
    call assert_false(mir_function_opcode_count_at(body, opcode_return + 1_int32, count, &
        message), 'opcode above mir-v0 was accepted')
    call assert_equal_integer(count, 0_int32, 'high invalid opcode did not clear output')

    body%function%instruction_count = 5_int32
    count = 99_int32
    call assert_false(mir_function_opcode_count_at(body, opcode_add, count, message), &
        'malformed body was accepted')
    call assert_equal_integer(count, 0_int32, 'invalid body did not clear output')
    call assert_equal(message, 'function instruction count does not match body', &
        'invalid body diagnostic changed')

    call make_body(body)
    body%instructions(1)%opcode = 0_int32
    count = 99_int32
    call assert_false(mir_function_opcode_count_at(body, opcode_add, count, message), &
        'body with invalid instruction opcode was accepted')
    call assert_equal_integer(count, 0_int32, 'invalid instruction did not clear output')

    write (*, '(a)') 'mir opcode-count query behavioral checks: ok'

contains

    subroutine make_body(body)
        type(mir_function_body_t), intent(out) :: body
        integer(int32), parameter :: opcodes(11) = [ &
            opcode_add, opcode_add, opcode_sub, opcode_mul, opcode_div, opcode_load, &
            opcode_store, opcode_compare, opcode_branch, opcode_call, opcode_return]
        integer :: index

        body%function%name = 'histogram'
        body%function%entry_block = 0_int32
        allocate (body%instructions(size(opcodes)))
        body%function%instruction_count = int(size(opcodes), int32)
        do index = 1, size(opcodes)
            call make_instruction(body%instructions(index), index - 1, opcodes(index))
        end do
        body%instructions(size(opcodes))%opcode = opcode_return
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
        instruction%source_rule = 'test/opcode-count'
    end subroutine make_instruction

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

end program test_mir_opcode_count_query
