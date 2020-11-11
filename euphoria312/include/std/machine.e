--------------------------------------------------------------------------------
--	Library: machine.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)machine.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.7
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.19
--Status: operational; complete
--Changes:]]]
--* documentation extended for ##unregister_block##
--
------
--==Euphoria Standard library: machine
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##allocate##
--* ##allocate_string##
--* ##free##
--* ##register_block##
--* ##unregister_block##
--
-- Utilise these routines by adding the following statement to your module:
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
--Parameter:
--# ##n##: the number of bytes to allocate
--
--Returns:
--
--* the address of the block of memory, or
--* 0 if the memory can't be allocated.
-- The address returned will be at least 4-byte aligned
--
-- Notes:
--
--When you are finished using the block, you should pass the address of the
-- block to ##free##. This will free the block and make the memory available
-- for other purposes. Euphoria will never free or reuse your block until you
-- explicitly call ##free##. When your program terminates, the operating system
-- will reclaim all memory for use with other programs. 
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
--Parameter:
--# ##s##: the string to be stored
--
--Returns:
--
--	a pointer to the memory address where the string is stored 
--
-- Notes:
--
-- The string is terminated with a 0 character.
-- This is the format expected for C strings.
-- If there is not enough memory available, 0 will be returned.
--*/
--------------------------------------------------------------------------------
global procedure free(machine_addr a)	-- frees the memory at address a
    machine_proc(M_FREE, a)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##a##: the address of the start of the block,
-- i.e. the address that was returned by ##allocate##.
--
-- Notes:
--
--This routine frees up a previously allocated block of memory.
--
-- Use ##free## to recycle blocks of memory during execution.
-- This will reduce the chance of running out of memory or getting into
-- excessive virtual memory swapping to disk.
-- Do not reference a block of memory that has been freed.
-- When your program terminates, all allocated memory will be returned
-- to the system.   
--*/
--------------------------------------------------------------------------------
global procedure register_block(atom block_addr, atom block_len)	-- see safe.e for usage
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##block_addr##: the start address of the block
--# ##block_len##: the length of the block
--
-- Notes:
--
-- This routine is only meant to be used for debugging purposes.
-- The library ##safe.e## tracks the blocks of memory that your program is
-- allowed to ##peek##, ##poke##, ##mem_copy## etc.
-- These are normally just the blocks that you have allocated using Euphoria's
-- ##allocate## routine, and which you have not yet freed using Euphoria's
-- ##free## routine.
-- In some cases, you may acquire additional, external, blocks of memory,
-- perhaps as a result of calling a C routine.
-- If you are debugging your program using ##safe.e##, you must register these
-- external blocks of memory or ##safe.e## will prevent you from accessing them.
-- When you are finished using an external block you can unregister it using
-- ##unregister_block##.
-- 
-- When you include machine.e, you'll get different versions of ##register_block##
-- and ##unregister_block## that do nothing.
-- This makes it easy to switch back and forth between debug and non-debug runs
-- of your program. 
--*/
--------------------------------------------------------------------------------
global procedure unregister_block(atom block_addr)	-- see safe.e for usage
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##block_addr##: the start address of the block
--
-- Notes:
--
-- In machine.e, this procedure does nothing.
-- It is there to simplify switching between the normal and debug version
-- of the library.
--
-- This routine is only meant to be used for debugging purposes.
-- Use it to unregister blocks of memory that you have previously registered
-- using ##register_block##.
-- By unregistering a block, you remove it from the list of safe blocks
-- maintained by ##safe.e##.
-- This prevents your program from performing any further reads or writes of
-- memory within the block.
--
-- See ##register_block## for further comments. 
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.17
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##register_block##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.11
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##free##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.02.09
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##allocate_string##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.11.26
--Status: operational; incomplete
--Changes:]]]
--* documentation extended for ##allocate##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.22
--Status: operational; incomplete
--Changes:]]]
--* defined ##register_block## - dummy
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
