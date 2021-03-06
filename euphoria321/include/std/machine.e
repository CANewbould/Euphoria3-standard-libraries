--------------------------------------------------------------------------------
--	Library: machine.e
--------------------------------------------------------------------------------
-- Notes:
--
-- allocate_string is still the Eu3 version
-- poke2 needs to be added; might need to look at conversion then standard poking
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)machine.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.02.24
--Status: operational; incomplete
--Changes:]]]
--* documentation slightly modified
--
------
--==Euphoria Standard library: machine
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##allocate##
--* ##allocate_data##
--* ##allocate_pointer_array##
--* ##allocate_string##
--* ##free##
--* ##free_pointer_array##
--* ##peek2u##
--* ##peek_string##
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
include memory.e as memory -- for deallocate
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant MAX_ADDR = power(2, 32) - 1	-- biggest address on a 32-bit machine
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant ADDRESS_LENGTH = 4
global constant BORDER_SPACE = 0
global constant PAGE_READ_WRITE = #04
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
procedure poke_pointer(atom address, object x)
	poke4(address, x)
end procedure
--------------------------------------------------------------------------------
function prepare_block(atom addr, integer a, integer protection)
	-- Only implemented in safe.e
	return addr
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function allocate(positive_int n)	-- allocates n bytes of memory; returns the address
    return machine_func(M_ALLOC, n)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //n//: the size of the requested block
--
-- Returns:
--
-- either:
--* an **atom**: the address of the allocated memory, or
--* //0// if the memory cannot be allocated.
--
-- You must use either an atom or an object to
-- receive the returned value as sometimes the returned memory address is
-- too larger for an **integer** to hold.
--
-- Notes:
--
-- Since ##allocate## acquires memory from the system, it is the programmer's
-- responsiblity to return that memory when the application no longer needs it, by
-- calling the ##free## function to release the memory back to the system.
--
-- When your program terminates, however, the operating system will reclaim
-- all memory that your applicaiton acquired anyway.
--
-- An address returned by this function shouldn't be passed to ##call##.
--*/
--------------------------------------------------------------------------------
global function allocate_data(positive_int n)	-- allocates a contiguous block of data memory
    atom a
    atom sla
    a = machine_func(M_ALLOC, n+BORDER_SPACE*2)
    sla = prepare_block(a, n, PAGE_READ_WRITE)
    return sla
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //n//: the size of the requested block
--
-- Returns:
--
-- either:
--* an **atom**: the address of the allocated memory, or
--* //0// if the memory can't be allocated.
--
-- You must use either an atom or object to receive the returned value as
-- sometimes the returned memory address is too larger for an integer to hold.
--
-- Notes:
--
-- Since ##allocate## acquires memory from the system, it is your responsiblity
-- to return that memory when your application is done with it.
-- There are two ways to do that - automatically or manually.
--* Automatically - If the cleanup parameter is non-zero, then the memory is
-- returned when the variable that receives the address goes out of scope and
-- is not referenced by anything else.
-- Alternatively you can force it be released by calling the ##delete## function. 
--* Manually - If the cleanup parameter is zero, then you must call the ##free##
-- function at some point in your program to release the memory back to the system. 
--
-- When your program terminates, the operating system will reclaim all memory
-- that your applicaiton acquired anyway. 
--
-- An address returned by this function shouldn't be passed to ##call##.
--
-- The address returned will be at least 8-byte aligned. 
--*/
--------------------------------------------------------------------------------
global function allocate_pointer_array(sequence pointers)	-- allocates a NULL terminated pointer array
	atom pList
	integer len len = length(pointers) * ADDRESS_LENGTH
    pList = allocate(len + ADDRESS_LENGTH)
    poke_pointer(pList, pointers)
    poke_pointer(pList + len, 0)
    return pList
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //pointers: a sequence of pointers to be stored
--
-- Returns:
--
-- an **atom**: the pointer to the start of the stored array
--
-- Notes:
--
-- This function adds the NULL terminator.
--*/
--------------------------------------------------------------------------------
global function allocate_string(sequence s)	-- creates a C-style null-terminated string in memory
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
--# //s//: the string to store in RAM.
--
-- Returns:
--
-- either:
--*  an **atom**, the address of the memory block where the string is
-- stored, or
--* //0// on failure.
--
-- Notes:
--
-- Only the 8 lowest bits of each atom in //s// are stored. Use
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
-- Parameter:
--# //addr//: either a single atom or a sequence of atoms;
-- these are addresses of a blocks to free. 
-- 
-- Notes:
--* Use ##free## to return blocks of memory used during execution.
-- This will reduce the chance of running out of memory or getting into
-- excessive virtual memory swapping to disk. 
--* Do not reference a block of memory that has been freed. 
--* When your program terminates, all allocated memory will be returned
-- to the system. 
--* //addr// must have been allocated previously using ##allocate##.
-- You cannot use it to relinquish part of a block.
-- Instead, you have to allocate a block of the new size, copy useful contents
-- from old block there and then use ##free## on the old block. 
--* An //addr// of zero is simply ignored. 
--
--*/
--------------------------------------------------------------------------------
global procedure free_pointer_array(atom pointers_array) -- frees a NULL terminated pointers array
    atom ptr
    atom saved
    saved = pointers_array
    ptr = peek4u(pointers_array)
	while ptr do
		memory:deallocate(ptr)
		pointers_array += ADDRESS_LENGTH
	--entry
		ptr = peek4u(pointers_array)
	end while
	free(saved)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //pointers_array//: memory address where the NULL terminated array starts
--
-- Notes:
--
--   This is for NULL terminated lists, such as allocated by ##allocate_pointer_array##.
--   Do not call ##free_pointer_array## for a pointer that was allocated to be cleaned
--   up automatically.  Instead, use ##delete##.
--*/
--------------------------------------------------------------------------------
global function peek_string(atom addr)	-- reads an ASCII string in RAM, starting from a supplied address
	atom ptr
	sequence str
	ptr = addr	-- start at beginning
	str = ""
	while peek(ptr) do
		str &= peek(ptr)
		ptr += 1
	end while	-- ends when a 'NULL' is found
	return str
end function
--------------------------------------------------------------------------------
--/*
--Parameter:
--# //addr//: the address at which to start reading 
--
-- Returns:
--
-- a **sequence** of bytes: the NULL-terminated string
--
-- Errors:
--
-- Further, ##peek## memory that doesn't belong to your process is something
-- the operating system could prevent, and you'd crash with a machine level
-- exception.
--
-- Notes:
--
-- An ASCII string is any sequence of bytes and ends with a 0 byte.
-- If you use ##peek_string## at some place where there is no string, you will get
-- a sequence of garbage.
--*/
--------------------------------------------------------------------------------
function peek2u_(atom addr) --> atom
	sequence peeked peeked = peek({addr,2})
	return peeked[2] * 256 + peeked[1]
end function
--------------------------------------------------------------------------------
global function peek2u(object addr_n_length) --> [object] atom|vector (integral)
	sequence ret
	atom addr
	integer len
	if atom(addr_n_length) then return peek2u_(addr_n_length)
	else    
		addr = addr_n_length[1]
		len = addr_n_length[2]
		ret = {}
		for i = 1 to len do
			ret &= peek2u_(addr)
			addr += 2
		end for
		return ret
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //addr_n_length//: either
--## an **atom**: to fetch one double word at the stated address, or
--## a **sequence** pair {addr,len}: to fetch len double words starting at //addr//
--
-- Returns:
--
-- either
--* an **integer** if the input was a single address, or
--* a **sequence** of integers if a sequence was passed.
--
-- In both cases, integers returned are words, in the range 0..65535.
--
-- Errors:
--
-- Using ##peek## in memory you don't own may be blocked by the OS, and cause a machine exception.
-- If you use the define safe these routines will catch these problems with a EUPHORIA error.
--
-- When supplying a {address, count} sequence, the count must not be negative.
--
-- Notes:
--
-- Since addresses are 32-bit numbers, they can be larger than the largest value of type
-- integer (31-bits). Variables that hold an address should therefore be declared as atoms.
--
-- It is faster to read several words at once using the second form of ##peek2u##than it is
-- to read one word at a time in a loop.
-- The returned sequence has the length you asked for on input.
--
-- Remember that ##peek2## takes just one argument,
-- which in the second form is actually a 2-element sequence.
--
-- The only difference between ##peek2s## and ##peek2u// is how words with the highest bit
-- set are returned. The function ##peek2s## assumes them to be negative, while ##peek2u##
-- just assumes them to be large and positive.
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
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.19
--Status: operational; incomplete
--Changes:]]]
--* ##peek2u## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.08.04
--Status: operational; incomplete
--Changes:]]]
--* ##free_pointer_array## defined
--* //M_ALLOC// and //M_FREE// deleted, as now available through memory.e
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.11
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##free##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.09
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##allocate_string##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.08
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##allocate##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.10.21
--Status: operational; incomplete
--Changes:]]]
--* defined ##peek_string##
--* defined ##allocate_pointer_array##
--* added ##ADDRESS_LENGTH##
--* defined local routine poke_pointer
--* defined ##allocate_data##
--* added ##BORDER_SPACE##
--* added ##PAGE_READ_WRITE##
--* defined local routine prepare_block
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.10
--Status: operational; incomplete
--Changes:]]]
--* copied directly from Eu3.2.0 folder
--------------------------------------------------------------------------------
