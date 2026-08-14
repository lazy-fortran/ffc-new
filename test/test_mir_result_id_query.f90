program test_mir_result_id_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_instruction_result_id_at, &
        mir_make_function_witness
    implicit none

    type(mir_function_body_t) :: body
    integer(int32) :: result_id
    character(len=:), allocatable :: message

    call mir_make_function_witness(body)

    call assert_true(mir_function_instruction_result_id_at(body, 0_int32, result_id, &
        message), 'first instruction result ID was not queryable')
    call assert_true(result_id == 1_int32, 'first instruction result ID changed')
    call assert_false(allocated(message), 'successful result-ID query produced a diagnostic')

    call assert_true(mir_function_instruction_result_id_at(body, 1_int32, result_id, &
        message), 'second instruction result ID was not queryable')
    call assert_true(result_id == 1_int32, 'second instruction result ID changed')

    call assert_false(mir_function_instruction_result_id_at(body, -1_int32, result_id, &
        message), 'negative result-ID query index was accepted')
    call assert_true(result_id == 0_int32, 'failed result-ID query did not clear its output')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative result-ID query diagnostic changed')

    call assert_false(mir_function_instruction_result_id_at(body, 2_int32, result_id, &
        message), 'out-of-range result-ID query index was accepted')
    call assert_true(result_id == 0_int32, 'out-of-range result-ID query did not clear its output')
    call assert_equal(message, 'instruction index is outside function body', &
        'out-of-range result-ID query diagnostic changed')

    body%function%instruction_count = 1_int32
    result_id = 99_int32
    call assert_false(mir_function_instruction_result_id_at(body, 0_int32, result_id, message), &
        'malformed body passed result-ID validation')
    call assert_true(result_id == 0_int32, 'malformed-body query did not clear its output')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed result-ID query diagnostic changed')

    write (*, '(a)') 'mir result-ID query behavioral checks: ok'

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

end program test_mir_result_id_query
