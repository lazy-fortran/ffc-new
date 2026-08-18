program test_frontend_ast_v1_mir_handoff
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v1_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, &
        value_kind_complex, value_kind_integer, value_kind_real
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_type('integer', value_kind_integer, 'i32')
    call check_type('real', value_kind_real, 'f32')
    call check_type('complex', value_kind_complex, 'c32')
    call check_generated_shape()

    call assert_false(ffc_lower_frontend_ast_v1_from_sx(v1_sx('logical'), body, message), &
        'unsupported v1 type spec was lowered')
    call assert_equal(message, 'unsupported-frontend-ast-v1-type-spec', &
        'unsupported v1 type diagnostic changed')
    write (*, '(a)') 'frontend AST v1 to MIR typed handoff behavioral checks: ok'

contains

    subroutine check_type(type_spec, expected_kind, expected_name)
        character(len=*), intent(in) :: type_spec, expected_name
        integer(int32), intent(in) :: expected_kind

        call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx(type_spec), body, message), &
            'typed v1 AST was not lowered: '//trim(type_spec))
        call assert_true(mir_validate_function_body(body, message), &
            'typed v1 MIR body is invalid: '//trim(type_spec))
        call assert_true(body%instructions(1)%result%kind == expected_kind, &
            'typed v1 MIR kind changed: '//trim(type_spec))
        call assert_equal(body%instructions(1)%result%type_name, expected_name, &
            'typed v1 MIR type name changed: '//trim(type_spec))
        call assert_equal(body%instructions(2)%result%type_name, expected_name, &
            'typed v1 return type changed: '//trim(type_spec))
    end subroutine check_type

    subroutine check_generated_shape()
        character(len=4096) :: serialized

        serialized = '(program-unit (root (program-root (name main) (span '// &
            '(source-span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file unit.f90) (start-byte 0) '// &
            '(end-byte 64) (source-hash hash-unit))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file unit.f90) (start-byte 10) (end-byte 24) '// &
            '(source-hash hash-unit))))))'
        call assert_true(ffc_lower_frontend_ast_v1_from_sx(serialized, body, message), &
            'generated frontend AST-v1 shape was rejected')
        call assert_true(mir_validate_function_body(body, message), &
            'generated frontend AST-v1 shape produced invalid MIR')
        call assert_equal(body%function%name, 'main', &
            'generated frontend AST-v1 name was not lowered')
    end subroutine check_generated_shape

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

end program test_frontend_ast_v1_mir_handoff
