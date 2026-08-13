program test_frontend_lowering
    use, intrinsic :: iso_fortran_env, only: int32, int64
    use ffc_lowering, only: frontend_root_kind_program, frontend_status_accepted, &
        frontend_v0_input_t, ffc_lower_frontend_v0, &
        ffc_frontend_v0_input_from_sx, ffc_lower_frontend_v0_from_sx, &
        ffc_validate_frontend_v0_input, ffc_validate_lowered_frontend_v0, &
        ffc_lower_program_root, ffc_program_root_from_sx, ffc_lower_program_root_from_sx, &
        ffc_validate_program_root, ffc_validate_lowered_program_root, ffc_program_root_t
    use ffc_mir, only: mir_function_body_t, mir_validate_function_body, &
        opcode_add, opcode_return, value_kind_integer
    implicit none

    type(frontend_v0_input_t) :: input
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    character(len=256) :: serialized
    logical :: ok
    type(ffc_program_root_t) :: root

    input%status = frontend_status_accepted
    input%root_kind = frontend_root_kind_program
    input%diagnostic_count = 0_int64
    call assert_true(ffc_lower_frontend_v0(input, body, message), &
        'accepted frontend-v0 input was rejected')
    call assert_false(allocated(message), 'accepted input produced a diagnostic')
    call assert_true(mir_validate_function_body(body, message), &
        'lowering produced an invalid mir-v0 body')
    call assert_true(ffc_validate_lowered_frontend_v0(body, message), &
        'lowering did not produce the bounded frontend-v0 body')
    call assert_equal(body%function%name, 'main', 'lowered function name changed')
    call assert_equal_integer(body%function%entry_block, 0_int32, &
        'lowered entry block changed')
    call assert_equal_integer(body%function%instruction_count, 2_int32, &
        'lowered instruction count changed')
    call assert_equal_integer(body%instructions(1)%opcode, opcode_add, &
        'lowered first opcode changed')
    call assert_equal_integer(body%instructions(2)%opcode, opcode_return, &
        'lowered second opcode changed')
    call assert_equal_integer(body%instructions(1)%result%kind, value_kind_integer, &
        'lowered result kind changed')
    call assert_equal(body%instructions(1)%source_rule, 'frontend-v0/program', &
        'lowered source provenance changed')
    call assert_equal(body%instructions(2)%source_rule, 'frontend-v0/program', &
        'lowered return provenance changed')

    input%status = 'rejected'
    call assert_rejected(input, 'frontend-v0 status must be accepted', &
        'rejected status was accepted')

    input%status = frontend_status_accepted
    input%root_kind = 'source'
    call assert_rejected(input, 'frontend-v0 root kind must be program', &
        'non-program root kind was accepted')

    input%root_kind = frontend_root_kind_program
    input%diagnostic_count = 1_int64
    call assert_rejected(input, 'frontend-v0 diagnostic count must be zero', &
        'diagnostic-bearing input was accepted')

    input%diagnostic_count = 0_int64
    call assert_true(ffc_lower_frontend_v0(input, body, message), &
        'restored frontend-v0 input was rejected')
    body%instructions(1)%source_rule = 'target/isa'
    call assert_false(ffc_validate_lowered_frontend_v0(body, message), &
        'source provenance mutation was accepted')
    call assert_equal(message, 'lowered frontend-v0 source provenance changed', &
        'source provenance mutation diagnostic changed')

    serialized = '(frontend-result (status accepted) (root-kind program) '// &
        '(diagnostic-count 0))'
    call assert_true(ffc_lower_frontend_v0_from_sx(serialized, body, message), &
        'canonical frontend SX was not lowered')
    call assert_true(ffc_validate_lowered_frontend_v0(body, message), &
        'canonical frontend SX produced an invalid lowering')
    ok = ffc_frontend_v0_input_from_sx(serialized, input, message)
    call assert_true(ffc_validate_frontend_v0_input(input, message), &
        'canonical frontend SX fields were not validated')

    call assert_invalid_sx('', 'malformed-sx-record')
    call assert_invalid_sx('(frontend-result (status accepted) '// &
        '(root-kind program) (diagnostic-count 0)', 'malformed-sx-record')
    call assert_invalid_sx('(frontend-result (status rejected) (root-kind none) '// &
        '(diagnostic-count 1) (extra x))', 'malformed-sx-record')
    call assert_invalid_sx('(frontend-result (status rejected) (root-kind none) '// &
        '(diagnostic-count 1))', 'frontend-v0 status must be accepted')
    call assert_invalid_sx('(frontend-result (status accepted) (root-kind none) '// &
        '(diagnostic-count 0))', 'invalid-accepted-result')
    call assert_invalid_sx('(frontend-result (status accepted) (root-kind program) '// &
        '(diagnostic-count 2))', 'invalid-accepted-result')

    root%name = 'unit'
    root%source_file = 'unit.f90'
    root%source_hash = 'hash-positive'
    root%start_byte = 0_int64
    root%end_byte = 16_int64
    call assert_true(ffc_validate_program_root(root, message), &
        'valid program root was rejected')
    call assert_true(ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
        root%start_byte, root%end_byte, body, message), &
        'valid program root was not lowered')
    call assert_true(ffc_validate_lowered_program_root(body, message), &
        'program-root lowering produced an invalid witness')
    call assert_equal(body%function%name, 'unit', 'program-root name was not lowered')
    call assert_equal(body%instructions(1)%source_rule, 'program-root', &
        'program-root source provenance was not preserved')
    call assert_equal(body%instructions(2)%source_rule, 'program-root', &
        'program-root return provenance was not preserved')

    root%name = ''
    call assert_false(ffc_validate_program_root(root, message), &
        'empty program-root name was accepted')
    call assert_equal(message, 'program root name must be non-empty', &
        'empty program-root name diagnostic changed')
    root%name = 'unit'
    root%start_byte = -1_int64
    call assert_false(ffc_validate_program_root(root, message), &
        'negative program-root span was accepted')
    call assert_equal(message, 'program root span is invalid', &
        'negative program-root span diagnostic changed')
    root%start_byte = 17_int64
    root%end_byte = 16_int64
    call assert_false(ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
        root%start_byte, root%end_byte, body, message), &
        'reversed program-root span was accepted')
    call assert_equal(message, 'program root span is invalid', &
        'reversed program-root span diagnostic changed')

    root%start_byte = 0_int64
    root%end_byte = 16_int64
    call assert_true(ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
        root%start_byte, root%end_byte, body, message), &
        'restored program root was rejected')
    body%instructions(1)%source_rule = 'target/isa'
    call assert_false(ffc_validate_lowered_program_root(body, message), &
        'program-root provenance mutation was accepted')
    call assert_equal(message, 'lowered program-root source provenance changed', &
        'program-root provenance mutation diagnostic changed')

    serialized = '(program-root (name unit) (span (file unit.f90) '// &
        '(start-byte 0) (end-byte 16) (source-hash hash-positive)))'
    call assert_true(ffc_program_root_from_sx(serialized, root, message), &
        'canonical program-root SX was rejected')
    call assert_equal(root%name, 'unit', 'program-root SX lost the name')
    call assert_equal(root%source_file, 'unit.f90', 'program-root SX lost the source file')
    call assert_equal(root%source_hash, 'hash-positive', 'program-root SX lost the source hash')
    call assert_equal_int64(root%start_byte, 0_int64, 'program-root SX lost the start byte')
    call assert_equal_int64(root%end_byte, 16_int64, 'program-root SX lost the end byte')
    call assert_true(ffc_lower_program_root_from_sx(serialized, body, message), &
        'canonical program-root SX was not lowered')
    call assert_true(ffc_validate_lowered_program_root(body, message), &
        'program-root SX produced an invalid MIR witness')
    call assert_equal(body%function%name, 'unit', 'program-root SX name was not lowered')
    call assert_equal(body%instructions(1)%source_rule, 'program-root', &
        'program-root SX provenance was not preserved')

    call assert_invalid_program_root_sx('(program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive))', 'malformed-sx-record')
    call assert_invalid_program_root_sx(serialized//' (extra x)', 'malformed-program-root')
    call assert_invalid_program_root_sx('(program-root (name unit) '// &
        '(span (file ) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'malformed-sx-record')
    call assert_invalid_program_root_sx('(program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) (source-hash )))', &
        'malformed-sx-record')
    call assert_invalid_program_root_sx('(program-root (name unit) '// &
        '(span (file unit.f90) (start-byte -1) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'program root span is invalid')
    call assert_invalid_program_root_sx('(program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 17) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'program root span is invalid')

contains

    subroutine assert_rejected(candidate, expected_message, description)
        type(frontend_v0_input_t), intent(in) :: candidate
        character(len=*), intent(in) :: expected_message, description

        call assert_false(ffc_lower_frontend_v0(candidate, body, message), description)
        call assert_equal(message, expected_message, 'frontend rejection diagnostic changed')
    end subroutine assert_rejected

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

        call assert_true(trim(actual) == trim(expected), description)
    end subroutine assert_equal

    subroutine assert_equal_integer(actual, expected, description)
        integer(int32), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal_integer

    subroutine assert_equal_int64(actual, expected, description)
        integer(int64), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal_int64

    subroutine assert_invalid_sx(serialized, expected_message)
        character(len=*), intent(in) :: serialized, expected_message

        call assert_false(ffc_lower_frontend_v0_from_sx(serialized, body, message), &
            'invalid frontend SX was lowered')
        if (trim(message) /= trim(expected_message)) then
            write (*, '(a)') 'unexpected frontend SX diagnostic: '//trim(message)// &
                ' expected '//trim(expected_message)
            error stop 'frontend SX diagnostic changed'
        end if
    end subroutine assert_invalid_sx

    subroutine assert_invalid_program_root_sx(serialized, expected_message)
        character(len=*), intent(in) :: serialized, expected_message

        call assert_false(ffc_lower_program_root_from_sx(serialized, body, message), &
            'invalid program-root SX was lowered')
        call assert_equal(message, expected_message, &
            'program-root SX diagnostic changed')
    end subroutine assert_invalid_program_root_sx

end program test_frontend_lowering
