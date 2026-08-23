program test_frontend_ast_v1_generic_integer_expression
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_load, opcode_return, opcode_store
    implicit none

    type(ffc_frontend_ast_v1_t) :: ast
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    character(len=4096) :: serialized
    integer :: index

    serialized = '(program-unit (root (program-root (name main) '// &
        '(span (source-span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit))))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind program) (name main) '// &
        '(span (source-span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit))))) (variable-count 1) '// &
        '(variable (variable-declaration (type-spec integer) (name x) '// &
        '(span (source-span (file unit.f90) (start-byte 10) (end-byte 24) '// &
        '(source-hash hash-unit))))) (assignment-count 1) '// &
        '(assignment (assignment-stmt (variable x) (expression '// &
        '(assignment-expression (kind binary-expression) (operator +) '// &
        '(left-operand x) (right-operand x))) '// &
        '(span (source-span (file unit.f90) (start-byte 25) (end-byte 34) '// &
        '(source-hash hash-unit))))))'

    call assert_true(ffc_frontend_ast_v1_from_sx(serialized, ast, message), &
        'generic integer expression AST was rejected')
    call assert_true(ffc_lower_frontend_ast_v1(ast, body, message), &
        'generic integer expression was not lowered')
    call assert_true(body%function%instruction_count == 5_int32, &
        'generic expression MIR instruction count changed')
    call assert_true(body%instructions(1)%opcode == opcode_load .and. &
        body%instructions(2)%opcode == opcode_load .and. &
        body%instructions(3)%opcode == opcode_add .and. &
        body%instructions(4)%opcode == opcode_store .and. &
        body%instructions(5)%opcode == opcode_return, &
        'generic expression MIR does not follow x + x semantics')
    call assert_true(all([(allocated(body%instructions(index)%storage_key), index = 1, 5, 3)]), &
        'generic expression storage shape changed')
    call assert_true(trim(body%instructions(1)%storage_key) == 'x' .and. &
        trim(body%instructions(2)%storage_key) == 'x' .and. &
        trim(body%instructions(4)%storage_key) == 'x', &
        'generic expression storage key changed')
    call assert_true(all([(body%instructions(index)%result%id == merge(2, index - 1, index >= 3), &
        index = 1, 5)]), 'generic expression result IDs changed')
    call assert_true(all([(trim(body%instructions(index)%source_rule) == &
        'frontend-ast-v1/expression', index = 1, 5)]), &
        'generic expression source rule changed')
    write (*, '(a)') 'frontend AST-v1 generic integer expression checks: ok'

contains

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

end program test_frontend_ast_v1_generic_integer_expression
