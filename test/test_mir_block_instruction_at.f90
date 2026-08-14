program test_mir_block_instruction_at
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_block_instruction_at, mir_function_body_t, &
        mir_instruction_t, mir_make_function_witness, opcode_add, opcode_return
    implicit none

    type(mir_function_body_t) :: body
    type(mir_instruction_t) :: instruction
    character(len=:), allocatable :: message

    call mir_make_function_witness(body)
    call assert_true(mir_function_block_instruction_at(body, 0_int32, 1_int32, &
        instruction, message), 'entry block instruction was not queryable')
    call assert_true(instruction%opcode == opcode_return, &
        'entry block instruction opcode changed')
    call assert_equal(instruction%source_rule, 'stmt/return', &
        'entry block instruction source rule changed')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_block_instruction_at(body, 0_int32, 0_int32, &
        instruction, message), 'malformed body was accepted')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    call mir_make_function_witness(body)
    call assert_false(mir_function_block_instruction_at(body, 1_int32, 0_int32, &
        instruction, message), 'wrong block was accepted')
    call assert_equal(message, 'block index is outside function body', &
        'wrong block diagnostic changed')

    call assert_false(mir_function_block_instruction_at(body, -1_int32, 0_int32, &
        instruction, message), 'negative block index was accepted')
    call assert_equal(message, 'block index must be non-negative', &
        'negative block diagnostic changed')

    call assert_false(mir_function_block_instruction_at(body, 0_int32, -1_int32, &
        instruction, message), 'negative instruction index was accepted')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative instruction diagnostic changed')

    call assert_false(mir_function_block_instruction_at(body, 0_int32, 2_int32, &
        instruction, message), 'out-of-range instruction index was accepted')
    call assert_equal(message, 'instruction index is outside block', &
        'out-of-range instruction diagnostic changed')

    call assert_true(mir_function_block_instruction_at(body, 0_int32, 0_int32, &
        instruction, message), 'first entry block instruction was not queryable')
    call assert_true(instruction%opcode == opcode_add, &
        'first entry block instruction opcode changed')

    write (*, '(a)') 'mir block instruction-at behavioral checks: ok'

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

end program test_mir_block_instruction_at
