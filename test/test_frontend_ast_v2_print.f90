program test_frontend_ast_v2_print
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx, &
        ffc_validate_frontend_ast_v2_print_7_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_10_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape, &
        ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape, &
        ffc_validate_frontend_ast_v2_print_seven_shape, ffc_validate_frontend_ast_v2_print_eight_shape, &
        ffc_validate_frontend_ast_v2_print_nine_shape, ffc_validate_frontend_ast_v2_print_ten_shape, &
        ffc_validate_frontend_ast_v2_print_generic_shape
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_output, opcode_return
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer :: item_index

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

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_five_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_8_9_10_11_shape(body, message), &
        'PRINT 7, 8, 9, 10, 11 MIR shape was rejected')
    call assert_equal(body%instructions(1)%opcode, opcode_const, 'fifth-route first const changed')
    call assert_equal(body%instructions(2)%opcode, opcode_output, 'fifth-route first output missing')
    call assert_equal(body%instructions(3)%opcode, opcode_const, 'fifth-route second const changed')
    call assert_equal(body%instructions(4)%opcode, opcode_output, 'fifth-route second output missing')
    call assert_equal(body%instructions(5)%opcode, opcode_const, 'fifth-route third const changed')
    call assert_equal(body%instructions(6)%opcode, opcode_output, 'fifth-route third output missing')
    call assert_equal(body%instructions(7)%opcode, opcode_const, 'fifth-route fourth const changed')
    call assert_equal(body%instructions(8)%opcode, opcode_output, 'fifth-route fourth output missing')
    call assert_equal(body%instructions(9)%opcode, opcode_const, 'fifth-route fifth const changed')
    call assert_equal(body%instructions(10)%opcode, opcode_output, 'fifth-route fifth output missing')
    call assert_equal(body%instructions(11)%opcode, opcode_return, 'fifth-route return changed')
    call assert_equal(body%instructions(9)%literal_value, 11, 'fifth-route literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_five_sx(), '(output-value-5 11)', '(output-value-5 10)'), body, message), &
        'PRINT wrong fifth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_five_sx(), '(output-value-5 11)', '(output-value-5)'), body, message), &
        'PRINT malformed fifth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_five_sx(), '(output-kind-5 integer-literal)', '(output-kind-5)'), body, message), &
        'PRINT missing fifth kind was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_five_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE five-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_six_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11, 12 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_7_8_9_10_11_12_shape(body, message), &
        'PRINT 7, 8, 9, 10, 11, 12 MIR shape was rejected')
    call assert_equal(body%instructions(12)%opcode, opcode_output, 'sixth PRINT output opcode missing')
    call assert_equal(body%instructions(13)%opcode, opcode_return, 'sixth PRINT return changed')
    call assert_equal(body%instructions(11)%literal_value, 12, 'sixth PRINT literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_six_sx(), '(output-value-6 12)', '(output-value-6 11)'), body, message), &
        'PRINT wrong sixth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_six_sx(), '(output-value-6 12)', '(output-value-6)'), body, message), &
        'PRINT missing sixth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_six_sx(), '(output-kind-6 integer-literal)', '(output-kind-6)'), body, message), &
        'PRINT missing sixth kind was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_six_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE six-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_seven_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11, 12, 13 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_seven_shape(body, message), &
        'PRINT seven-item MIR shape was rejected')
    call assert_equal(body%instructions(13)%opcode, opcode_const, 'seventh PRINT const missing')
    call assert_equal(body%instructions(14)%opcode, opcode_output, 'seventh PRINT output missing')
    call assert_equal(body%instructions(15)%opcode, opcode_return, 'seventh PRINT return changed')
    call assert_equal(body%instructions(13)%literal_value, 13, 'seventh PRINT literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_seven_sx(), '(output-value-7 13)', '(output-value-7 12)'), body, message), &
        'PRINT wrong seventh item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_seven_sx(), '(output-value-7 13)', '(output-value-7)'), body, message), &
        'PRINT missing seventh item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_seven_sx(), '(output-kind-7 integer-literal)', '(output-kind-7)'), body, message), &
        'PRINT missing seventh kind was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_seven_sx(), '(output-rule-7 R1217)', '(output-rule-7)'), body, message), &
        'PRINT missing seventh rule was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_seven_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE seven-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_eight_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11, 12, 13, 14 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_eight_shape(body, message), &
        'PRINT eight-item MIR shape was rejected')
    call assert_equal(body%function%instruction_count, 17, 'eight-item instruction count changed')
    call assert_equal(body%instructions(15)%literal_value, 14, 'eighth PRINT literal changed')
    call assert_equal(body%instructions(16)%opcode, opcode_output, 'eighth PRINT output missing')
    call assert_equal(body%instructions(17)%opcode, opcode_return, 'eight-item return changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_eight_sx(), '(output-value-8 14)', '(output-value-8 13)'), body, message), &
        'PRINT wrong eighth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_eight_sx(), '(output-value-8 14)', '(output-value-8)'), body, message), &
        'PRINT missing eighth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_eight_sx(), '(output-rule-8 R1217)', '(output-rule-8)'), body, message), &
        'PRINT missing eighth rule was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_eight_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE eight-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_nine_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11, 12, 13, 14, 15 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_nine_shape(body, message), &
        'PRINT nine-item MIR shape was rejected')
    call assert_equal(body%function%instruction_count, 19, 'nine-item instruction count changed')
    call assert_equal(body%instructions(17)%literal_value, 15, 'ninth PRINT literal changed')
    call assert_equal(body%instructions(18)%opcode, opcode_output, 'ninth PRINT output missing')
    call assert_equal(body%instructions(19)%opcode, opcode_return, 'nine-item return changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_nine_sx(), '(output-value-9 15)', '(output-value-9 14)'), body, message), &
        'PRINT wrong ninth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_nine_sx(), '(output-value-9 15)', '(output-value-9)'), body, message), &
        'PRINT missing ninth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_nine_sx(), '(output-rule-9 R1217)', '(output-rule-9)'), body, message), &
        'PRINT missing ninth rule was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_nine_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE nine-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_ten_sx(), body, message), &
        'PRINT star 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_ten_shape(body, message), &
        'PRINT ten-item MIR shape was rejected')
    call assert_equal(body%function%instruction_count, 21, 'ten-item instruction count changed')
    do item_index = 1, 10
        call assert_equal(body%instructions(2 * item_index - 1)%opcode, opcode_const, &
            'ten-item const missing')
        call assert_equal(body%instructions(2 * item_index)%opcode, opcode_output, &
            'ten-item output missing')
        call assert_equal(body%instructions(2 * item_index - 1)%literal_value, item_index + 6, &
            'ten-item source correspondence changed')
    end do
    call assert_equal(body%instructions(21)%opcode, opcode_return, 'ten-item return changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_ten_sx(), '(output-value-10 16)', '(output-value-10 15)'), body, message), &
        'PRINT wrong tenth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_ten_sx(), '(output-value-10 16)', '(output-value-10)'), body, message), &
        'PRINT missing tenth item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_ten_sx(), '(output-rule-10 R1217)', '(output-rule-10)'), body, message), &
        'PRINT missing tenth rule was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_ten_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE ten-item mutation was accepted')

    call assert_true(ffc_lower_frontend_ast_v2_from_sx(envelope_generic_sx(), body, message), &
        'PRINT star 17, 18, 19 envelope was rejected')
    call assert_true(ffc_validate_frontend_ast_v2_print_generic_shape(body, message), &
        'PRINT generic MIR shape was rejected')
    call assert_equal(body%function%instruction_count, 7, 'generic PRINT instruction count changed')
    call assert_equal(body%instructions(1)%literal_value, 17, 'generic first literal changed')
    call assert_equal(body%instructions(3)%literal_value, 18, 'generic second literal changed')
    call assert_equal(body%instructions(5)%literal_value, 19, 'generic third literal changed')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_generic_sx(), '(output-value-3 19)', '(output-value-3 20)'), body, message), &
        'PRINT generic wrong third item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_generic_sx(), '(output-value-3 19)', '(output-value-3)'), body, message), &
        'PRINT generic missing third item was accepted')
    call assert_true(.not. ffc_lower_frontend_ast_v2_from_sx(&
        replace_text(envelope_generic_sx(), '(print-stmt ', '(write-stmt '), body, message), &
        'WRITE generic mutation was accepted')

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

    function envelope_generic_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 46) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 17) (output-count 3) '// &
            '(output-kind-2 integer-literal) (output-value-2 18) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 19) (output-rule-3 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_generic_sx

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

    function envelope_five_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 48) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 5) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(output-kind-4 integer-literal) (output-value-4 10) (output-rule-4 R1217) '// &
            '(output-kind-5 integer-literal) (output-value-5 11) (output-rule-5 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_five_sx

    function envelope_six_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 50) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 6) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(output-kind-4 integer-literal) (output-value-4 10) (output-rule-4 R1217) '// &
            '(output-kind-5 integer-literal) (output-value-5 11) (output-rule-5 R1217) '// &
            '(output-kind-6 integer-literal) (output-value-6 12) (output-rule-6 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_six_sx

    function envelope_seven_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 52) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 7) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(output-kind-4 integer-literal) (output-value-4 10) (output-rule-4 R1217) '// &
            '(output-kind-5 integer-literal) (output-value-5 11) (output-rule-5 R1217) '// &
            '(output-kind-6 integer-literal) (output-value-6 12) (output-rule-6 R1217) '// &
            '(output-kind-7 integer-literal) (output-value-7 13) (output-rule-7 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_seven_sx

    function envelope_eight_sx() result(value)
        character(len=4096) :: value

        value = '(program-unit-v2 (root (program-root (name p) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 54) (source-hash print-test))))) '// &
            '(declaration-count 0) (declaration) (variable-count 0) (variable) '// &
            '(execution-part (print-stmt (format-kind default-char-expr) (format-value *) '// &
            '(output-kind integer-literal) (output-value 7) (output-count 8) '// &
            '(output-kind-2 integer-literal) (output-value-2 8) (output-rule-2 R1217) '// &
            '(output-kind-3 integer-literal) (output-value-3 9) (output-rule-3 R1217) '// &
            '(output-kind-4 integer-literal) (output-value-4 10) (output-rule-4 R1217) '// &
            '(output-kind-5 integer-literal) (output-value-5 11) (output-rule-5 R1217) '// &
            '(output-kind-6 integer-literal) (output-value-6 12) (output-rule-6 R1217) '// &
            '(output-kind-7 integer-literal) (output-value-7 13) (output-rule-7 R1217) '// &
            '(output-kind-8 integer-literal) (output-value-8 14) (output-rule-8 R1217) '// &
            '(statement-rule R1212) (format-rule R1215) (output-rule R1217) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-test))))'
    end function envelope_eight_sx

    function envelope_nine_sx() result(value)
        character(len=4096) :: value

        value = envelope_eight_sx()
        value = replace_text(value, '(end-byte 54)', '(end-byte 56)')
        value = replace_text(value, '(output-count 8)', '(output-count 9)')
        value = replace_text(value, '(statement-rule R1212)', &
            '(output-kind-9 integer-literal) (output-value-9 15) (output-rule-9 R1217) (statement-rule R1212)')
    end function envelope_nine_sx

    function envelope_ten_sx() result(value)
        character(len=4096) :: value

        value = envelope_nine_sx()
        value = replace_text(value, '(end-byte 56)', '(end-byte 58)')
        value = replace_text(value, '(output-count 9)', '(output-count 10)')
        value = replace_text(value, '(statement-rule R1212)', &
            '(output-kind-10 integer-literal) (output-value-10 16) (output-rule-10 R1217) (statement-rule R1212)')
    end function envelope_ten_sx

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
