--------------------------------------------------------------------------------
--	Library: math.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)math.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.2.0.1 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.27
--Status: operational; complete
--Changes:]]]
--* documented ##arcsin##
--
------
--==Euphoria Standard library: math
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##arccos##
--* ##arcsin##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/math.e</eucode>
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
include mathcons.e	-- for PI
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant PI_HALF =  PI / 2.0  -- this is pi/2
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
type trig_range(object x)
--  values passed to arccos and arcsin must be [-1, +1]
    if atom(x) then
		return x >= -1 and x <= 1
    else
		for i = 1 to length(x) do
		    if not trig_range(x[i]) then
			return 0
		    end if
		end for
		return 1
    end if
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
global function arccos(trig_range value)	--  returns an angle given its cosine
    return PI_HALF - 2 * arctan(value / (1.0 + sqrt(1.0 - value * value)))
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##value##: an object, each atom containing a cosine value.
--
-- Returns:
--
--   an **object**, the same shape as ##value##.
-- Each element of the result is an atom, representing an angle whose cosine is
-- the corresponding element in the source.
--
-- Errors:
--
--   If any atom in ##value## is not in the -1..1 range, as it cannot be a
-- cosine of a real number, an error occurs.
--
-- Notes:
--
-- A value between 0 and ##PI## radians will be returned.
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- ##arccos## is not as fast as ##arctan##.
--*/
--------------------------------------------------------------------------------
global function arcsin(trig_range value)	--  returns angle(s) in radians
    return 2 * arctan(value / (1.0 + sqrt(1.0 - value * value)))
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--		# ##value## : an object, each atom containing a sine value.
--
-- Returns:
--
--		An **object**, the same shape as ##value##.
-- When ##value## is an atom, the result is an atom,
-- an angle whose sine is ##value##.
--
-- Errors:
--
--	If any atom in ##value## is not in the -1..1 range, it cannot be the sine
-- of a real number, and an error occurs.
--
-- Notes:
--
-- A value between ##-PI/2## and ##+PI/2## (radians) inclusive will be returned.
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- ##arcsin## is not as fast as ##arctan##.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.23
--Status: operational; complete
--Changes:]]]
--* documented ##arccos##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.10
--Status: created; incomplete
--Changes:]]]
--* defined ##arccos##
--* defined ##arcsin##
--* included ##mathcons.e##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.09
--Status: created; incomplete
--Changes:]]]
--* defined ##mod##
--
--------------------------------------------------------------------------------
