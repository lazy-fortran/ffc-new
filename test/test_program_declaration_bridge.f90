program test_program_declaration_bridge
    use ffc_lowering, only: ffc_lower_program_declaration_from_sx, &
        ffc_program_declaration_from_sx, ffc_validate_lowered_program_root, &
        ffc_program_root_t
    use ffc_mir, only: mir_function_body_t, opcode_add, opcode_return
    implicit none

    type(ffc_program_root_t) :: root
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    character(len=512) :: serialized

    serialized = '(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive)))'
    call assert_true(ffc_program_declaration_from_sx(serialized, root, message), &
        'canonical program declaration was rejected')
    call assert_equal(root%name, 'unit', 'declaration name was not mapped')
    call assert_equal(root%source_file, 'unit.f90', 'declaration file was not mapped')
    call assert_equal(root%source_hash, 'hash-positive', 'declaration hash was not mapped')
    call assert_true(root%start_byte == 0 .and. root%end_byte == 16, &
        'declaration span was not mapped')
    call assert_true(ffc_lower_program_declaration_from_sx(serialized, body, message), &
        'canonical program declaration was not lowered')
    call assert_true(ffc_validate_lowered_program_root(body, message), &
        'declaration did not produce a valid program-root witness')
    call assert_equal(body%function%name, 'unit', 'witness name was not lowered')
    call assert_equal(body%instructions(1)%source_rule, 'program-root', &
        'witness source rule changed')
    call assert_true(body%instructions(1)%opcode == opcode_add .and. &
        body%instructions(2)%opcode == opcode_return, 'witness opcodes changed')

    call assert_invalid('(program-declaration (declaration-kind module) (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'invalid-program-declaration-kind')
    call assert_invalid(serialized//' (extra x)', 'malformed-program-declaration')
    call assert_invalid('(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive))', 'malformed-program-declaration')
    call assert_invalid('(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file ) (start-byte 0) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'malformed-program-declaration-file')
    call assert_invalid('(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 16) (source-hash )))', &
        'malformed-program-declaration-source-hash')
    call assert_invalid('(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file unit.f90) (start-byte -1) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'program root span is invalid')
    call assert_invalid('(program-declaration (declaration-kind program) (name unit) '// &
        '(span (file unit.f90) (start-byte 17) (end-byte 16) '// &
        '(source-hash hash-positive)))', 'program root span is invalid')

    write (*, '(a)') 'program declaration bridge behavioral checks: ok'

contains

    subroutine assert_invalid(value, expected_message)
        character(len=*), intent(in) :: value, expected_message

        call assert_false(ffc_lower_program_declaration_from_sx(value, body, message), &
            'invalid program declaration was lowered')
        call assert_equal(message, expected_message, 'wrong declaration rejection')
    end subroutine assert_invalid

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

end program test_program_declaration_bridge
