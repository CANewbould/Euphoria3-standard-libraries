--------------------------------------------------------------------------------
--	Library: sequence.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)sequence.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.02
--Status: created; incomplete
--Changes:]]]
--* defined ##reverse##
--
------
--==Euphoria Standard library: sequence
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##reverse##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/sequence.e</eucode>
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
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
global function reverse(sequence target, integer pFrom, integer pTo)	-- reverses the order of elements in a sequence
    integer lLimit
    integer n
	sequence t
	integer uppr
    if pFrom = 0 then pFrom = 1 end if  -- set default
	n = length(target)
	if n < 2 then
		return target
	end if
	if pFrom < 1 then
		pFrom = 1
	end if
	if pTo < 1 then
		pTo = n + pTo
	end if
	if pTo < pFrom or pFrom >= n then
		return target
	end if
	if pTo > n then
		pTo = n
	end if
	lLimit = floor((pFrom+pTo-1)/2)
	t = target
	uppr = pTo
	for lowr = pFrom to lLimit do
		t[uppr] = target[lowr]
		t[lowr] = target[uppr]
		uppr -= 1
	end for
	return t
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##target##: the sequence to reverse.
--# ##pFrom##: the starting point.  Defaults to 1 if set to 0.
--# ##pTo##: the end point. See the notes below for how to relate to the sequence's end.
--
-- Returns:
--	A **sequence**, the same length as ##target##
-- and the same elements, but those with index between ##pFrom## and ##pTo##
-- appear in reverse order.
--
-- Notes:
-- In the result sequence, some or all top-level elements appear in reverse order compared
-- to the original sequence. This does not reverse any sub-sequences found in the original
-- sequence.
--
-- The ##pTo## parameter can be negative, which indicates an offset from the last element.
-- Thus a value of -1 refers to the second-last element.
-- 
-- A value of 0 refers to the last element.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
