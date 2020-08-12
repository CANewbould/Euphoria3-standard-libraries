--------------------------------------------------------------------------------
--	Library: get.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)(std)get.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.09.22
--Status: created; complete
--Changes:]]]
--* edited documentation
--* defined ##GET_NOTHING##
--* modified get_ch
--* defined Get2
--* defined get_value
--* redefined ##get##
--* redefined ##value##
--
------
--==Euphoria Standard library: get
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
-- library of the same name.
--* ##get##
--* ##value##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/get.e</eucode>
--
--*/
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--/*
--=== Includes
--*/
--------------------------------------------------------------------------------
include io.e as io  -- for seek, where
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant DIGITS = "0123456789"
constant ESCAPE_CHARS = "nt'\"\\r"
constant ESCAPED_CHARS = "\n\t'\"\\\r"
constant GET_IGNORE = -2    -- GET_NOTHING
constant HEX_DIGITS = DIGITS & "ABCDEF"
constant START_NUMERIC = DIGITS & "-+.#"
constant TRUE = (1 = 1)
constant white_space = " \t\n\r"
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant GET_EOF = -1
global constant GET_FAIL = 1
global constant GET_LONG_ANSWER = routine_id("Get2")
global constant GET_NOTHING = -2
global constant GET_SUCCESS = 0
global constant GET_SHORT_ANSWER = routine_id("Get")
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type char(integer x)
    return x >= -1 and x <= 255
end type
--------------------------------------------------------------------------------
type file_number(integer fn)	-- NB. global in EU3.1.3's io.e
    return fn > 2
end type
--------------------------------------------------------------------------------
type natural(integer x)
    return x >= 0
end type
--------------------------------------------------------------------------------
type plus_or_minus(integer x)
    return x = -1 or x = +1
end type
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
char ch  -- the current character
natural input_file input_file = 0	-- file to be read from (default to avoid warning)
object input_string -- string to be read from
integer leading_whitespace
natural string_next
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
procedure get_ch()
	-- set ch to the next character in the input stream (either string or file)
    if sequence(input_string) then
		if string_next <= length(input_string) then
		    ch = input_string[string_next]
		    string_next += 1
		else
		    ch = GET_EOF
		end if
    else    
		ch = getc(input_file)
		if ch = GET_EOF then
			string_next += 1
		end if
    end if
end procedure
--------------------------------------------------------------------------------
function escape_char(char c)
	-- return escape character
    natural i
    i = find(c, ESCAPE_CHARS)
    if i = 0 then
		return GET_FAIL
    else
		return ESCAPED_CHARS[i]
    end if
end function
--------------------------------------------------------------------------------
function get_qchar()
	-- get a single-quoted character
	-- ch is "live" at exit
    char c    
    get_ch()
    c = ch
    if ch = '\\' then
		get_ch()
		c = escape_char(ch)
		if c = GET_FAIL then
		    return {GET_FAIL, 0}
		end if
    elsif ch = '\'' then
		return {GET_FAIL, 0}
    end if
    get_ch()
    if ch != '\'' then
		return {GET_FAIL, 0}
    else
		get_ch()
		return {GET_SUCCESS, c}
    end if
end function
--------------------------------------------------------------------------------
procedure skip_blanks()
	-- skip white space
	-- ch is "live" at entry and exit
    while find(ch, white_space) do
		get_ch()
    end while
end procedure
--------------------------------------------------------------------------------
function get_number()
	-- read a number
	-- ch is "live" at entry and exit
    plus_or_minus sign, e_sign
    natural ndigits
    integer hex_digit
    atom mantissa, dec, e_mag
    sign = +1
    mantissa = 0
    ndigits = 0
    -- process sign
    if ch = '-' then
		sign = -1
		get_ch()
    elsif ch = '+' then
		get_ch()
    end if
    -- get mantissa
    if ch = '#' then
		-- process hex integer and return
		get_ch()
		while TRUE do
		    hex_digit = find(ch, HEX_DIGITS)-1
		    if hex_digit >= 0 then
				ndigits += 1
				mantissa = mantissa * 16 + hex_digit
				get_ch()
		    else
				if ndigits > 0 then
				    return {GET_SUCCESS, sign * mantissa}
				else
				    return {GET_FAIL, 0}
				end if
		    end if
		end while       
    end if    
    -- decimal integer or floating point
    while ch >= '0' and ch <= '9' do
		ndigits += 1
		mantissa = mantissa * 10 + (ch - '0')
		get_ch()
    end while    
    if ch = '.' then
		-- get fraction
		get_ch()
		dec = 10
		while ch >= '0' and ch <= '9' do
		    ndigits += 1
		    mantissa += (ch - '0') / dec
		    dec *= 10
		    get_ch()
		end while
    end if    
    if ndigits = 0 then
		return {GET_FAIL, 0}
    end if
    mantissa = sign * mantissa    
    if ch = 'e' or ch = 'E' then
		-- get exponent sign
		e_sign = +1
		e_mag = 0
		get_ch()
		if ch = '-' then
		    e_sign = -1
		    get_ch()
		elsif ch = '+' then
		    get_ch()
		end if
		-- get exponent magnitude 
		if ch >= '0' and ch <= '9' then
		    e_mag = ch - '0'
		    get_ch()
		    while ch >= '0' and ch <= '9' do
				e_mag = e_mag * 10 + ch - '0'
				get_ch()                          
		    end while
		else
		    return {GET_FAIL, 0} -- no exponent
		end if
		e_mag *= e_sign 
		if e_mag > 308 then
		    -- rare case: avoid power() overflow
		    mantissa *= power(10, 308)
		    if e_mag > 1000 then
				e_mag = 1000 
		    end if
		    for i = 1 to e_mag - 308 do
				mantissa *= 10
		    end for
		else
		    mantissa *= power(10, e_mag)
		end if
    end if    
    return {GET_SUCCESS, mantissa}
end function
--------------------------------------------------------------------------------
function get_string()
	-- get a double-quoted character string
	-- ch is "live" at exit
    sequence text
    text = ""
    while TRUE do
		get_ch()
		if ch = GET_EOF or ch = '\n' then
		    return {GET_FAIL, 0}
		elsif ch = '"' then
		    get_ch()
		    return {GET_SUCCESS, text}
		elsif ch = '\\' then
		    get_ch()
		    ch = escape_char(ch)
		    if ch = GET_FAIL then
				return {GET_FAIL, 0}
		    end if
		end if
		text = text & ch
    end while
end function
--------------------------------------------------------------------------------
function Get()
	-- read a Euphoria data object as a string of characters
	-- and return {error_flag, value}
	-- Note: ch is "live" at entry and exit of this routine
    sequence s, e
    skip_blanks()
    if find(ch, START_NUMERIC) then
		return get_number()
    elsif ch = '{' then
		-- process a sequence
		s = {}
		get_ch()
		skip_blanks()
		if ch = '}' then
		    get_ch()
		    return {GET_SUCCESS, s} -- empty sequence
		end if	
		while TRUE do
		    e = Get() -- read next element
		    if e[1] != GET_SUCCESS then
				return e
		    end if
		    s = append(s, e[2])
		    skip_blanks()
		    if ch = '}' then
				get_ch()
				return {GET_SUCCESS, s}
		    elsif ch != ',' then
				return {GET_FAIL, 0}
		    end if
		    get_ch() -- skip comma
		end while
    elsif ch = '\"' then
		return get_string()
    elsif ch = '\'' then
		return get_qchar()
    elsif ch = -1 then
		return {GET_EOF, 0}
    else
		return {GET_FAIL, 0}
    end if
end function
--------------------------------------------------------------------------------
function Get2()
-- read a Euphoria data object as a string of characters
-- and return {error_flag, value, total number of characters, leading whitespace}
-- Note: ch is "live" at entry and exit of this routine.
-- Uses the regular Get() to read sequence elements.
    sequence e
	integer e1
    natural offset
	sequence s
	-- init
	offset = string_next-1
	get_ch()
	while find(ch, white_space) do
		get_ch()
	end while
	if ch = -1 then -- string is made of whitespace only
		return {GET_EOF, 0, string_next-1-offset ,string_next-1}
	end if
	leading_whitespace = string_next-2-offset -- index of the last whitespace: string_next points past the first non whitespace
	while 1 do
		if find(ch, START_NUMERIC) then
			e = get_number()
			if e[1] != GET_IGNORE then -- either a number or something illegal was read, so exit: the other goto
				return e & {string_next-1-offset-(ch!=-1), leading_whitespace}
			end if          -- else go read next item, starting at top of loop
			get_ch()
			if ch=-1 then
				return {GET_NOTHING, 0, string_next-1-offset-(ch!=-1), leading_whitespace} -- empty sequence
			end if
		elsif ch = '{' then
			-- process a sequence
			s = {}
			get_ch()
			skip_blanks()
			if ch = '}' then -- empty sequence
				get_ch()
				return {GET_SUCCESS, s, string_next-1-offset-(ch!=-1), leading_whitespace} -- empty sequence
			end if
			while TRUE do -- read: comment(s), element, comment(s), comma and so on till it terminates or errors out
				while 1 do -- read zero or more comments and an element
					e = Get() -- read next element, using standard function
					e1 = e[1]
					if e1 = GET_SUCCESS then
						s = append(s, e[2])
						exit  -- element read and added to result
					elsif e1 != GET_IGNORE then
						return e & {string_next-1-offset-(ch!=-1), leading_whitespace}
					-- else it was a comment, keep going
					elsif ch='}' then
						get_ch()
						return {GET_SUCCESS, s, string_next-1-offset-(ch!=-1),leading_whitespace} -- empty sequence
					end if
				end while
				while 1 do -- now read zero or more post element comments
					skip_blanks()
					if ch = '}' then
						get_ch()
					return {GET_SUCCESS, s, string_next-1-offset-(ch!=-1), leading_whitespace}
					elsif ch!='-' then
						exit
					else -- comment starts after item and before comma
						e = get_number() -- reads anything starting with '-'
						if e[1] != GET_IGNORE then  -- it was not a comment, this is illegal
							return {GET_FAIL, 0, string_next-1-offset-(ch!=-1),leading_whitespace}
						end if
						-- read next comment or , or }
					end if
			end while
				if ch != ',' then
				return {GET_FAIL, 0, string_next-1-offset-(ch!=-1), leading_whitespace}
				end if
			get_ch() -- skip comma
			end while
		elsif ch = '\"' then
			e = get_string()
			return e & {string_next-1-offset-(ch!=-1), leading_whitespace}
		elsif ch = '\'' then
			e = get_qchar()
			return e & {string_next-1-offset-(ch!=-1), leading_whitespace}
		else
			return {GET_FAIL, 0, string_next-1-offset-(ch!=-1), leading_whitespace}
		end if
	end while
end function
--------------------------------------------------------------------------------
function get_value(object target, integer start_point, integer answer_type)
	if answer_type != GET_SHORT_ANSWER and answer_type != GET_LONG_ANSWER then
		printf(1, "Invalid type of answer, please only use %s (the default) or %s.", {"GET_SHORT_ANSWER", "GET_LONG_ANSWER"})
	end if
	if atom(target) then -- get()
		input_file = target
		if start_point then
			if io:seek(target, io:where(target)+start_point) then
				puts(1, "Initial seek() for get() failed!")
			end if
		end if
		string_next = 1
		input_string = 0
	else
		input_string = target
		string_next = start_point
	end if
	if answer_type = GET_SHORT_ANSWER then
		get_ch()
	end if
	return call_func(answer_type, {})
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function get(integer file)	-- reads the string representation of a Euphoria object from a file; converts to the value of the object
	return get_value(file, 0, GET_SHORT_ANSWER)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- # ##file##: the handle to an open file from which to read
--
-- Returns:
--
-- A **sequence**, of length 2 (##GET_SHORT_ANSWER##) or 4 (##GET_LONG_ANSWER##), made of
--
-- * an integer, the return status. This is any of:
-- ** ##GET_SUCCESS## ~-- object was read successfully
-- ** ##GET_EOF## ~--     end of file before object was read completely
-- ** ##GET_FAIL## ~--    object is not syntactically correct
-- ** ##GET_NOTHING## ~-- nothing was read, even a partial object string, before end of input
-- * an object, the value that was read. This is valid only if return status is ##GET_SUCCESS##.
-- * an integer, the number of characters read. On an error, this is the point at which the
--   error was detected.
-- * an integer, the amount of initial whitespace read before the first active character was found
--
-- Notes:
--
-- This routine is a simplified version of the OE4 routines, insofar as just the
-- short-answer version is provided.
--*/
--------------------------------------------------------------------------------
global function value(sequence string)	-- reads the representation of a Euphoria object from a sequence of characters and converts to the value of the object
	return get_value(string, 1, GET_SHORT_ANSWER)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- # ##string##: the sequence from which to read text
--
-- Returns:
-- A **sequence**, of length 2 (GET_SHORT_ANSWER) or 4 (GET_LONG_ANSWER), made of
--
-- * an integer, the return status. This is any of
-- ** ##GET_SUCCESS## ~-- object was read successfully
-- ** ##GET_EOF## ~--     end of file before object was read completely
-- ** ##GET_FAIL## ~--    object is not syntactically correct
-- ** ##GET_NOTHING## ~-- nothing was read, even a partial object string, before end of input
-- * an object, the value that was read. This is valid only if return status is ##GET_SUCCESS##.
-- * an integer, the number of characters read. On an error, this is the point at which the
--   error was detected.
-- * an integer, the amount of initial whitespace read before the first active character was found
--
-- Notes:
--
-- This routine is a simplified version of the OE4 routines, insofar as just the
-- short-answer version is provided.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.16
--Status: created; incomplete
--Changes:]]]
--* defined ##get##
--------------------------------------------------------------------------------
