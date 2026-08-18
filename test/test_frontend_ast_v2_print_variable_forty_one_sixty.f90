program test_frontend_ast_v2_print_variable_forty_one_sixty
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_load, opcode_output, opcode_return, &
        value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer :: item_count, index

    do item_count = 41, 60
        if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_sx(item_count), body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop '41-to-60 stored-variable PRINT route was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')
        call assert_true(body%function%instruction_count == 2 * item_count + 7, 'instruction count changed')
        do index = 7, 2 * item_count + 6, 2
            call assert_true(body%instructions(index)%opcode == opcode_load .and. &
                body%instructions(index + 1)%opcode == opcode_output, 'output pair changed')
            call assert_true(body%instructions(index)%result%kind == value_kind_integer .and. &
                trim(body%instructions(index)%result%type_name) == 'i32' .and. &
                trim(body%instructions(index)%storage_key) == 'x', 'output load metadata changed')
            call assert_true(body%instructions(index)%result%id == int((index + 5) / 2, int32), &
                'output result ID changed')
        end do
        call assert_true(body%instructions(body%function%instruction_count)%opcode == opcode_return, &
            'return opcode changed')
    end do
    write (*, '(a)') 'frontend AST v2 variable 41/50/60-item PRINT checks: ok'

contains

    function positive_sx(item_count) result(value)
        integer, intent(in) :: item_count
        character(len=:), allocatable :: value
        character(len=16) :: item_text, count_text
        integer :: item_index

        write (count_text, '(i0)') item_count
        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 100) (source-hash print-variable-41-60))))) '// &
            '(declaration-count 1) (declaration (program-declaration (declaration-kind program) '// &
            '(name main) (span (source-span (file main.f90) (start-byte 0) (end-byte 100) '// &
            '(source-hash print-variable-41-60))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) (span (source-span '// &
            '(file main.f90) (start-byte 10) (end-byte 20) (source-hash print-variable-41-60))))) '// &
            '(execution-part (assignment-sequence (assignment-count 2) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind integer-literal) (operator ) (left-operand 3) (right-operand ))) '// &
            '(span (source-span (file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash print-variable-41-60))))) '// &
            '(assignment (assignment-stmt (variable x) (expression (assignment-expression '// &
            '(kind binary-expression) (operator **) (left-operand x) (right-operand 2))) '// &
            '(span (source-span (file main.f90) (start-byte 32) (end-byte 42) '// &
            '(source-hash print-variable-41-60)))))) '// &
            '(print-stmt (format-kind default-char-expr) (format-value *) ( output-kind variable ) '// &
            '( output-name x ) ( output-count '//trim(count_text)//' )'
        do item_index = 2, item_count
            write (item_text, '(i0)') item_index
            value = trim(value)//' ( output-kind-'//trim(item_text)//' variable ) ( output-name-'// &
                trim(item_text)//' x ) ( output-rule-'//trim(item_text)//' R901 )'
        end do
        value = trim(value)//' (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) (output-page 248) '// &
            '(source-hash print-variable-41-60))))'
    end function positive_sx

    subroutine assert_true(condition, description)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: description

        if (.not. condition) then
            write (*, '(a)') trim(description)
            error stop description
        end if
    end subroutine assert_true

end program test_frontend_ast_v2_print_variable_forty_one_sixty
