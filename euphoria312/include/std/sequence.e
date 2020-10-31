--------------------------------------------------------------------------------
--	Library: sequence.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)sequence.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.04.11
--Status: created; complete
--Changes:]]]
--* documented ##reverse##
--
------
--==Euphoria Standard library: sequence
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##reverse##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/sequence.e</eucode>
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
global function reverse(sequence s)	-- reverses the top-level elements of a sequence
-- Thanks to Hawke' for helping to make this run faster.
    integer lowr
	integer n
	integer n2
    sequence t
    n = length(s)
    n2 = floor(n/2)+1
    t = repeat(0, n)
    lowr = 1
    for uppr = n to n2 by -1 do
		t[uppr] = s[lowr]
		t[lowr] = s[uppr]
		lowr += 1
    end for
    return t
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##s##: the source sequence
--
-- Returns:
--
-- a **sequence** having the top-level elements in reverse order of the original
-- sequence.
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.19
--Status: created; incomplete
--Changes:]]]
--* defined ##reverse##
--------------------------------------------------------------------------------
