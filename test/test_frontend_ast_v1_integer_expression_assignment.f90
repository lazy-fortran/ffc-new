program test_frontend_ast_v1_integer_expression_assignment
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1, &
        ffc_validate_frontend_ast_v1_integer_assignment_program_shape, &
        ffc_validate_frontend_ast_v1_int_expr_assignment_shape, &
        ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_mul, opcode_return, opcode_store, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    type(ffc_frontend_ast_v1_t) :: ast
    character(len=:), allocatable :: message

    call assert_true(lower_expression(ast, body, message), &
        'wrapped integer expression AST-v1 was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
        body, message), 'generated integer expression shape rejected its positive path')
    call assert_true(body%function%instruction_count == 3_int32, &
        'integer expression instruction count changed')
    call assert_true(body%instructions(1)%opcode == opcode_add, &
        'expression was not represented by add')
    call assert_true(body%instructions(2)%opcode == opcode_store, &
        'expression assignment was not represented by store')
    call assert_true(body%instructions(3)%opcode == opcode_return, &
        'expression return opcode changed')
    call assert_true(body%instructions(1)%result%kind == value_kind_integer, &
        'expression result kind changed')
    call assert_equal(body%instructions(1)%result%type_name, 'i32', &
        'expression result type changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/expression', &
        'expression source rule changed')

    call assert_true(lower_multiplication(ast, body, message), &
        'wrapped integer multiplication AST-v1 was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(body, message), &
        'generated integer multiplication shape rejected its positive path')
    call assert_true(body%instructions(1)%opcode == opcode_mul, &
        'multiplication was not represented by mul')
    call assert_true(body%instructions(2)%opcode == opcode_store .and. &
        body%instructions(3)%opcode == opcode_return, &
        'multiplication assignment shape changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/expression', &
        'multiplication source rule changed')

    body%instructions(1)%opcode = opcode_add
    call assert_false(ffc_validate_frontend_ast_v1_int_mul_expr_assignment_shape(body, message), &
        'multiplication opcode mutation was accepted')

    body%instructions(1)%opcode = opcode_store
    call assert_false(ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
        body, message), 'expression opcode mutation was accepted')

    call assert_true(lower_expression(ast, body, message), &
        'integer expression AST-v1 could not be rebuilt')
    body%instructions(1)%result%kind = 2_int32
    call assert_false(ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
        body, message), 'expression type-kind mutation was accepted')

    call assert_true(lower_expression(ast, body, message), &
        'integer expression AST-v1 could not be rebuilt')
    body%instructions(2)%source_rule = 'frontend-ast-v1/assignment'
    call assert_false(ffc_validate_frontend_ast_v1_int_expr_assignment_shape(&
        body, message), 'expression source-rule mutation was accepted')

    call assert_true(lower_assignment(ast, body, message), &
        'literal integer assignment AST-v1 was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'literal integer assignment shape was not preserved')
    call assert_true(body%function%instruction_count == 2_int32, &
        'literal integer assignment instruction count changed')

    call assert_true(lower_wrapped_literal(ast, body, message), &
        'wrapped integer literal AST-v1 was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_integer_assignment_program_shape(body, message), &
        'wrapped integer literal assignment shape was not preserved')
    call assert_true(body%function%instruction_count == 2_int32, &
        'wrapped integer literal assignment instruction count changed')

    ast%assignment%value = '( binary-expr ( operator - ) ( left 1 ) ( right 2 ) )'
    call assert_false(ffc_lower_frontend_ast_v1(ast, body, message), &
        'unsupported expression operator was accepted')
    ast%assignment%value = '( binary-expr ( operator + ) ( left 1 ) ( right 3 ) )'
    call assert_false(ffc_lower_frontend_ast_v1(ast, body, message), &
        'unsupported expression operand was accepted')
    ast%assignment%value = '( binary-expr ( operator + ) ( left 1 ) ( right 2 )'
    call assert_false(ffc_lower_frontend_ast_v1(ast, body, message), &
        'malformed expression wrapper was accepted')
    ast%assignment%value = '( binary-expr ( operator * ) ( left 2 ) ( right 2 ) )'
    call assert_false(ffc_lower_frontend_ast_v1(ast, body, message), &
        'unsupported multiplication operand was accepted')
    write (*, '(a)') 'frontend AST-v1 integer expression assignment checks: ok'

contains

    function common_sx(expression) result(serialized)
        character(len=*), intent(in) :: expression
        character(len=4096) :: serialized

        serialized = '(program-unit (root (program-root (name main) '// &
            '(span (source-span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) (name main) '// &
            '(span (source-span (file unit.f90) (start-byte 0) (end-byte 64) '// &
            '(source-hash hash-unit))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file unit.f90) (start-byte 10) (end-byte 24) '// &
            '(source-hash hash-unit))))) (assignment-count 1) '// &
            '(assignment (assignment-stmt (variable x) (expression '//trim(expression)//') '// &
            '(span (source-span (file unit.f90) (start-byte 25) (end-byte 34) '// &
            '(source-hash hash-unit))))))'
    end function common_sx

    logical function lower_expression(ast, body, message) result(ok)
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out) :: message

        ok = ffc_frontend_ast_v1_from_sx(common_sx(&
            '(assignment-expression (kind binary-expression) (operator +) '// &
            '(left-operand 1) (right-operand 2))'), ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower_expression

    logical function lower_assignment(ast, body, message) result(ok)
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out) :: message

        ok = ffc_frontend_ast_v1_from_sx(common_sx('1'), ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower_assignment

    logical function lower_multiplication(ast, body, message) result(ok)
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out) :: message

        ok = ffc_frontend_ast_v1_from_sx(common_sx(&
            '(assignment-expression (kind binary-expression) (operator *) '// &
            '(left-operand 1) (right-operand 2))'), ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower_multiplication

    logical function lower_wrapped_literal(ast, body, message) result(ok)
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out) :: message

        ok = ffc_frontend_ast_v1_from_sx(common_sx(&
            '(assignment-expression (kind integer-literal) (operator ) '// &
            '(left-operand 1) (right-operand ))'), ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower_wrapped_literal

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

end program test_frontend_ast_v1_integer_expression_assignment
