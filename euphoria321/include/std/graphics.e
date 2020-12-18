--------------------------------------------------------------------------------
--	Library: graphics.e
--------------------------------------------------------------------------------
-- Notes:
--
-- Needs full OE4 documentation
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)graphics.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.09.25
--Status: operational; incomplete
--Changes:]]]
--* ##graphics_mode## defined
--
------
--==Euphoria Standard library: graphics
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##bk_color##
--* ##get_position##
--* ##graphics_mode##
--* ##scroll##
--* ##text_color##
--* ##wrap##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/graphics.e</eucode>
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
include types.e -- for boolean
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_GET_POSITION = 25
constant M_GRAPHICS_MODE  = 5
constant M_SCROLL = 8
constant M_SET_B_COLOR = 10
constant M_SET_T_COLOR = 9
constant M_WRAP = 7
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
type color(integer x)
    return x >= 0 and x <= 255
end type
--------------------------------------------------------------------------------
type positive_int(integer x)
    return x >= 1
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
global procedure bk_color(color c)	-- sets the background colour to one of the sixteen standard colours
    machine_proc(M_SET_B_COLOR, c)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##c## : the new text colour.
-- Add ##BLINKING## to get blinking text in some modes.
--
-- Notes:
--
-- To restore the original background colour when your program finishes, 
-- (often ##0 - BLACK##), you must call ##bk_color##.
-- If the cursor is at the bottom line of the screen, you may have to print
-- something before terminating your program; printing ##'\n'## may be enough.
--*/
--------------------------------------------------------------------------------
global function get_position()	-- 	-- returns the current line and column position of the cursor position
    return machine_func(M_GET_POSITION, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- 		a **sequence**: ##{line, column}##, the current position of the text mode cursor.
--
-- Notes:
--
--   The coordinate system for displaying text is different from the one for displaying pixels. 
--   Pixels are displayed such that the top-left is ##(x=0,y=0)## and the first coordinate controls 
--   the horizontal, left-right location. In pixel-graphics modes you can display both text and 
--   pixels. ##get_position## returns the current line and column for the text that you are 
--   displaying, not the pixels that you may be plotting. There is no corresponding routine for 
--   getting the current pixel position, because there is no such thing.
--*/
--------------------------------------------------------------------------------
global function graphics_mode(object m) -- attempts to set up a new graphics mode
   return machine_func(M_GRAPHICS_MODE, m)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- # ##x##: an object, but it will be ignored.
--
-- Returns:
--
-- an **integer**: always returns zero. 
--
-- Notes:
--
-- * This has no effect on Unix platforms.
-- * On Windows, it causes a console to be shown if one has not already been created.
--*/
--------------------------------------------------------------------------------
global procedure scroll(integer amount, positive_int top_line, positive_int bottom_line)	-- scrolls a region of text on the screen
	machine_proc(M_SCROLL, {amount, top_line, bottom_line})
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##amount## : an integer, the number of lines by which to scroll. 
--        This is ##>0## to scroll up and ##<0## to scroll down.
-- 		# ##top_line## : the 1-based number of the topmost line to scroll.
-- 		# ##bottom_line## : the 1-based number of the bottom-most line to scroll.
--
-- Notes:
--
-- * New blank lines will appear at the vacated lines.
-- * You could perform the scrolling operation using a series of calls to ##puts##, 
-- but ##scroll## is much faster.
-- * The position of the cursor after scrolling is not defined.
--
--*/
--------------------------------------------------------------------------------
global procedure text_color(color c)	-- sets the foreground text color to c - text or graphics modes
    machine_proc(M_SET_T_COLOR, c)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##c## : the new text colour.
-- Add ##BLINKING## to get blinking text in some modes.
--
-- Notes:
--
-- Text that you print after calling ##text_color## will have the desired colour.
--
-- When your program terminates, the last color that you selected and actually printed on the 
-- screen will remain in effect. Thus you may have to print something, maybe just ##'\n'##, 
-- in ##WHITE## to restore white text, especially if you are at the bottom line of the 
-- screen, ready to scroll up.
--*/
--------------------------------------------------------------------------------
global procedure wrap(boolean on)   -- determines whether text will wrap when hitting the rightmost column
    machine_proc(M_WRAP, on)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##on## : an object, 0 to truncate text, anything else to wrap.
--
-- Notes:
--
-- By default text will wrap.
--
-- Use ##wrap## in text modes or pixel-graphics modes when you are displaying long 
-- lines of text.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.02.25
--Status: operational; incomplete
--Changes:]]]
--* documented ##wrap##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.02.23
--Status: operational; incomplete
--Changes:]]]
--* documented ##text_color##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.02.22
--Status: operational; complete
--Changes:]]]
--* documented ##scroll##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.02.20
--Status: operational; complete
--Changes:]]]
--* documented ##get_position##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.01.31
--Status: operational; complete
--Changes:]]]
--* documented ##bk_color##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.10.13
--Status: operational; complete
--Changes:]]]
--* revised to include ##types.e##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.10.10
--Status: operational; complete
--Changes:]]]
--* copy/created from v3.2.0
--------------------------------------------------------------------------------
