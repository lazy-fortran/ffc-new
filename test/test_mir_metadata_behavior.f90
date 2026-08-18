program test_mir_metadata_behavior
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_t, &
        opcode_add, opcode_return, value_kind_address, value_kind_character, value_kind_integer
    use ffc_mir_metadata, only: mir_source_rule_name, mir_source_rule_value, &
        source_rule_frontend_ast_v1_program, source_rule_frontend_v0_program, &
        source_rule_program_root
    implicit none

    character(len=32), parameter :: opcode_names(10) = [character(len=32) :: &
        'add', 'sub', 'mul', 'div', 'load', 'store', 'compare', 'branch', 'call', &
        'return']
    character(len=32), parameter :: kind_names(6) = [character(len=32) :: &
        'integer', 'real', 'logical', 'address', 'complex', 'character']
    type(mir_function_body_t) :: body
    character(len=512) :: sx
    character(len=:), allocatable :: message
    integer(int32) :: index
    logical :: ok

    call assert_equal(source_rule_program_root, 'program-root', &
        'generated program-root source rule changed')
    call assert_equal(source_rule_frontend_v0_program, 'frontend-v0/program', &
        'generated frontend-v0 source rule changed')
    call assert_equal(source_rule_frontend_ast_v1_program, 'frontend-ast-v1/program', &
        'generated AST-v1 source rule changed')
    call assert_equal(mir_source_rule_name(source_rule_frontend_v0_program), &
        'frontend_v0_program', 'source-rule name lookup changed')
    call assert_equal(mir_source_rule_value('frontend_ast_v1_program'), &
        source_rule_frontend_ast_v1_program, 'source-rule value lookup changed')
    call assert_equal(mir_source_rule_name('not-a-source-rule'), '', &
        'unknown source-rule lookup did not clear')

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

    do index = value_kind_integer, value_kind_character
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

    subroutine assert_equal(value, expected, description)
        character(len=*), intent(in) :: value, expected, description

        if (trim(value) /= trim(expected)) error stop description
    end subroutine assert_equal

end program test_mir_metadata_behavior
