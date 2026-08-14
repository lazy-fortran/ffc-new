program test_mir_result_kind_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, &
        mir_function_instruction_result_kind_at, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    integer(int32) :: kind
    character(len=:), allocatable :: message

    call mir_make_function_witness(body)

    call assert_true(mir_function_instruction_result_kind_at(body, 0_int32, kind, message), &
        'first instruction result kind was not queryable')
    call assert_true(kind == value_kind_integer, &
        'first instruction result kind changed')
    call assert_false(allocated(message), 'successful result-kind query produced a diagnostic')

    call assert_true(mir_function_instruction_result_kind_at(body, 1_int32, kind, message), &
        'second instruction result kind was not queryable')
    call assert_true(kind == value_kind_integer, &
        'second instruction result kind changed')

    call assert_false(mir_function_instruction_result_kind_at(body, -1_int32, kind, message), &
        'negative result-kind query index was accepted')
    call assert_true(kind == 0_int32, 'failed result-kind query did not clear its output')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative result-kind query diagnostic changed')

    call assert_false(mir_function_instruction_result_kind_at(body, 2_int32, kind, message), &
        'out-of-range result-kind query index was accepted')
    call assert_equal(message, 'instruction index is outside function body', &
        'out-of-range result-kind query diagnostic changed')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_instruction_result_kind_at(body, 0_int32, kind, message), &
        'inconsistent function body passed result-kind validation')
    call assert_equal(message, 'function instruction count does not match body', &
        'inconsistent result-kind query diagnostic changed')

    write (*, '(a)') 'mir result-kind query behavioral checks: ok'

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

end program test_mir_result_kind_query
