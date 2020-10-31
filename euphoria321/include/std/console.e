--------------------------------------------------------------------------------
--	Library: console.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)console.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2020.07.17
--Status: operational; complete
--Changes:]]]
--* defined ##display##
--
------
--==Euphoria Standard library: console
--===Types
--* ##positive_int##
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##allow_break##
--* ##any_key##
--* ##attr_to_colors##
--* ##check_break##
--* ##colors_to_attr##
--* ##cursor##
--* ##display##
--* ##display_text_image##
--* ##free_console##
--* ##get_screen_char##
--* ##prompt_number##
--* ##prompt_string##
--* ##put_screen_char##
--* ##save_text_image##
--* ##text_rows##
--* ##wait_key##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/console.e</eucode>
--
------
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
include get.e as stdget -- for GET_SUCCESS, value
include graphcst.e as graphcst	-- for true_bgcolor, true_fgcolor, VC_COLUMNS, VC_LINES, video_config
include pretty.e as pretty -- for pretty_print
include text.e as text -- for trim
include types.e as types -- for t_display
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_ALLOW_BREAK = 42
constant M_CHECK_BREAK = 43
constant M_CURSOR = 6
constant M_FREE_CONSOLE = 54
constant M_GET_SCREEN_CHAR = 58
constant M_PUT_SCREEN_CHAR = 59
constant M_TEXTROWS = 12
constant M_WAIT_KEY = 26
constant TRUE = (1=1)
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--/*
-- ==== Cursor Style Constants
--*/
--------------------------------------------------------------------------------
global constant BLOCK_CURSOR = #0007
global constant HALF_BLOCK_CURSOR = #0407
global constant NO_CURSOR = #2000
global constant THICK_UNDERLINE_CURSOR = #0507
global constant UNDERLINE_CURSOR = #0607
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type boolean(integer this)
    return this = TRUE or this = (1=0)
end type
--------------------------------------------------------------------------------
type positive_atom(atom x)
	return x >= 1
end type
--------------------------------------------------------------------------------
type text_point(sequence p)
	return length(p) = 2 and p[1] >= 1 and p[2] >= 1
		   and p[1] <= 200 and p[2] <= 500 -- rough sanity check
end type
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global type positive_int(object x)
	if integer(x) and x >= 1 then
		return 1
	else
		return 0
	end if
end type
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
integer wait_key_id
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
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global procedure allow_break(boolean b) -- sets the behaviour of CTRL+C/CTRL+Break
	machine_proc(M_ALLOW_BREAK, b)
end procedure
--------------------------------------------------------------------------------
--/*
--Parameter:
--# ##b##: TRUE (to enable the trapping of CTRL+C/CTRL+Break) or FALSE (to disable it) 
--
--Notes:
--
--When b is TRUE, CTRL+C and CTRL+Break can terminate your program when it tries
-- to read input from the keyboard.
--When b is FALSE your program will not be terminated by CTRL+C or CTRL+Break.
--
--Initially your program can be terminated at any point where it tries to read
-- from the keyboard.
--
--You can find out if the user has pressed CTRL+C or CTRL+Break by calling
-- check_break().
--*/
--------------------------------------------------------------------------------
global procedure any_key(sequence prompt, integer con)  -- -- displays a prompt and waits for any key
	if not length(prompt) then prompt = "Press Any Key to continue..." end if
    if not find(con, {1, 2}) then
		con = 1
	end if
	puts(con, prompt)
	if call_func(wait_key_id, {}) then end if
	puts(con, "\n")
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##prompt##: the prompt to display; defaults [""] to "Press Any Key to continue..."
--   # ##con##: Either 1 (stdout), or 2 (stderr)
--
--Notes:
--
-- This wraps ##wait_key## by giving a clue that the user should press a key, and
-- perhaps do some other things as well.
--*/
--------------------------------------------------------------------------------
global function attr_to_colors(integer attr_code)	-- converts an attribute code to its foreground and background color components
    sequence fgbg
	fgbg = and_bits({attr_code, attr_code/16}, #0F)
    return {find(fgbg[1],true_fgcolor)-1, find(fgbg[2],true_bgcolor)-1}
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##attr_code##: an attribute code
--
-- Returns:
-- A **sequence**,
--  of two elements - ##{fgcolor, bgcolor}##
--*/
--------------------------------------------------------------------------------
global function check_break()   -- returns the number of Control-C/Control-BREAK key presses
	return machine_func(M_CHECK_BREAK, 0)
end function
--------------------------------------------------------------------------------
--/*
--Returns:
--
--An **integer**: the number of times that CTRL+C or CTRL+Break have been
-- pressed since the last call to ##check_break##,
-- or since the beginning of the program if this is the first call.
--
--Notes:
--
-- This is useful after you have called ##allow_break## which
--  prevents CTRL+C or CTRL+Break from terminating your
--  program. You can use ##check_break## to find out if the user
--  has pressed one of these keys. You might then perform some action
--  such as a graceful shutdown of your program.
--
-- Neither CTRL+C or CTRL+Break will be returned as input
--  characters when you read the keyboard. You can only detect
--  them by calling ##check_break##.
--*/
--------------------------------------------------------------------------------
global function colors_to_attr(object fgbg, integer bg)	-- converts a foreground and background color set to its attribute code format
	if sequence(fgbg) then
		return true_fgcolor[fgbg[1]+1] + true_bgcolor[fgbg[2]+1] * 16
	else
		return true_fgcolor[fgbg+1] + true_bgcolor[bg+1] * 16
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##fgbg##: Either a sequence of ##{fgcolor, bgcolor}## or just an integer fgcolor.
--      # ##bg##: An integer bgcolor. Only used when ##fgbg## is an integer.
--
-- Returns:
--
--        An **integer** -
-- an attribute code.
--*/
--------------------------------------------------------------------------------
global procedure cursor(integer style)  -- selects a style of cursor
	machine_proc(M_CURSOR, style)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##style## : an integer defining the cursor shape.
--
-- Platform:
--
--		Not Unix.
--
-- Notes:
--
--   In pixel-graphics modes no cursor is displayed.
--*/
--------------------------------------------------------------------------------
global procedure display(object data_in, object args, integer finalnl) -- displays the supplied data on the console screen at the current cursor position
	if atom(data_in) then
		if integer(data_in) then
			printf(1, "%d", data_in)
		else
			puts(1, text:trim(sprintf("%15.15f", data_in), '0'))
		end if
	elsif length(data_in) > 0 then
		if types:t_display(data_in) then
			if data_in[$] = '_' then
				data_in = data_in[1..$-1]
				finalnl = 0
			end if
			puts(1, text:format(data_in, args))
		else
			if atom(args) or length(args) = 0 then
				pretty:pretty_print(1, data_in, {2})
			else
				pretty:pretty_print(1, data_in, args)
			end if
		end if
	else
		if equal(args, 2) then
			puts(1, `""`)
		end if
	end if
	if finalnl = 0 then
		-- no new line
	elsif equal(args, 0) then
		-- no new line
	else
		puts(1, '\n')
	end if
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //data_in//: the object to be shown
--# //args//: arguments used to format the output
--# //finalnl//: determines whether a new line is output after the data (1)
--  or not (0)
--
--*/
--------------------------------------------------------------------------------
global procedure display_text_image(text_point xy, sequence text)	-- displays a text image at line xy[1], column xy[2] in any text mode
	integer extra_col2
	integer extra_lines
	sequence one_row
    sequence vc    
	vc = graphcst:video_config()
	if xy[1] < 1 or xy[2] < 1 then
		return -- bad starting point
	end if
	extra_lines = vc[graphcst:VC_LINES] - xy[1] + 1
	if length(text) > extra_lines then
		if extra_lines <= 0 then
			return -- nothing to display
		end if
		text = text[1..extra_lines] -- truncate
	end if
	extra_col2 = 2 * (vc[VC_COLUMNS] - xy[2] + 1)
	for row = 1 to length(text) do
		one_row = text[row]
		if length(one_row) > extra_col2 then
			if extra_col2 <= 0 then
				return -- nothing to display
			end if
			one_row = one_row[1..extra_col2] -- truncate
		end if
		machine_proc(M_PUT_SCREEN_CHAR, {xy[1]+row-1, xy[2], one_row})
	end for
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##xy##: a pair of 1-based coordinates representing the point at which to start writing
--# ##text##: a list of sequences of alternated character and attribute
--
-- Notes:
--
-- This routine displays to the active text page, and only works in text modes.
--
-- You might use ##save_text_image##/##display_text_image## in a text-mode graphical
-- user interface, to allow "pop-up" dialog boxes, and drop-down menus to appear and disappear
-- without losing what was previously on the screen.
--*/
--------------------------------------------------------------------------------
global procedure free_console()	-- deletes the console text-window (if one currently exists)
    machine_proc(M_FREE_CONSOLE, 0)
end procedure
--------------------------------------------------------------------------------
--/*
-- Notes:
--
-- Call this if you are getting an unwanted "Press Enter" message
-- at the end of execution of your program on Linux/FreeBSD or Windows.
--
--  Euphoria will create a console text window for your program the first time that your
--  program prints something to the screen, reads something from the keyboard, or in some
--  way needs a console. On WINDOWS this window will automatically disappear when your program
--  terminates, but you can call ##free_console## to make it disappear sooner. On Linux or FreeBSD, 
--  the text mode console is always there, but an xterm window will disappear after Euphoria 
--  issues a "Press Enter" prompt at the end of execution.
--  
--  On Unix-style systems, ##free_console### will set the terminal parameters back to normal,
--  undoing the effect that curses has on the screen.
--  
--  In an xterm window, a call to ##free_console##, without any further
--  printing to the screen or reading from the keyboard, will eliminate the
--  "Press Enter" prompt that Euphoria normally issues at the end of execution.
--  
--  After freeing the console window, you can create a new console window by printing
--  something to the screen, or simply calling ##clear_screen##, ##position## or any other
--  routine that needs a console.
--  
--  When you use the trace facility, or when your program has an error, Euphoria will
--  automatically create a console window to display trace information, error messages etc.
--  
--  There's a WINDOWS API routine, {{{FreeConsole()}}} that does something similar to
--  ##free_console##. You should use ##free_console## instead, because it lets the interpreter know
--  that there is no longer a console to write to or read from.
--*/
--------------------------------------------------------------------------------
global function get_screen_char(positive_atom line, positive_atom column, integer fgbg) -- gets the value and attribute of the character at a given screen location
	sequence ca
	ca = machine_func(M_GET_SCREEN_CHAR, {line, column})
	if fgbg then
		ca = ca[1] & and_bits({ca[2], ca[2]/16}, #0F)
	end if
	return ca
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##line##: the 1-base line number of the location
--   # ##column##: the 1-base column number of the location
--   # ##fgbg##: an integer, if ##0## (the default) you get an attribute_code
--                   returned otherwise you get a foreground and background color
--                   number returned.
--
-- Returns:
-- * If fgbg is zero then a **sequence** of //two// elements, ##{character, attribute_code}##
-- for the specified location.
-- * If fgbg is not zero then a **sequence** of //three// elements, ##{characterfg_color, bg_color}##.
--
-- Comments:
-- * This function inspects a single character on the //active page//.
-- * The attribute_code is an atom that contains the foreground and background
-- color of the character, and possibly other operating-system dependant 
-- information describing the appearance of the character on the screen.
-- * With ##get_screen_char## and ##put_screen_char## you can save and restore
-- a character on the screen along with its attribute_code.
-- * The ##fg_color## and ##bg_color## are integers in the range ##0## to ##15## which correspond
-- to the values in the table~:
--*/
--------------------------------------------------------------------------------
global function prompt_number(sequence prompt, sequence range)  -- prompts the user to enter a number
	object answer
	while TRUE do
		 puts(1, prompt)
		 answer = gets(0) -- make sure whole line is read
		 puts(1, '\n')
		 answer = stdget:value(answer)
		 if answer[1] != stdget:GET_SUCCESS or sequence(answer[2]) then
			  puts(1, "A number is expected - try again\n")
		 else
			 if length(range) = 2 then
				  if range[1] <= answer[2] and answer[2] <= range[2] then
					  return answer[2]
				  else
					printf(1, "A number from %g to %g is expected here - try again\n", range)
				  end if
			  else
				  return answer[2]
			  end if
		 end if
	end while
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##prompt##: the string to display on the screen
--   # ##range##: is a sequence of two values {lower, upper} which determine the range of values
--  		   that the user may enter. ##range## can be empty, {}, if there are no restrictions.
--
-- Returns:
--
--   An **atom**, 
-- in the assigned range which the user typed in.
--
-- Errors:
--
--   If ##puts## cannot display ##prompt## on standard output, or if the first or second element
--   of ##prompt## is a sequence, a runtime error will be raised.
--
--   If a user tries cancelling the prompt by hitting Control+Z, the program will abort as well,
--   issuing a type check error.
--
-- Notes:
--
--   As long as the user enters a number that is less than lower or greater
--   than upper, the user will be prompted again.
--*/
--------------------------------------------------------------------------------
global function prompt_string(sequence prompt)  -- prompts the user to enter a string of text
	object answer
	puts(1, prompt)
	answer = gets(0)
	puts(1, '\n')
	if sequence(answer) and length(answer) > 0 then
		return answer[1..$-1] -- trim the \n
	else
		return ""
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##prompt##: the string to display on the screen
--
-- Returns:
--
-- 		A **sequence**, the string that the user typed in, stripped of any new-line character.
--
-- Notes:
--
--     If the user happens to type control-Z (indicates end-of-file), "" will be returned.
--*/
--------------------------------------------------------------------------------
global procedure put_screen_char(positive_atom line, positive_atom column, sequence char_attr)	-- stores and displays a sequence of characters with attributes at a given location
	machine_proc(M_PUT_SCREEN_CHAR, {line, column, char_attr})
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##line##: the 1-based line at which to start writing
-- 		# ##column##: the 1-based column at which to start writing
-- 		# ##char_attr##: a sequence of alternated characters and attribute codes
--
-- ##char_attr## must be in the form  ##{character, attribute code, character, attribute code, ...}##.
--
-- Errors:
-- 		The length of ##char_attr## must be a multiple of two.
--
-- Comments:
--
-- The attributes atom contains the foreground colour, background colour, and possibly other platform-dependent information controlling how the character is displayed on the screen.
-- If ##char_attr## has ##0## length, nothing will be written to the screen. The characters are written to the //active page//.
-- It is faster to write several characters to the screen with a single call to ##put_screen_char## than it is to write one character at a time.
--*/
--------------------------------------------------------------------------------
global function save_text_image(text_point top_left, text_point bottom_right)	-- copies a rectangular block of text out of screen memory
	sequence image, row_chars
	image = {}
	for row = top_left[1] to bottom_right[1] do
		row_chars = {}
		for col = top_left[2] to bottom_right[2] do
			row_chars &= machine_func(M_GET_SCREEN_CHAR, {row, col})
		end for
		image = append(image, row_chars)
	end for
	return image
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##top_left##: the coordinates, given as a pair, of the upper left corner of the area to save.
--   # ##bottom_right##: the coordinates, given as a pair, of the lower right corner of the area to save.
--
-- Returns:
--
--   A **sequence**, 
-- of ##{character, attribute, character, ...}## lists.
--	 
-- Comments:
--
-- The returned value is appropriately handled by ##display_text_image##.
--
-- This routine reads from the active text page, and only works in text modes.
--
-- You might use this function in a text-mode graphical user interface to save a portion of the 
-- screen before displaying a drop-down menu, dialog box, alert box, and so on.
--*/
--------------------------------------------------------------------------------
global function text_rows(positive_int rows)	-- sets the number of lines on a text-mode screen
	return machine_func(M_TEXTROWS, rows)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##rows##: an integer, the desired number of rows
--
-- Platform:
--		//Windows//
--
-- Returns:
--
-- 		An **integer** - the actual number of text lines
--
-- Comments:
--
-- Values of 25, 28, 43 and 50 lines are supported by most video cards.
--*/
--------------------------------------------------------------------------------
global function wait_key()  -- waits for user to press a key, unless any is pending, and returns a key code
	return machine_func(M_WAIT_KEY, 0)
end function
wait_key_id = routine_id("wait_key")
--------------------------------------------------------------------------------
--/*
-- Returns:
--
--   An **integer** key code.
--
-- If one is waiting in the keyboard buffer, then return it.
-- Otherwise, wait for one to come up.
--*/
--------------------------------------------------------------------------------
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.03
--Status: operational; incomplete
--Changes:]]]
--* defined ##put_screen_char##
--* defined ##positive_int##
--* defined ##save_text_image##
--* defined ##colors_to_attr##
--* defined ##attr_to_colors##
--* defined ##text_rows##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2018.12.11
--Status: operational; incomplete
--Changes:]]]
--* defined (local) positive_atom type
--* defined ##get_screen_char##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.12.16
--Status: operational; incomplete
--Changes:]]]
--* defined ##prompt_number##
--* included ##std/get.e## for this routine
--* completed documentation for those routines in Eu3 as well
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.11.28
--Status: operational; incomplete
--Changes:]]]
--* defined ##display_text_image##
--* defined local type text_point
--* defined local constant M_PUT_SCREEN_CHAR
--* defined ##free_console##
--* defined local constant M_FREE_CONSOLE
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.10.03
--Status: operational; incomplete
--Changes:]]]
--* modified documentation of ##allow_break##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.19
--Status: operational; incomplete
--Changes:]]]
--* defined ##prompt_string##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.07
--Status: operational; incomplete
--Changes:]]]
--* defined ##cursor##
--* defined associated constants
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.05
--Status: operational; incomplete
--Changes:]]]
--* defined ##any_key##
--* defined ##wait_key##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.04
--Status: operational; incomplete
--Changes:]]]
--* defined ##allow_break##
--* defined ##check_break##
--------------------------------------------------------------------------------
