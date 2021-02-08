--------------------------------------------------------------------------------
--	Application: filesys.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Program: (test)filesys.ex
-- Description: test application for the standard library ##filesys.e##
------
--[[[Version: 3.2.1.10
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2021.02.08
--Status: operational
--Changes:]]]
--* added test for ##join_path##
--
--==<detailed description>
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
include std/filesys.e
include std/io.e
include include/utils.e -- for heading, section, closing & EOL
include std/types.e -- for string
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant LIB = "(std)filesys.e"
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
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function look_at(sequence path_name, sequence item)
    puts(SCREEN, path_name & '\\')
    puts(SCREEN, item[1] & EOL)
    return 0
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
--/*
--==== Running
--*/
--------------------------------------------------------------------------------
heading(LIB)
section(EOL & "testing current_dir")
string curr_dir curr_dir = current_dir()
printf(SCREEN, "The current directory is '%s'" & EOL, {curr_dir})
string os os = curr_dir & SLASH & "math.ex"
puts(SCREEN, "Testing using 'math.ex'" & EOL)
section("testing dir")
constant S_C = "; "
sequence bits bits = dir("math.ex")
puts(SCREEN, bits[1][1] & S_C)
puts(SCREEN, bits[1][2] & S_C)
for i = 3 to length(bits[1]) - 1 do
	print(SCREEN, bits[1][i])
	puts(SCREEN, S_C)
end for
print(SCREEN, bits[1][$])
puts(SCREEN, EOL)
section("testing walk_dir")
if walk_dir(curr_dir, routine_id("look_at"), 1, -99999) then end if
section("testing pathname")
--printf(SCREEN, "The pathname is '%s'" & EOL, {pathname(os)})
section("testing pathinfo")
sequence info info = pathinfo(os)
printf(SCREEN, "Path info = %s" & EOL, {info[1]})
printf(SCREEN, "File info = %s" & EOL, {info[2]})
printf(SCREEN, "Name = %s" & EOL, {info[3]})
printf(SCREEN, "Extension = %s" & EOL, {info[4]})
printf(SCREEN, "Drive = %s" & EOL, {info[5]})
section("testing dirname")
printf(SCREEN, "The dirname is '%s'" & EOL, {dirname(os)})
section("testing filename")
printf(SCREEN, "The filename is '%s'" & EOL, {filename(os)})
section("testing very simple filename")
printf(SCREEN, "The filename is '%s'" & EOL, {filename("fred")})
section("testing fileext")
printf(SCREEN, "The file's extension is '%s'" & EOL, {fileext(os)})
section("testing join_path")
printf(SCREEN, "join_path({\"usr\", \"home\", \"john\", \"hello.txt\"}) -> %s" & EOL,
{join_path({"usr", "home", "john", "hello.txt"})})
closing(DEFAULT_MESSAGE)
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2021.01.22
--Status: operational
--Changes:]]]
--* added test for ##pathinfo##
--* added test for ##dirname##
--* added test for ##filename##
--* added test for ##fileext##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2020.12.18
--Status: operational
--Changes:]]]
--* added call to types.e
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.03.26
--Status: operational
--Changes:]]]
--* modified to use //math.ex// as target file
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.5
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.10.16
--Status: operational
--Changes:]]]
--* modified to make ##include## references relative
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.4
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.09
--Status: operational
--Changes:]]]
--* copied
--* commented out tests of routines not yet available
--------------------------------------------------------------------------------
--[[[Version: 3.2.3
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017/07/03
--Status: operational
--Changes:]]]
--* added test for ##dirname##
--------------------------------------------------------------------------------
--[[[Version: 3.2.3
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017/07/03
--Status: operational
--Changes:]]]
--* added test for ##fileext##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.06.29
--Status: operational
--Changes:]]]
--* modified test for ##dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.1
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.06.29
--Status: operational
--Changes:]]]
--* created
--* test for ##current_dir##
--* test for ##dir##
--* test for ##pathinfo##
--* test for ##pathname##
--* tests for ##filename##
--------------------------------------------------------------------------------
