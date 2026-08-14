program test_frontend_ast_handoff
    use, intrinsic :: iso_fortran_env, only: int64
    use ffc_frontend_ast, only: ffc_frontend_ast_v0_from_sx, ffc_frontend_ast_v0_t, &
        ffc_lower_frontend_ast_v0_from_sx
    use ffc_lowering, only: ffc_validate_lowered_program_root
    use ffc_mir, only: mir_function_body_t
    implicit none

    type(ffc_frontend_ast_v0_t) :: ast
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    character(len=4096) :: serialized

    serialized = '(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))))'
    call assert_true(ffc_frontend_ast_v0_from_sx(serialized, ast, message), &
        'one-declaration frontend AST was rejected')
    call assert_true(ast%declaration_count == 1_int64 .and. ast%declaration_present, &
        'one-declaration AST cardinality changed')
    call assert_equal(ast%root%name, 'unit', 'root name was not preserved')
    call assert_equal(ast%root%source_file, 'unit.f90', 'root source file was not preserved')
    call assert_equal(ast%root%source_hash, 'hash-unit', 'root source hash was not preserved')
    call assert_true(ast%root%start_byte == 0_int64 .and. ast%root%end_byte == 64_int64, &
        'root span was not preserved')
    call assert_equal(ast%declaration%source_file, 'unit.f90', &
        'declaration source file was not preserved')
    call assert_equal(ast%declaration%source_hash, 'hash-unit', &
        'declaration source hash was not preserved')
    call assert_true(ffc_lower_frontend_ast_v0_from_sx(serialized, body, message), &
        'one-declaration frontend AST was not lowered')
    call assert_true(ffc_validate_lowered_program_root(body, message), &
        'one-declaration AST did not produce a valid MIR witness')
    call assert_equal(body%function%name, 'unit', 'root name was not lowered into MIR')

    serialized = '(program-unit (root (program-root (name empty) '// &
        '(span (file empty.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash hash-empty)))) (declaration-count 0))'
    call assert_true(ffc_frontend_ast_v0_from_sx(serialized, ast, message), &
        'zero-declaration frontend AST was rejected')
    call assert_true(ast%declaration_count == 0_int64 .and. .not. ast%declaration_present, &
        'zero-declaration AST cardinality changed')
    call assert_true(ffc_lower_frontend_ast_v0_from_sx(serialized, body, message), &
        'zero-declaration frontend AST was not lowered')
    call assert_true(ffc_validate_lowered_program_root(body, message), &
        'zero-declaration AST did not produce a valid MIR witness')
    call assert_equal(body%function%name, 'empty', 'zero-declaration root was not lowered')

    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1))', &
        'frontend-ast-v0-declaration-count-mismatch')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 0) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file unit.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash hash-unit)))))', 'frontend-ast-v0-declaration-count-mismatch')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 2) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file unit.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash hash-unit)))))', 'frontend-ast-v0-declaration-count-mismatch')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind module) '// &
        '(name unit) (span (file unit.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash hash-unit)))))', 'invalid-program-declaration-kind')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file other.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash hash-unit)))))', 'frontend-ast-v0-invalid-provenance')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file unit.f90) (start-byte 0) (end-byte 1) '// &
        '(source-hash other-hash)))))', 'frontend-ast-v0-invalid-provenance')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 1) '// &
        '(declaration (program-declaration (declaration-kind program) '// &
        '(name unit) (span (file unit.f90) (start-byte 65) (end-byte 66) '// &
        '(source-hash hash-unit)))))', 'frontend-ast-v0-invalid-provenance')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 8) (end-byte 4) '// &
        '(source-hash hash-unit)))) (declaration-count 0))', &
        'program root span is invalid')
    call assert_invalid('(program-unit (root (program-root (name unit) '// &
        '(span (file unit.f90) (start-byte 0) (end-byte 64) '// &
        '(source-hash hash-unit)))) (declaration-count 0)', &
        'malformed-frontend-ast-v0')

    write (*, '(a)') 'frontend AST handoff behavioral checks: ok'

contains

    subroutine assert_invalid(value, expected_message)
        character(len=*), intent(in) :: value, expected_message

        call assert_false(ffc_frontend_ast_v0_from_sx(value, ast, message), &
            'invalid frontend AST was accepted')
        call assert_equal(message, expected_message, 'wrong frontend AST rejection')
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

end program test_frontend_ast_handoff
