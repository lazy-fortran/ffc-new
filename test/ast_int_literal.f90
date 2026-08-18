program test_ast_int_literal
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_frontend_ast_v1_from_sx, ffc_frontend_ast_v1_t, &
        ffc_lower_frontend_ast_v1, ffc_validate_frontend_ast_v1_int_literal_assignment_shape
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_to_sx, &
        mir_function_body_t, opcode_const, opcode_return, opcode_store
    implicit none

    type(ffc_frontend_ast_v1_t) :: ast
    type(mir_function_body_t) :: body, roundtrip_body
    character(len=:), allocatable :: message
    character(len=4096) :: serialized
    logical :: ok

    ok = ffc_frontend_ast_v1_from_sx(common_sx(&
        '(assignment-expression (kind integer-literal) (operator ) '// &
        '(left-operand 7) (right-operand ))'), ast, message)
    call assert_true(ok, 'decimal literal wrapper was rejected: '//trim(message))
    ok = ffc_lower_frontend_ast_v1(ast, body, message)
    call assert_true(ok, 'decimal literal wrapper was not lowered: '//trim(message))
    call assert_true(ffc_validate_frontend_ast_v1_int_literal_assignment_shape(body, message), &
        'generated literal assignment shape was rejected: '//trim(message))
    call assert_true(body%instructions(1)%opcode == opcode_const, 'literal did not emit const')
    call assert_true(body%instructions(1)%literal_value == 7_int32, &
        'literal value was not serialized into MIR')
    call assert_true(body%instructions(2)%opcode == opcode_store, 'literal store was omitted')
    call assert_true(body%instructions(3)%opcode == opcode_return, 'literal return was omitted')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v1/assignment', &
        'literal source rule changed')

    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'literal MIR was not serialized: '//trim(message))
    call assert_true(index(trim(serialized), &
        '(opcode const) (source-rule frontend-ast-v1/assignment) (literal 7)') > 0, &
        'serialized MIR const field order changed')
    call mir_function_body_from_sx(trim(serialized), roundtrip_body, ok, message)
    call assert_true(ok, 'serialized literal MIR was not readable: '//trim(message))
    call assert_true(roundtrip_body%instructions(1)%literal_value == 7_int32, &
        'literal value did not survive MIR round-trip')

    call assert_false(ffc_frontend_ast_v1_from_sx(common_sx(&
        '(assignment-expression (kind integer-literal) (operator ) '// &
        '(left-operand 7x) (right-operand ))'), ast, message), &
        'non-decimal literal was accepted')
    call assert_false(ffc_frontend_ast_v1_from_sx(common_sx(&
        '(assignment-expression (kind integer-literal) (operator ) '// &
        '(left-operand 2147483648) (right-operand ))'), ast, message), &
        'out-of-range literal was accepted')
    call assert_false(ffc_frontend_ast_v1_from_sx(common_sx(&
        '(assignment-expression (kind integer-literal) (operator ) '// &
        '(left-operand ) (right-operand ))'), ast, message), &
        'malformed literal was accepted')

    write (*, '(a)') 'frontend AST-v1 integer literal assignment checks: ok'

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

end program test_ast_int_literal
