program test_mir_source_rule_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_t, &
        mir_function_body_to_sx, mir_function_instruction_source_rule_at, &
        mir_make_function_witness
    implicit none

    type(mir_function_body_t) :: body
    character(len=1024) :: serialized
    character(len=:), allocatable :: message, source_rule
    logical :: ok

    call mir_make_function_witness(body)
    body%instructions(1)%source_rule = 'frontend-v0/program'
    body%instructions(2)%source_rule = 'frontend-v0/program'

    call assert_true(mir_function_instruction_source_rule_at(body, 0_int32, &
        source_rule, message), 'first source identity was not queryable')
    call assert_equal(source_rule, 'frontend-v0/program', &
        'first source identity changed')
    call assert_false(allocated(message), 'successful source query produced a diagnostic')

    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'source identity witness was not exported')
    call mir_function_body_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'source identity witness was not imported')
    call assert_true(mir_function_instruction_source_rule_at(body, 1_int32, &
        source_rule, message), 'second source identity was not queryable')
    call assert_equal(source_rule, 'frontend-v0/program', &
        'round-tripped source identity changed')

    call assert_false(mir_function_instruction_source_rule_at(body, -1_int32, &
        source_rule, message), 'negative source query index was accepted')
    call assert_equal(source_rule, '', 'failed source query did not clear its output')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative source query diagnostic changed')

    call assert_false(mir_function_instruction_source_rule_at(body, 2_int32, &
        source_rule, message), 'out-of-range source query index was accepted')
    call assert_equal(source_rule, '', 'out-of-range source query did not clear its output')
    call assert_equal(message, 'instruction index is outside function body', &
        'out-of-range source query diagnostic changed')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_instruction_source_rule_at(body, 0_int32, &
        source_rule, message), 'inconsistent body passed source query validation')
    call assert_equal(message, 'function instruction count does not match body', &
        'inconsistent source query diagnostic changed')

    write (*, '(a)') 'mir source-rule query behavioral checks: ok'

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

end program test_mir_source_rule_query
