--------------------------------------------------------------------------------
--	Library: memconst.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria321)(include)(std)memconst.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.03
--Status: operational; incomplete
--Changes:]]]
--* local WINDOWS  defined
--* lost ')' added
--
--==Euphoria Standard library: memconst
--
-- This library hold values to support the standard ##memory## library.
--
-- The following are part of the Open Euphoria's standard
-- library and has been tested/amended to function with Eu3.1.1.
--===Constants
--* //M_ALLOC//
--* //M_FREE//
--* //PAGE_EXECUTE//
--* //PAGE_EXECUTE_READ//
--===Types
--===Routines
--
-- Utilise this support by adding the following statement to your module:
--<eucode>include std/memconst.e</eucode>
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
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant PROT_EXEC = 4
constant PROT_READ = 1
constant WINDOWS = 2 -- better than calling os.e
--------------------------------------------------------------------------------
--	Local generators
--------------------------------------------------------------------------------
function plat_or(atom win, atom unix)
    if platform() = WINDOWS then return win
    else return unix    
    end if
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant M_ALLOC = 16
global constant M_FREE = 17
global constant PAGE_EXECUTE = plat_or(#10, PROT_EXEC)
global constant PAGE_EXECUTE_READ = plat_or(#20, or_bits(PROT_READ, PROT_EXEC))
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
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.01
--Status: operational; incomplete
--Changes:]]]
--* mechanism for OS-related values set up
--* //PAGE_EXECUTE// defined accordingly
--* //PAGE_EXECUTE_READ// defined similarly
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.08.04
--Status: operational; incomplete
--Changes:]]]
--* created
--* //M_ALLOC// defined
--* //M_FREE// defined
--------------------------------------------------------------------------------
