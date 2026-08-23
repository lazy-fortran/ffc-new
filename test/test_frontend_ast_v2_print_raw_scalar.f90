program test_frontend_ast_v2_print_raw_scalar
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_output, opcode_return, opcode_store
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(positive_sx(), body, message), &
        'raw scalar AST-v2 envelope was rejected')
    call assert_true(mir_validate_function_body(body, message), 'raw scalar MIR is invalid')
    call assert_true(body%function%instruction_count == 5_int32, 'raw scalar MIR count changed')
    call assert_true(body%instructions(1)%opcode == opcode_const .and. &
        body%instructions(1)%literal_value == 42, 'raw scalar constant changed')
    call assert_storage(2)
    call assert_storage(3)
    call assert_true(body%instructions(4)%opcode == opcode_output .and. &
        body%instructions(5)%opcode == opcode_return, 'raw scalar output tail changed')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(output-name counter_2)', '(output-name other)'), body, message), &
        'corrupt raw scalar output name was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(assignment-count 1)', '(assignment-count 0)'), body, message), &
        'corrupt raw scalar assignment count was accepted')
    write (*, '(a)') 'frontend AST v2 raw scalar PRINT checks: ok'

contains

    subroutine assert_storage(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'raw scalar storage missing')
        call assert_equal(body%instructions(index)%storage_key, 'counter_2', &
            'raw scalar storage key changed')
    end subroutine assert_storage

    function positive_sx() result(value)
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 70) (source-hash raw-counter-2))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash raw-counter-2))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name counter_2) '// &
            '(span (source-span (file main.f90) (start-byte 13) (end-byte 30) '// &
            '(source-hash raw-counter-2))))) (execution-part '// &
            '(assignment-sequence (assignment-count 1) (assignment (assignment-stmt '// &
            '(variable counter_2) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand 42) (right-operand ))) (span (source-span '// &
            '(file main.f90) (start-byte 31) (end-byte 48) (source-hash raw-counter-2)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind variable) (output-name counter_2) (statement-rule R1212) '// &
            '(format-rule R1215) (output-rule R901) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash raw-counter-2))))'
    end function positive_sx

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=8192) :: replaced
        integer :: location

        replaced = value
        location = index(replaced, old)
        if (location > 0) replaced = replaced(:location - 1)//new//replaced(location + len(old):)
    end function replace_text

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

end program test_frontend_ast_v2_print_raw_scalar
