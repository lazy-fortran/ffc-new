program test_mir_typed_sx
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, &
        mir_function_witness_from_sx, mir_function_witness_to_sx, &
        value_kind_real
    implicit none

    type(mir_function_body_t) :: body
    character(len=1024) :: serialized
    character(len=:), allocatable :: message
    logical :: ok

    call mir_make_function_witness(body)
    body%instructions(1)%result%id = 37_int32
    body%instructions(1)%result%kind = value_kind_real
    body%instructions(1)%result%type_name = 'f64'
    body%instructions(2)%result = body%instructions(1)%result

    call mir_function_witness_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'typed witness was not serialized')
    call assert_true(index(trim(serialized), &
        '(result (id 37) (kind real) (type f64))') > 0, &
        'typed result was not emitted')

    call mir_function_witness_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'typed witness did not import: '//trim(message))
    call assert_true(body%instructions(1)%result%id == 37_int32, &
        'result id was not preserved')
    call assert_true(body%instructions(1)%result%kind == value_kind_real, &
        'result kind was not preserved')
    call assert_equal(body%instructions(1)%result%type_name, 'f64', &
        'result type was not preserved')
    call assert_true(body%instructions(2)%result%id == 37_int32, &
        'second result id was not preserved')

    call mir_function_witness_from_sx('(mir-function (name main) '// &
        '(entry-block 0) (instruction-count 2) (instructions '// &
        '(instruction (id 0) (opcode add) (source-rule expr/add) '// &
        '(result (id 1) (kind unknown) (type i32))) '// &
        '(instruction (id 1) (opcode return) (source-rule stmt/return) '// &
        '(result (id 1) (kind integer) (type i32)))))', body, ok, message)
    call assert_false(ok, 'unknown result kind was accepted')

contains

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
        character(len=*), intent(in) :: actual
        character(len=*), intent(in) :: expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal

end program test_mir_typed_sx
