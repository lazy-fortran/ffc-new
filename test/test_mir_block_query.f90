program test_mir_block_query
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_block_at, mir_function_body_from_sx, &
        mir_function_body_to_sx, mir_function_body_t, &
        mir_function_instruction_source_rule_at
    implicit none

    type(mir_function_body_t) :: body
    character(len=4096) :: serialized
    character(len=:), allocatable :: message, source_rule
    integer(int32) :: first_instruction, instruction_count
    logical :: ok

    serialized = '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode return) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32)))))'
    call mir_function_body_from_sx(serialized, body, ok, message)
    call assert_true(ok, 'canonical function/block SX was not imported')

    call assert_true(mir_function_block_at(body, 0_int32, first_instruction, &
        instruction_count, message), 'entry block was not queryable')
    call assert_equal_integer(first_instruction, 0_int32, &
        'entry block first instruction changed')
    call assert_equal_integer(instruction_count, 2_int32, &
        'entry block instruction count changed')
    call assert_true(mir_function_instruction_source_rule_at(body, first_instruction, &
        source_rule, message), 'block instruction source identity was not queryable')
    call assert_equal(source_rule, 'frontend-v0/program', &
        'block instruction source identity changed')

    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'imported function/block SX was not exported')
    call assert_equal(serialized, '(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 2) (instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode return) (source-rule frontend-v0/program) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        'function/block SX was not canonical')

    call assert_false(mir_function_block_at(body, -1_int32, first_instruction, &
        instruction_count, message), 'negative block index was accepted')
    call assert_equal(message, 'block index must be non-negative', &
        'negative block index diagnostic changed')
    call assert_false(mir_function_block_at(body, 1_int32, first_instruction, &
        instruction_count, message), 'out-of-range block index was accepted')
    call assert_equal(message, 'block index is outside function body', &
        'out-of-range block index diagnostic changed')

    call mir_function_body_from_sx('(mir-function (name main) (entry-block 0) '// &
        '(instruction-count 1) (instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0(program)) (result (id 1) (kind integer) '// &
        '(type i32)))))', body, ok, message)
    call assert_false(ok, 'malformed source identity was accepted')
    call assert_equal(message, 'unexpected SX token', &
        'malformed source identity diagnostic changed')

    write (*, '(a)') 'mir block query behavioral checks: ok'

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

end program test_mir_block_query
