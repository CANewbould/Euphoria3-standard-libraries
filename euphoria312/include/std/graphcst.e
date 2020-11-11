--------------------------------------------------------------------------------
--	Library: graphcst.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)graphcst.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.4
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
--* ##video_config##
--
-- The routines and constants defined in this module are part of the Eu3.1.1
-- installation and
-- deliver exactly the same functionality as those defined in Open Euphoria's
-- standard library of the same name.
--
-- Utilise them by adding the following statement to your module:
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
include os.e	-- for LINUX
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
	if platform() = LINUX then
		return l
	else
		return w
	end if
end function
--------------------------------------------------------------------------------
--/*
--==== colours
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
--/*
--=== Variables
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer BLUE
global integer CYAN
global integer RED
global integer BROWN
global integer BRIGHT_BLUE
global integer BRIGHT_CYAN
global integer BRIGHT_RED
global integer YELLOW
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
global function video_config()  -- returns sequence of information on video configuration
    return machine_func(M_VIDEO_CONFIG, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- a **sequence** of values describing the current video configuration
--
-- The format is:
--
-- {color_monitor?, mode, text lines, text columns, xpixels, ypixels, #colors, pages}
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version:3.1.2.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.23
--Status: operational; complete
--Changes:]]]
--* defined ##BLINKING##
--* added colour codes
--------------------------------------------------------------------------------
--[[[Version:3.1.2.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.01.28
--Status: operational; complete
--Changes:]]]
--* updated documentation for ##video_config##
--------------------------------------------------------------------------------
--[[[Version:3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.31
--Status: operational; complete
--Changes:]]]
--* defined ##video_config##
--* defined COLOUR_CONSTANTS
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
