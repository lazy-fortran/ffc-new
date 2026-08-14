program test_mir_instruction_count_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_instruction_at, &
        mir_function_instruction_count_at, mir_instruction_t, mir_make_function_witness, &
        opcode_add, opcode_return
    implicit none

    type(mir_function_body_t) :: body
    type(mir_instruction_t) :: instruction
    character(len=:), allocatable :: message
    integer(int32) :: count

    call mir_make_function_witness(body)
    call assert_true(mir_function_instruction_count_at(body, count, message), &
        'valid function instruction count was not queryable')
    call assert_equal_integer(count, 2_int32, 'function instruction count changed')
    call assert_false(allocated(message), 'successful count query produced a diagnostic')

    call assert_true(mir_function_instruction_at(body, 0_int32, instruction, message), &
        'first instruction was not queryable')
    call assert_true(instruction%opcode == opcode_add, 'first instruction changed')
    call assert_true(mir_function_instruction_at(body, 1_int32, instruction, message), &
        'second instruction was not queryable')
    call assert_true(instruction%opcode == opcode_return, 'second instruction changed')

    count = 99_int32
    body%function%instruction_count = 1_int32
    call assert_false(mir_function_instruction_count_at(body, count, message), &
        'malformed body was accepted')
    call assert_equal_integer(count, 0_int32, 'malformed body did not clear count')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    call mir_make_function_witness(body)
    count = 99_int32
    call assert_false(mir_function_instruction_at(body, -1_int32, instruction, message), &
        'negative instruction index was accepted')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative instruction diagnostic changed')
    call assert_false(mir_function_instruction_at(body, 2_int32, instruction, message), &
        'out-of-bounds instruction index was accepted')
    call assert_equal(message, 'instruction index is outside function body', &
        'out-of-bounds instruction diagnostic changed')

    write (*, '(a)') 'mir instruction-count query behavioral checks: ok'

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

end program test_mir_instruction_count_query
