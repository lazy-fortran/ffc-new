program test_mir_frontend_handoff
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_lowering, only: ffc_lower_frontend_v0_from_sx
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_to_sx, &
        mir_function_body_t, mir_function_instruction_opcode_at, &
        mir_function_instruction_result_kind_at, mir_validate_function_body, &
        opcode_add, opcode_return, value_kind_integer
    implicit none

    type(mir_function_body_t) :: body
    character(len=4096) :: serialized
    character(len=4096) :: roundtrip
    character(len=:), allocatable :: message
    integer(int32) :: opcode, kind
    logical :: ok

    call assert_true(ffc_lower_frontend_v0_from_sx( &
        '(frontend-result (status accepted) (root-kind program) '// &
        '(diagnostic-count 0))', body, message), &
        'validated frontend handoff was rejected')
    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'validated frontend handoff was not exported')
    call assert_true(index(trim(serialized), &
        '(source-rule frontend-v0/program)') > 0, &
        'frontend source identity was not exported')

    call mir_function_body_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'frontend MIR handoff was not imported: '//trim(message))
    call assert_true(mir_validate_function_body(body, message), &
        'imported frontend MIR body is invalid')
    call assert_true(mir_function_instruction_opcode_at(body, 0_int32, opcode, message), &
        'imported add opcode was not queryable')
    call assert_true(opcode == opcode_add, 'imported add opcode changed')
    call assert_true(mir_function_instruction_result_kind_at(body, 0_int32, kind, message), &
        'imported result kind was not queryable')
    call assert_true(kind == value_kind_integer, 'imported result kind changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-v0/program', &
        'imported add source identity changed')
    call assert_true(mir_function_instruction_opcode_at(body, 1_int32, opcode, message), &
        'imported return opcode was not queryable')
    call assert_true(opcode == opcode_return, 'imported return opcode changed')
    call assert_equal(body%instructions(2)%source_rule, 'frontend-v0/program', &
        'imported return source identity changed')
    call mir_function_body_to_sx(body, roundtrip, ok, message)
    call assert_true(ok, 'imported frontend MIR handoff was not re-exported')
    call assert_equal(roundtrip, serialized, 'frontend MIR handoff was not canonical')

    call assert_frontend_rejected('(frontend-result (status acceptedx) '// &
        '(root-kind program) (diagnostic-count 0))', 'malformed-sx-record')
    call assert_frontend_rejected('(frontend-result (status accepted) '// &
        '(root-kind program) (diagnostic-count 0) (extra x))', &
        'malformed-sx-record')

    call assert_rejected('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions '// &
        '(instruction (id 1) (opcode add) (source-rule frontend-v0/program) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        'instruction id does not match body slot')
    call assert_rejected('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions '// &
        '(instruction (id 0) (opcode unknown) (source-rule frontend-v0/program) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        'unknown mir-v0 opcode')
    call assert_rejected('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions '// &
        '(instruction (id 0) (opcode add) (source-rule frontend-v0/program) '// &
        '(result (id 1) (kind unknown) (type i32)))))', &
        'unknown mir-v0 value kind')
    call assert_rejected('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 100) (instructions))', &
        'instruction count exceeds SX token capacity')
    call assert_rejected('(mir-function (name main) (entry-block 1) '// &
        '(instruction-count 1) (instructions '// &
        '(instruction (id 0) (opcode add) (source-rule frontend-v0/program) '// &
        '(result (id 1) (kind integer) (type i32))))) extra', &
        'trailing SX input')

    body%instructions(1)%source_rule = 'frontend-v0(program)'
    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_false(ok, 'invalid source identity was exported')
    call assert_equal(message, 'instruction source rule is not a valid SX atom', &
        'invalid source identity diagnostic changed')

contains

    subroutine assert_rejected(input_text, expected_message)
        character(len=*), intent(in) :: input_text, expected_message

        call mir_function_body_from_sx(input_text, body, ok, message)
        call assert_false(ok, 'malformed MIR handoff was accepted')
        call assert_equal(message, expected_message, 'malformed MIR diagnostic changed')
    end subroutine assert_rejected

    subroutine assert_frontend_rejected(input_text, expected_message)
        character(len=*), intent(in) :: input_text, expected_message

        call assert_false(ffc_lower_frontend_v0_from_sx(input_text, body, message), &
            'incompatible frontend handoff was accepted')
        call assert_equal(message, expected_message, &
            'incompatible frontend handoff diagnostic changed')
    end subroutine assert_frontend_rejected

    subroutine assert_true(condition, description)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: description

        if (.not. condition) error stop description
    end subroutine assert_true

    subroutine assert_false(condition, description)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: description

        call assert_true(.not. condition, description)
    end subroutine assert_false

    subroutine assert_equal(actual, expected, description)
        character(len=*), intent(in) :: actual, expected, description

        if (trim(actual) /= trim(expected)) then
            write (*, '(a)') 'actual: '//trim(actual)//' expected: '//trim(expected)
            error stop description
        end if
    end subroutine assert_equal

end program test_mir_frontend_handoff
