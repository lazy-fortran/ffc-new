program test_mir_body_sx_size
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_sx_size, &
        mir_function_body_t, mir_function_body_to_sx
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: expected, serialized, message
    integer(int32) :: size
    logical :: ok

    expected = '(mir-function (name sized) (entry-block 0) (instruction-count 1) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule expr/size) (result (id 7) (kind integer) (type i32)))))'
    call mir_function_body_from_sx(expected, body, ok, message)
    call assert_true(ok, 'size witness was rejected')
    call assert_true(mir_function_body_sx_size(body, size, message), &
        'valid body size query was rejected')
    call assert_equal_integer(size, int(len(expected), int32), &
        'size query disagrees with independent SX oracle')

    allocate (character(len=int(size)) :: serialized)
    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'exact-sized output buffer was rejected')
    call assert_equal(serialized, expected, 'exact-sized serialization changed')

    body%function%instruction_count = 2_int32
    size = 91_int32
    call assert_false(mir_function_body_sx_size(body, size, message), &
        'malformed body size was accepted')
    call assert_equal_integer(size, 0_int32, 'failed size query left stale output')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed body diagnostic changed')

    write (*, '(a)') 'mir body SX size query controls: ok'

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

end program test_mir_body_sx_size
