--------------------------------------------------------------------------------
--	Library: text.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)text.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.04.10
--Status: created; complete
--Changes:]]]
--* documented ##lower##
--* documented ##sprint##
--* documented ##upper##
--
------
--==Euphoria Standard library: text
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##lower##
--* ##sprint##
--* ##upper##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/text.e</eucode>
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
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant TO_LOWER = 'a' - 'A' 
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
global function lower(object x)	-- converts atom or sequence to lower case
    return x + (x >= 'A' and x <= 'Z') * TO_LOWER
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##x##: the value to be converted (character, string, or sequence of same)
--
-- Returns:
--
-- an **object**, of the same shape as ##x##, with all characters or strings
-- converted to lower-case
--*/
--------------------------------------------------------------------------------
global function sprint(object x)	-- return the string representation of any Euphoria data object 
    sequence s				 
    if atom(x) then
		return sprintf("%.10g", x)
    else
		s = "{"
		for i = 1 to length(x) do
		    s &= sprint(x[i])  
		    if i < length(x) then
				s &= ','
		    end if
		end for
		s &= "}"
		return s
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##x##: the object to be displayed
--
-- Returns:
--
-- a **sequence**: the representation of ##x## as a string of characters
--
-- Notes:
--
-- This is the same as the output from ##print(1, x)## or '?', but it's
-- returned as a string sequence rather than printed.
--
-- The atoms contained within ##x## will be displayed to a maximum of 10
-- significant digits, just as with the ##print## routine.
--*/
--------------------------------------------------------------------------------
global function upper(object x)	-- convert atom or sequence to upper case
    return x - (x >= 'a' and x <= 'z') * TO_LOWER
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##x##: the value to be converted (character, string, or sequence of same)
--
-- Returns:
--
-- an **object**, of the same shape as ##x##, with all characters or strings
-- converted to upper-case
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
--Date: 2017.08.21
--Status: created; incomplete
--Changes:]]]
--* defined ##upper##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.20
--Status: created; incomplete
--Changes:]]]
--* defined ##sprint##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.17
--Status: created; incomplete
--Changes:]]]
--* defined ##lower##
--------------------------------------------------------------------------------
