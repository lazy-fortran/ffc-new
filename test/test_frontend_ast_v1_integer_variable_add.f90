program test_integer_variable_add
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1, ffc_validate_frontend_ast_v1_int_var_assignment_shape
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_const, opcode_load, opcode_return, &
        opcode_store, value_kind_integer
    implicit none

    type(ffc_frontend_ast_v1_t) :: ast
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(lower(variable_add_expression(), body), 'variable add was not lowered')
    call assert_true(ffc_validate_frontend_ast_v1_int_var_assignment_shape(body, message), &
        'generated variable expression shape rejected its positive path')
    call assert_true(body%function%instruction_count == 5_int32, 'instruction count changed')
    call assert_true(body%instructions(1)%id == 0_int32 .and. &
        body%instructions(1)%opcode == opcode_load .and. &
        body%instructions(1)%result%id == 0_int32, 'load shape changed')
    call assert_true(body%instructions(2)%id == 1_int32 .and. &
        body%instructions(2)%opcode == opcode_const .and. &
        body%instructions(2)%literal_value == 1_int32 .and. &
        body%instructions(2)%result%id == 1_int32, 'constant shape changed')
    call assert_true(body%instructions(3)%id == 2_int32 .and. &
        body%instructions(3)%opcode == opcode_add .and. &
        body%instructions(3)%result%id == 2_int32, 'add shape changed')
    call assert_true(body%instructions(4)%id == 3_int32 .and. &
        body%instructions(4)%opcode == opcode_store .and. &
        body%instructions(4)%result%id == 2_int32, 'store shape changed')
    call assert_true(body%instructions(5)%id == 4_int32 .and. &
        body%instructions(5)%opcode == opcode_return .and. &
        body%instructions(5)%result%id == 2_int32, 'return shape changed')
    call assert_true(all_integer_expression_metadata(body), 'expression metadata changed')

    call assert_false(lower('(assignment-expression (kind binary-expression) (operator +) '// &
        '(left-operand y) (right-operand 1))', body), 'wrong variable was accepted')
    call assert_false(lower('(assignment-expression (kind binary-expression) (operator +) '// &
        '(left-operand x) (right-operand 2))', body), 'wrong operand was accepted')
    call assert_false(lower('(assignment-expression (kind binary-expression) (operator +) '// &
        '(left-operand x) (right-operand 1)', body), 'malformed expression was accepted')
    write (*, '(a)') 'frontend AST-v1 integer variable add checks: ok'

contains

    function variable_add_expression() result(expression)
        character(len=160) :: expression

        expression = '(assignment-expression (kind binary-expression) (operator +) '// &
            '(left-operand x) (right-operand 1))'
    end function variable_add_expression

    logical function lower(expression, candidate) result(ok)
        character(len=*), intent(in) :: expression
        type(mir_function_body_t), intent(out) :: candidate
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
        ok = ffc_frontend_ast_v1_from_sx(serialized, ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, candidate, message)
    end function lower

    logical function all_integer_expression_metadata(candidate) result(ok)
        type(mir_function_body_t), intent(in) :: candidate
        integer :: index

        ok = .true.
        do index = 1, 5
            ok = ok .and. candidate%instructions(index)%result%kind == value_kind_integer
            ok = ok .and. trim(candidate%instructions(index)%result%type_name) == 'i32'
            ok = ok .and. trim(candidate%instructions(index)%source_rule) == &
                'frontend-ast-v1/expression'
        end do
    end function all_integer_expression_metadata

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

end program test_integer_variable_add
