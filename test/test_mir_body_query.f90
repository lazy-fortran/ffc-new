program test_mir_body_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_at, mir_function_body_from_sx, &
        mir_function_body_to_sx, mir_function_body_t
    implicit none

    type(mir_function_body_t) :: body
    type(mir_function_body_t) :: queried_body
    character(len=4096) :: serialized
    character(len=4096) :: roundtrip
    character(len=:), allocatable :: message
    logical :: ok

    serialized = '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode return) '// &
        '(source-rule frontend-v0/return) (result (id 1) (kind integer) (type i32)))))'
    call mir_function_body_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'canonical body SX was not imported')

    call assert_true(mir_function_body_at(body, queried_body, message), &
        'imported body was not queryable')
    call assert_equal(queried_body%function%name, 'main', 'body function name changed')
    call assert_equal(queried_body%instructions(1)%source_rule, 'frontend-v0/program', &
        'first body source identity changed')
    call assert_equal(queried_body%instructions(2)%source_rule, 'frontend-v0/return', &
        'second body source identity changed')
    call assert_false(allocated(message), 'successful body query produced a diagnostic')

    call mir_function_body_to_sx(queried_body, roundtrip, ok, message)
    call assert_true(ok, 'queried body was not exportable')
    call assert_equal(roundtrip, serialized, 'queried body SX was not canonical')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_body_at(body, queried_body, message), &
        'inconsistent body was accepted')
    call assert_false(allocated(queried_body%instructions), &
        'failed body query did not clear its output')
    call assert_equal(message, 'function instruction count does not match body', &
        'inconsistent body diagnostic changed')

    call mir_function_body_from_sx('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0(program)) (result (id 1) (kind integer) '// &
        '(type i32)))))', body, ok, message)
    call assert_false(ok, 'malformed source identity was accepted')
    call assert_equal(message, 'unexpected SX token', &
        'malformed source identity diagnostic changed')

    write (*, '(a)') 'mir body query behavioral checks: ok'

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

end program test_mir_body_query
