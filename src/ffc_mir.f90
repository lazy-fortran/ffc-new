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
