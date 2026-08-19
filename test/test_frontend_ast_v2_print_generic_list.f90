program test_frontend_ast_v2_print_generic_list
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_load, opcode_output, opcode_return
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'generic PRINT list was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'generic MIR is invalid')
    call assert_true(body%function%instruction_count == 11, 'generic MIR count changed')
    call assert_true(body%instructions(3)%opcode == opcode_load, 'first item is not a load')
    call assert_true(body%instructions(4)%opcode == opcode_output, 'first output is missing')
    call assert_true(body%instructions(5)%opcode == opcode_const .and. &
        body%instructions(5)%literal_value == 7, 'literal item was not lowered')
    call assert_true(body%instructions(6)%opcode == opcode_output, 'literal output is missing')
    call assert_true(body%instructions(7)%opcode == opcode_load, 'third item is not a load')
    call assert_true(body%instructions(8)%opcode == opcode_output, 'third output is missing')
    call assert_true(body%instructions(9)%opcode == opcode_const .and. &
        body%instructions(9)%literal_value == 8, 'fourth item was not lowered')
    call assert_true(body%instructions(10)%opcode == opcode_output, 'fourth output is missing')
    call assert_true(body%instructions(11)%opcode == opcode_return, 'return is missing')
    call assert_true(all_source_rules_are_print_stmt(body), 'print source identity was lost')
    call assert_literal_list(literal_sx_count(1), [7], 'one-item literal list')
    call assert_literal_list(literal_sx_count(4), [7, 8, 9, 10], 'four-item literal list')
    call assert_literal_list(literal_sx_count(10), [7, 8, 9, 10, 11, 12, 13, 14, 15, 16], &
        'ten-item literal list')
    call assert_literal_list(literal_sx_20_22(), [20, 21, 22], '20,21,22')
    call assert_literal_list(literal_sx_100_500(), [100, 200, 300, 400, 500], '100,200,300,400,500')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(literal_sx_count(11), body, message), &
        'eleven-item literal list was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(literal_sx_count(4), '(page 248)', ''), &
        body, message), 'malformed literal list was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(print-stmt ', '(write-stmt '), body, message), 'WRITE was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(clause 12.6.3)', '(clause 12.6.4)'), body, message), &
        'wrong output-item clause was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(page 248)', '(page 249)'), body, message), &
        'wrong output-item page was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        ' (clause 12.6.3)', ''), body, message), &
        'missing output-item clause was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        ' (page 248)', ''), body, message), &
        'missing output-item page was accepted')
    write (*, '(a)') 'frontend AST v2 generic PRINT list checks: ok'

contains

    function positive_sx() result(value)
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 60) (source-hash generic-print))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 60) '// &
            '(source-hash generic-print))))) (variable-count 1) (variable '// &
            '(variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash generic-print))))) '// &
            '(execution-part (assignment-sequence (assignment-count 1) (assignment '// &
            '(assignment-stmt (variable x) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand 3) (right-operand ))) (span (source-span (file main.f90) '// &
            '(start-byte 25) (end-byte 26) (source-hash generic-print)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) (output-count 4) '// &
            '(output-items (output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248)) '// &
            '(output-item (kind integer-literal) (value 7) (rule R1217) '// &
            '(clause 12.6.3) (page 248)) '// &
            '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248)) '// &
            '(output-item (kind integer-literal) (value 8) (rule R1217) '// &
            '(clause 12.6.3) (page 248))) '// &
            '(statement-rule R1212) (format-rule R1215) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash generic-print))))'
    end function positive_sx

    function literal_sx_20_22() result(value)
        character(len=8192) :: value

        value = positive_sx()
        value = replace_text(value, '(output-count 4)', '(output-count 3)')
        value = replace_text(value, '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 20) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 22) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, '(output-item (kind integer-literal) (value 7) (rule R1217) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 21) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, ' (output-item (kind integer-literal) (value 8) (rule R1217) '// &
            '(clause 12.6.3) (page 248))', '')
    end function literal_sx_20_22

    function literal_sx_count(item_count) result(value)
        integer, intent(in) :: item_count
        character(len=8192) :: value
        character(len=32) :: item_text
        character(len=8192) :: items
        integer :: item_index, start, finish

        value = positive_sx()
        start = index(value, '(output-items')
        finish = index(value(start:), ') (statement-rule R1212)')
        call assert_true(start > 0 .and. finish > 0, 'literal-list template is malformed')
        items = '(output-items'
        do item_index = 1, item_count
            write (item_text, '(i0)') item_index + 6
            items = trim(items)//' (output-item (kind integer-literal) (value '//trim(item_text)//') '// &
                '(rule R1217) (clause 12.6.3) (page 248))'
        end do
        value = value(:start - 1)//trim(items)//value(start + finish - 1:)
        write (item_text, '(i0)') item_count
        value = replace_text(value, '(output-count 4)', '(output-count '//trim(item_text)//')')
    end function literal_sx_count

    function literal_sx_100_500() result(value)
        character(len=8192) :: value

        value = positive_sx()
        value = replace_text(value, '(output-count 4)', '(output-count 5)')
        value = replace_text(value, '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 100) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 300) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, '(output-item (kind integer-literal) (value 7) (rule R1217) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 200) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, '(output-item (kind integer-literal) (value 8) (rule R1217) '// &
            '(clause 12.6.3) (page 248))', '(output-item (kind integer-literal) (value 400) '// &
            '(rule R1217) (clause 12.6.3) (page 248))')
        value = replace_text(value, ') (statement-rule R1212)', ' (output-item (kind integer-literal) '// &
            '(value 500) (rule R1217) (clause 12.6.3) (page 248)) ) (statement-rule R1212)')
    end function literal_sx_100_500

    subroutine assert_literal_list(serialized, expected, description)
        character(len=*), intent(in) :: serialized, description
        integer, intent(in) :: expected(:)
        type(mir_function_body_t) :: candidate
        character(len=:), allocatable :: candidate_message
        integer :: item_index, instruction_index

        call assert_true(ffc_lower_frontend_ast_v2_from_sx(serialized, candidate, candidate_message), &
            description//' was rejected')
        call assert_true(mir_validate_function_body(candidate, candidate_message), &
            description//' MIR is invalid')
        call assert_true(candidate%function%instruction_count == 2 * size(expected) + 3, &
            description//' MIR count changed')
        do item_index = 1, size(expected)
            instruction_index = 2 * item_index + 1
            call assert_true(candidate%instructions(instruction_index)%opcode == opcode_const .and. &
                candidate%instructions(instruction_index)%literal_value == expected(item_index), &
                description//' literal value/order changed')
            call assert_true(candidate%instructions(instruction_index + 1)%opcode == opcode_output, &
                description//' output is missing')
        end do
        call assert_true(candidate%instructions(candidate%function%instruction_count)%opcode == opcode_return, &
            description//' return is missing')
    end subroutine assert_literal_list

    logical function all_source_rules_are_print_stmt(candidate) result(ok)
        type(mir_function_body_t), intent(in) :: candidate
        integer :: index

        ok = .true.
        do index = 3, 11
            if (trim(candidate%instructions(index)%source_rule) /= 'frontend-ast-v2/print-stmt') ok = .false.
        end do
    end function all_source_rules_are_print_stmt

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

end program test_frontend_ast_v2_print_generic_list
