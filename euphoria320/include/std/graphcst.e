--------------------------------------------------------------------------------
--	Library: graphcst.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)graphcst.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.24
--Status: operational; complete
--Changes:]]]
--* corrected errors in defining colour codes
--
------
--==Euphoria Standard library: graphcst
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##video_config##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/graphcst.e</eucode>
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
include os.e	-- for LINUX, WIN32
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_VIDEO_CONFIG = 13
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant BLINKING = 16
--------------------------------------------------------------------------------
	-- colour-defining utility
--------------------------------------------------------------------------------
function os(integer w, integer l)
	if platform() = WIN32 then
		return w
	else
		return l
	end if
end function
--------------------------------------------------------------------------------
--/*
--==== Colours
--*/
--------------------------------------------------------------------------------
global constant BLACK = 0  -- in graphics modes this is "transparent"
global constant GREEN = 2
global constant MAGENTA = 5
global constant WHITE = 7
global constant GRAY  = 8
global constant BRIGHT_GREEN = 10
global constant BRIGHT_MAGENTA = 13
global constant BRIGHT_WHITE = 15
global constant BLUE = os(1, 4)
global constant CYAN = os(3, 6)
global constant RED = os(4, 1)
global constant BROWN = os(6, 3)
global constant BRIGHT_BLUE = os(9, 12)
global constant BRIGHT_CYAN = os(11, 14)
global constant BRIGHT_RED = os(12, 9)
global constant YELLOW = os(14, 11)
--------------------------------------------------------------------------------
--/*
--==== video_config sequence accessors
--*/
--------------------------------------------------------------------------------
global constant VC_COLOR = 1
global constant VC_COLUMNS = 4
global constant VC_LINES = 3
global constant VC_MODE  = 2
global constant VC_NCOLORS = 7
global constant VC_PAGES = 8
global constant VC_XPIXELS = 5
global constant VC_YPIXELS = 6
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
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
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function video_config()  -- returns sequence of information on video configuration
    return machine_func(M_VIDEO_CONFIG, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- 		A **sequence**, of 10 non-negative integers, laid out as follows:
--	# color monitor? ~-- 1 0 if monochrome, 1 otherwise
--	# current video mode
-- 	# number of text rows in console buffer
-- 	# number of text columns in console buffer
--	# screen width in pixels
--	# screen height in pixels
--	# number of colors
--	# number of display pages
-- 	# number of text rows for current screen size
-- 	# number of text columns for current screen size
--
-- Notes:
--
-- Constants are available for convenient access to the returned configuration data:
--     * ##VC_COLOR##
--     * ##VC_MODE##
--     * ##VC_LINES##
--     * ##VC_COLUMNS##
--     * ##VC_XPIXELS##
--     * ##VC_YPIXELS##
--     * ##VC_NCOLORS##
--     * ##VC_PAGES##
--     * ##VC_SCRNLINES##
--     * ##VC_SCRNCOLS##
--
-- This routine makes it easy for you to parameterize a program so it will work in many
-- different graphics modes.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version:3.2.0.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.23
--Status: operational; complete
--Changes:]]]
--* defined ##BLINKING##
--* added colours
--------------------------------------------------------------------------------
--[[[Version:3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.26
--Status: operational; complete
--Changes:]]]
--* copied
--* updated comment
--------------------------------------------------------------------------------
--[[[Version:3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.14
--Status: created; incomplete
--Changes:]]]
--* defined ##VC_COLUMNS##
--* defined ##VC_LINES##
--
--------------------------------------------------------------------------------
