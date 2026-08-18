module ffc_mir
    use, intrinsic :: iso_fortran_env, only: int32
    use ffc_mir_metadata, only: mir_opcode_histogram_size, mir_opcode_name, &
        mir_opcode_value, mir_value_kind_name, mir_value_kind_value, opcode_add, &
        opcode_branch, opcode_call, opcode_compare, opcode_div, opcode_load, &
        opcode_const, opcode_mul, opcode_return, opcode_store, opcode_sub, &
        value_kind_address, &
        value_kind_character, value_kind_complex, value_kind_integer, value_kind_logical, &
        value_kind_real, &
        mir_type_spec_name, mir_type_spec_value_kind
    implicit none
    private

    public :: value_kind_integer, value_kind_real, value_kind_logical, value_kind_address, &
        value_kind_complex, value_kind_character
    public :: mir_type_spec_name, mir_type_spec_value_kind
    public :: opcode_const, opcode_add, opcode_sub, opcode_mul, opcode_div, opcode_load, opcode_store
    public :: opcode_compare, opcode_branch, opcode_call, opcode_return
    public :: mir_opcode_histogram_size

    integer(int32), parameter :: mir_witness_max_instructions = 2_int32

    type, public :: mir_value_t
        integer(int32) :: id = 0_int32
        integer(int32) :: kind = 0_int32
        character(len=:), allocatable :: type_name
    end type mir_value_t

    type, public :: mir_instruction_t
        integer(int32) :: id = 0_int32
        integer(int32) :: opcode = 0_int32
        integer(int32) :: literal_value = 0_int32
        type(mir_value_t) :: result
        character(len=:), allocatable :: source_rule
    end type mir_instruction_t

    type, public :: mir_function_t
        character(len=:), allocatable :: name
        integer(int32) :: entry_block = 0_int32
        integer(int32) :: instruction_count = 0_int32
    end type mir_function_t

    type, public :: mir_function_body_t
        type(mir_function_t) :: function
        type(mir_instruction_t), allocatable :: instructions(:)
    end type mir_function_body_t

    type, public :: mir_block_range_t
        integer(int32) :: first_instruction = 0_int32
        integer(int32) :: instruction_count = 0_int32
    end type mir_block_range_t

    type, public :: mir_block_table_t
        type(mir_block_range_t), allocatable :: ranges(:)
    end type mir_block_table_t

    public :: mir_make_function_witness
    public :: mir_function_body_to_sx
    public :: mir_function_body_from_sx
    public :: mir_function_body_sx_size
    public :: mir_function_witness_to_sx
    public :: mir_function_witness_from_sx
    public :: mir_validate_function_body
    public :: mir_function_instruction_at
    public :: mir_function_instruction_opcode_at
    public :: mir_function_instruction_count_at
    public :: mir_function_opcode_count_at
    public :: mir_function_opcode_histogram_at
    public :: mir_function_instruction_result_id_at
    public :: mir_function_instruction_result_kind_at
    public :: mir_function_instruction_result_type_at
    public :: mir_function_instruction_source_rule_at
    public :: mir_function_at
    public :: mir_function_body_at
    public :: mir_function_block_at
    public :: mir_function_block_instruction_at
    public :: mir_function_block_count_at
    public :: mir_make_function_block_table
    public :: mir_make_function_block_table_from_lengths
    public :: mir_validate_function_block_table
    public :: mir_function_block_table_range_at
    public :: mir_validate_function_witness
    public :: mir_validate_value
    public :: mir_validate_instruction
    public :: mir_validate_function

contains

    logical function mir_validate_value(value, message) result(valid)
        type(mir_value_t), intent(in) :: value
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (value%id < 0_int32) then
            call set_message(message, "value id must be non-negative")
            return
        end if
        if (value%kind < value_kind_integer .or. value%kind > value_kind_character) then
            call set_message(message, "value kind is outside mir-v0")
            return
        end if
        if (.not. allocated(value%type_name)) then
            call set_message(message, "value type name must be non-empty")
            return
        end if
        if (len_trim(value%type_name) == 0) then
            call set_message(message, "value type name must be non-empty")
            return
        end if
        if (.not. mir_is_sx_atom(value%type_name)) then
            call set_message(message, "value type name is not a valid SX atom")
            return
        end if
        valid = .true.
    end function mir_validate_value

    logical function mir_validate_instruction(instruction, message) result(valid)
        type(mir_instruction_t), intent(in) :: instruction
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (instruction%id < 0_int32) then
            call set_message(message, "instruction id must be non-negative")
            return
        end if
        if (instruction%opcode < opcode_add .or. instruction%opcode > opcode_const) then
            call set_message(message, "instruction opcode is outside mir-v0")
            return
        end if
        if (instruction%opcode /= opcode_const .and. instruction%literal_value /= 0_int32) then
            call set_message(message, "non-const instruction has a literal value")
            return
        end if
        if (.not. mir_validate_value(instruction%result, message)) return
        if (.not. allocated(instruction%source_rule)) then
            call set_message(message, "instruction source rule must be non-empty")
            return
        end if
        if (len_trim(instruction%source_rule) == 0) then
            call set_message(message, "instruction source rule must be non-empty")
            return
        end if
        if (.not. mir_is_sx_atom(instruction%source_rule)) then
            call set_message(message, "instruction source rule is not a valid SX atom")
            return
        end if
        valid = .true.
    end function mir_validate_instruction

    logical function mir_validate_function(function, message) result(valid)
        type(mir_function_t), intent(in) :: function
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. allocated(function%name)) then
            call set_message(message, "function name must be non-empty")
            return
        end if
        if (len_trim(function%name) == 0) then
            call set_message(message, "function name must be non-empty")
            return
        end if
        if (.not. mir_is_sx_atom(function%name)) then
            call set_message(message, "function name is not a valid SX atom")
            return
        end if
        if (function%entry_block < 0_int32) then
            call set_message(message, "function entry block must be non-negative")
            return
        end if
        if (function%instruction_count < 0_int32) then
            call set_message(message, "function instruction count must be non-negative")
            return
        end if
        valid = .true.
    end function mir_validate_function

    subroutine mir_make_function_witness(body)
        type(mir_function_body_t), intent(out) :: body

        body%function%name = "main"
        body%function%entry_block = 0_int32
        allocate (body%instructions(2))
        body%function%instruction_count = int(size(body%instructions), int32)

        body%instructions(1)%id = 0_int32
        body%instructions(1)%opcode = opcode_add
        body%instructions(1)%result%id = 1_int32
        body%instructions(1)%result%kind = value_kind_integer
        body%instructions(1)%result%type_name = "i32"
        body%instructions(1)%source_rule = "expr/add"

        body%instructions(2)%id = 1_int32
        body%instructions(2)%opcode = opcode_return
        body%instructions(2)%result = body%instructions(1)%result
        body%instructions(2)%source_rule = "stmt/return"
    end subroutine mir_make_function_witness

    logical function mir_validate_function_body(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message ! text-policy: diagnostic boundary
        integer(int32) :: index

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function(body%function, message)) return
        if (.not. allocated(body%instructions)) then
            call set_message(message, "function instructions must be allocated")
            return
        end if
        if (body%function%instruction_count /= int(size(body%instructions), int32)) then
            call set_message(message, "function instruction count does not match body")
            return
        end if
        do index = 1, int(size(body%instructions), int32)
            if (body%instructions(index)%id /= index - 1_int32) then
                call set_message(message, "instruction is not owned by its body slot")
                return
            end if
            if (.not. mir_validate_instruction(body%instructions(index), message)) return
        end do
        valid = .true.
    end function mir_validate_function_body

    logical function mir_function_instruction_at(body, index, instruction, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        type(mir_instruction_t), intent(out) :: instruction
        character(len=:), allocatable, intent(out), optional :: message

        instruction%id = 0_int32
        instruction%opcode = 0_int32
        instruction%result%id = 0_int32
        instruction%result%kind = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (index < 0_int32) then
            call set_message(message, "instruction index must be non-negative")
            return
        end if
        if (index >= body%function%instruction_count) then
            call set_message(message, "instruction index is outside function body")
            return
        end if
        instruction = body%instructions(index + 1_int32)
        valid = .true.
    end function mir_function_instruction_at

    logical function mir_function_instruction_opcode_at(body, index, opcode, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        integer(int32), intent(out) :: opcode
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_instruction_t) :: instruction

        opcode = 0_int32
        call clear_message(message)
        valid = mir_function_instruction_at(body, index, instruction, message)
        if (.not. valid) return
        opcode = instruction%opcode
    end function mir_function_instruction_opcode_at

    logical function mir_function_instruction_count_at(body, count, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(out) :: count
        character(len=:), allocatable, intent(out), optional :: message

        count = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        count = body%function%instruction_count
        valid = .true.
    end function mir_function_instruction_count_at

    logical function mir_function_opcode_count_at(body, opcode, count, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: opcode
        integer(int32), intent(out) :: count
        character(len=:), allocatable, intent(out), optional :: message

        integer(int32) :: index
        integer(int32) :: instruction_opcode

        count = 0_int32
        call clear_message(message)
        valid = .false.
        if (opcode < opcode_add .or. opcode > opcode_const) then
            call set_message(message, "opcode is outside mir-v0")
            return
        end if
        if (.not. mir_validate_function_body(body, message)) return
        do index = 0_int32, body%function%instruction_count - 1_int32
            if (.not. mir_function_instruction_opcode_at(body, index, instruction_opcode, &
                message)) then
                count = 0_int32
                return
            end if
            if (instruction_opcode == opcode) count = count + 1_int32
        end do
        valid = .true.
    end function mir_function_opcode_count_at

    logical function mir_function_opcode_histogram_at(body, histogram, total, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(out) :: histogram(mir_opcode_histogram_size)
        integer(int32), intent(out) :: total
        character(len=:), allocatable, intent(out), optional :: message

        integer(int32) :: index
        integer(int32) :: opcode

        histogram = 0_int32
        total = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        do index = 1, int(size(body%instructions), int32)
            opcode = body%instructions(index)%opcode
            histogram(opcode) = histogram(opcode) + 1_int32
            total = total + 1_int32
        end do
        valid = .true.
    end function mir_function_opcode_histogram_at

    logical function mir_function_instruction_result_id_at(body, index, result_id, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        integer(int32), intent(out) :: result_id
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_instruction_t) :: instruction

        result_id = 0_int32
        call clear_message(message)
        valid = mir_function_instruction_at(body, index, instruction, message)
        if (.not. valid) return
        result_id = instruction%result%id
    end function mir_function_instruction_result_id_at

    logical function mir_function_instruction_result_kind_at(body, index, kind, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        integer(int32), intent(out) :: kind
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_instruction_t) :: instruction

        kind = 0_int32
        call clear_message(message)
        valid = mir_function_instruction_at(body, index, instruction, message)
        if (.not. valid) return
        kind = instruction%result%kind
    end function mir_function_instruction_result_kind_at

    logical function mir_function_instruction_result_type_at(body, index, type_name, &
            message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        character(len=:), allocatable, intent(out) :: type_name
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_instruction_t) :: instruction

        type_name = ''
        call clear_message(message)
        valid = mir_function_instruction_at(body, index, instruction, message)
        if (.not. valid) return
        type_name = instruction%result%type_name
    end function mir_function_instruction_result_type_at

    logical function mir_function_instruction_source_rule_at(body, index, source_rule, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: index
        character(len=:), allocatable, intent(out) :: source_rule
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_instruction_t) :: instruction

        source_rule = ''
        call clear_message(message)
        valid = mir_function_instruction_at(body, index, instruction, message)
        if (.not. valid) return
        source_rule = instruction%source_rule
    end function mir_function_instruction_source_rule_at

    logical function mir_function_at(body, name, entry_block, instruction_count, message) &
            result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out) :: name
        integer(int32), intent(out) :: entry_block
        integer(int32), intent(out) :: instruction_count
        character(len=:), allocatable, intent(out), optional :: message

        name = ''
        entry_block = 0_int32
        instruction_count = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        name = body%function%name
        entry_block = body%function%entry_block
        instruction_count = body%function%instruction_count
        valid = .true.
    end function mir_function_at

    logical function mir_function_body_at(body, selected_body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        type(mir_function_body_t), intent(out) :: selected_body
        character(len=:), allocatable, intent(out), optional :: message

        call reset_body(selected_body)
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        selected_body = body
        valid = .true.
    end function mir_function_body_at

    logical function mir_function_block_at(body, block_index, first_instruction, &
            instruction_count, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: block_index
        integer(int32), intent(out) :: first_instruction
        integer(int32), intent(out) :: instruction_count
        character(len=:), allocatable, intent(out), optional :: message

        first_instruction = 0_int32
        instruction_count = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (block_index < 0_int32) then
            call set_message(message, "block index must be non-negative")
            return
        end if
        if (block_index /= body%function%entry_block) then
            call set_message(message, "block index is outside function body")
            return
        end if
        instruction_count = body%function%instruction_count
        valid = .true.
    end function mir_function_block_at

    logical function mir_function_block_instruction_at(body, block_index, instruction_index, &
            instruction, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: block_index
        integer(int32), intent(in) :: instruction_index
        type(mir_instruction_t), intent(out) :: instruction
        character(len=:), allocatable, intent(out), optional :: message ! text-policy: diagnostic boundary

        integer(int32) :: first_instruction
        integer(int32) :: block_instruction_count

        instruction%id = 0_int32
        instruction%opcode = 0_int32
        instruction%result%id = 0_int32
        instruction%result%kind = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_function_block_at(body, block_index, first_instruction, &
            block_instruction_count, message)) return
        if (instruction_index < 0_int32) then
            call set_message(message, "instruction index must be non-negative")
            return
        end if
        if (instruction_index >= block_instruction_count) then
            call set_message(message, "instruction index is outside block")
            return
        end if
        valid = mir_function_instruction_at(body, first_instruction + instruction_index, &
            instruction, message)
    end function mir_function_block_instruction_at

    logical function mir_function_block_count_at(body, block_count, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(out) :: block_count
        character(len=:), allocatable, intent(out), optional :: message

        block_count = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        block_count = 1_int32
        valid = .true.
    end function mir_function_block_count_at

    logical function mir_make_function_block_table(body, table, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(out) :: table
        character(len=:), allocatable, intent(out), optional :: message

        call reset_block_table(table)
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        allocate (table%ranges(1))
        table%ranges(1)%first_instruction = 0_int32
        table%ranges(1)%instruction_count = body%function%instruction_count
        valid = .true.
    end function mir_make_function_block_table

    logical function mir_make_function_block_table_from_lengths(body, block_instruction_counts, &
            table, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(in) :: block_instruction_counts(:)
        type(mir_block_table_t), intent(out) :: table
        character(len=:), allocatable, intent(out), optional :: message

        type(mir_block_range_t), allocatable :: ranges(:)
        integer :: allocation_status
        integer(int32) :: index
        integer(int32) :: first_instruction

        call reset_block_table(table)
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (size(block_instruction_counts) < 1) then
            call set_message(message, "block partition must contain at least one block")
            return
        end if
        allocate (ranges(size(block_instruction_counts)), stat=allocation_status)
        if (allocation_status /= 0) then
            call set_message(message, "block table allocation failed")
            return
        end if
        first_instruction = 0_int32
        do index = 1, int(size(block_instruction_counts), int32)
            if (block_instruction_counts(index) <= 0_int32) then
                call set_message(message, "block instruction count must be positive")
                deallocate (ranges)
                return
            end if
            if (block_instruction_counts(index) > body%function%instruction_count - &
                first_instruction) then
                call set_message(message, "block partition exceeds function body")
                deallocate (ranges)
                return
            end if
            ranges(index)%first_instruction = first_instruction
            ranges(index)%instruction_count = block_instruction_counts(index)
            first_instruction = first_instruction + block_instruction_counts(index)
        end do
        if (first_instruction /= body%function%instruction_count) then
            call set_message(message, "block partition does not cover function body")
            deallocate (ranges)
            return
        end if
        call move_alloc(ranges, table%ranges)
        valid = .true.
    end function mir_make_function_block_table_from_lengths

    logical function mir_validate_function_block_table(body, table, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        character(len=:), allocatable, intent(out), optional :: message

        integer(int32) :: index
        integer(int32) :: expected_first

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (.not. allocated(table%ranges)) then
            call set_message(message, "block table ranges must be allocated")
            return
        end if
        if (size(table%ranges) < 1) then
            call set_message(message, "block table must contain at least one range")
            return
        end if
        expected_first = 0_int32
        do index = 1, int(size(table%ranges), int32)
            if (table%ranges(index)%first_instruction /= expected_first) then
                call set_message(message, "block table ranges are not contiguous")
                return
            end if
            if (table%ranges(index)%instruction_count < 0_int32) then
                call set_message(message, "block range instruction count must be non-negative")
                return
            end if
            expected_first = expected_first + table%ranges(index)%instruction_count
        end do
        if (expected_first /= body%function%instruction_count) then
            call set_message(message, "block table does not cover function body")
            return
        end if
        valid = .true.
    end function mir_validate_function_block_table

    logical function mir_function_block_table_range_at(body, table, block_index, &
            first_instruction, instruction_count, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        type(mir_block_table_t), intent(in) :: table
        integer(int32), intent(in) :: block_index
        integer(int32), intent(out) :: first_instruction
        integer(int32), intent(out) :: instruction_count
        character(len=:), allocatable, intent(out), optional :: message

        first_instruction = 0_int32
        instruction_count = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_block_table(body, table, message)) return
        if (block_index < 0_int32) then
            call set_message(message, "block index must be non-negative")
            return
        end if
        if (block_index >= int(size(table%ranges), int32)) then
            call set_message(message, "block index is outside block table")
            return
        end if
        first_instruction = table%ranges(block_index + 1_int32)%first_instruction
        instruction_count = table%ranges(block_index + 1_int32)%instruction_count
        valid = .true.
    end function mir_function_block_table_range_at

    logical function mir_validate_function_witness(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message ! text-policy: diagnostic boundary

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 2_int32) then
            call set_message(message, "function witness instruction count changed")
            return
        end if
        if (body%function%name /= "main") then
            call set_message(message, "function witness name changed")
            return
        end if
        if (body%function%entry_block /= 0_int32) then
            call set_message(message, "function witness entry block changed")
            return
        end if
        if (body%instructions(1)%opcode /= opcode_add) then
            call set_message(message, "function witness add instruction changed")
            return
        end if
        if (body%instructions(1)%source_rule /= "expr/add") then
            call set_message(message, "function witness add source rule changed")
            return
        end if
        if (body%instructions(2)%opcode /= opcode_return) then
            call set_message(message, "function witness return instruction changed")
            return
        end if
        if (body%instructions(2)%source_rule /= "stmt/return") then
            call set_message(message, "function witness return source rule changed")
            return
        end if
        valid = .true.
    end function mir_validate_function_witness

    logical function mir_is_sx_atom(value) result(valid)
        character(len=*), intent(in) :: value
        integer :: position

        valid = len(value) > 0
        if (.not. valid) return
        do position = 1, len(value)
            if (index(' '//char(9)//char(10)//char(13)//'()', &
                value(position:position)) > 0) then
                valid = .false.
                return
            end if
        end do
    end function mir_is_sx_atom

    subroutine mir_function_witness_to_sx(body, output, ok, message)
        type(mir_function_body_t), intent(in) :: body
        character(len=*), intent(out) :: output
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message

        call write_function_sx(body, output, ok, message, .true.)
    end subroutine mir_function_witness_to_sx

    subroutine mir_function_body_to_sx(body, output, ok, message)
        type(mir_function_body_t), intent(in) :: body
        character(len=*), intent(out) :: output
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message

        call write_function_sx(body, output, ok, message, .false.)
    end subroutine mir_function_body_to_sx

    logical function mir_function_body_sx_size(body, size, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        integer(int32), intent(out) :: size
        character(len=:), allocatable, intent(out), optional :: message

        character(len=32) :: id_text, result_id_text
        character(len=32) :: opcode_text, result_kind_text
        integer(int32) :: index

        size = 0_int32
        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return

        size = int(len('(mir-function (name ') + len_trim(body%function%name) + &
            len(') (entry-block ') + len_trim(itoa(body%function%entry_block)) + &
            len(') (instruction-count ') + &
            len_trim(itoa(body%function%instruction_count)) + len(') (instructions'), int32)
        do index = 1, body%function%instruction_count
            write (id_text, '(i0)') body%instructions(index)%id
            write (result_id_text, '(i0)') body%instructions(index)%result%id
            opcode_text = mir_opcode_name(body%instructions(index)%opcode)
            result_kind_text = mir_value_kind_name(body%instructions(index)%result%kind)
            size = size + int(len(' (instruction (id ') + len_trim(id_text) + &
                len(') (opcode ') + len_trim(opcode_text) + &
                len(')') + &
                merge(len(' (literal ') + len_trim(itoa(body%instructions(index)%literal_value)) + &
                len(')'), 0, body%instructions(index)%opcode == opcode_const) + &
                len(' (source-rule ') + len_trim(body%instructions(index)%source_rule) + &
                len(') (result (id ') + len_trim(result_id_text) + &
                len(') (kind ') + len_trim(result_kind_text) + &
                len(') (type ') + &
                len_trim(body%instructions(index)%result%type_name) + len(')))'), int32)
        end do
        size = size + int(len('))'), int32)
        valid = .true.
    end function mir_function_body_sx_size

    subroutine write_function_sx(body, output, ok, message, witness)
        type(mir_function_body_t), intent(in) :: body
        character(len=*), intent(out) :: output
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message
        logical, intent(in) :: witness

        character(len=32) :: count_text, id_text, result_id_text
        character(len=32) :: opcode_text, result_kind_text
        character(len=:), allocatable :: canonical
        integer :: index

        output = ''
        message = ''
        if (witness) then
            ok = mir_validate_function_witness(body, message)
        else
            ok = mir_validate_function_body(body, message)
        end if
        if (.not. ok) return

        write (count_text, '(i0)') body%function%instruction_count
        canonical = '(mir-function (name '//trim(body%function%name)//') '// &
            '(entry-block '//trim(adjustl(itoa(body%function%entry_block)))//') '// &
            '(instruction-count '//trim(count_text)//') (instructions'
        do index = 1, size(body%instructions)
            write (id_text, '(i0)') body%instructions(index)%id
            write (result_id_text, '(i0)') body%instructions(index)%result%id
            opcode_text = mir_opcode_name(body%instructions(index)%opcode)
            result_kind_text = mir_value_kind_name(body%instructions(index)%result%kind)
            canonical = trim(canonical)//' (instruction (id '//trim(id_text)//') '// &
                '(opcode '//trim(opcode_text)//')'
            if (body%instructions(index)%opcode == opcode_const) then
                canonical = trim(canonical)//' (literal '// &
                    trim(itoa(body%instructions(index)%literal_value))//')'
            end if
            canonical = trim(canonical)//' (source-rule '// &
                trim(body%instructions(index)%source_rule)//') (result (id '// &
                trim(result_id_text)//') (kind '//trim(result_kind_text)//') (type '// &
                trim(body%instructions(index)%result%type_name)// &
                ')))'
        end do
        canonical = trim(canonical)//'))'
        if (len_trim(canonical) > len(output)) then
            ok = .false.
            message = 'sx-output-too-short'
            output = ''
        else
            output(:len_trim(canonical)) = canonical
        end if
    end subroutine write_function_sx

    subroutine mir_function_witness_from_sx(input, body, ok, message)
        character(len=*), intent(in) :: input
        type(mir_function_body_t), intent(out) :: body
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message

        call read_function_sx(input, body, ok, message, .true.)
    end subroutine mir_function_witness_from_sx

    subroutine mir_function_body_from_sx(input, body, ok, message)
        character(len=*), intent(in) :: input
        type(mir_function_body_t), intent(out) :: body
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message

        call read_function_sx(input, body, ok, message, .false.)
    end subroutine mir_function_body_from_sx

    subroutine read_function_sx(input, body, ok, message, witness)
        character(len=*), intent(in) :: input
        type(mir_function_body_t), intent(out) :: body
        logical, intent(out) :: ok
        character(len=:), allocatable, intent(out) :: message
        logical, intent(in) :: witness

        character(len=256) :: token(128)
        integer :: token_count, position, index
        integer(int32) :: count

        call reset_body(body)
        message = repeat(' ', 256)
        ok = tokenize_sx(input, token, token_count, message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        position = 1
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = expect_token(token, token_count, position, 'mir-function', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = read_named_atom(token, token_count, position, 'name', body%function%name, message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = read_named_integer(token, token_count, position, 'entry-block', &
            body%function%entry_block, message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = read_named_integer(token, token_count, position, 'instruction-count', &
            count, message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        if (count < 0_int32) then
            ok = .false.
            message = 'negative instruction count'
            call reset_body(body)
            return
        end if
        if (witness .and. count > mir_witness_max_instructions) then
            ok = .false.
            message = 'instruction count exceeds witness bound'
            call reset_body(body)
            return
        end if
        if (count > int(token_count, int32)) then
            ok = .false.
            message = 'instruction count exceeds SX token capacity'
            call reset_body(body)
            return
        end if
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = expect_token(token, token_count, position, 'instructions', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        allocate (body%instructions(count))
        body%function%instruction_count = count
        do index = 1, count
            ok = read_instruction(token, token_count, position, index - 1, &
                body%instructions(index), message)
            if (.not. ok) then
                call reset_body(body)
                return
            end if
        end do
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        ok = expect_token(token, token_count, position, ')', message)
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        if (position <= token_count) then
            ok = .false.
            message = 'trailing SX input'
            call reset_body(body)
            return
        end if
        if (witness) then
            ok = mir_validate_function_witness(body, message)
        else
            ok = mir_validate_function_body(body, message)
        end if
        if (.not. ok) then
            call reset_body(body)
            return
        end if
        if (ok) message = ''
    end subroutine read_function_sx

    character(len=32) function itoa(value)
        integer(int32), intent(in) :: value

        write (itoa, '(i0)') value
    end function itoa

    logical function tokenize_sx(input, token, token_count, message) result(ok)
        character(len=*), intent(in) :: input
        character(len=*), intent(out) :: token(:)
        integer, intent(out) :: token_count
        character(len=*), intent(out) :: message

        integer :: start, position, input_length
        character :: current

        token = ''
        token_count = 0
        message = ''
        position = 1
        input_length = len_trim(input)
        do while (position <= input_length)
            current = input(position:position)
            if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                current == char(13)) then
                position = position + 1
            else if (current == '(' .or. current == ')') then
                if (.not. append_token(input(position:position), token, token_count, message)) then
                    ok = .false.
                    return
                end if
                position = position + 1
            else
                start = position
                do while (position <= input_length)
                    current = input(position:position)
                    if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                        current == char(13) .or. current == '(' .or. current == ')') exit
                    position = position + 1
                end do
                if (.not. append_token(input(start:position - 1), token, token_count, message)) then
                    ok = .false.
                    return
                end if
            end if
        end do
        ok = token_count > 0
        if (.not. ok) message = 'empty SX input'
    end function tokenize_sx

    logical function append_token(value, token, token_count, message) result(ok)
        character(len=*), intent(in) :: value
        character(len=*), intent(inout) :: token(:)
        integer, intent(inout) :: token_count
        character(len=*), intent(out) :: message

        message = ''
        if (token_count == size(token)) then
            message = 'SX input has too many tokens'
            ok = .false.
            return
        end if
        if (len_trim(value) > len(token(1))) then
            message = 'SX atom is too long'
            ok = .false.
            return
        end if
        token_count = token_count + 1
        token(token_count) = value
        ok = .true.
    end function append_token

    logical function expect_token(token, token_count, position, expected, message) result(ok)
        character(len=*), intent(in) :: token(:), expected
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: message

        if (position > token_count) then
            message = 'unexpected end of SX input'
            ok = .false.
            return
        end if
        if (trim(token(position)) /= expected) then
            message = 'unexpected SX token'
            ok = .false.
            return
        end if
        position = position + 1
        message = ''
        ok = .true.
    end function expect_token

    logical function read_named_atom(token, token_count, position, name, value, message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=:), allocatable, intent(out) :: value
        character(len=*), intent(out) :: message

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        if (position > token_count) then
            message = 'missing SX atom'
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            message = 'missing SX atom'
            ok = .false.
            return
        end if
        value = trim(token(position))
        position = position + 1
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_atom

    logical function read_named_integer(token, token_count, position, name, value, message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        integer(int32), intent(out) :: value
        character(len=*), intent(out) :: message
        integer :: ios
        character(len=:), allocatable :: integer_text

        ok = read_named_atom(token, token_count, position, name, integer_text, message)
        if (.not. ok) return
        read (integer_text, *, iostat=ios) value
        if (ios /= 0) then
            message = 'SX integer is invalid'
            ok = .false.
        else
            message = ''
            ok = .true.
        end if
    end function read_named_integer

    logical function read_instruction(token, token_count, position, id, instruction, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count, id
        integer, intent(inout) :: position
        type(mir_instruction_t), intent(out) :: instruction
        character(len=*), intent(out) :: message
        character(len=:), allocatable :: opcode_name
        integer(int32) :: serialized_id

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'instruction', message)
        if (.not. ok) return
        ok = read_named_integer(token, token_count, position, 'id', serialized_id, message)
        if (.not. ok) return
        if (serialized_id /= int(id, int32)) then
            message = 'instruction id does not match body slot'
            ok = .false.
            return
        end if
        instruction%id = int(id, int32)
        ok = read_named_atom(token, token_count, position, 'opcode', opcode_name, message)
        if (.not. ok) return
        instruction%opcode = mir_opcode_value(opcode_name)
        if (instruction%opcode == 0_int32) then
            message = 'unknown mir-v0 opcode'
            ok = .false.
            return
        end if
        instruction%literal_value = 0_int32
        if (instruction%opcode == opcode_const) then
            ok = read_named_integer(token, token_count, position, 'literal', &
                instruction%literal_value, message)
            if (.not. ok) return
        end if
        ok = read_named_atom(token, token_count, position, 'source-rule', &
            instruction%source_rule, message)
        if (.not. ok) return
        ok = read_value(token, token_count, position, instruction%result, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_instruction

    logical function read_value(token, token_count, position, value, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        type(mir_value_t), intent(out) :: value
        character(len=*), intent(out) :: message
        character(len=:), allocatable :: kind_name

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, 'result', message)
        if (.not. ok) return
        ok = read_named_integer(token, token_count, position, 'id', value%id, message)
        if (.not. ok) return
        ok = read_named_atom(token, token_count, position, 'kind', kind_name, message)
        if (.not. ok) return
        value%kind = mir_value_kind_value(kind_name)
        if (value%kind == 0_int32) then
            message = 'unknown mir-v0 value kind'
            ok = .false.
            return
        end if
        ok = read_named_atom(token, token_count, position, 'type', value%type_name, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_value

    subroutine reset_body(body)
        type(mir_function_body_t), intent(out) :: body

        body%function%name = ''
        body%function%entry_block = 0_int32
        body%function%instruction_count = 0_int32
    end subroutine reset_body

    subroutine reset_block_table(table)
        type(mir_block_table_t), intent(out) :: table

        if (allocated(table%ranges)) deallocate (table%ranges)
    end subroutine reset_block_table

    subroutine clear_message(message)
        character(len=:), allocatable, intent(out), optional :: message

        if (present(message)) then
            if (allocated(message)) deallocate(message)
        end if
    end subroutine clear_message

    subroutine set_message(message, text)
        character(len=:), allocatable, intent(out), optional :: message
        character(len=*), intent(in) :: text

        if (present(message)) message = text
    end subroutine set_message

end module ffc_mir
