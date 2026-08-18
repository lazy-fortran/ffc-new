program test_frontend_ast_v1_double_precision
    use, intrinsic :: iso_fortran_env, only: int32, int64
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1_from_sx, &
        ffc_validate_frontend_ast_v1_double_precision_program_shape
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_add, &
        opcode_return, value_kind_real
    implicit none

    type(mir_function_body_t) :: body
    type(ffc_frontend_ast_v1_t) :: ast
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx(1_int64, 1_int64, &
        'double-precision'), body, message), &
        'canonical double-precision AST-v1 type was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message), &
        'generated double-precision instruction shape rejected its positive path')
    call assert_true(mir_validate_function_body(body, message), &
        'lowered double-precision MIR body is invalid')
    call assert_true(body%function%instruction_count == 2_int32, &
        'double-precision instruction count changed')
    call assert_true(body%instructions(1)%opcode == opcode_add, &
        'double-precision add opcode changed')
    call assert_true(body%instructions(2)%opcode == opcode_return, &
        'double-precision return opcode changed')
    call assert_true(body%instructions(1)%result%kind == value_kind_real, &
        'double-precision AST-v1 type did not lower to real kind')
    call assert_equal(body%instructions(1)%result%type_name, 'f64', &
        'double-precision AST-v1 type did not lower to f64')
    call assert_equal(body%instructions(2)%result%type_name, 'f64', &
        'double-precision AST-v1 return type did not lower to f64')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/program', &
        'double-precision source rule changed')
    call assert_equal(body%instructions(2)%source_rule, 'frontend-ast-v1/program', &
        'double-precision return source rule changed')

    call assert_false(ffc_frontend_ast_v1_from_sx(v1_sx(0_int64, 1_int64, &
        'double-precision'), ast, message), &
        'double-precision declaration-count neighbor was accepted')
    call assert_equal(message, 'invalid-frontend-ast-v1-cardinality', &
        'double-precision declaration-count diagnostic changed')
    call assert_false(ffc_frontend_ast_v1_from_sx(v1_sx(1_int64, 2_int64, &
        'double-precision'), ast, message), &
        'double-precision variable-count neighbor was accepted')
    call assert_equal(message, 'invalid-frontend-ast-v1-cardinality', &
        'double-precision variable-count diagnostic changed')

    call assert_false(ffc_lower_frontend_ast_v1_from_sx(v1_sx(1_int64, 1_int64, 'unsupported'), &
        body, message), &
        'unsupported AST-v1 type was lowered')
    call assert_equal(message, 'unsupported-frontend-ast-v1-type-spec', &
        'unsupported AST-v1 type diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx(1_int64, 1_int64, &
        'double-precision'), body, message), 'double-precision AST-v1 program could not be rebuilt')
    body%instructions(2)%source_rule = 'frontend-ast-v1/return'
    call assert_false(ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message), &
        'double-precision source-rule neighbor was accepted')
    call assert_equal(message, 'frontend-ast-v1 double-precision source rule changed', &
        'double-precision source-rule diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx(1_int64, 1_int64, &
        'double-precision'), body, message), 'double-precision AST-v1 program could not be rebuilt')
    body%instructions(1)%result%type_name = 'f32'
    call assert_false(ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message), &
        'double-precision type neighbor was accepted')
    call assert_equal(message, 'frontend-ast-v1 double-precision result shape changed', &
        'double-precision type diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(v1_sx(1_int64, 1_int64, &
        'double-precision'), body, message), 'double-precision AST-v1 program could not be rebuilt')
    body%function%instruction_count = 1_int32
    call assert_false(ffc_validate_frontend_ast_v1_double_precision_program_shape(body, message), &
        'double-precision instruction-count neighbor was accepted')
    call assert_equal(message, 'function instruction count does not match body', &
        'double-precision instruction-count diagnostic changed')
    write (*, '(a)') 'frontend AST v1 double-precision behavioral checks: ok'

contains

    function v1_sx(declaration_count, variable_count, type_spec) result(serialized)
        integer(int64), intent(in) :: declaration_count, variable_count
        character(len=*), intent(in) :: type_spec
        character(len=4096) :: serialized
        character(len=32) :: declaration_count_text, variable_count_text

        write (declaration_count_text, '(i0)') declaration_count
        write (variable_count_text, '(i0)') variable_count
        serialized = '(program-unit (root (program-root (name main) '// &
            '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (declaration-count '// &
            trim(declaration_count_text)//') '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (variable-count '// &
            trim(variable_count_text)//') '// &
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
