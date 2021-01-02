--------------------------------------------------------------------------------
--	Library: memory.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria321)(include)(std)memory.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.02
--Status: incomplete
--Changes:]]]
--* **machine_addr** defined
--* local material defined
--* slots for //safe// routines created
--
--==Euphoria Standard library: memory
--
-- This library hold the standard ##memory## management library.
--
-- The following are part of the Open Euphoria's standard
-- library and has been tested/amended to function with Eu3.1.1.
--===Constants
--===Types
--* **machine_addr**
--===Routines
--* ##check_all_blocks##
--* ##deallocate##
--* ##prepare_block##
--* ##register_block##
--* ##safe_address##
--* ##unregister_block##
--
-- Utilise this support by adding the following statement to your module:
--<eucode>include std/memory.e</eucode>
------
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
include memconst.e as memconst -- for M_FREE
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant FALSE = 0, TRUE = not FALSE
constant MAX_ADDR = power(2, 32)-1
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
type positive_int(object x)
	if not integer(x) then
		return FALSE
	end if
    return x >= 1
end type
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global type machine_addr(object a)-- a 32-bit non-null machine address 
	if not atom(a) then
		return FALSE
	end if
	if not integer(a)then
		if floor(a) != a then
			return FALSE
		end if
	end if
	return a > 0 and a <= MAX_ADDR
end type
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
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global procedure check_all_blocks()
    -- for safe.e
end procedure
--------------------------------------------------------------------------------
--/*
-- Only implemented in safe.e
--*/
--------------------------------------------------------------------------------
global function prepare_block(atom addr, integer a, integer protection)
    -- for safe.e
	return addr
end function
--------------------------------------------------------------------------------
--/*
-- Only implemented in safe.e
--*/
--------------------------------------------------------------------------------
global procedure deallocate(atom addr)
    machine_proc(memconst:M_FREE, addr)    
end procedure
--------------------------------------------------------------------------------
--/*
-- Internal use of the library only. ##free## calls this.  It works with
-- only atoms and in the SAFE implementation is different.
--*/
--------------------------------------------------------------------------------
global procedure register_block(atom block_addr, atom block_len, integer protection )
    -- for safe.e
end procedure
--------------------------------------------------------------------------------
--/*
-- Only implemented in safe.e
--*/
--------------------------------------------------------------------------------
function safe_address(atom start, integer len, positive_int action)
    -- for safe.e
	return TRUE
end function
--------------------------------------------------------------------------------
--/*
-- Only implemented in safe.e
--*/
--------------------------------------------------------------------------------
global procedure unregister_block(atom block_addr, atom block_len, integer protection )
    -- for safe.e
end procedure
--------------------------------------------------------------------------------
--/*
-- Only implemented in safe.e
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.08.04
--Status: incomplete
--Changes:]]]
--* created
--* ##deallocate## created
--------------------------------------------------------------------------------
