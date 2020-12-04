--------------------------------------------------------------------------------
--	Application: filesys.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- Needs to be checked in WINDOWS - may need command-line test as well
--------------------------------------------------------------------------------
--/*
--= Program: (test)(eu3)machine.ex
-- Description: test program for Eu3's filesys routines
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.12.04
--Status: operational
--Changes:]]]
--* added pathinfo examples from manual
--* revised output layout to use writeln
--* added conditional pause
--
--==Testing filesys routines
--
--# pathinfo tests made OS dependent; "N/A" used for values not-assigned
--
------
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
include std/filesys.e   -- for pathinfo
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant CLOSURE = "\n*** Press ENTER to close screen ***"
constant KEYBOARD = 0
constant LIB = "File System routines"
constant EOL = '\n'
constant SCREEN = 1
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
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
procedure test_pathinfo(sequence path)
    sequence info info = pathinfo(path, 0)
    puts(SCREEN, path & "-> " & EOL)
    for i = 1 to 5 do
        if length(info[i]) = 0 then info[i] = "N/A" end if
            writeln(info[i])
    end for
    writeln(repeat('-', length(path)))
end procedure
--------------------------------------------------------------------------------
procedure writeln(sequence text)
    puts(SCREEN, text & EOL)
end procedure
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
procedure main()
    writeln(repeat('-', length(LIB) + 16))
    writeln("*** Testing " & LIB & " ***")
    writeln(repeat('-', length(LIB) + 16))
    writeln("--- Testing pathinfo ---")
    if platform() = WINDOWS then
        test_pathinfo("C:\\euphoria\\docs\\readme.txt")
    else
        test_pathinfo("/opt/euphoria/docs/readme.txt")
        test_pathinfo("/opt/euphoria/docs/readme")
    end if
    writeln(repeat('-', length(CLOSURE)))
    writeln(CLOSURE)
    writeln(repeat('-', length(CLOSURE)))
    if platform() = WINDOWS then getc(KEYBOARD) end if -- to PAUSE
end procedure
--------------------------------------------------------------------------------
--/*
--==== Running
--*/
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
�1.0
