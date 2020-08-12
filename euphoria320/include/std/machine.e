--------------------------------------------------------------------------------
--	Library: machine.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)machine.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.11
--Status: operational; complete
--Changes:]]]
--* documentation extended for ##free##
--
------
--==Euphoria Standard library: machine
--
-- Where the Open Euphoria routine has additional (and optional) arguments the
-- early form has been retained, but with the newer code, as appropriate.
--
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--
--* ##allocate##
--* ##allocate_string##
--* ##free##
--* ##register_block##
--* ##unregister_block##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/machine.e</eucode>
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
constant M_ALLOC = 16
constant M_FREE = 17
constant MAX_ADDR = power(2, 32) - 1	-- biggest address on a 32-bit machine
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
type machine_addr(atom a)	-- a 32-bit non-null machine address 
    return a > 0 and a <= MAX_ADDR and floor(a) = a
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
global function allocate(positive_int n)	-- allocates n bytes of memory; returns the address
    return machine_func(M_ALLOC, n)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--   # ##n##: the size of the requested block
--
-- Returns:
--
--*   an **atom**: the address of the allocated memory, or
--* 0 if the memory cannot be allocated.
-- You must use either an atom or an object to
-- receive the returned value as sometimes the returned memory address is
-- too larger for an **integer** to hold.
--
-- Notes:
--
-- * Since ##allocate## acquires memory from the system, it is the programmer's
-- responsiblity to return that memory when the application no longer needs it, by
-- calling the ##free## function to release the memory back to the system.
--
-- When your program terminates, however, the operating system will reclaim
-- all memory that your applicaiton acquired anyway.
--
-- An address returned by this function shouldn't be passed to ##call##.
--*/
--------------------------------------------------------------------------------
global function allocate_string(sequence s)	-- allocates a C-style null-terminated string in memory
    atom mem    
    mem = machine_func(M_ALLOC, length(s) + 1) -- Thanks to Igor
    if mem then
		poke(mem, s)
		poke(mem + length(s), 0)  -- Thanks to Aku
    end if
    return mem
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--              # ##s##: the string to store in RAM.
--
-- Returns:
--
--  an **atom**, the address of the memory block where the string is
-- stored, or 0 on failure.
--
-- Notes:
--
-- Only the 8 lowest bits of each atom in ##s## is stored. Use
-- ##allocate_wstring##  for storing double byte encoded strings.
--
-- There is no allocate_string_low function. However, you could easily
-- craft one by adapting the code for ##allocate_string##.
--
-- Since ##allocate_string## allocates memory, you are responsible for
-- freeing the block when done with it, by calling ##free##.
--*/
--------------------------------------------------------------------------------
global procedure free(object addr)	-- frees the memory at a given address
    machine_proc(M_FREE, addr)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##addr##: either a single atom or a sequence of atoms;
-- these are addresses of a blocks to free. 
-- 
-- Notes:
--* Use ##free## to return blocks of memory used during execution.
-- This will reduce the chance of running out of memory or getting into
-- excessive virtual memory swapping to disk. 
--* Do not reference a block of memory that has been freed. 
--* When your program terminates, all allocated memory will be returned
-- to the system. 
--* ##addr## must have been allocated previously using ##allocate##.
-- You cannot use it to relinquish part of a block.
-- Instead, you have to allocate a block of the new size, copy useful contents
-- from old block there and then use ##free## on the old block. 
--* An ##addr## of zero is simply ignored. 
--
--*/
--------------------------------------------------------------------------------
global procedure register_block(atom block_addr, atom block_len)	-- see safe.e for usage
end procedure
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
global procedure unregister_block(atom block_addr)	-- see safe.e for usage
end procedure
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.09
--Status: operational; complete
--Changes:]]]
--* documentation extended for ##allocate_string##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.11.26
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##allocate##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.10
--Status: operational; incomplete
--Changes:]]]
--* copied directly from Eu3.1.2 folder
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.09
--Status: operational; incomplete
--Changes:]]]
--* defined ##allocate_string##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions:3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.02
--Status: created; incomplete
--Changes:]]]
--* defined ##allocate##
--* defined ##free##
--------------------------------------------------------------------------------
