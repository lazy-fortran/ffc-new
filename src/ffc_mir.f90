module ffc_mir
    use, intrinsic :: iso_fortran_env, only: int32
    implicit none
    private

    integer(int32), parameter, public :: value_kind_integer = 1_int32
    integer(int32), parameter, public :: value_kind_real = 2_int32
    integer(int32), parameter, public :: value_kind_logical = 3_int32
    integer(int32), parameter, public :: value_kind_address = 4_int32

    integer(int32), parameter, public :: opcode_add = 1_int32
    integer(int32), parameter, public :: opcode_sub = 2_int32
    integer(int32), parameter, public :: opcode_mul = 3_int32
    integer(int32), parameter, public :: opcode_div = 4_int32
    integer(int32), parameter, public :: opcode_load = 5_int32
    integer(int32), parameter, public :: opcode_store = 6_int32
    integer(int32), parameter, public :: opcode_compare = 7_int32
    integer(int32), parameter, public :: opcode_branch = 8_int32
    integer(int32), parameter, public :: opcode_call = 9_int32
    integer(int32), parameter, public :: opcode_return = 10_int32

    type, public :: mir_value_t
        integer(int32) :: id = 0_int32
        integer(int32) :: kind = 0_int32
        character(len=:), allocatable :: type_name
    end type mir_value_t

    type, public :: mir_instruction_t
        integer(int32) :: id = 0_int32
        integer(int32) :: opcode = 0_int32
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

    public :: mir_make_function_witness
    public :: mir_validate_function_body
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
        if (value%kind < value_kind_integer .or. value%kind > value_kind_address) then
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
        if (instruction%opcode < opcode_add .or. instruction%opcode > opcode_return) then
            call set_message(message, "instruction opcode is outside mir-v0")
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
