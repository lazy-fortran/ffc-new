program test_frontend_ast_v2_print_variable_seven_ten_items
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, opcode_output, &
        opcode_pow, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer :: item_count, instruction_index, output_index

    do item_count = 7, 40
        call assert_true(lower_positive(item_count), 'source-backed stored-variable PRINT route was rejected')
        call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
        call assert_true(body%function%instruction_count == 2 * item_count + 7, 'instruction count changed')
        do instruction_index = 1, body%function%instruction_count
            call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, &
                'result kind changed')
            call assert_equal(body%instructions(instruction_index)%result%type_name, 'i32', 'result type changed')
            if (instruction_index <= 6) then
                call assert_equal(body%instructions(instruction_index)%source_rule, &
                    'frontend-ast-v2/execution-part', 'execution source rule changed')
            else
                call assert_equal(body%instructions(instruction_index)%source_rule, &
                    'frontend-ast-v2/print-stmt', 'PRINT source rule changed')
            end if
        end do
        call assert_true(body%instructions(1)%opcode == opcode_const .and. &
            body%instructions(2)%opcode == opcode_store .and. body%instructions(3)%opcode == opcode_load .and. &
            body%instructions(4)%opcode == opcode_const .and. body%instructions(5)%opcode == opcode_pow .and. &
            body%instructions(6)%opcode == opcode_store, 'execution prefix changed')
        do output_index = 1, item_count
            instruction_index = 7 + 2 * (output_index - 1)
            call assert_true(body%instructions(instruction_index)%opcode == opcode_load .and. &
                body%instructions(instruction_index + 1)%opcode == opcode_output, 'output pair changed')
            call assert_true(body%instructions(instruction_index)%result%id == 5 + output_index .and. &
                body%instructions(instruction_index + 1)%result%id == 5 + output_index, 'output result ID changed')
            call assert_storage(instruction_index)
        end do
        call assert_true(body%instructions(body%function%instruction_count)%opcode == opcode_return .and. &
            body%instructions(body%function%instruction_count)%result%id == 5 + item_count, 'return changed')
        call assert_true(body%instructions(1)%literal_value == literal_value_for(item_count) .and. &
            body%instructions(4)%literal_value == exponent_for(item_count), 'constant transport changed')
    end do
    write (*, '(a)') 'frontend AST v2 variable seven-to-forty-item PRINT checks: ok'

contains

    logical function lower_positive(item_count) result(ok)
        integer, intent(in) :: item_count

        ok = ffc_lower_frontend_ast_v2_from_sx(positive_sx(item_count), body, message)
        if (.not. ok .and. allocated(message)) write (*, '(a)') trim(message)
    end function lower_positive

    function positive_sx(item_count) result(value)
        integer, intent(in) :: item_count
        character(len=:), allocatable :: value
        character(len=16) :: count_text, item_text
        integer :: item_index, literal_value, exponent

        select case (item_count)
        case (7:40); literal_value = 3; exponent = 2
        end select
        write (count_text, '(i0)') item_count
        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 100) (source-hash print-variable-six-item))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 100) '// &
            '(source-hash print-variable-six-item))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash print-variable-six-item))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand '//trim(adjustl(itoa(literal_value)))// &
            ') (right-operand ))) (span (source-span (file main.f90) (start-byte 25) '// &
            '(end-byte 31) (source-hash print-variable-six-item))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator **) (left-operand x) (right-operand '// &
            trim(adjustl(itoa(exponent)))//'))) (span (source-span (file main.f90) (start-byte 32) '// &
            '(end-byte 42) (source-hash print-variable-six-item)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) ( output-kind variable ) '// &
            '( output-name x ) ( output-count '//trim(adjustl(count_text))//' )'
        do item_index = 2, item_count
            write (item_text, '(i0)') item_index
            value = trim(value)//' ( output-kind-'//trim(item_text)//' variable ) ( output-name-'// &
                trim(item_text)//' x ) ( output-rule-'//trim(item_text)//' R901 )'
        end do
        value = trim(value)//' (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-variable-six-item))))'
    end function positive_sx

    function itoa(value) result(text)
        integer, intent(in) :: value
        character(len=16) :: text

        write (text, '(i0)') value
    end function itoa

    integer function literal_value_for(item_count) result(value)
        integer, intent(in) :: item_count

        select case (item_count)
        case (7:40); value = 3
        end select
    end function literal_value_for

    integer function exponent_for(item_count) result(value)
        integer, intent(in) :: item_count

        select case (item_count)
        case (7:40); value = 2
        end select
    end function exponent_for

    subroutine assert_storage(instruction_index)
        integer, intent(in) :: instruction_index

        call assert_true(allocated(body%instructions(instruction_index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(instruction_index)%storage_key, 'x', 'storage key changed')
    end subroutine assert_storage

    subroutine assert_true(value, description)
        logical, intent(in) :: value
        character(len=*), intent(in) :: description

        if (.not. value) error stop description
    end subroutine assert_true

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

end program test_frontend_ast_v2_print_variable_seven_ten_items
