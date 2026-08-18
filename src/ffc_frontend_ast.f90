module ffc_frontend_ast
    use, intrinsic :: iso_fortran_env, only: int64
    use ffc_lowering, only: ffc_lower_program_root, ffc_program_declaration_from_sx, &
        ffc_program_root_from_sx, ffc_program_root_t, ffc_validate_program_root
    use ffc_mir, only: mir_function_body_t, mir_make_function_witness, &
        mir_type_spec_name, mir_type_spec_value_kind
    implicit none
    private

    integer, parameter :: frontend_ast_token_capacity = 256
    integer, parameter :: frontend_ast_token_length = 256
    integer, parameter :: frontend_ast_expression_length = 4096

    type, public :: ffc_frontend_ast_v0_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        integer(int64) :: declaration_count = 0_int64
        logical :: declaration_present = .false.
    end type ffc_frontend_ast_v0_t

    type, public :: ffc_frontend_variable_declaration_v1_t
        character(len=128) :: type_spec = ''
        character(len=128) :: name = ''
        character(len=256) :: source_file = ''
        character(len=128) :: source_hash = ''
        integer(int64) :: start_byte = 0_int64
        integer(int64) :: end_byte = 0_int64
    end type ffc_frontend_variable_declaration_v1_t

    type, public :: ffc_frontend_ast_v1_t
        type(ffc_program_root_t) :: root
        type(ffc_program_root_t) :: declaration
        type(ffc_frontend_variable_declaration_v1_t) :: variable
        integer(int64) :: declaration_count = 0_int64
        integer(int64) :: variable_count = 0_int64
    end type ffc_frontend_ast_v1_t

    public :: ffc_frontend_ast_v0_from_sx
    public :: ffc_lower_frontend_ast_v0
    public :: ffc_lower_frontend_ast_v0_from_sx
    public :: ffc_validate_frontend_ast_v0
    public :: ffc_frontend_ast_v1_from_sx
    public :: ffc_lower_frontend_ast_v1
    public :: ffc_lower_frontend_ast_v1_from_sx
    public :: ffc_validate_frontend_ast_v1

contains

    logical function ffc_frontend_ast_v1_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v1_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position

        ast = ffc_frontend_ast_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-root')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%declaration_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
            message)
        if (.not. parsed) return
        parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-declaration')
            return
        end if
        parsed = read_named_atom(token, token_count, position, 'variable-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, ast%variable_count, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'variable', expression, message)
        if (.not. parsed) return
        parsed = parse_variable_declaration_v1(trim(expression), ast%variable, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1')
            parsed = .false.
            return
        end if
        parsed = ffc_validate_frontend_ast_v1(ast, message)
    end function ffc_frontend_ast_v1_from_sx

    logical function ffc_validate_frontend_ast_v1(ast, message) result(valid)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count /= 1_int64 .or. ast%variable_count /= 1_int64) then
            call set_message(message, 'invalid-frontend-ast-v1-cardinality')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%name) /= trim(ast%declaration%name)) then
            call set_message(message, 'frontend-ast-v1-declaration-name-mismatch')
            return
        end if
        if (.not. ffc_validate_variable_declaration_v1(ast%variable, message)) return
        if (trim(ast%root%source_file) /= trim(ast%variable%source_file) .or. &
            trim(ast%root%source_hash) /= trim(ast%variable%source_hash)) then
            call set_message(message, 'frontend-ast-v1-invalid-provenance')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v1

    logical function ffc_lower_frontend_ast_v1(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v1_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        integer :: kind
        character(len=32) :: type_name

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v1(ast, message)
        if (.not. lowered) return
        kind = mir_type_spec_value_kind(ast%variable%type_spec)
        type_name = mir_type_spec_name(ast%variable%type_spec)
        call mir_make_function_witness(body)
        body%function%name = trim(ast%root%name)
        body%instructions(1)%result%kind = kind
        body%instructions(1)%result%type_name = trim(type_name)
        body%instructions(2)%result = body%instructions(1)%result
        body%instructions(1)%source_rule = 'frontend-ast-v1/program'
        body%instructions(2)%source_rule = 'frontend-ast-v1/program'
    end function ffc_lower_frontend_ast_v1

    logical function ffc_lower_frontend_ast_v1_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v1_t) :: ast

        call clear_message(message)
        lowered = ffc_frontend_ast_v1_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v1(ast, body, message)
    end function ffc_lower_frontend_ast_v1_from_sx

    logical function ffc_frontend_ast_v0_from_sx(serialized, ast, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_ast_v0_t), intent(out) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=64) :: count_text
        integer :: token_count, position
        integer(int64) :: declaration_count

        ast = ffc_frontend_ast_v0_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return

        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'program-unit', message)
        if (.not. parsed) return

        parsed = read_named_expression(token, token_count, position, 'root', expression, message)
        if (.not. parsed) return
        parsed = ffc_program_root_from_sx(trim(expression), ast%root, message)
        if (.not. parsed) return

        parsed = read_named_atom(token, token_count, position, 'declaration-count', count_text, &
            message)
        if (.not. parsed) return
        parsed = parse_count(count_text, declaration_count, message)
        if (.not. parsed) return
        ast%declaration_count = declaration_count

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if
        if (trim(token(position)) == '(') then
            parsed = read_named_expression(token, token_count, position, 'declaration', expression, &
                message)
            if (.not. parsed) return
            parsed = ffc_program_declaration_from_sx(trim(expression), ast%declaration, message)
            if (.not. parsed) return
            ast%declaration_present = .true.
        else if (trim(token(position)) /= ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            parsed = .false.
            return
        end if

        parsed = ffc_validate_frontend_ast_v0(ast, message)
    end function ffc_frontend_ast_v0_from_sx

    logical function ffc_validate_frontend_ast_v0(ast, message) result(valid)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (.not. ffc_validate_program_root(ast%root, message)) return
        if (ast%declaration_count < 0_int64) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            return
        end if
        if (ast%declaration_count == 0_int64) then
            if (ast%declaration_present) then
                call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
                return
            end if
            valid = .true.
            return
        end if
        if (ast%declaration_count /= 1_int64 .or. .not. ast%declaration_present) then
            call set_message(message, 'frontend-ast-v0-declaration-count-mismatch')
            return
        end if
        if (.not. ffc_validate_program_root(ast%declaration, message)) return
        if (trim(ast%root%source_file) /= trim(ast%declaration%source_file)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (trim(ast%root%source_hash) /= trim(ast%declaration%source_hash)) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%start_byte < ast%root%start_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        if (ast%declaration%end_byte > ast%root%end_byte) then
            call set_message(message, 'frontend-ast-v0-invalid-provenance')
            return
        end if
        valid = .true.
    end function ffc_validate_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0(ast, body, message) result(lowered)
        type(ffc_frontend_ast_v0_t), intent(in) :: ast
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        lowered = ffc_validate_frontend_ast_v0(ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_program_root(ast%root%name, ast%root%source_file, &
            ast%root%source_hash, ast%root%start_byte, ast%root%end_byte, body, message)
    end function ffc_lower_frontend_ast_v0

    logical function ffc_lower_frontend_ast_v0_from_sx(serialized, body, message) result(lowered)
        character(len=*), intent(in) :: serialized
        type(mir_function_body_t), intent(out) :: body
        character(len=:), allocatable, intent(out), optional :: message

        type(ffc_frontend_ast_v0_t) :: ast

        call clear_message(message)
        lowered = ffc_frontend_ast_v0_from_sx(serialized, ast, message)
        if (.not. lowered) return
        lowered = ffc_lower_frontend_ast_v0(ast, body, message)
    end function ffc_lower_frontend_ast_v0_from_sx

    logical function tokenize_frontend_ast_sx(input, token, token_count, message) result(ok)
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
                if (.not. append_token(input(position:position), token, token_count, message)) &
                    return
                position = position + 1
            else
                start = position
                do while (position <= input_length)
                    current = input(position:position)
                    if (current == ' ' .or. current == char(9) .or. current == char(10) .or. &
                        current == char(13) .or. current == '(' .or. current == ')') exit
                    position = position + 1
                end do
                if (.not. append_token(input(start:position - 1), token, token_count, message)) &
                    return
            end if
        end do
        ok = token_count > 0
        if (.not. ok) call set_message(message, 'malformed-frontend-ast-v0')
    end function tokenize_frontend_ast_sx

    logical function parse_variable_declaration_v1(serialized, variable, message) result(parsed)
        character(len=*), intent(in) :: serialized
        type(ffc_frontend_variable_declaration_v1_t), intent(out) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=frontend_ast_expression_length) :: expression
        character(len=128) :: type_spec, name
        integer :: token_count, position

        variable = ffc_frontend_variable_declaration_v1_t()
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'variable-declaration', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'type-spec', type_spec, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'name', name, message)
        if (.not. parsed) return
        parsed = read_named_expression(token, token_count, position, 'span', expression, message)
        if (.not. parsed) return
        parsed = parse_source_span_v1(trim(expression), variable%source_file, &
            variable%start_byte, variable%end_byte, variable%source_hash, message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            return
        end if
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) then
            call set_message(message, 'malformed-frontend-ast-v1-variable-close')
            return
        end if
        variable%type_spec = type_spec
        variable%name = name
        parsed = ffc_validate_variable_declaration_v1(variable, message)
    end function parse_variable_declaration_v1

    logical function parse_source_span_v1(serialized, source_file, start_byte, end_byte, &
            source_hash, message) result(parsed)
        character(len=*), intent(in) :: serialized
        character(len=*), intent(out) :: source_file, source_hash
        integer(int64), intent(out) :: start_byte, end_byte
        character(len=:), allocatable, intent(out), optional :: message

        character(len=frontend_ast_token_length) :: token(frontend_ast_token_capacity)
        character(len=64) :: start_text, end_text
        integer :: token_count, position

        source_file = ''
        source_hash = ''
        start_byte = 0_int64
        end_byte = 0_int64
        call clear_message(message)
        parsed = tokenize_frontend_ast_sx(serialized, token, token_count, message)
        if (.not. parsed) return
        position = 1
        parsed = expect_token(token, token_count, position, '(', message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, 'source-span', message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'file', source_file, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'start-byte', start_text, message)
        if (.not. parsed) return
        parsed = parse_count(start_text, start_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'end-byte', end_text, message)
        if (.not. parsed) return
        parsed = parse_count(end_text, end_byte, message)
        if (.not. parsed) return
        parsed = read_named_atom(token, token_count, position, 'source-hash', source_hash, message)
        if (.not. parsed) return
        parsed = expect_token(token, token_count, position, ')', message)
        if (.not. parsed) return
        if (position <= token_count) then
            call set_message(message, 'malformed-frontend-ast-v1-span')
            parsed = .false.
        end if
    end function parse_source_span_v1

    logical function ffc_validate_variable_declaration_v1(variable, message) result(valid)
        type(ffc_frontend_variable_declaration_v1_t), intent(in) :: variable
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        valid = .false.
        if (len_trim(variable%type_spec) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-type-spec')
            return
        end if
        if (mir_type_spec_value_kind(variable%type_spec) == 0) then
            call set_message(message, 'unsupported-frontend-ast-v1-type-spec')
            return
        end if
        if (len_trim(variable%name) == 0 .or. len_trim(variable%source_file) == 0 .or. &
            len_trim(variable%source_hash) == 0) then
            call set_message(message, 'invalid-frontend-ast-v1-variable')
            return
        end if
        if (variable%start_byte < 0_int64 .or. variable%end_byte < variable%start_byte) then
            call set_message(message, 'invalid-frontend-ast-v1-variable-span')
            return
        end if
        valid = .true.
    end function ffc_validate_variable_declaration_v1

    logical function append_token(value, token, token_count, message) result(ok)
        character(len=*), intent(in) :: value
        character(len=*), intent(inout) :: token(:)
        integer, intent(inout) :: token_count
        character(len=:), allocatable, intent(out), optional :: message

        call clear_message(message)
        if (token_count == size(token)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(value) > len(token(1))) then
            call set_message(message, 'malformed-frontend-ast-v0')
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
        character(len=:), allocatable, intent(out), optional :: message

        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= expected) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        position = position + 1
        call clear_message(message)
        ok = .true.
    end function expect_token

    logical function read_named_atom(token, token_count, position, name, value, message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        value = ''
        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) == '(' .or. trim(token(position)) == ')') then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (len_trim(token(position)) > len(value)) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        value = token(position)
        position = position + 1
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_atom

    logical function read_named_expression(token, token_count, position, name, expression, &
            message) result(ok)
        character(len=*), intent(in) :: token(:), name
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        ok = expect_token(token, token_count, position, '(', message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, name, message)
        if (.not. ok) return
        ok = read_expression(token, token_count, position, expression, message)
        if (.not. ok) return
        ok = expect_token(token, token_count, position, ')', message)
    end function read_named_expression

    logical function read_expression(token, token_count, position, expression, message) result(ok)
        character(len=*), intent(in) :: token(:)
        integer, intent(in) :: token_count
        integer, intent(inout) :: position
        character(len=*), intent(out) :: expression
        character(len=:), allocatable, intent(out), optional :: message

        integer :: depth, index, start

        expression = ''
        call clear_message(message)
        if (position > token_count) then
            call set_message(message, 'malformed-frontend-ast-v0')
            ok = .false.
            return
        end if
        if (trim(token(position)) /= '(') then
            call set_message(message, 'malformed-frontend-ast-v0')
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
                        call set_message(message, 'malformed-frontend-ast-v0')
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
        call set_message(message, 'malformed-frontend-ast-v0')
        ok = .false.
    end function read_expression

    logical function parse_count(text, value, message) result(ok)
        character(len=*), intent(in) :: text
        integer(int64), intent(out) :: value
        character(len=:), allocatable, intent(out), optional :: message

        integer :: index
        integer(int64) :: digit

        value = 0_int64
        call clear_message(message)
        if (len_trim(text) == 0) then
            call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
            ok = .false.
            return
        end if
        do index = 1, len_trim(text)
            if (text(index:index) < '0' .or. text(index:index) > '9') then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            digit = int(iachar(text(index:index)) - iachar('0'), int64)
            if (value > (huge(value) - digit) / 10_int64) then
                call set_message(message, 'invalid-frontend-ast-v0-declaration-count')
                ok = .false.
                return
            end if
            value = value * 10_int64 + digit
        end do
        ok = .true.
    end function parse_count

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

end module ffc_frontend_ast
