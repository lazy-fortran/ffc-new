program test_frontend_ast_v1_logical
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1_from_sx, &
        ffc_validate_frontend_ast_v1_logical_program_shape
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_add, &
        opcode_return, value_kind_logical
    implicit none

    type(mir_function_body_t) :: body
    type(ffc_frontend_ast_v1_t) :: ast
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v1_from_sx( &
        v1_sx('logical'), body, message), &
        'canonical logical AST-v1 type was not lowered')
    call assert_true( &
        ffc_validate_frontend_ast_v1_logical_program_shape(body, message), &
        'generated logical instruction shape rejected its positive path')
    call assert_true(mir_validate_function_body(body, message), &
        'logical MIR body is invalid')
    call assert_true(body%instructions(1)%opcode == opcode_add, &
        'logical add opcode changed')
    call assert_true(body%instructions(2)%opcode == opcode_return, &
        'logical return opcode changed')
    call assert_true(body%instructions(1)%result%kind == value_kind_logical, &
        'logical result kind changed')
    call assert_equal(body%instructions(1)%result%type_name, 'logical', &
        'logical result type changed')
    call assert_equal(body%instructions(2)%result%type_name, 'logical', &
        'logical return type changed')

    body%instructions(2)%source_rule = 'frontend-ast-v1/return'
    call assert_false( &
        ffc_validate_frontend_ast_v1_logical_program_shape(body, message), &
        'logical source-rule mutation was accepted')
    call assert_equal(message, 'frontend-ast-v1 logical source rule changed', &
        'logical source-rule diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx( &
        v1_sx('logical'), body, message), &
        'logical AST-v1 program could not be rebuilt')
    body%instructions(1)%result%type_name = 'i32'
    call assert_false( &
        ffc_validate_frontend_ast_v1_logical_program_shape(body, message), &
        'logical type mutation was accepted')
    call assert_equal(message, 'frontend-ast-v1 logical result shape changed', &
        'logical type diagnostic changed')

    call assert_false( &
        ffc_frontend_ast_v1_from_sx(v1_sx('logical(kind=4)'), ast, message), &
        'logical kind selector was accepted')
    call assert_true(len_trim(message) > 0, &
        'logical kind-selector failure had no diagnostic')

    write (*, '(a)') 'frontend AST-v1 logical instruction policy checks: ok'

contains

    function v1_sx(type_spec) result(serialized)
        character(len=*), intent(in) :: type_spec
        character(len=4096) :: serialized

        serialized = '(program-unit (root (program-root (name main) '// &
            '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec '//trim(type_spec)//') '// &
            '(name x) (span (source-span (file unit.f90) (start-byte 10) '// &
            '(end-byte 24) (source-hash hash-unit))))))'
    end function v1_sx

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

end program test_frontend_ast_v1_logical
