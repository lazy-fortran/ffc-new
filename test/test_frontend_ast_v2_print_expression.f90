program test_frontend_ast_v2_print_expression
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_add, opcode_const, opcode_load, &
        opcode_div, opcode_mul, opcode_output, opcode_pow, opcode_return, opcode_store, opcode_sub
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_shape(positive_sx(.true.), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call assert_true(body%instructions(1)%literal_value == 3, 'x=3 initializer changed')
    call check_shape(replace_text(positive_sx(.true.), '(right 1)', '(right 2)'), &
        [opcode_const, opcode_store, opcode_load, opcode_const, opcode_add, opcode_output, opcode_load, &
        opcode_output, opcode_return])
    call assert_true(body%instructions(4)%literal_value == 2, 'x+2 constant changed')
    call check_shape(positive_sx(.false.), [opcode_const, opcode_store, opcode_load, opcode_output, opcode_load, &
        opcode_const, opcode_add, opcode_output, opcode_return])
    call check_shape(replace_text(positive_sx(.true.), '(right 1)', '(right x)'), &
        [opcode_const, opcode_store, opcode_load, opcode_load, opcode_add, opcode_output, opcode_load, &
        opcode_output, opcode_return])
    call assert_load_storage([3, 4, 7])
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator *)'), &
        '(right 1)', '(right 2)'), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_mul, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator /)'), &
        '(right 1)', '(right 2)'), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_div, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator –)'), &
        '(right 1)', '(right 2)'), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_sub, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator -)'), &
        '(right 1)', '(right 2)'), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_sub, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator **)'), &
        '(right 1)', '(right 2)'), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_pow, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call check_power_shape(5)
    call check_power_shape(7)
    call check_power_shape(10)
    call check_shape(replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator **)'), &
        '(right 1)', '(right x)'), [opcode_const, opcode_store, opcode_load, opcode_load, opcode_pow, &
        opcode_output, opcode_load, opcode_output, opcode_return])
    call assert_load_storage([3, 4])
    call check_shape(replace_text(power_four_sx(.true.), '(right 4)', '(right x)'), &
        [opcode_const, opcode_store, opcode_load, opcode_load, opcode_pow, &
        opcode_output, opcode_const, opcode_output, opcode_return])
    call assert_load_storage([3, 4])
    call assert_true(body%instructions(1)%literal_value == 4, 'x=4 initializer changed')
    call check_shape(power_four_sx(.true.), [opcode_const, opcode_store, opcode_load, opcode_const, opcode_pow, &
        opcode_output, opcode_const, opcode_output, opcode_return])
    call assert_true(body%instructions(4)%literal_value == 4, 'power-four exponent literal changed')
    call check_shape(power_four_sx(.false.), [opcode_const, opcode_store, opcode_const, opcode_output, opcode_load, &
        opcode_const, opcode_pow, opcode_output, opcode_load, opcode_output, opcode_return])
    call assert_true(body%instructions(6)%literal_value == 4, 'power-four exponent literal changed')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(.true.), '(operator +)', &
        '(operator *)'), body, message), 'wrong expression operator was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(.true.), '(right 1)', &
        '(right )'), body, message), 'missing expression operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(.true.), '(right 1)', &
        '(right 3)'), body, message), 'x+3 expression operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(replace_text(positive_sx(.true.), &
        '(operator +)', '(operator *)'), '(right 1)', '(right 3)'), body, message), &
        'unsupported multiplication operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(replace_text(positive_sx(.true.), &
        '(operator +)', '(operator /)'), '(right 1)', '(right 3)'), body, message), &
        'unsupported division operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(replace_text(positive_sx(.true.), &
        '(operator +)', '(operator –)'), '(right 1)', '(right 3)'), body, message), &
        'unsupported subtraction operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(replace_text(positive_sx(.true.), &
        '(operator +)', '(operator -)'), '(right 1)', '(right 3)'), body, message), &
        'unsupported ASCII subtraction operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(.true.), '(rule R1217)', &
        '(rule R901)'), body, message), 'wrong expression provenance was accepted')
    write (*, '(a)') 'frontend AST v2 generic expression checks: ok'

contains

    subroutine check_shape(serialized, expected)
        character(len=*), intent(in) :: serialized
        integer(int32), intent(in) :: expected(:)
        integer :: index

        if (.not. ffc_lower_frontend_ast_v2_from_sx(serialized, body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'generic expression was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
        call assert_true(size(expected) == body%function%instruction_count, 'instruction count changed')
        do index = 1, size(expected)
            call assert_true(body%instructions(index)%opcode == expected(index), 'instruction order changed')
            call assert_equal(body%instructions(index)%result%type_name, 'i32', 'result type changed')
            if (index >= 3 .and. index <= size(expected) - 1) then
                call assert_equal(body%instructions(index)%source_rule, 'frontend-ast-v2/print-stmt', &
                    'PRINT provenance changed')
            end if
        end do
    end subroutine check_shape

    subroutine check_power_shape(exponent)
        integer, intent(in) :: exponent
        character(len=32) :: exponent_text
        character(len=12288) :: serialized

        write (exponent_text, '(i0)') exponent
        serialized = replace_text(replace_text(positive_sx(.true.), '(operator +)', '(operator **)'), &
            '(right 1)', '(right '//trim(exponent_text)//')')
        call check_shape(serialized, [opcode_const, opcode_store, opcode_load, opcode_const, opcode_pow, &
            opcode_output, opcode_load, opcode_output, opcode_return])
        call assert_true(body%instructions(4)%literal_value == exponent, &
            'power exponent literal changed')
    end subroutine check_power_shape

    subroutine assert_load_storage(indices)
        integer, intent(in) :: indices(:)
        integer :: index

        do index = 1, size(indices)
            call assert_true(allocated(body%instructions(indices(index))%storage_key), &
                'expression load storage key missing')
            call assert_equal(body%instructions(indices(index))%storage_key, 'x', &
                'expression load storage key changed')
        end do
    end subroutine assert_load_storage

    function positive_sx(expression_first) result(value)
        logical, intent(in) :: expression_first
        character(len=12288) :: value, items

        if (expression_first) then
            items = '(output-item (kind integer-expression) (operator +) (left x) (right 1) '// &
                '(rule R1217) (clause 12.6.3) (page 248)) (output-item (kind variable) (name x) '// &
                '(rule R901) (clause 12.6.3) (page 248))'
        else
            items = '(output-item (kind variable) (name x) (rule R901) (clause 12.6.3) (page 248)) '// &
                '(output-item (kind integer-expression) (operator +) (left x) (right 1) '// &
                '(rule R1217) (clause 12.6.3) (page 248))'
        end if
        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 50) (source-hash generic-expression))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 50) '// &
            '(source-hash generic-expression))))) (variable-count 1) (variable (variable-declaration '// &
            '(type-spec integer) (name x) (span (source-span (file main.f90) (start-byte 10) (end-byte 20) '// &
            '(source-hash generic-expression))))) (execution-part (assignment-sequence (assignment-count 1) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand 3) (right-operand ))) (span (source-span (file main.f90) '// &
            '(start-byte 25) (end-byte 26) (source-hash generic-expression)))))) (print-stmt '// &
            '(format-kind default-char-expr) (format-value *) (output-count 2) (output-items ITEMS) '// &
            '(statement-rule R1212) (format-rule R1215) (source-document J3-24-007) '// &
            '(statement-clause 12.6.1) (format-clause 12.6.2.2) (output-clause 12.6.3) '// &
            '(statement-page 242) (format-page 244) (output-page 248) (source-hash generic-expression))))'
        value = replace_text(value, 'ITEMS', trim(items))
    end function positive_sx

    function power_four_sx(expression_first) result(value)
        logical, intent(in) :: expression_first
        character(len=12288) :: value
        character(len=1024) :: literal_item

        value = replace_text(replace_text(positive_sx(expression_first), '(operator +)', '(operator **)'), &
            '(right 1)', '(right 4)')
        value = replace_text(value, '(left-operand 3)', '(left-operand 4)')
        literal_item = '(output-item (kind integer-literal) (value 7) (rule R1217) '// &
            '(clause 12.6.3) (page 248))'
        value = replace_text(value, '(output-item (kind variable) (name x) (rule R901) '// &
            '(clause 12.6.3) (page 248))', literal_item)
        if (.not. expression_first) then
            value = replace_text(value, '(output-count 2)', '(output-count 3)')
            value = replace_text(value, '(output-item (kind integer-expression) (operator **) (left x) '// &
                '(right 4) (rule R1217) (clause 12.6.3) (page 248))', &
                '(output-item (kind integer-expression) (operator **) (left x) (right 4) '// &
                '(rule R1217) (clause 12.6.3) (page 248)) '// &
                '(output-item (kind variable) (name x) (rule R901) (clause 12.6.3) (page 248))')
        end if
    end function power_four_sx

    function replace_text(value, old, new) result(replaced)
        character(len=*), intent(in) :: value, old, new
        character(len=12288) :: replaced
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

end program test_frontend_ast_v2_print_expression
