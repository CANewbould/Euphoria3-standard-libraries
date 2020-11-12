--------------------------------------------------------------------------------
--	Library: text.e
--------------------------------------------------------------------------------
-- Notes:
--
-- lower & upper are still defined as per eu3.1.2
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)text.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.10
--Status: operational; complete
--Changes:]]]
--* copied from eu3.1.2
--* modified ##sprint##
--
------
--==Euphoria Standard library: text
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##lower##
--* ##sprint##
--* ##upper##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/text.e</eucode>
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
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
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   An **atom** or **sequence**, the lowercase version of ##x##.
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
		if s[$] = ',' then
			s[$] = '}'
		else
			s &= '}'
		end if
		return s
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   A **sequence**, a string representation of ##x##.
--
-- Notes:
--
-- This is exactly the same as ##print(fn, x)##, except that the output is returned as a sequence of characters, rather
-- than being sent to a file or device. ##x## can be any Euphoria object.
--
-- The atoms contained within ##x## will be displayed to a maximum of 10 significant digits,
-- just as with ##print##.
--*/
--------------------------------------------------------------------------------
global function upper(object x)	-- convert atom or sequence to upper case
    return x - (x >= 'a' and x <= 'z') * TO_LOWER
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   An **atom** or **sequence**, the uppercase version of ##x##.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
