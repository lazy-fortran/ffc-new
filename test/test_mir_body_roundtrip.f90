program test_mir_body_roundtrip
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_from_sx, mir_function_body_to_sx, &
        mir_function_body_t, mir_validate_function_body, value_kind_real
    implicit none

    type(mir_function_body_t) :: body
    character(len=4096) :: serialized, roundtrip
    character(len=:), allocatable :: message
    logical :: ok

    call check_valid_body('(mir-function (name empty) (entry-block 0) '// &
        '(instruction-count 0) (instructions))', 'empty', 0_int32)
    call check_valid_body('(mir-function (name branches) (entry-block 0) '// &
        '(instruction-count 3) (instructions (instruction (id 0) (opcode add) '// &
        '(source-rule block/entry) (result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode branch) (source-rule block/branch) '// &
        '(result (id 2) (kind logical) (type logical))) '// &
        '(instruction (id 2) (opcode return) (source-rule block/exit) '// &
        '(result (id 2) (kind logical) (type logical)))))', 'branches', 3_int32)
    call check_typed_body
    call check_source_linked_body
    call check_controls

    write (*, '(a)') 'mir body independent round-trip gate: ok'

contains

    subroutine check_valid_body(expected, expected_name, expected_count)
        character(len=*), intent(in) :: expected, expected_name
        integer(int32), intent(in) :: expected_count

        call mir_function_body_from_sx(expected, body, ok, message)
        call assert_true(ok, 'valid body was rejected: '//trim(message))
        call assert_true(mir_validate_function_body(body, message), &
            'imported body failed independent validation')
        call assert_equal(body%function%name, expected_name, &
            'function name changed during import')
        call assert_true(body%function%instruction_count == expected_count, &
            'instruction count changed during import')
        call mir_function_body_to_sx(body, roundtrip, ok, message)
        call assert_true(ok, 'valid body was not exported: '//trim(message))
        call assert_equal(roundtrip, expected, 'canonical SX changed during round-trip')
    end subroutine check_valid_body

    subroutine check_typed_body
        character(len=*), parameter :: expected = &
            '(mir-function (name typed) (entry-block 0) (instruction-count 1) '// &
            '(instructions (instruction (id 0) (opcode add) '// &
            '(source-rule expr/typed) (result (id 7) (kind real) (type f64)))))'

        call check_valid_body(expected, 'typed', 1_int32)
        call assert_true(body%instructions(1)%result%id == 7_int32, &
            'typed result id was not preserved')
        call assert_true(body%instructions(1)%result%kind == value_kind_real, &
            'typed result kind was not preserved')
        call assert_equal(body%instructions(1)%result%type_name, 'f64', &
            'typed result type was not preserved')
    end subroutine check_typed_body

    subroutine check_source_linked_body
        character(len=*), parameter :: expected = &
            '(mir-function (name linked) (entry-block 0) (instruction-count 2) '// &
            '(instructions (instruction (id 0) (opcode add) '// &
            '(source-rule frontend-v0/expr-12) (result (id 1) (kind integer) '// &
            '(type i32))) (instruction (id 1) (opcode return) '// &
            '(source-rule frontend-v0/return-13) (result (id 1) (kind integer) '// &
            '(type i32)))))'

        call check_valid_body(expected, 'linked', 2_int32)
        call assert_equal(body%instructions(1)%source_rule, 'frontend-v0/expr-12', &
            'first source identity was not preserved')
        call assert_equal(body%instructions(2)%source_rule, 'frontend-v0/return-13', &
            'second source identity was not preserved')
    end subroutine check_source_linked_body

    subroutine check_controls
        character(len=*), parameter :: malformed = &
            '(mir-function (name bad) (entry-block 0) (instruction-count 1) '// &
            '(instructions (instruction (id 0) (opcode add) '// &
            '(source-rule malformed (result (id 1) (kind integer) (type i32)))))'
        character(len=*), parameter :: invalid_opcode = &
            '(mir-function (name bad) (entry-block 0) (instruction-count 1) '// &
            '(instructions (instruction (id 0) (opcode invalid) '// &
            '(source-rule bad) (result (id 1) (kind integer) (type i32)))))'
        character(len=*), parameter :: count_mismatch = &
            '(mir-function (name bad) (entry-block 0) (instruction-count 2) '// &
            '(instructions (instruction (id 0) (opcode add) '// &
            '(source-rule bad) (result (id 1) (kind integer) (type i32)))))'

        call mir_function_body_from_sx(malformed, body, ok, message)
        call assert_false(ok, 'malformed SX was accepted')
        call assert_equal(message, 'unexpected SX token', 'malformed diagnostic changed')
        call assert_false(allocated(body%instructions), 'malformed input left stale body')
        call assert_equal(body%function%name, '', 'malformed input left stale function')

        call mir_function_body_from_sx(invalid_opcode, body, ok, message)
        call assert_false(ok, 'invalid opcode was accepted')
        call assert_equal(message, 'unknown mir-v0 opcode', &
            'invalid opcode diagnostic changed')
        call assert_false(allocated(body%instructions), 'invalid opcode left stale body')

        call mir_function_body_from_sx(count_mismatch, body, ok, message)
        call assert_false(ok, 'count mismatch was accepted')
        call assert_equal(message, 'unexpected SX token', &
            'count mismatch diagnostic changed')
        call assert_false(allocated(body%instructions), 'count mismatch left stale body')

        call mir_function_body_from_sx('(mir-function (name stale) (entry-block 0) '// &
            '(instruction-count 0) (instructions))', body, ok, message)
        call assert_true(ok, 'stale-output setup body was rejected')
        serialized = 'stale output'
        body%function%instruction_count = 1_int32
        call mir_function_body_to_sx(body, serialized, ok, message)
        call assert_false(ok, 'invalid body was exported')
        call assert_equal(serialized, '', 'failed export left stale serialized output')
    end subroutine check_controls

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

end program test_mir_body_roundtrip
