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

    type, public :: ffc_program_root_t
        character(len=128) :: name = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_program_root_t

    public :: ffc_lower_frontend_v0
    public :: ffc_frontend_v0_input_from_sx
    public :: ffc_validate_frontend_v0_input
    public :: ffc_lower_frontend_v0_from_sx
    public :: ffc_validate_lowered_frontend_v0
    public :: ffc_lower_program_root
    public :: ffc_program_root_from_sx
    public :: ffc_lower_program_root_from_sx
    public :: ffc_program_declaration_from_sx
    public :: ffc_lower_program_declaration_from_sx
    public :: ffc_program_unit_from_sx
    public :: ffc_lower_program_unit_from_sx
    public :: ffc_validate_program_root
    public :: ffc_validate_lowered_program_root

contains

    logical function ffc_lower_program_root(name, source_file, source_hash, start_byte, &
            end_byte, body, message) result(lowered)
        character(len=*), intent(in) :: name, source_file, source_hash
        integer(int64), intent(in) :: start_byte, end_byte
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_program_root_t) :: root

        root%name = name
        root%source_file = source_file
        root%source_hash = source_hash
        root%start_byte = start_byte
        root%end_byte = end_byte
        lowered = ffc_validate_program_root(root, message)
        if (.not. lowered) return

        call mir_make_function_witness(body)
        body%function%name = trim(root%name)
        body%instructions(1)%source_rule = 'program-root'
        body%instructions(2)%source_rule = 'program-root'
    end function ffc_lower_program_root

    logical function ffc_validate_program_root(root, message) result(valid)
        type(ffc_program_root_t), intent(in) :: root
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (len_trim(root%name) == 0) then
            call set_message(message, 'program root name must be non-empty')
            return
        end if
        if (len_trim(root%source_file) == 0) then
            call set_message(message, 'program root source file must be non-empty')
            return
        end if
        if (len_trim(root%source_hash) == 0) then
            call set_message(message, 'program root source hash must be non-empty')
            return
        end if
        if (root%start_byte < 0_int64 .or. root%end_byte < root%start_byte) then
            call set_message(message, 'program root span is invalid')
            return
        end if
        valid = .true.
    end function ffc_validate_program_root

    logical function ffc_program_root_from_sx(serialized, root, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_program_root_t), intent(out) :: root
        character(len=:), allocatable, intent(out), optional :: message

        character(len=256) :: token(32)
        character(len=128) :: name, source_hash
        character(len=256) :: source_file
        character(len=64) :: start_text, end_text
        integer :: token_count, position
        integer(int64) :: start_byte, end_byte
        logical :: source_span_wrapped

        root = ffc_program_root_t()
        call clear_message(message)
        parsed = tokenize_frontend_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, 'program-root', message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'name', name, message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, 'span', message)
        if (.not. parsed) return
        parsed = consume_source_span_wrapper(token, token_count, position, source_span_wrapped, &
            message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'file', source_file, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'start-byte', start_text, message)
        if (.not. parsed) return
        parsed = parse_program_root_integer(start_text, start_byte, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'end-byte', end_text, message)
        if (.not. parsed) return
        parsed = parse_program_root_integer(end_text, end_byte, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'source-hash', source_hash, message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (source_span_wrapped) then
            parsed = expect_frontend_token(token, token_count, position, ')', message)
            if (.not. parsed) return
        end if
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-program-root')
            parsed = .false.
            return
        end if

        root%name = name
        root%source_file = source_file
        root%source_hash = source_hash
        root%start_byte = start_byte
        root%end_byte = end_byte
        parsed = ffc_validate_program_root(root, message)
    end function ffc_program_root_from_sx

    logical function ffc_lower_program_root_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_program_root_t) :: root

        call clear_message(message)
        lowered = ffc_program_root_from_sx(serialized, root, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
            root%start_byte, root%end_byte, body, message)
    end function ffc_lower_program_root_from_sx

    logical function ffc_program_declaration_from_sx(serialized, root, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_program_root_t), intent(out) :: root
        character(len=:), allocatable, intent(out), optional :: message

        character(len=256) :: token(64)
        character(len=32) :: declaration_kind
        character(len=128) :: name, source_hash
        character(len=256) :: source_file
        character(len=64) :: start_text, end_text
        integer :: token_count, position
        integer(int64) :: start_byte, end_byte
        logical :: source_span_wrapped

        root = ffc_program_root_t()
        call clear_message(message)
        parsed = tokenize_frontend_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration')
            return
        end if
        parsed = expect_frontend_token(token, token_count, position, 'program-declaration', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration')
            return
        end if
        parsed = read_frontend_atom(token, token_count, position, 'declaration-kind', &
            declaration_kind, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-kind')
            return
        end if
        parsed = read_frontend_atom(token, token_count, position, 'name', name, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-name')
            return
        end if
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        parsed = expect_frontend_token(token, token_count, position, 'span', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        parsed = consume_source_span_wrapper(token, token_count, position, source_span_wrapped, &
            message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        parsed = read_frontend_atom(token, token_count, position, 'file', source_file, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-file')
            return
        end if
        parsed = read_frontend_atom(token, token_count, position, 'start-byte', start_text, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        parsed = parse_program_declaration_integer(start_text, start_byte, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'end-byte', end_text, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        parsed = parse_program_declaration_integer(end_text, end_byte, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'source-hash', source_hash, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-source-hash')
            return
        end if
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration-span')
            return
        end if
        if (source_span_wrapped) then
            parsed = expect_frontend_token(token, token_count, position, ')', message)
            if (.not. parsed) then
                call set_message(message, 'malformed-program-declaration-span')
                return
            end if
        end if
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-declaration')
            return
        end if
        if (position <= token_count) then
            call set_message(message, 'malformed-program-declaration')
            parsed = .false.
            return
        end if

        if (trim(declaration_kind) /= frontend_root_kind_program) then
            call set_message(message, 'invalid-program-declaration-kind')
            parsed = .false.
            return
        end if
        root%name = name
        root%source_file = source_file
        root%source_hash = source_hash
        root%start_byte = start_byte
        root%end_byte = end_byte
        parsed = ffc_validate_program_root(root, message)
    end function ffc_program_declaration_from_sx

    logical function ffc_lower_program_declaration_from_sx(serialized, body, message) &
            result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_program_root_t) :: root

        call clear_message(message)
        lowered = ffc_program_declaration_from_sx(serialized, root, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
            root%start_byte, root%end_byte, body, message)
    end function ffc_lower_program_declaration_from_sx

    logical function ffc_program_unit_from_sx(serialized, root, declaration_count, message) &
            result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_program_root_t), intent(out) :: root
        integer(int64), intent(out) :: declaration_count
        character(len=:), allocatable, intent(out), optional :: message

        character(len=256) :: token(256)
        character(len=256) :: root_sx
        character(len=256) :: declaration_sx
        character(len=64) :: count_text
        integer :: token_count, position, index
        integer(int64) :: parsed_count
        type(ffc_program_root_t) :: declaration_root

        root = ffc_program_root_t()
        declaration_count = 0_int64
        call clear_message(message)
        parsed = tokenize_frontend_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return
        parsed = read_frontend_expression(token, token_count, position, root_sx, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit-root')
            return
        end if
        parsed = parse_program_unit_root_field(root_sx, root, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'declaration-count', &
            count_text, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit')
            return
        end if
        parsed = parse_program_unit_count(count_text, parsed_count, message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit-declarations')
            return
        end if
        parsed = expect_frontend_token(token, token_count, position, 'declarations', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit-declarations')
            return
        end if

        index = 0
        do
            if (position > token_count) then
                call set_message(message, 'malformed-program-unit-declarations')
                parsed = .false.
                return
            end if
            if (trim(token(position)) == ')') exit
            index = index + 1
            parsed = read_frontend_expression(token, token_count, position, declaration_sx, &
                message)
            if (.not. parsed) then
                call set_message(message, 'malformed-program-unit-declaration')
                return
            end if
            parsed = ffc_program_declaration_from_sx(trim(declaration_sx), declaration_root, &
                message)
            if (.not. parsed) return
        end do
        position = position + 1
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit')
            return
        end if
        if (position <= token_count) then
            call set_message(message, 'malformed-program-unit')
            parsed = .false.
            return
        end if
        if (parsed_count /= int(index, int64)) then
            call set_message(message, 'program-unit-declaration-count-mismatch')
            parsed = .false.
            return
        end if
        declaration_count = parsed_count
    end function ffc_program_unit_from_sx

    logical function parse_program_unit_root_field(serialized, root, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_program_root_t), intent(out) :: root
        character(len=:), allocatable, intent(out), optional :: message

        character(len=256) :: token(32)
        character(len=256) :: root_sx
        integer :: token_count, position

        root = ffc_program_root_t()
        call clear_message(message)
        parsed = tokenize_frontend_sx(serialized, token, token_count, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-program-unit-root')
            return
        end if
        position = 1
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, 'root', message)
        if (.not. parsed) return
        parsed = read_frontend_expression(token, token_count, position, root_sx, message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-program-unit-root')
            parsed = .false.
            return
        end if
        parsed = ffc_program_root_from_sx(trim(root_sx), root, message)
    end function parse_program_unit_root_field

    logical function read_frontend_expression(token, token_count, position, expression, &
            message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        integer :: depth, start, index

        expression = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= '(') then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        start = position
        depth = 0
        do index = position, token_count
            if (trim(token(index)) == '(') then
                depth = depth + 1
            else if (trim(token(index)) == ')') then
                depth = depth - 1
            end if
            if (depth == 0) then
                expression = trim(token(start))
                do start = position + 1, index
                    if (len_trim(expression) + len_trim(token(start)) + 1 > len(expression)) then
                        call set_message(message, 'malformed-sx-record')
                        ok = .false.
                        return
                    end if
                    expression = trim(expression)//' '//trim(token(start))
                end do
                position = index + 1
                ok = .true.
                return
            end if
        end do
        call set_message(message, 'malformed-sx-record')
        ok = .false.
    end function read_frontend_expression

    logical function parse_program_unit_count(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        ok = parse_frontend_count(text, value, message)
        if (ok) return
        if (present(message)) then
            if (trim(message) == 'negative-diagnostic-count') then
                call set_message(message, 'negative-program-unit-declaration-count')
            else if (trim(message) == 'diagnostic-count-too-large') then
                call set_message(message, 'program-unit-declaration-count-too-large')
            else
                call set_message(message, 'malformed-program-unit-declaration-count')
            end if
        end if
    end function parse_program_unit_count

    logical function ffc_lower_program_unit_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_program_root_t) :: root
        integer(int64) :: declaration_count

        call clear_message(message)
        lowered = ffc_program_unit_from_sx(serialized, root, declaration_count, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(root%name, root%source_file, root%source_hash, &
            root%start_byte, root%end_byte, body, message)
    end function ffc_lower_program_unit_from_sx

    logical function ffc_validate_lowered_program_root(body, message) result(valid)
        type(mir_function_body_t), intent(in) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. mir_validate_function_body(body, message)) return
        if (body%function%instruction_count /= 2 .or. &
            body%instructions(1)%opcode /= opcode_add .or. &
            body%instructions(2)%opcode /= opcode_return) then
            call set_message(message, 'lowered program-root witness shape changed')
            return
        end if
        if (body%instructions(1)%source_rule /= 'program-root' .or. &
            body%instructions(2)%source_rule /= 'program-root') then
            call set_message(message, 'lowered program-root source provenance changed')
            return
        end if
        valid = .true.
    end function ffc_validate_lowered_program_root

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

    logical function ffc_frontend_v0_input_from_sx(serialized, input, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(frontend_v0_input_t), intent(out) :: input
        character(len=:), allocatable, intent(out), optional :: message

        character(len=64) :: token(32)
        character(len=8) :: status
        character(len=32) :: root_kind
        character(len=64) :: count_text
        integer :: token_count, position
        integer(int64) :: diagnostic_count

        input = frontend_v0_input_t()
        call clear_message(message)
        parsed = tokenize_frontend_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, 'frontend-result', message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'status', status, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'root-kind', root_kind, message)
        if (.not. parsed) return
        parsed = read_frontend_atom(token, token_count, position, 'diagnostic-count', &
            count_text, message)
        if (.not. parsed) return
        parsed = parse_frontend_count(count_text, diagnostic_count, message)
        if (.not. parsed) return
        parsed = expect_frontend_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-sx-record')
            parsed = .false.
            return
        end if

        input%status = status
        input%root_kind = root_kind
        input%diagnostic_count = diagnostic_count
        parsed = ffc_validate_frontend_v0_input(input, message)
    end function ffc_frontend_v0_input_from_sx

    logical function ffc_validate_frontend_v0_input(input, message) result(valid)
        type(frontend_v0_input_t), intent(in) :: input
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (input%status /= frontend_status_accepted .and. &
            input%status /= frontend_status_rejected) then
            call set_message(message, 'invalid-result-status')
            return
        end if
        if (input%root_kind /= frontend_root_kind_program .and. &
            input%root_kind /= frontend_root_kind_none) then
            call set_message(message, 'invalid-result-root-kind')
            return
        end if
        if (input%diagnostic_count < 0_int64) then
            call set_message(message, 'negative-diagnostic-count')
            return
        end if
        if (input%status == frontend_status_accepted) then
            if (input%root_kind /= frontend_root_kind_program .or. &
                input%diagnostic_count /= 0_int64) then
                call set_message(message, 'invalid-accepted-result')
                return
            end if
        else if (input%root_kind /= frontend_root_kind_none .or. &
                input%diagnostic_count == 0_int64) then
            call set_message(message, 'invalid-rejected-result')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_v0_input

    logical function ffc_lower_frontend_v0_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(frontend_v0_input_t) :: input

        call clear_message(message)
        lowered = ffc_frontend_v0_input_from_sx(serialized, input, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_v0(input, body, message)
    end function ffc_lower_frontend_v0_from_sx

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

    logical function tokenize_frontend_sx(input, token, token_count, message) result(ok)
        character(len=*), intent(in) :: input
        character(len=*), intent(out) :: token(:)
        integer, intent(out) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        integer :: position, start, input_length
        character :: current

        token = ''
        token_count = 0
        call clear_message(message)
        position = 1
        input_length = len_trim(input)
        do while (position <= input_length)
            current = input(position:position)
            if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                current == char(13)) then
                position = position + 1
            else if (current == '(' .or. current == ')') then
                if (.not. append_frontend_token(input(position:position), token, &
                    token_count, message)) return
                position = position + 1
            else
                start = position
                do while (position <= input_length)
                    current = input(position:position)
                    if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                        current == char(13) .or. current == '(' .or. current == ')') exit
                    position = position + 1
                end do
                if (.not. append_frontend_token(input(start:position - 1), token, &
                    token_count, message)) return
            end if
        end do
        ok = token_count > 0
        if (.not. ok) call set_message(message, 'malformed-sx-record')
    end function tokenize_frontend_sx

    logical function consume_source_span_wrapper(token, token_count, position, wrapped, &
            message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        logical, intent(out) :: wrapped
        character(len=:), allocatable, intent(out), optional :: message

        wrapped = .false.
        ok = .true.
        call clear_message(message)
        if (position > token_count) return
        if (trim(token(position)) /= '(') return
        if (position + 1 > token_count) return
        if (trim(token(position + 1)) /= 'source-span') return
        position = position + 2
        wrapped = .true.
    end function consume_source_span_wrapper

    logical function append_frontend_token(value, token, token_count, message) result(ok)
        character(len=*), intent(in) :: value
        character(len=*), intent(inout) :: token(:)
        integer, intent(inout) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        if (token_count == size(token)) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        if (len_trim(value) > len(token(1))) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        token_count = token_count + 1
        token(token_count) = value
        ok = .true.
    end function append_frontend_token

    logical function expect_frontend_token(token, token_count, position, expected, &
            message) result(ok)
        character(len=*), intent(in) :: token(:), expected
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=:), allocatable, intent(out), optional :: message

        if (position > token_count) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= expected) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        position = position + 1
        call clear_message(message)
        ok = .true.
    end function expect_frontend_token

    logical function read_frontend_atom(token, token_count, position, name, value, &
            message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        ok = expect_frontend_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_frontend_token(token, token_count, position, name, message)
        if (.not. ok) return
        if (position > token_count) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        if (len_trim(token(position)) > len(value)) then
            call set_message(message, 'malformed-sx-record')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = expect_frontend_token(token, token_count, position, ')', message)
    end function read_frontend_atom

    logical function parse_frontend_count(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        integer(int64) :: digit

        value = 0_int64
        call clear_message(message)
        if (len_trim(text) == 0) then
            call set_message(message, 'malformed-sx-count')
            ok = .false.
            return
        end if
        if (text(1:1) == '-') then
            call set_message(message, 'negative-diagnostic-count')
            ok = .false.
            return
        end if
        do index = 1, len_trim(text)
            if (text(index:index) < '0' .or. text(index:index) > '9') then
                call set_message(message, 'malformed-sx-count')
                ok = .false.
                return
            end if
            digit = int(iachar(text(index:index)) - iachar('0'), int64)
            if (value > (huge(value) - digit) / 10_int64) then
                call set_message(message, 'diagnostic-count-too-large')
                ok = .false.
                return
            end if
            value = value * 10_int64 + digit
        end do
        ok = .true.
    end function parse_frontend_count

    logical function parse_program_root_integer(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index, first_digit, sign
        integer(int64) :: digit

        value = 0_int64
        call clear_message(message)
        first_digit = 1
        sign = 1
        if (len_trim(text) > 0) then
            if (text(1:1) == '-') then
                sign = -1
                first_digit = 2
            else if (text(1:1) == '+') then
                first_digit = 2
            end if
        end if
        if (first_digit > len_trim(text)) then
            call set_message(message, 'malformed-program-root-span')
            ok = .false.
            return
        end if
        do index = first_digit, len_trim(text)
            if (text(index:index) < '0' .or. text(index:index) > '9') then
                call set_message(message, 'malformed-program-root-span')
                ok = .false.
                return
            end if
            digit = int(iachar(text(index:index)) - iachar('0'), int64)
            if (value > (huge(value) - digit) / 10_int64) then
                call set_message(message, 'malformed-program-root-span')
                ok = .false.
                return
            end if
            value = value * 10_int64 + digit
        end do
        if (sign < 0) value = -value
        ok = .true.
    end function parse_program_root_integer

    logical function parse_program_declaration_integer(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        ok = parse_program_root_integer(text, value, message)
        if (.not. ok) call set_message(message, 'malformed-program-declaration-span')
    end function parse_program_declaration_integer

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
