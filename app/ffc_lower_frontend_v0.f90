program ffc_lower_frontend_v0
    use, intrinsic :: iso_fortran_env, only: error_unit, int32, int64
    use ffc_lowering, only: ffc_lower_frontend_v0_from_sx
    use ffc_mir, only: mir_function_body_sx_size, mir_function_body_t, &
        mir_function_body_to_sx
    implicit none

    character(len=:), allocatable :: input_path, output_path, input, output
    character(len=:), allocatable :: message
    type(mir_function_body_t) :: body
    integer(int32) :: output_size
    logical :: ok

    call read_path_argument(1, input_path, ok)
    if (.not. ok) call fail('expected input and output paths')
    call read_path_argument(2, output_path, ok)
    if (.not. ok .or. command_argument_count() /= 2) then
        call fail('expected input and output paths')
    end if

    call read_input_file(input_path, input, ok)
    if (.not. ok) call fail('cannot read input file')

    ok = ffc_lower_frontend_v0_from_sx(input, body, message)
    if (.not. ok) then
        if (allocated(message)) then
            call fail('invalid frontend-v0 input: '//trim(message))
        else
            call fail('invalid frontend-v0 input')
        end if
    end if

    ok = mir_function_body_sx_size(body, output_size, message)
    if (.not. ok) then
        if (allocated(message)) then
            call fail('invalid mir-v0 output: '//trim(message))
        else
            call fail('invalid mir-v0 output')
        end if
    end if
    allocate (character(len=int(output_size)) :: output)
    call mir_function_body_to_sx(body, output, ok, message)
    if (.not. ok) then
        if (allocated(message)) then
            call fail('invalid mir-v0 output: '//trim(message))
        else
            call fail('invalid mir-v0 output')
        end if
    end if

    call write_output_file(output_path, output, ok)
    if (.not. ok) call fail('cannot write output file')

contains

    subroutine read_path_argument(number, value, valid)
        integer, intent(in) :: number
        character(len=:), allocatable, intent(out) :: value
        logical, intent(out) :: valid

        integer :: length, status

        length = 0
        call get_command_argument(number, length=length, status=status)
        if (status /= 0 .or. length == 0) then
            valid = .false.
            return
        end if
        allocate (character(len=length) :: value)
        call get_command_argument(number, value, status=status)
        if (status /= 0) then
            valid = .false.
            return
        end if
        valid = len_trim(value) > 0
    end subroutine read_path_argument

    subroutine read_input_file(path, contents, valid)
        character(len=*), intent(in) :: path
        character(len=:), allocatable, intent(out) :: contents
        logical, intent(out) :: valid

        integer(int64) :: file_size
        integer :: file_unit, io_status
        logical :: exists

        valid = .false.
        file_size = 0_int64
        inquire (file=trim(path), exist=exists)
        if (.not. exists) return
        open (newunit=file_unit, file=trim(path), status='old', action='read', &
            access='stream', form='unformatted', iostat=io_status)
        if (io_status /= 0) return
        inquire (unit=file_unit, size=file_size, iostat=io_status)
        if (io_status /= 0) then
            close (file_unit)
            return
        end if
        if (file_size > int(huge(0), int64)) then
            close (file_unit)
            return
        end if
        allocate (character(len=int(file_size)) :: contents)
        if (file_size > 0_int64) then
            read (file_unit, iostat=io_status) contents
        else
            io_status = 0
        end if
        valid = io_status == 0
        close (file_unit)
    end subroutine read_input_file

    subroutine write_output_file(path, contents, valid)
        character(len=*), intent(in) :: path, contents
        logical, intent(out) :: valid

        integer :: file_unit, io_status

        valid = .false.
        open (newunit=file_unit, file=trim(path), status='replace', action='write', &
            access='stream', form='unformatted', iostat=io_status)
        if (io_status /= 0) return
        write (file_unit, iostat=io_status) contents
        close (file_unit, iostat=io_status)
        valid = io_status == 0
    end subroutine write_output_file

    subroutine fail(reason)
        character(len=*), intent(in) :: reason

        write (error_unit, '(a)') 'ffc-lower-frontend-v0: '//trim(reason)
        error stop 1
    end subroutine fail

end program ffc_lower_frontend_v0
