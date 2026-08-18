program test_frontend_ast_v2_print
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx, &
        ffc_validate_frontend_ast_v2_print_7_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_10_shape
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_output, opcode_return
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_sx(), body, message), &
        'PRINT star 7 envelope was rejected')
    call assert_true(mir_validate_function_body(body, message), 'PRINT MIR is invalid')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_shape(body, message), &
        'PRINT MIR shape was rejected')
    call assert_equal(body%instructions(1)%opcode, opcode_const, 'PRINT literal opcode changed')
    call assert_equal(body%instructions(2)%opcode, opcode_output, 'PRINT output opcode missing')
    call assert_equal(body%instructions(3)%opcode, opcode_return, 'PRINT return opcode changed')
    call assert_equal(body%instructions(1)%literal_value, 7, 'PRINT literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_sx(), '(output-value 7)', '(output-value 8)'), body, message), &
        'PRINT 8 mutation was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE mutation was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_sx(), '(output-value 7)', '(output-value)'), body, message), &
        'missing PRINT item was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_two_sx(), body, message), &
        'PRINT star 7, 8 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_8_shape(body, message), &
        'PRINT 7, 8 MIR shape was rejected')
    call assert_equal(body%instructions(1)%opcode, opcode_const, 'first PRINT literal opcode changed')
    call assert_equal(body%instructions(2)%opcode, opcode_output, 'first PRINT output opcode missing')
    call assert_equal(body%instructions(3)%opcode, opcode_const, 'second PRINT literal opcode changed')
    call assert_equal(body%instructions(4)%opcode, opcode_output, 'second PRINT output opcode missing')
    call assert_equal(body%instructions(5)%opcode, opcode_return, 'PRINT 7, 8 return opcode changed')
    call assert_equal(body%instructions(1)%literal_value, 7, 'first PRINT literal changed')
    call assert_equal(body%instructions(3)%literal_value, 8, 'second PRINT literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_two_sx(), '(output-value-2 8)', '(output-value-2 9)'), body, message), &
        'PRINT wrong second item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_two_sx(), '(output-value-2 8)', '(output-value-2)'), body, message), &
        'PRINT missing second item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_two_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE two-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_three_sx(), body, message), &
        'PRINT star 7, 8, 9 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_8_9_shape(body, message), &
        'PRINT 7, 8, 9 MIR shape was rejected')
    call assert_equal(body%instructions(1)%opcode, opcode_const, 'third-route first const changed')
    call assert_equal(body%instructions(2)%opcode, opcode_output, 'third-route first output missing')
    call assert_equal(body%instructions(3)%opcode, opcode_const, 'third-route second const changed')
    call assert_equal(body%instructions(4)%opcode, opcode_output, 'third-route second output missing')
    call assert_equal(body%instructions(5)%opcode, opcode_const, 'third-route third const changed')
    call assert_equal(body%instructions(6)%opcode, opcode_output, 'third-route third output missing')
    call assert_equal(body%instructions(7)%opcode, opcode_return, 'third-route return changed')
    call assert_equal(body%instructions(1)%literal_value, 7, 'third-route first literal changed')
    call assert_equal(body%instructions(3)%literal_value, 8, 'third-route second literal changed')
    call assert_equal(body%instructions(5)%literal_value, 9, 'third-route third literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_three_sx(), '(output-value-3 9)', '(output-value-3 8)'), body, message), &
        'PRINT wrong third item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_three_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE three-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_four_sx(), body, message), &
        'PRINT star 7, 8, 9, 10 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_8_9_10_shape(body, message), &
        'PRINT 7, 8, 9, 10 MIR shape was rejected')
    call assert_equal(body%instructions(1)%opcode, opcode_const, 'fourth-route first const changed')
    call assert_equal(body%instructions(2)%opcode, opcode_output, 'fourth-route first output missing')
    call assert_equal(body%instructions(3)%opcode, opcode_const, 'fourth-route second const changed')
    call assert_equal(body%instructions(4)%opcode, opcode_output, 'fourth-route second output missing')
    call assert_equal(body%instructions(5)%opcode, opcode_const, 'fourth-route third const changed')
    call assert_equal(body%instructions(6)%opcode, opcode_output, 'fourth-route third output missing')
    call assert_equal(body%instructions(7)%opcode, opcode_const, 'fourth-route fourth const changed')
    call assert_equal(body%instructions(8)%opcode, opcode_output, 'fourth-route fourth output missing')
    call assert_equal(body%instructions(9)%opcode, opcode_return, 'fourth-route return changed')
    call assert_equal(body%instructions(1)%literal_value, 7, 'fourth-route first literal changed')
    call assert_equal(body%instructions(3)%literal_value, 8, 'fourth-route second literal changed')
    call assert_equal(body%instructions(5)%literal_value, 9, 'fourth-route third literal changed')
    call assert_equal(body%instructions(7)%literal_value, 10, 'fourth-route fourth literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_four_sx(), '(output-value-4 10)', '(output-value-4 9)'), body, message), &
        'PRINT wrong fourth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_four_sx(), '(output-value-4 10)', '(output-value-4)'), body, message), &
        'PRINT missing fourth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_four_sx(), '(output-rule-4 R1217)', '(output-rule-4)'), body, message), &
        'PRINT missing fourth rule was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_four_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE four-item mutation was accepted')

    write (*, '(a)') 'frontend AST v2 PRINT star 7 checks: ok'

contains

    function envelope_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 40) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_sx

    function envelope_two_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 42) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 2) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(output-rule-2 R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_two_sx

    function envelope_three_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 44) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 3) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 44) '// &
            '(source-hash print-test))) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_three_sx

    function envelope_four_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 46) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 4) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(output-kind-4 integer-literal) (output-value-4 10) (output-rule-4 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_four_sx

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=4096) :: replaced
        integer :: start

        replaced = value
        start = index(replaced, old)
        if (start > 0) replaced = replaced(:start - 1)//new//replaced(start + len(old):)
    end function replace_text

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_equal(actual, expected, description)
        integer(int32), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal

end program test_frontend_ast_v2_print
