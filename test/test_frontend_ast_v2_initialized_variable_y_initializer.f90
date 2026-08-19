program test_frontend_ast_v2_initialized_variable_y_initializer
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_frontend_ast, only: ffc_lower_frontend_ast_v2_from_sx
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, opcode_const, opcode_load, &
        opcode_output, opcode_return, opcode_store, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message

    call check_initializer(0_int32)
    call check_initializer(23_int32)
    call check_initializer(2047_int32)

    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('23'), &
        '(variable y)', '(variable x)'), body, message), &
        'mutated assignment variable was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('23'), &
        '(output-name y)', '(output-name x)'), body, message), &
        'mutated PRINT variable was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('23'), &
        '(kind integer-literal)', '(kind real-literal)'), body, message), &
        'mutated initializer kind was accepted')
    call assert_false(ffc_lower_frontend_ast_v2_from_sx(replace_text(witness('23'), &
        '(source-hash initialized-variable-y-initializer)', '(source-hash mutated)'), body, message), &
        'mutated source provenance was accepted')

    write (*, '(a)') 'frontend AST v2 initialized variable-y initializer checks: ok'

contains

    subroutine check_initializer(expected)
        integer(int32), intent(in) :: expected
        character(len=32) :: literal
        integer(int32) :: expected_opcodes(5), expected_results(5)
        integer :: instruction_index

        write (literal, '(i0)') expected
        if (.not. ffc_lower_frontend_ast_v2_from_sx(witness(trim(literal)), body, message)) then
            if (allocated(message)) write (*, '(a)') trim(message)
            error stop 'variable-y initializer was rejected'
        end if
        call assert_true(mir_validate_function_body(body, message), 'initializer MIR is invalid')

        expected_opcodes = [opcode_const, opcode_store, opcode_load, opcode_output, opcode_return]
        expected_results = [2_int32, 1_int32, 1_int32, 1_int32, 1_int32]
        call assert_true(body%function%instruction_count == 5_int32, &
            'initializer instruction count changed')
        do instruction_index = 1, 5
            call assert_true(body%instructions(instruction_index)%id == instruction_index - 1, &
                'instruction ID changed')
            call assert_true(body%instructions(instruction_index)%opcode == &
                expected_opcodes(instruction_index), 'opcode sequence changed')
            call assert_true(body%instructions(instruction_index)%result%id == &
                expected_results(instruction_index), 'result ID sequence changed')
            call assert_true(body%instructions(instruction_index)%result%kind == value_kind_integer, &
                'result kind changed')
            call assert_equal(body%instructions(instruction_index)%result%type_name, 'i32', &
                'result type changed')
        end do

        call assert_true(body%instructions(1)%literal_value == expected, &
            'initializer value was not transported')
        call assert_storage(2)
        call assert_storage(3)
        call assert_no_storage(1)
        call assert_no_storage(4)
        call assert_no_storage(5)

        call assert_equal(body%instructions(1)%source_rule, 'frontend-ast-v2/execution-part', &
            'initializer source provenance changed')
        call assert_equal(body%instructions(2)%source_rule, 'frontend-ast-v2/execution-part', &
            'store source provenance changed')
        call assert_equal(body%instructions(3)%source_rule, 'frontend-ast-v2/print-stmt', &
            'load source provenance changed')
        call assert_equal(body%instructions(4)%source_rule, 'frontend-ast-v2/print-stmt', &
            'output source provenance changed')
        call assert_equal(body%instructions(5)%source_rule, 'frontend-ast-v2/print-stmt', &
            'return source provenance changed')
    end subroutine check_initializer

    subroutine assert_storage(index)
        integer, intent(in) :: index

        call assert_true(allocated(body%instructions(index)%storage_key), 'storage key missing')
        call assert_equal(body%instructions(index)%storage_key, 'y', 'storage key changed')
    end subroutine assert_storage

    subroutine assert_no_storage(index)
        integer, intent(in) :: index

        call assert_true(.not. allocated(body%instructions(index)%storage_key), &
            'unexpected storage key')
    end subroutine assert_no_storage

    function witness(literal) result(value)
        character(len=*), intent(in) :: literal
        character(len=8192) :: value

        value = '(program-unit-v2 (root (program-root (name main) (span (source-span '// &
            '(file main.f90) (start-byte 0) (end-byte 40) '// &
            '(source-hash initialized-variable-y-initializer))))) (declaration-count 1) '// &
            '(declaration (program-declaration (declaration-kind program) (name main) '// &
            '(span (source-span (file main.f90) (start-byte 0) (end-byte 40) '// &
            '(source-hash initialized-variable-y-initializer))))) (variable-count 1) '// &
            '(variable (variable-declaration (type-spec integer) (name y) '// &
            '(span (source-span (file main.f90) (start-byte 10) (end-byte 20) '// &
            '(source-hash initialized-variable-y-initializer))))) (execution-part '// &
            '(assignment-sequence (assignment-count 1) (assignment (assignment-stmt '// &
            '(variable y) (expression (assignment-expression (kind integer-literal) '// &
            '(operator ) (left-operand LITERAL) (right-operand ))) (span (source-span '// &
            '(file main.f90) (start-byte 25) (end-byte 31) '// &
            '(source-hash initialized-variable-y-initializer)))))) (print-stmt '// &
            '(format-kind default-char-expr) (format-value *) (output-kind variable) '// &
            '(output-name y) (statement-rule R1212) (format-rule R1215) (output-rule R901) '// &
            '(source-document J3-24-007) (statement-clause 12.6.1) '// &
            '(format-clause 12.6.2.2) (output-clause 12.6.3) (statement-page 242) '// &
            '(format-page 244) (output-page 248) '// &
            '(source-hash initialized-variable-y-initializer))))'
        value = replace_text(value, 'LITERAL', trim(literal))
    end function witness

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

end program test_frontend_ast_v2_initialized_variable_y_initializer
