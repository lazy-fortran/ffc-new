program test_mir_metadata_behavior
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_t, &
        opcode_add, opcode_return, value_kind_address, value_kind_integer
    implicit none

    character(len=32), parameter :: opcode_names(10) = [character(len=32) :: &
        'add', 'sub', 'mul', 'div', 'load', 'store', 'compare', 'branch', 'call', &
        'return']
    character(len=32), parameter :: kind_names(4) = [character(len=32) :: &
        'integer', 'real', 'logical', 'address']
    type(mir_function_body_t) :: body
    character(len=512) :: sx
    character(len=:), allocatable :: message
    integer(int32) :: index
    logical :: ok

    do index = opcode_add, opcode_return
        sx = '(mir-function (name opcode) (entry-block 0) (instruction-count 1) '// &
            '(instructions (instruction (id 0) (opcode '//trim(opcode_names(index))// &
            ') (source-rule metadata/opcode) (result (id 1) (kind integer) '// &
            '(type i32)))))'
        call mir_function_body_from_sx(trim(sx), body, ok, message)
        call assert_true(ok, 'generated opcode metadata was not accepted')
        call assert_true(body%instructions(1)%opcode == index, &
            'opcode value changed from the independent metadata oracle')
    end do

    do index = value_kind_integer, value_kind_address
        sx = '(mir-function (name kind) (entry-block 0) (instruction-count 1) '// &
            '(instructions (instruction (id 0) (opcode add) '// &
            '(source-rule metadata/kind) (result (id 1) (kind '// &
            trim(kind_names(index))//') (type i32)))))'
        call mir_function_body_from_sx(trim(sx), body, ok, message)
        call assert_true(ok, 'generated value-kind metadata was not accepted')
        call assert_true(body%instructions(1)%result%kind == index, &
            'value-kind value changed from the independent metadata oracle')
    end do

    write (*, '(a)') 'mir metadata behavioral checks: ok'

contains

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

end program test_mir_metadata_behavior
