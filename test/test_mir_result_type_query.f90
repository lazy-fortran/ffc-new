program test_mir_result_type_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_instruction_result_type_at, &
        mir_make_function_witness
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message, type_name

    call mir_make_function_witness(body)
    body%instructions(1)%result%type_name = 'derived::i32'

    call assert_true(mir_function_instruction_result_type_at(body, 0_int32, type_name, &
        message), 'first instruction result type was not queryable')
    call assert_equal(type_name, 'derived::i32', 'first result type provenance changed')
    call assert_false(allocated(message), 'successful result-type query produced a diagnostic')

    call assert_true(mir_function_instruction_result_type_at(body, 1_int32, type_name, &
        message), 'second instruction result type was not queryable')
    call assert_equal(type_name, 'i32', 'second result type changed')

    call assert_false(mir_function_instruction_result_type_at(body, -1_int32, type_name, &
        message), 'negative result-type query index was accepted')
    call assert_equal(type_name, '', 'failed result-type query did not clear its output')
    call assert_equal(message, 'instruction index must be non-negative', &
        'negative result-type query diagnostic changed')

    call assert_false(mir_function_instruction_result_type_at(body, 2_int32, type_name, &
        message), 'out-of-range result-type query index was accepted')
    call assert_equal(message, 'instruction index is outside function body', &
        'out-of-range result-type query diagnostic changed')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_instruction_result_type_at(body, 0_int32, type_name, &
        message), 'inconsistent function body passed result-type validation')
    call assert_equal(message, 'function instruction count does not match body', &
        'inconsistent result-type query diagnostic changed')

    call mir_make_function_witness(body)
    body%instructions(1)%result%type_name = 'f 64'
    call assert_false(mir_function_instruction_result_type_at(body, 0_int32, type_name, &
        message), 'an SX-delimited type name was accepted')
    call assert_equal(message, 'value type name is not a valid SX atom', &
        'invalid type-name diagnostic changed')

    write (*, '(a)') 'mir result-type query behavioral checks: ok'

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

end program test_mir_result_type_query
