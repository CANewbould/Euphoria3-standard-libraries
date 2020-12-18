--------------------------------------------------------------------------------
--	Library: utils.e
--------------------------------------------------------------------------------
--/*
--= Library: (test)(include)utils.e
-- Description: A utility offering support for console programs
------
--[[[Version: 3.2.1.7
--Euphoria Versions: Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.10.10
--Status: updated; operational
--Changes:]]]
--* made ##SCREEN## global
--
------
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.6
--Euphoria Versions: Versions: 3.2.0 upwards
--Author: C A Newbould
--Status: updated; operational
--Changes:]]]
--------------------------------------------------------------------------------
--[[[Version: 3.2.2017.02.19.5
--Euphoria Versions: Versions: 3.1.1 upwards
--Author: C A Newbould
--Status: updated; operational
--Changes:]]]
--* added references to ##std/io.e##
--* modified procedure ##line##
--* modified local function check_default
--* defined ##DEFAULT_MESSAGE##
--------------------------------------------------------------------------------
--[[[Version: 3.2.2017.01.31.4
--Euphoria Versions: Versions: 3.1.1 upwards
--Author: C A Newbould
--Status: updated; operational
--Changes:]]]
--* added procedure ##new_screen##
--* added local function check_default
--* added local procedure anykey
--------------------------------------------------------------------------------
--[[[Version: 3.1.0
--Euphoria Versions: Versions: 3.1.1 upwards
--Date: 29 January 2017
--Author: C A Newbould
--Status: updated; operational
--Changes:]]]
--* added procedure ##line##
--* added procedure ##section##
--* added constants ##WITH##, ##WITHOUT##
--------------------------------------------------------------------------------
--[[[Version: 3.0.1
--Euphoria Versions: Versions: 3.1.1 upwards
--Date: 28 January 2017
--Author: C A Newbould
--Status: created
--Changes:]]]
--* ##closing## modified
--------------------------------------------------------------------------------
--[[[Version: 3.0.0
--Euphoria Versions: Versions: 3.1.1 upwards
--Date: 27 January 2017
--Author: C A Newbould
--Status: created
--Changes:]]]
--* constants ##EOL## and ##LINES## defined
--* procedures ##heading## and ##closing## defined
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
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant FALSE = (1=0)
constant KEYBOARD = 0
constant SCREEN = 1
constant TRUE = (1=1)
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant LINES = repeat('_', 80)
global constant EOL = '\n'
global constant WITH = TRUE
global constant WITHOUT = FALSE
global constant DEFAULT_MESSAGE = {}
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type boolean(integer this)
    return this = FALSE or this = TRUE
end type
--------------------------------------------------------------------------------
type string(sequence this)
    boolean ret
    ret = TRUE
    for i = 1 to length(this) do
        if this[i] < 0 or this[i] > 255 then return FALSE end if
    end for
    return ret
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
function check_default(string message)
    if equal(message, DEFAULT_MESSAGE) then
        message = "*** Press ENTER to close this program ***"
    end if
    return message
end function
--------------------------------------------------------------------------------
procedure anykey(string message)
    puts(SCREEN, EOL & message)
    if getc(KEYBOARD) then end if
end procedure
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global procedure line(boolean eol)  -- prints a line WITH(OUT) EOL
    if eol then
        puts(SCREEN, LINES & EOL)            
    else
        puts(SCREEN, LINES)
    end if
end procedure
--------------------------------------------------------------------------------
global procedure heading(string name)  -- prints a heading incorporating the name
    line(WITH)
    puts(SCREEN, "*** Testing '" & name & "' ***" & EOL)
    line(WITHOUT)
end procedure
--------------------------------------------------------------------------------
global procedure new_screen(string name)    -- after user intervention, clears the screen and repeats the current heading
    anykey("*** Press ENTER to open a new screen ***")
    clear_screen()
    heading(name)
end procedure
--------------------------------------------------------------------------------
global procedure section(string name)  -- prints a section prompt incorporating the name
    puts(SCREEN, "--- " & name & " ---" & EOL)
end procedure
--------------------------------------------------------------------------------
global procedure closing(string message)    -- prints a closing message and waits for a user response
    line(WITH)
    puts(SCREEN, "*** END ***\n")
    line(WITH)
    anykey(check_default(message))
end procedure
--------------------------------------------------------------------------------
--/*
-- If ##message## = "" then a default of {{{"*** Press any key to close this program ***"}}} is substituted
--*/
--------------------------------------------------------------------------------
