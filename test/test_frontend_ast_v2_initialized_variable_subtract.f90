program test_frontend_ast_v2_initialized_variable_subtract
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, &
        opcode_load, opcode_output, opcode_return, opcode_store, opcode_sub, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    integer(int32) :: expected_opcodes(9), expected_results(9)
    integer :: instruction_index

    if (.not. ffc_lower_frontend_ast_v2_from_sx(positive_sx(), body, message)) then
        if (allocated(message)) write (*, '(a)') trim(message)
        error stop 'initialized variable-subtract source was rejected'
    end if
    call assert_true(mir_validate_function_body(body, message), 'generated MIR is invalid')

    expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_load, opcode_sub, &
        opcode_store, opcode_load, opcode_output, opcode_return]
    expected_results = [0_int32, 1_int32, 2_int32, 3_int32, 4_int32, 4_int32, &
        6_int32, 6_int32, 6_int32]
    call assert_true(body%function%instruction_count == 9_int32, 'instruction count changed')
    do instruction_index = 1, 9
        call assert_true(body%instructions(instruction_index)%opcode == &
            expected_opcodes(instruction_index), 'opcode sequence changed')
        call assert_true(body%instructions(instruction_index)%result%id == &
            expected_results(instruction_index), 'result ID sequence changed')
        call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, &
            'result kind changed')
        call assert_equal(body%instructions(instruction_index)%result%type_name, 'i32', &
            'result type changed')
        if (instruction_index <= 6) then
            call assert_equal(body%instructions(instruction_index)%source_rule, &
                'frontend-ast-v2/execution-part', 'execution provenance changed')
        else
            call assert_equal(body%instructions(instruction_index)%source_rule, &
                'frontend-ast-v2/print-stmt', 'PRINT provenance changed')
        end if
    end do
    call assert_true(body%instructions(1)%literal_value == 23_int32, 'initializer literal changed')
    call assert_storage(2)
    call assert_storage(3)
    call assert_storage(4)
    call assert_storage(6)
    call assert_storage(7)
    call assert_no_storage(1)
    call assert_no_storage(5)
    call assert_no_storage(8)
    call assert_no_storage(9)

    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(right-operand x)', '(right-operand y)'), body, message), &
        'mutated variable-subtract operand was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(positive_sx(), &
        '(source-hash initialized-variable-subtract)', '(source-hash mutated)'), body, message), &
        'mutated source provenance was accepted')

    write (*, '(a)') 'frontend AST v2 initialized variable-subtract MIR checks: ok'

contains

    function positive_sx() result(value)
        character(len=12288) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash initialized-variable-subtract))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 70) '// &
            '(source-hash initialized-variable-subtract))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name x) '// &
            '(span (source-span (file main.f90) (start-byte 10) (end-byte 20) '// &
            '(source-hash initialized-variable-subtract))))) (execution-part '// &
            '(assignment-sequence (assignment-count 2) (assignment (assignment-stmt '// &
            '(variable x) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand 23) (right-operand ))) (span (source-span '// &
            '(file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash initialized-variable-subtract))))) (assignment (assignment-stmt '// &
            '(variable x) (expression (assignment-expression (kind binary-expression) '// &
            '(operator -) (left-operand x) (right-operand x))) (span (source-span '// &
            '(file main.f90) (start-byte 32) (end-byte 42) '// &
            '(source-hash initialized-variable-subtract)))))) (print-stmt '// &
            '(format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name x) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) (format-clause 12.6.2.2) '// &
            '(output-clause 12.6.3) (statement-page 242) (format-page 244) '// &
            '(output-page 248) (source-hash initialized-variable-subtract))))'
    end function positive_sx

    subroutine assert_storage(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(index)%storage_key, 'x', 'storage key changed')
    end subroutine assert_storage

    subroutine assert_no_storage(index)
        integer, intent(in) :: index

        call assert_true(.not. allocated(body%instructions(index)%storage_key), &
            'unexpected storage key')
    end subroutine assert_no_storage

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

end program test_frontend_ast_v2_initialized_variable_subtract
