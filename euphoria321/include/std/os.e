--------------------------------------------------------------------------------
--	Library: os.e
--------------------------------------------------------------------------------
-- Notes:
--
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)os.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2018.02.24
--Status: operational; incomplete
--Changes:]]]
--* added more OS contants
--
------
--==Euphoria Standard library: os
-- Operating system helpers.
--===Constants
--* ##FREEBSD##
--* ##LINUX##
--* ##NETBSD##
--* ##OPENBSD##
--* ##OSX##
--* ##WINDOWS##
--* ##WIN32##
--
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##instance##
--* ##sleep##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/os.e</eucode>
--
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
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_INSTANCE = 55
constant M_SLEEP = 64
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--/*
--==== OS indicators
--*/
--------------------------------------------------------------------------------
global constant WIN32 = 2
global constant WINDOWS = WIN32
global constant LINUX = 3
global constant OSX = 4
global constant OPENBSD = 6
global constant NETBSD = 7
global constant FREEBSD = 8
--------------------------------------------------------------------------------
--
--=== EuCANOOP property types
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
global function instance()	-- returns hInstance on Windows and Process ID (pid) on Unix
    return machine_func(M_INSTANCE, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Notes:
--
-- In Windows the ##hInstance## can be passed around to various Windows routines.
--*/
--------------------------------------------------------------------------------
global procedure sleep(atom t)	-- go to sleep for t seconds, allowing (on WIN32 and Linux) other processes to run
    if t >= 0 then
	machine_proc(M_SLEEP, t)
    end if
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- # ##t##: the number of seconds for which to sleep.
--
-- Notes:
--
-- The operating system will suspend your process and schedule other processes.
--
-- With multiple tasks, the whole program sleeps, not just the current task. To make
-- just the current task sleep, you can call ##task_schedule##
-- and then execute ##task_yield##. Another option is to call ##task_delay##.
--*/
--------------------------------------------------------------------------------
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.12
--Status: operational; incomplete
--Changes:]]]
--* added definition of ##WINDOWS##
--* added constants to list
--* extended documentation
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.10
--Status: created; operational; incomplete
--Changes:]]]
--* copied directly from Eu3.2.0 folder
--* modified embedded comment
--------------------------------------------------------------------------------
