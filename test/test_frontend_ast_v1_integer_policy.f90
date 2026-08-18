program test_frontend_ast_v1_integer_policy
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v1_from_sx, &
        ffc_validate_frontend_ast_v1_integer_program_shape
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_return, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(integer_v1_sx(), body, message), &
        'integer AST-v1 program was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_integer_program_shape(body, message), &
        'generated integer instruction shape rejected its positive path')
    call assert_true(body%function%instruction_count == 2_int32, &
        'integer instruction count changed')
    call assert_true(body%instructions(1)%opcode == opcode_add, &
        'integer add opcode changed')
    call assert_true(body%instructions(2)%opcode == opcode_return, &
        'integer return opcode changed')
    call assert_true(body%instructions(1)%result%kind == value_kind_integer, &
        'integer result kind changed')
    call assert_equal(body%instructions(1)%result%type_name, 'i32', &
        'integer result type changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/program', &
        'integer source rule changed')

    body%instructions(1)%opcode = opcode_return
    call assert_false(ffc_validate_frontend_ast_v1_integer_program_shape(body, message), &
        'malformed opcode neighbor was accepted')
    call assert_equal(message, 'frontend-ast-v1 integer opcode shape changed', &
        'malformed opcode diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(integer_v1_sx(), body, message), &
        'integer AST-v1 program could not be rebuilt')
    body%instructions(1)%result%type_name = 'f64'
    call assert_false(ffc_validate_frontend_ast_v1_integer_program_shape(body, message), &
        'malformed type neighbor was accepted')
    call assert_equal(message, 'frontend-ast-v1 integer result shape changed', &
        'malformed type diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(integer_v1_sx(), body, message), &
        'integer AST-v1 program could not be rebuilt')
    body%instructions(2)%source_rule = 'frontend-ast-v1/return'
    call assert_false(ffc_validate_frontend_ast_v1_integer_program_shape(body, message), &
        'malformed source-rule neighbor was accepted')
    call assert_equal(message, 'frontend-ast-v1 integer source rule changed', &
        'malformed source-rule diagnostic changed')

    call assert_true(ffc_lower_frontend_ast_v1_from_sx(integer_v1_sx(), body, message), &
        'integer AST-v1 program could not be rebuilt')
    body%function%instruction_count = 1_int32
    call assert_false(ffc_validate_frontend_ast_v1_integer_program_shape(body, message), &
        'malformed instruction-count neighbor was accepted')
    call assert_equal(message, 'function instruction count does not match body', &
        'malformed instruction-count diagnostic changed')
    write (*, '(a)') 'frontend AST-v1 integer instruction policy checks: ok'

contains

    function integer_v1_sx() result(serialized)
        character(len=4096) :: serialized

        serialized = '(program-unit (root (program-root (name main) '// &
            '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit)))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file unit.f90) (start-byte 10) (end-byte 24) '// &
            '(source-hash hash-unit))))))'
    end function integer_v1_sx

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

end program test_frontend_ast_v1_integer_policy
