--------------------------------------------------------------------------------
--	Library: console.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)console.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.11
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.12.16
--Status: operational; complete
--Changes:]]]
--* extended documentation of ##prompt_number##
--* extended documentation of ##prompt_string##
--
------
--==Euphoria Standard library: console
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##allow_break##
--* ##check_break##
--* ##cursor##
--* ##display_text_image##
--* ##free_console##
--* ##get_screen_char##
--* ##prompt_number##
--* ##prompt_string##
--* ##put_screen_char##
--* ##save_text_image##
--* ##wait_key##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/console.e</eucode>
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
include get.e as stdget -- for value
include std/graphcst.e	-- for VC_COLUMNS, VC_LINES, video_config
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant FALSE = (1 = 0)
constant M_ALLOW_BREAK = 42
constant M_CHECK_BREAK = 43
constant M_CURSOR = 6
constant M_FREE_CONSOLE = 54
constant M_GET_SCREEN_CHAR = 58
constant M_PUT_SCREEN_CHAR = 59
constant SCREEN = 1
constant TRUE = (1 = 1)
constant M_WAIT_KEY = 26
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
-- cursor styles:
global constant NO_CURSOR = #2000
global constant UNDERLINE_CURSOR = #0607
global constant THICK_UNDERLINE_CURSOR = #0507
global constant HALF_BLOCK_CURSOR = #0407
global constant BLOCK_CURSOR = #0007
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type boolean(integer b)
    return b = 0 or b = 1
end type
--------------------------------------------------------------------------------
type positive_atom(atom x)
    return x > 0
end type
--------------------------------------------------------------------------------
type string(sequence x) -- a sequence containing only character elements
    for i = 1 to length(x) do
        if sequence(x[i]) then return FALSE end if
        if (x[i] < ' ') and (x[i] != 9) and (x[i] != 13) and (x[i] != 10) then return FALSE end if
        if x[i]> 254 then return FALSE end if
    end for
    return TRUE
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
global procedure allow_break(boolean b)	-- sets behaviour of control-c/control-break
    machine_proc(M_ALLOW_BREAK, b)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
--   # ##b##: TRUE (!= 0) to enable the trapping of
--     Control+C and Control+Break, or FALSE (0) to disable it.
--
-- Notes:
--
-- If ##b## is TRUE then allow Control+C/Control+Break to
-- terminate the program. If b is FALSE then don't allow it.
--
-- When b is 1 (true), Control+C and Control+Break can terminate your program
-- when it tries to read input from the keyboard.
-- When b is 0 (false) your program will not be terminated by Control+C 
-- or Control+Break.
--
-- Initially your program can be terminated at any point where it tries to read
-- from the keyboard.
--
-- You can find out if the user has pressed Control+C or Control+Break by
-- calling ##check_break##.
--*/
--------------------------------------------------------------------------------
global function check_break()	-- returns the number of times that control-c or control-break was pressed since the last time check_break() was called
    return machine_func(M_CHECK_BREAK, 0)
end function
--------------------------------------------------------------------------------
--/*
-- This is useful after you have called ##allow_break##(0) which prevents control-c
-- or control-break from terminating your program.
-- You can use ##check_break##() to find out if the user has pressed one of these keys.
-- You might then perform some action such as a graceful shutdown of your program.
--
-- Neither control-c or control-break will be returned as input characters when you
-- read the keyboard.
-- You can only detect them by calling ##check_break##().
--*/
--------------------------------------------------------------------------------
global procedure cursor(integer style)	-- choose a cursor style
    machine_proc(M_CURSOR, style)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##style##: an integer defining the cursor shape.
--
-- Platform:
--
--		Not **Unix**.
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
	vc = video_config()
	if xy[1] < 1 or xy[2] < 1 then
		return	-- bad starting point
	end if
	extra_lines = vc[VC_LINES] - xy[1] + 1 
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
--# ##xy##: the coordinates {line, column} representing the point at which to start writing 
--# ##text##: the 2-dimensional sequence of {characters,attributes}

-- Notes:
--
-- The coordinate {1,1} represents the top left of the screen.
-- Other characters appear to the right or below this position.
--
-- The attributes indicate the foreground and background color of the preceding character. 
--
-- The ##text## parameter would normally be the result of a previous call to
-- ##save_text_image##, although you could construct it yourself. 
--
-- Displays to the active text page.
--*/
--------------------------------------------------------------------------------
global procedure free_console()	-- frees (deletes) any console window associated with your program
    machine_proc(M_FREE_CONSOLE, 0)
end procedure
--------------------------------------------------------------------------------
--/*
-- Notes:
--
-- Euphoria will create a console text window for your program the first time
-- that your program prints something to the screen, reads something from the
-- keyboard, or in some way needs a console (similar to a DOS-prompt window).
-- On WIN32 this window will automatically disappear when your program
-- terminates, but you can call ##free_console## to make it disappear sooner.
-- On Linux or FreeBSD, the text mode console is always there, but an xterm
-- window will disappear after Euphoria issues a "Press Enter" prompt at the
-- end of execution.
-- 
-- On Linux or FreeBSD, free_console() will set the terminal parameters back to
-- normal, undoing the effect that curses has on the screen. 
--
-- In a Linux or FreeBSD xterm window, a call to ##free_console##, without any
-- further printing to the screen or reading from the keyboard, will eliminate
-- the "Press Enter" prompt that Euphoria normally issues at the end of
-- execution.
-- 
-- After freeing the console window, you can create a new console window by
-- printing something to the screen, or simply calling ##clear_screen##,
-- ##position## or any other routine that needs a console.
-- 
-- When you use the trace facility, or when your program has an error,
-- Euphoria will automatically create a console window to display trace
-- information, error messages, etc. 
--
-- There is a WIN32 API routine, ##FreeConsole## that does something similar to
-- ##free_console##. You should use ##free_console##, because it lets the
-- interpreter know that there is no longer a console. 
--*/
--------------------------------------------------------------------------------
global function get_screen_char(positive_atom line, positive_atom column)	-- gets the value and attribute of the character at a given screen location  
    return machine_func(M_GET_SCREEN_CHAR, {line, column})  
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##line##: the 1-base line number of the location
-- 		# ##column##: the 1-base column number of the location
--
-- Returns:
--
-- a **sequence** of //two// elements, ##{character, attribute_code}##
-- for the specified location.
--
-- Notes:
--
-- * This function inspects a single character on the //active page//.
-- * The attribute_code is an atom that contains the foreground and background
-- color of the character, and possibly other operating-system dependant 
-- information describing the appearance of the character on the screen.
-- * The fg_color and bg_color are integers in the range 0 to 15, which correspond
-- to...
-- |= color number |= name |
-- |       0       | black      |
-- |       1       | dark blue      |
-- |       2       | green      |
-- |       3       | cyan      |
-- |       4       | crimson      |
-- |       5       | purple      |
-- |       6       | brown      |
-- |       7       | light gray      |
-- |       8       | dark gray      |
-- |       9       | blue      |
-- |       10      | bright green      |
-- |       11      | light blue      |
-- |       12      | red      |
-- |       13      | magenta      |
-- |       14      | yellow      |
-- |       15      | white      |
--
-- * With ##get_screen_char## and ##put_screen_char## you can save and restore
-- a character on the screen along with its attribute_code.
--*/
--------------------------------------------------------------------------------
global function prompt_number(sequence prompt, sequence range)	-- prompts the user to enter a number
    object answer
    while TRUE do
	 puts(SCREEN, prompt)
	 answer = gets(0) -- make sure whole line is read
	 puts(SCREEN, '\n')
	 answer = stdget:value(answer)
	 if answer[1] != GET_SUCCESS or sequence(answer[2]) then
	      puts(SCREEN, "A number is expected - try again\n")
	 else
	     if length(range) = 2 then
		  if range[1] <= answer[2] and answer[2] <= range[2] then
		      return answer[2]
		  else
		      printf(SCREEN,
		      "A number from %g to %g is expected here - try again\n",
		       range)
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
--# ##prompt##: the string used as the prompt
--# ##range##: a sequence {lower, upper} to signify a range of possible values
--
-- Notes:
--
-- The range can be empty, {}, if there are no restrictions.
--*/
--------------------------------------------------------------------------------
global function prompt_string(string prompt)	-- prompts the user to enter a string of text
    object answer
    puts(SCREEN, prompt)
    answer = gets(0)
    puts(SCREEN, '\n')
    if string(answer) and length(answer) > 0 then
		return answer[1..$-1] -- trim the \n
    else
		return ""
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##prompt##: the string used as the prompt
--
-- Notes:
--
-- The string that the user types will be returned as a sequence,
-- minus any new-line character.
--
-- If the user types control-Z (indicates end-of-file), "" will be returned.
--*/
--------------------------------------------------------------------------------
global procedure put_screen_char(positive_atom line, positive_atom column, sequence char_attr)	-- stores {character, attributes, character, attributes, ...} 
	machine_proc(M_PUT_SCREEN_CHAR, {line, column, char_attr})
end procedure
--------------------------------------------------------------------------------
global function save_text_image(text_point top_left, text_point bottom_right)	-- copies a rectangular block of text out of screen memory
	sequence image
	sequence row_chars
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
-- Copies, given the coordinates of the top-left and bottom-right corners.
--
-- Reads from the active text page.
--*/
--------------------------------------------------------------------------------
global function wait_key()  -- gets the next key pressed by the user; wait until a key is pressed
    return machine_func(M_WAIT_KEY, 0)
end function
--------------------------------------------------------------------------------
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.10
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.11.13
--Status: operational; complete
--Changes:]]]
--* extended documentation of ##free_console##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.10
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.11.13
--Status: operational; complete
--Changes:]]]
--* extended documentation of ##display_text_image##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.9
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.11.13
--Status: operational; complete
--Changes:]]]
--* extended documentation of ##cursor##
--* extended documentation of ##free_console##
--* extended documentation of ##get_screen_char##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.8
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.10.03
--Status: operational; complete
--Changes:]]]
--* extended documentation of ##allow_break##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.7
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.08.23
--Status: operational; complete
--Changes:]]]
--* defined function ##wait_key##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.19
--Status: created; incomplete
--Changes:]]]
--* defined function ##save_text_image##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.17
--Status: created; incomplete
--Changes:]]]
--* defined function ##put_screen_char##
--* defined procedure ##prompt_number##
--* defined procedure ##prompt_string##
--* modified ##display_text_image##
--* added [internal] definition of string
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.16
--Status: created; incomplete
--Changes:]]]
--* defined function ##get_screen_char##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.14
--Status: created; incomplete
--Changes:]]]
--* defined ##free_console##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.14
--Status: created; incomplete
--Changes:]]]
--* defined ##display_text_image##
--* added reference to ##graphcst.e##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.11
--Status: created; incomplete
--Changes:]]]
--* defined ##cursor## & associated styles
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.09
--Status: created; incomplete
--Changes:]]]
--* defined ##allow_break##
--* defined ##check_break##
--------------------------------------------------------------------------------
