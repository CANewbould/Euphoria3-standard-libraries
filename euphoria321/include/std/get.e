--------------------------------------------------------------------------------
--	Library: get.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)get.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.12.16
--Status: created; complete
--Changes:]]]
--* copied from the 3.1.2 version
--
------
--==Euphoria Standard library: io
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
-- library of the same name.
--* ##get##
--* ##value##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/get.e</eucode>
--
--*/
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--
--=== Includes
--
--------------------------------------------------------------------------------
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
constant HEX_DIGITS = DIGITS & "ABCDEF"
constant START_NUMERIC = DIGITS & "-+.#"
constant TRUE = (1 = 1)
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant GET_EOF = -1
global constant GET_FAIL = 1
global constant GET_SUCCESS = 0
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
    while find(ch, " \t\n\r") do
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
--	Shared with other modules
--------------------------------------------------------------------------------
global function get(file_number file)	-- reads the string representation of a Euphoria object from a file; converts to the value of the object
    input_file = file
    input_string = 0
    get_ch()
    return Get()
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##file##: the handle to a file
--
-- Returns:
--
-- a **sequence** containing
--* the error_status
--* the value
--
-- Notes:
--
-- Error status codes are:
--* GET_SUCCESS - object was read successfully
--* GET_EOF     - end of file before object was read completely
--* GET_FAIL    - object is not syntactically correct
--* GET_NOTHING - nothing was read, even a partial object string, before end of input
--
-- ##get## can read arbitrarily complicated Euphoria objects.
-- You could have a long sequence of values in braces and separated by commas
-- and comments, e.g. {23, {49, 57}, 0.5, -1, 99, 'A', "john"}.
-- A single call to get() will read in this entire sequence and return its value
-- as a result, as well as complementary information.
--
-- Each call to ##get## picks up where the previous call left off.
-- For instance, a series of 5 calls to ##get## would be needed to read in the
-- this sequence: ## `99 5.2 {1, 2, 3}.
--
-- On the sixth and any subsequent call to ##get## you would see a GET_EOF
-- status. If you had something like:
--
-- {1, 2, xxx}
--
-- in the input stream you would see a GET_FAIL error status because xxx is not
-- a Euphoria object.
--
-- After seeing ##something\nBut no value##the input stream stops right there, you  
-- will receive a status code of ##GET_NOTHING##,
-- because nothing but whitespace or comments was read. If you had opted for a short answer,
-- you would get ##GET_EOF## instead.
--
-- Multiple "top-level" objects in the input stream must be
-- separated from each other with one or more "whitespace"
-- characters (blank, tab, \r, or \n). At the very least, a top
-- level number must be followed by a white space from the following object.
-- Whitespace is not necessary //within// a top-level object. Comments, terminated by either
-- '\n' or '\r', are allowed anywhere inside sequences, and ignored if at the top level.
-- A call to ##get## will read one entire top-level object, plus possibly one additional
-- (whitespace) character, after a top level number, even though the next object may have an
-- identifiable starting point.
--
-- The combination of ##print## and ##get## can be used to save a Euphoria
-- object to disk and later read it back.
-- This technique could be used to implement a database as one or more large
-- Euphoria sequences stored in disk files.
-- The sequences could be read into memory, updated and then written back to
-- disk after each series of transactions is complete.
-- Remember to write out a whitespace character (using ##puts##) after each call
-- to print(), at least when a top level number was just printed.
--
-- The value returned is not meaningful unless you have a GET_SUCCESS status.
--*/
--------------------------------------------------------------------------------
global function value(sequence string)	-- reads the representation of a Euphoria object from a sequence of characters and converts to the value of the object
    input_string = string
    string_next = 1
    get_ch()
    return Get()
end function
--------------------------------------------------------------------------------
--/*
--Parameter:
--# ##string##: the string representation of a Euphoria object
--
-- Returns:
-- a **sequence** containing
--* the error_status
--* the value
--
-- The error_status can be one of:
--* GET_SUCCESS - a valid object representation was found
--* GET_EOF     - end of string reached too soon
--* GET_FAIL    - syntax is wrong
--* GET_NOTHING - end of string reached without any value being even partially read
--
-- Notes:
--
-- This works the same as ##get##, but it reads from a string that you supply,
-- rather than from a file or device.
--
-- After reading one valid representation of a Euphoria object, ##value## will
-- stop reading and ignore any additional characters in the string.
-- For example, "36" and "36P" will both give you {GET_SUCCESS, 36}.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.02.14
--Status: created; complete
--Changes:]]]
--* documented ##get##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.17
--Status: created; complete
--Changes:]]]
--* defined ##value##
--* modified order of routines
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.16
--Status: created; incomplete
--Changes:]]]
--* defined ##get##
--------------------------------------------------------------------------------
