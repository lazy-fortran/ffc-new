program test_dispatch_l2_mir_trace
    use ffc_lowering, only: ffc_lower_frontend_v0_from_sx
    use ffc_mir, only: mir_function_body_t, mir_function_body_to_sx, &
        mir_validate_function_body
    implicit none

    character(len=*), parameter :: accepted = &
        '(frontend-result (status accepted) (root-kind program) '// &
        '(diagnostic-count 0))'
    character(len=*), parameter :: rejected = &
        '(frontend-result (status rejected) (root-kind none) '// &
        '(diagnostic-count 1))'
    character(len=*), parameter :: expected = &
        '(mir-function (name main) (entry-block 0) (instruction-count 2) '// &
        '(instructions (instruction (id 0) (opcode add) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) '// &
        '(type i32))) (instruction (id 1) (opcode return) '// &
        '(source-rule frontend-v0/program) (result (id 1) (kind integer) '// &
        '(type i32)))))'
    character(len=*), parameter :: expected_hash = &
        '24662352aa66af913bfff52df466a76cf54a55445f9315b4b10b928c63a80f7d'
    character(len=*), parameter :: payload_path = '/tmp/ffc-l2-mir-trace.sx'
    character(len=*), parameter :: digest_path = '/tmp/ffc-l2-mir-trace.sha256'

    type(mir_function_body_t) :: body
    character(len=512) :: serialized
    character(len=:), allocatable :: message
    logical :: ok

    call assert_true(ffc_lower_frontend_v0_from_sx(accepted, body, message), &
        'accepted frontend-v0 fixture was rejected')
    call assert_true(mir_validate_function_body(body, message), &
        'accepted fixture did not produce valid MIR-v0')
    call mir_function_body_to_sx(body, serialized, ok, message)
    call assert_true(ok, 'accepted fixture was not serialized')
    call assert_equal(trim(serialized), expected, &
        'canonical MIR-v0 SX changed')
    call assert_hash(serialized)

    call assert_false(ffc_lower_frontend_v0_from_sx(rejected, body, message), &
        'rejected frontend-v0 fixture was accepted')
    call assert_equal(message, 'frontend-v0 status must be accepted', &
        'rejected frontend-v0 diagnostic changed')
    call assert_false(allocated(body%instructions), &
        'rejected frontend-v0 fixture left an output artifact')

    write (*, '(a)') 'L2 frontend-v0 to MIR-v0 trace: ok'

contains

    subroutine assert_hash(value)
        character(len=*), intent(in) :: value

        character(len=128) :: digest
        integer :: file_unit, io_status, exit_status
        logical :: exists

        call remove_file(payload_path)
        call remove_file(digest_path)
        open (newunit=file_unit, file=payload_path, status='new', action='write', &
            access='stream', form='unformatted', iostat=io_status)
        call assert_true(io_status == 0, 'could not create MIR-v0 hash input')
        write (file_unit, iostat=io_status) value(:len_trim(value))//achar(10)
        close (file_unit, iostat=io_status)
        call assert_true(io_status == 0, 'could not write MIR-v0 hash input')

        call execute_command_line('sha256sum '//payload_path//' > '//digest_path, &
            wait=.true., exitstat=exit_status)
        call assert_true(exit_status == 0, 'sha256sum failed for MIR-v0 output')
        open (newunit=file_unit, file=digest_path, status='old', action='read', &
            iostat=io_status)
        call assert_true(io_status == 0, 'could not read MIR-v0 output hash')
        read (file_unit, '(a)', iostat=io_status) digest
        close (file_unit, status='delete', iostat=exit_status)
        call assert_true(io_status == 0, 'could not read MIR-v0 output hash')
        call assert_equal(digest(:len(expected_hash)), expected_hash, &
            'canonical MIR-v0 SX hash changed')

        inquire (file=payload_path, exist=exists)
        if (exists) then
            open (newunit=file_unit, file=payload_path, status='old', iostat=io_status)
            close (file_unit, status='delete', iostat=exit_status)
        end if
    end subroutine assert_hash

    subroutine remove_file(path)
        character(len=*), intent(in) :: path

        integer :: file_unit, io_status
        logical :: exists

        inquire (file=path, exist=exists)
        if (.not. exists) return
        open (newunit=file_unit, file=path, status='old', iostat=io_status)
        if (io_status == 0) close (file_unit, status='delete', iostat=io_status)
    end subroutine remove_file

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

    subroutine assert_equal(actual, expected_value, description)
        character(len=*), intent(in) :: actual, expected_value, description

        call assert_true(trim(actual) == trim(expected_value), description)
    end subroutine assert_equal

end program test_dispatch_l2_mir_trace
