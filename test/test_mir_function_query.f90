program test_mir_function_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_at, mir_function_block_at, &
        mir_function_body_from_sx, mir_function_body_to_sx, mir_function_body_t, &
        mir_function_instruction_source_rule_at
    implicit none

    type(mir_function_body_t) :: body
    character(len=4096) :: serialized
    character(len=4096) :: roundtrip
    character(len=:), allocatable :: function_name, message, source_rule
    integer(int32) :: entry_block, instruction_count
    integer(int32) :: first_instruction, block_instruction_count
    logical :: ok

    serialized = '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode return) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32)))))'
    call mir_function_body_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'canonical function SX was not imported')

    call assert_true(mir_function_at(body, function_name, entry_block, instruction_count, &
        message), 'function metadata was not queryable')
    call assert_equal(function_name, 'main', 'function name changed')
    call assert_equal_integer(entry_block, 0_int32, 'function entry block changed')
    call assert_equal_integer(instruction_count, 2_int32, &
        'function instruction count changed')
    call assert_false(allocated(message), 'successful function query produced a diagnostic')

    call assert_true(mir_function_block_at(body, entry_block, first_instruction, &
        block_instruction_count, message), 'queried entry block was not usable')
    call assert_equal_integer(first_instruction, 0_int32, &
        'entry block first instruction changed')
    call assert_equal_integer(block_instruction_count, instruction_count, &
        'entry block instruction count changed')
    call assert_true(mir_function_instruction_source_rule_at(body, first_instruction, &
        source_rule, message), 'function source identity was not queryable')
    call assert_equal(source_rule, 'frontend-v0/program', &
        'function source identity changed')

    call mir_function_body_to_sx(body, roundtrip, ok, message)
    call assert_true(ok, 'imported function SX was not exported')
    call assert_equal(roundtrip, serialized, 'function SX was not canonical')

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_at(body, function_name, entry_block, instruction_count, &
        message), 'inconsistent function body was accepted')
    call assert_equal(function_name, '', 'failed function query did not clear its name')
    call assert_equal_integer(entry_block, 0_int32, &
        'failed function query did not clear its entry block')
    call assert_equal_integer(instruction_count, 0_int32, &
        'failed function query did not clear its instruction count')
    call assert_equal(message, 'function instruction count does not match body', &
        'inconsistent function diagnostic changed')

    call mir_function_body_from_sx('(mir-function (name main) (entry-block -1) '// &
        '(instruction-count 0) (instructions))', body, ok, message)
    call assert_false(ok, 'negative function entry block was accepted')
    call assert_equal(message, 'function entry block must be non-negative', &
        'negative function entry block diagnostic changed')

    call mir_function_body_from_sx('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0(program)) (result (id 1) (kind integer) '// &
        '(type i32)))))', body, ok, message)
    call assert_false(ok, 'malformed source identity was accepted')
    call assert_equal(message, 'unexpected SX token', &
        'malformed source identity diagnostic changed')

    write (*, '(a)') 'mir function query behavioral checks: ok'

contains

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

    subroutine assert_equal_integer(actual, expected, description)
        integer(int32), intent(in) :: actual, expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal_integer

end program test_mir_function_query
