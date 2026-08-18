program test_frontend_ast_v1_integer_assignment
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1, &
        ffc_validate_frontend_ast_v1_integer_assignment_program_shape
    use ffc_mir, only: mir_function_body_t, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(ffc_frontend_ast_v1_t) :: ast
    character(len=:), allocatable :: message

    call assert_true(lower_assignment(ast, body, message), &
        'integer assignment AST-v1 was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'generated integer assignment shape rejected its positive path')
    call assert_true(body%function%instruction_count == 2_int32, &
        'integer assignment instruction count changed')
    call assert_true(body%instructions(1)%opcode == opcode_store, &
        'assignment was not represented by store')
    call assert_true(body%instructions(2)%opcode == opcode_return, &
        'assignment return opcode changed')
    call assert_true(body%instructions(1)%result%kind == value_kind_integer, &
        'assignment result kind changed')
    call assert_equal(body%instructions(1)%result%type_name, 'i32', &
        'assignment result type changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/assignment', &
        'assignment source rule changed')

    body%instructions(1)%opcode = opcode_return
    call assert_false(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'assignment opcode mutation was accepted')

    call assert_true(lower_assignment(ast, body, message), &
        'integer assignment AST-v1 could not be rebuilt')
    body%instructions(1)%result%type_name = 'f64'
    call assert_false(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'assignment type mutation was accepted')

    call assert_true(lower_assignment(ast, body, message), &
        'integer assignment AST-v1 could not be rebuilt')
    body%instructions(1)%source_rule = 'frontend-ast-v1/program'
    call assert_false(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'assignment source-rule mutation was accepted')

    ast%assignment%value = '2'
    call assert_false(ffc_lower_frontend_ast_v1(ast, body, message), &
        'malformed assignment AST-v1 was accepted')
    write (*, '(a)') 'frontend AST-v1 integer assignment checks: ok'

contains

    function assignment_sx() result(serialized)
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
    end function assignment_sx

    logical function lower_assignment(ast, body, message) result(ok)
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out) :: message

        ok = ffc_frontend_ast_v1_from_sx(declaration_sx(), ast, message)
        if (.not. ok) return
        ast%assignment_count = 1_int32
        ast%assignment%target = 'x'
        ast%assignment%value = '1'
        ast%assignment%source_file = ast%root%source_file
        ast%assignment%source_hash = ast%root%source_hash
        ast%assignment%start_byte = 25
        ast%assignment%end_byte = 30
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower_assignment

    function declaration_sx() result(serialized)
        character(len=4096) :: serialized

        serialized = assignment_sx()
    end function declaration_sx

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

end program test_frontend_ast_v1_integer_assignment
