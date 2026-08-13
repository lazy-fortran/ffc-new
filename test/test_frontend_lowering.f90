program test_frontend_lowering
    use, intrinsic :: iso_fortran_env, only: int32, int64
    use ffc_lowering, only: frontend_root_kind_program, frontend_status_accepted, &
        frontend_v0_input_t, ffc_lower_frontend_v0
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, &
        mir_validate_function_witness, opcode_add, opcode_return, value_kind_integer
    implicit none

    type(frontend_v0_input_t) :: input
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    input%status = frontend_status_accepted
    input%root_kind = frontend_root_kind_program
    input%diagnostic_count = 0_int64
    call assert_true(ffc_lower_frontend_v0(input, body, message), &
        'accepted frontend-v0 input was rejected')
    call assert_false(allocated(message), 'accepted input produced a diagnostic')
    call assert_true(mir_validate_function_body(body, message), &
        'lowering produced an invalid mir-v0 body')
    call assert_equal(body%function%name, 'main', 'lowered function name changed')
    call assert_equal_integer(body%function%entry_block, 0_int32, &
        'lowered entry block changed')
    call assert_equal_integer(body%function%instruction_count, 2_int32, &
        'lowered instruction count changed')
    call assert_equal_integer(body%instructions(1)%opcode, opcode_add, &
        'lowered first opcode changed')
    call assert_equal_integer(body%instructions(2)%opcode, opcode_return, &
        'lowered second opcode changed')
    call assert_equal_integer(body%instructions(1)%result%kind, value_kind_integer, &
        'lowered result kind changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-v0/program', &
        'lowered source provenance changed')
    call assert_equal(body%instructions(2)%source_rule, 'frontend-v0/program', &
        'lowered return provenance changed')

    input%status = 'rejected'
    call assert_rejected(input, 'frontend-v0 status must be accepted', &
        'rejected status was accepted')

    input%status = frontend_status_accepted
    input%root_kind = 'source'
    call assert_rejected(input, 'frontend-v0 root kind must be program', &
        'non-program root kind was accepted')

    input%root_kind = frontend_root_kind_program
    input%diagnostic_count = 1_int64
    call assert_rejected(input, 'frontend-v0 diagnostic count must be zero', &
        'diagnostic-bearing input was accepted')

    input%diagnostic_count = 0_int64
    call assert_true(ffc_lower_frontend_v0(input, body, message), &
        'restored frontend-v0 input was rejected')
    body%instructions(1)%source_rule = 'target/isa'
    call assert_false(mir_validate_function_witness(body, message), &
        'source provenance mutation was accepted')
    call assert_equal(message, 'function witness add source rule changed', &
        'source provenance mutation diagnostic changed')

contains

    subroutine assert_rejected(candidate, expected_message, description)
        type(frontend_v0_input_t), intent(in) :: candidate
        character(len=*), intent(in) :: expected_message, description

        call assert_false(ffc_lower_frontend_v0(candidate, body, message), description)
        call assert_equal(message, expected_message, 'frontend rejection diagnostic changed')
    end subroutine assert_rejected

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

end program test_frontend_lowering
