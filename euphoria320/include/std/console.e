--------------------------------------------------------------------------------
--	Library: console.e
--------------------------------------------------------------------------------
-- Notes:
--
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)console.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.8
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2019.05.01
--Status: operational; complete
--Changes:]]]
--* ##get_screen_char## modified 
------
--==Euphoria Standard library: console
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##allow_break##
--* ##check_break##
--* ##cursor##
--* ##display_text_image##
--* ##free_console##
--* ##get_screen_char##
--* ##prompt_number##
--* ##prompt_string##
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
include std/get.e as stdget -- for GET_SUCCESS, value
include std/graphcst.e as graphcst	-- for VC_COLUMNS, VC_LINES, video_config
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
--=== EuCANOOP property types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
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
--
--# ##b##: TRUE (to enable the trapping of CTRL+C/CTRL+Break) or FALSE (to disable it). 
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
--You can find out if the user has pressed CTRL+C or CTRL+Break
-- by calling check_break().
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
--# ##xy## : a pair of 1-based coordinates representing the point at which to start writing
--# ##text## : a list of sequences of alternated character and attribute
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
--   # ##line## : the 1-base line number of the location
--   # ##column## : the 1-base column number of the location
--      # ##fgbg## : an integer, if ##0## (the default) you get an attribute_code
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
global function wait_key()  -- waits for user to press a key, unless any is pending, and returns a key code
	return machine_func(M_WAIT_KEY, 0)
end function
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
--[[[Version: 3.2.0.7
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2018.12.12
--Status: operational; complete
--Changes:]]]
--* defined (local) positive_atom type
--* defined ##get_screen_char##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.6
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.12.16
--Status: operational; complete
--Changes:]]]
--* defined ##prompt_number##
--* included ##std/get.e## for this routine
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.5
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.11.28
--Status: operational; incomplete
--Changes:]]]
-- defined ##display_text_image##
-- defined local type text_point
-- defined local constant M_PUT_SCREEN_CHAR
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.4
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.11.14
--Status: operational; incomplete
--Changes:]]]
-- defined ##free_console##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.3
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.10.03
--Status: operational; incomplete
--Changes:]]]
--------------------------------------------------------------------------------
--* modified documentation of ##allow_break##
--[[[Version: 3.2.0.2
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.09.19
--Status: operational; incomplete
--Changes:]]]
--* defined ##prompt_string##
--* corrected errors in ##wait_key##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.1
--Euphoria Versions: 3.2.0 and later
--Author: C A Newbould
--Date: 2017.09.07
--Status: operational; incomplete
--Changes:]]]
--* defined ##cursor##
--* defined associated constants
--* defined ##wait_key##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.04
--Status: operational; incomplete
--Changes:]]]
--* defined ##allow_break##
--* defined ##check_break##
--------------------------------------------------------------------------------
