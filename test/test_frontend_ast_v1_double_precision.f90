program test_frontend_ast_v1_double_precision
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v1_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, value_kind_real
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx('double-precision'), body, message), &
        'canonical double-precision AST-v1 type was not lowered')
    call assert_true(mir_validate_function_body(body, message), &
        'lowered double-precision MIR body is invalid')
    call assert_true(body%instructions(1)%result%kind == value_kind_real, &
        'double-precision AST-v1 type did not lower to real kind')
    call assert_equal(body%instructions(1)%result%type_name, 'f64', &
        'double-precision AST-v1 type did not lower to f64')
    call assert_equal(body%instructions(2)%result%type_name, 'f64', &
        'double-precision AST-v1 return type did not lower to f64')

    call assert_false(ffc_lower_frontend_ast_v1_from_sx(v1_sx('unsupported'), body, message), &
        'unsupported AST-v1 type was lowered')
    call assert_equal(message, 'unsupported-frontend-ast-v1-type-spec', &
        'unsupported AST-v1 type diagnostic changed')
    write (*, '(a)') 'frontend AST v1 double-precision behavioral checks: ok'

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

end program test_frontend_ast_v1_double_precision
