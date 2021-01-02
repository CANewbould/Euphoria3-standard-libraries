--------------------------------------------------------------------------------
--	Library: safe.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)safe.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.02
--Status: created; incomplete
--Changes:]]]
--* //BORDER_SPACE// defined
--* //LEADER// defined
--* //TRAILER// defined
--* //check_calls// defined
--* //edges_only// defined
--* local types defined
--* //safe_address_list// defined
--* local pointers defined
--* //memconst.e// included
--* machine_addr re-defined
--* **bordered_address** defined
--
------
--==Euphoria Standard library: safe
-- The following are part of the Eu3.2.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--===Constants
--* //BORDER_SPACE//
--* //LEADER//
--* //TRAILER//
--===Variables
--* //check_calls//
--* //edges_only//
--* //safe_address_list//
--===Types
--* **bordered_address**
--===Routines
--* ##register_block##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/safe.e</eucode>
--
--*/
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
-- Information message
--------------------------------------------------------------------------------
puts(1, "\n\t\tUsing Debug Version of machine.e\n")
--------------------------------------------------------------------------------
--
--=== Includes
--
--------------------------------------------------------------------------------
include std/memconst.e
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
-- pointers
constant ALLOC_NUMBER = 3
constant BLOCK_ADDRESS = 1
constant BLOCK_LENGTH = 2
constant BLOCK_PROT = 4
-- booleans
constant BAD = 0
constant FALSE = 0, TRUE = not FALSE
constant OK = 1
--
constant LOW_ADDR = power(2, 20)-1
constant MAX_ADDR = power(2, 32) - 1 -- biggest address on a 32-bit machine
constant M_FREE = 17
constant M_SLEEP = 64
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant BORDER_SPACE = 40
global constant LEADER = repeat('@', BORDER_SPACE)
global constant TRAILER = repeat('%', BORDER_SPACE)
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type low_machine_addr(atom a) -- a legal low machine address 
    return a > 0 and a <= LOW_ADDR and floor(a) = a
end type
--------------------------------------------------------------------------------
type machine_addr(atom a) -- a 32-bit non-null machine address 
	if not atom(a) then return FALSE end if
 	if not integer(a)then
		if floor(a) != a then return FALSE end if
	end if
	return a > 0 and a <= MAX_ADDR
end type
--------------------------------------------------------------------------------
type natural(object x)
	if not integer(x) then return 0 end if
	return x >= 0
end type
--------------------------------------------------------------------------------
type positive_int(integer x)
    return x >= 1
end type
--------------------------------------------------------------------------------
-- dependant values
--------------------------------------------------------------------------------
type ext_addr(object a) -- external address
	return machine_addr(a)
end type
--------------------------------------------------------------------------------
type far_addr(sequence a) -- protected mode far address {seg, offset}
    return length(a) = 2 and integer(a[1]) and machine_addr(a[2])
end type
--------------------------------------------------------------------------------
type int_addr(object a) -- internal address
	return machine_addr(a)
end type
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global type bordered_address(ext_addr addr)
	sequence l
	for i = 1 to length(safe_address_list) do
		if safe_address_list[i][BLOCK_ADDRESS] = addr then
			l = peek({addr - BORDER_SPACE, BORDER_SPACE})
			return equal(l, LEADER)
		end if
	end for
	return 0
end type
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
atom allocation_num allocation_num = 0
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer check_calls check_calls = 1
global integer edges_only edges_only = (platform()=2)
global sequence safe_address_list safe_address_list = {} 
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
global procedure register_block(machine_addr block_addr, positive_int block_len)	-- registers an externally-acquired block of memory as being safe to use
    allocation_num += 1
    safe_address_list = prepend(safe_address_list, {block_addr, block_len,
                -allocation_num})
end procedure
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
--Date: 2017.08.22
--Status: created; incomplete
--Changes:]]]
--* defined ##register_block##
--------------------------------------------------------------------------------
