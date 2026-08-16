program test_frontend_mir_cli
    use ffc_lowering, only: ffc_lower_frontend_v0_from_sx
    use ffc_mir, only: mir_function_body_t, mir_function_body_to_sx
    implicit none

    character(len=*), parameter :: accepted = &
        '(frontend-result (status accepted) (root-kind program) '// &
        '(diagnostic-count 0))'
    character(len=*), parameter :: expected = &
        '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) '// &
        '(type i32))) (instruction (id 1) (opcode return) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) '// &
        '(type i32)))))'
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: first, second, message
    logical :: ok

    ok = ffc_lower_frontend_v0_from_sx(accepted, body, message)
    call assert_true(ok, 'accepted frontend-v0 input was rejected')

    allocate (character(len=1024) :: first)
    call mir_function_body_to_sx(body, first, ok, message)
    call assert_true(ok, 'lowered body was not serialized')
    call assert_equal(trim(first), expected, 'canonical mir-v0 output changed')

    allocate (character(len=1024) :: second)
    call mir_function_body_to_sx(body, second, ok, message)
    call assert_true(ok, 'lowered body was not serialized twice')
    call assert_equal(trim(second), trim(first), 'mir-v0 output was not deterministic')

    call assert_rejected('', 'malformed-sx-record', 'empty input was accepted')
    call assert_rejected('(frontend-result (status rejected) (root-kind none) '// &
        '(diagnostic-count 1))', 'frontend-v0 status must be accepted', &
        'rejected frontend result was accepted')

    write (*, '(a)') 'frontend to MIR CLI API controls: ok'

contains

    subroutine assert_rejected(input, expected_message, description)
        character(len=*), intent(in) :: input, expected_message, description

        ok = ffc_lower_frontend_v0_from_sx(input, body, message)
        call assert_true(.not. ok, description)
        call assert_equal(trim(message), expected_message, &
            'frontend rejection diagnostic changed')
    end subroutine assert_rejected

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_equal(actual, expected_value, description)
        character(len=*), intent(in) :: actual, expected_value, description

        call assert_true(actual == expected_value, description)
    end subroutine assert_equal

end program test_frontend_mir_cli
