program test_frontend_ast_v1_integer_add
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_const, opcode_return, opcode_store, &
        value_kind_integer
    implicit none

    type(ffc_frontend_ast_v1_t) :: ast
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(lower(add_expression()), 'add fixture was not lowered')
    call assert_true(body%function%instruction_count == 5_int32, 'add count changed')
    call assert_true(body%instructions(1)%id == 0_int32 .and. &
        body%instructions(1)%opcode == opcode_const .and. &
        body%instructions(1)%literal_value == 1_int32 .and. &
        body%instructions(1)%result%id == 0_int32, 'left const changed')
    call assert_true(body%instructions(2)%id == 1_int32 .and. &
        body%instructions(2)%opcode == opcode_const .and. &
        body%instructions(2)%literal_value == 2_int32 .and. &
        body%instructions(2)%result%id == 1_int32, 'right const changed')
    call assert_true(body%instructions(3)%id == 2_int32 .and. &
        body%instructions(3)%opcode == opcode_add .and. &
        body%instructions(3)%result%id == 2_int32, 'add result changed')
    call assert_true(body%instructions(4)%opcode == opcode_store .and. &
        body%instructions(4)%result%id == 2_int32 .and. &
        body%instructions(5)%opcode == opcode_return .and. &
        body%instructions(5)%result%id == 2_int32, 'store-return shape changed')
    call assert_true(all_integer_results(body), 'integer result metadata changed')

    call assert_false(lower('( binary-expr ( operator - ) ( left 1 ) ( right 2 ) )'), &
        'wrong operator was accepted')
    call assert_false(lower('( binary-expr ( operator + ) ( left 1 ) ( right 3 ) )'), &
        'wrong operand was accepted')
    write (*, '(a)') 'frontend AST-v1 integer add checks: ok'

contains

    function add_expression() result(expression)
        character(len=128) :: expression

        expression = '( binary-expr ( operator + ) ( left 1 ) ( right 2 ) )'
    end function add_expression

    logical function lower(expression) result(ok)
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
            '(span (source-span (file unit.f90) '// &
            '(start-byte 25) (end-byte 34) (source-hash hash-unit))))))'
        ok = ffc_frontend_ast_v1_from_sx(serialized, ast, message)
        if (.not. ok) return
        ok = ffc_lower_frontend_ast_v1(ast, body, message)
    end function lower

    logical function all_integer_results(candidate) result(ok)
        type(mir_function_body_t), intent(in) :: candidate
        integer :: index

        ok = .true.
        do index = 1, 5
            ok = ok .and. candidate%instructions(index)%result%kind == value_kind_integer
            ok = ok .and. trim(candidate%instructions(index)%result%type_name) == 'i32'
            ok = ok .and. trim(candidate%instructions(index)%source_rule) == &
                'frontend-ast-v1/expression'
        end do
    end function all_integer_results

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

end program test_frontend_ast_v1_integer_add
