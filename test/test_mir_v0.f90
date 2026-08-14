program test_mir_v0
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir, only: mir_function_body_t, mir_function_t, mir_instruction_t, &
        mir_value_t, mir_make_function_witness, mir_validate_function, &
        mir_validate_function_body, mir_validate_function_witness, &
        mir_validate_instruction, mir_validate_value, &
        mir_function_instruction_at, &
        mir_function_witness_to_sx, mir_function_witness_from_sx, &
        opcode_add, opcode_return, value_kind_integer
    implicit none

    type(mir_value_t) :: value
    type(mir_instruction_t) :: instruction
    type(mir_instruction_t) :: selected_instruction
    type(mir_function_t) :: function
    type(mir_function_body_t) :: body
    character(len=:), allocatable :: message
    character(len=1024) :: serialized
    character(len=1024) :: roundtrip
    logical :: ok

    value%id = 1_int32
    value%kind = value_kind_integer
    value%type_name = "i32"
    call assert_true(mir_validate_value(value, message), "valid value rejected")
    call assert_true(.not. allocated(message), "valid value produced a diagnostic")

    value%kind = 0_int32
    call assert_false(mir_validate_value(value, message), "invalid value accepted")
    call assert_equal(message, "value kind is outside mir-v0", "value diagnostic")

    instruction%id = 2_int32
    instruction%opcode = opcode_add
    instruction%result = value
    instruction%result%kind = value_kind_integer
    instruction%source_rule = "expr/add"
    call assert_true(mir_validate_instruction(instruction, message), &
        "valid instruction rejected")

    instruction%opcode = opcode_return + 1_int32
    call assert_false(mir_validate_instruction(instruction, message), &
        "invalid instruction accepted")

    function%name = "main"
    function%entry_block = 0_int32
    function%instruction_count = 3_int32
    call assert_true(mir_validate_function(function, message), "valid function rejected")

    function%instruction_count = -1_int32
    call assert_false(mir_validate_function(function, message), "invalid function accepted")
    call assert_equal(message, "function instruction count must be non-negative", &
        "function diagnostic")

    call mir_make_function_witness(body)
    call assert_true(mir_validate_function_body(body, message), &
        "valid function body rejected")
    call assert_true(mir_validate_function_witness(body, message), &
        "valid function witness rejected")
    call assert_equal(body%instructions(1)%source_rule, "expr/add", &
        "add source rule was not preserved")
    call assert_equal(body%instructions(2)%source_rule, "stmt/return", &
        "return source rule was not preserved")

    body%function%instruction_count = 1_int32
    call assert_false(mir_validate_function_body(body, message), &
        "count mutation accepted")
    call assert_equal(message, "function instruction count does not match body", &
        "count mutation diagnostic")

    call mir_make_function_witness(body)
    body%instructions(2)%id = 0_int32
    call assert_false(mir_validate_function_body(body, message), &
        "ownership mutation accepted")
    call assert_equal(message, "instruction is not owned by its body slot", &
        "ownership mutation diagnostic")

    call mir_make_function_witness(body)
    body%instructions(1)%source_rule = "expr/changed"
    call assert_false(mir_validate_function_witness(body, message), &
        "source-rule mutation accepted")
    call assert_equal(message, "function witness add source rule changed", &
        "source-rule mutation diagnostic")

    call mir_make_function_witness(body)
    call mir_function_witness_to_sx(body, serialized, ok, message)
    call assert_true(ok, "valid function witness was not serialized")
    call assert_equal(trim(serialized), &
        '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) (source-rule expr/add) '// &
        '(result (id 1) (kind integer) (type i32))) '// &
        '(instruction (id 1) (opcode return) (source-rule stmt/return) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        "function witness SX is not canonical")

    call mir_function_witness_from_sx(serialized, body, ok, message)
    call assert_true(ok, "function witness SX did not round-trip: "//trim(message))
    call assert_true(mir_validate_function_witness(body, message), &
        "round-tripped function witness is invalid")

    call mir_function_witness_to_sx(body, roundtrip, ok, message)
    call assert_true(ok, "round-tripped function witness was not serializable")
    call assert_equal(trim(roundtrip), trim(serialized), &
        "function witness SX round-trip is not canonical")

    call assert_true(mir_function_instruction_at(body, 0_int32, selected_instruction, &
        message), &
        "round-tripped first instruction was not accessible")
    call assert_true(selected_instruction%opcode == opcode_add, &
        "round-tripped first instruction opcode changed")
    call assert_equal(selected_instruction%source_rule, "expr/add", &
        "round-tripped first instruction source rule changed")

    call assert_true(mir_function_instruction_at(body, 1_int32, selected_instruction, &
        message), &
        "round-tripped second instruction was not accessible")
    call assert_true(selected_instruction%opcode == opcode_return, &
        "round-tripped second instruction opcode changed")

    call assert_false(mir_function_instruction_at(body, -1_int32, selected_instruction, &
        message), &
        "negative instruction index was accepted")
    call assert_equal(message, "instruction index must be non-negative", &
        "negative instruction index diagnostic")

    call assert_false(mir_function_instruction_at(body, 2_int32, selected_instruction, &
        message), &
        "out-of-range instruction index was accepted")
    call assert_equal(message, "instruction index is outside function body", &
        "out-of-range instruction index diagnostic")

    body%function%instruction_count = 1_int32
    call assert_false(mir_function_instruction_at(body, 0_int32, selected_instruction, &
        message), &
        "inconsistent function body was accepted by accessor")
    call assert_equal(message, "function instruction count does not match body", &
        "inconsistent function body diagnostic")

    call mir_function_witness_from_sx('(mir-function (name main) '// &
        '(entry-block 0) (instruction-count 2) (instructions '// &
        '(instruction (id 0) (opcode return) (source-rule stmt/return) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        body, ok, message)
    call assert_false(ok, "count-inconsistent SX was accepted")

    call mir_function_witness_from_sx('(mir-function (name main) '// &
        '(entry-block 0) (instruction-count 1) (instructions '// &
        '(instruction (id 0) (opcode bogus) (source-rule stmt/return) '// &
        '(result (id 1) (kind integer) (type i32)))))', &
        body, ok, message)
    call assert_false(ok, "malformed opcode SX was accepted")

    call mir_function_witness_from_sx('(mir-function (name main) '// &
        '(entry-block 0) (instruction-count 3) (instructions))', &
        body, ok, message)
    call assert_false(ok, "over-bound SX was accepted")

contains

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
        character(len=*), intent(in) :: actual
        character(len=*), intent(in) :: expected
        character(len=*), intent(in) :: description

        call assert_true(actual == expected, description)
    end subroutine assert_equal

end program test_mir_v0
