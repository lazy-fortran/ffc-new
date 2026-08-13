module ffc_lowering
    use, intrinsic :: iso_fortran_env, only: int64
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, &
        mir_validate_function_body, opcode_add, opcode_return
    implicit none
    private

    character(len=*), parameter, public :: frontend_status_accepted = 'accepted'
    character(len=*), parameter, public :: frontend_status_rejected = 'rejected'
    character(len=*), parameter, public :: frontend_root_kind_program = 'program'
    character(len=*), parameter, public :: frontend_root_kind_none = 'none'

    type, public :: frontend_v0_input_t
        character(len=8) :: status = frontend_status_rejected
        character(len=32) :: root_kind = frontend_root_kind_none
        integer(int64) :: diagnostic_count = 0_int64
    end type frontend_v0_input_t

    public :: ffc_lower_frontend_v0
    public :: ffc_validate_lowered_frontend_v0

contains

    logical function ffc_lower_frontend_v0(input, body, message) result(lowered)
        type(frontend_v0_input_t), intent(in) :: input
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        lowered = .false.
        if (input%status /= frontend_status_accepted) then
            call set_message(message, 'frontend-v0 status must be accepted')
            return
        end if
        if (input%root_kind /= frontend_root_kind_program) then
            call set_message(message, 'frontend-v0 root kind must be program')
            return
        end if
        if (input%diagnostic_count /= 0_int64) then
            call set_message(message, 'frontend-v0 diagnostic count must be zero')
            return
        end if

        call mir_make_function_witness(body)
        body%instructions(1)%source_rule = 'frontend-v0/program'
        body%instructions(2)%source_rule = 'frontend-v0/program'
        lowered = .true.
    end function ffc_lower_frontend_v0

    logical function ffc_validate_lowered_frontend_v0(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%name /= 'main' .or. body%function%entry_block /= 0) then
            call set_message(message, 'lowered frontend-v0 function shape changed')
            return
        end if
        if (body%function%instruction_count /= 2) then
            call set_message(message, 'lowered frontend-v0 instruction shape changed')
            return
        end if
        if (body%instructions(1)%opcode /= opcode_add .or. &
            body%instructions(2)%opcode /= opcode_return) then
            call set_message(message, 'lowered frontend-v0 opcode shape changed')
            return
        end if
        if (body%instructions(1)%source_rule /= 'frontend-v0/program' .or. &
            body%instructions(2)%source_rule /= 'frontend-v0/program') then
            call set_message(message, 'lowered frontend-v0 source provenance changed')
            return
        end if
        valid = .true.
    end function ffc_validate_lowered_frontend_v0

    subroutine clear_message(message)
        character(len=:), allocatable, intent(out), optional :: message

        if (present(message)) then
            if (allocated(message)) deallocate (message)
        end if
    end subroutine clear_message

    subroutine set_message(message, text)
        character(len=:), allocatable, intent(out), optional :: message
        character(len=*), intent(in) :: text

        if (present(message)) message = text
    end subroutine set_message

end module ffc_lowering
