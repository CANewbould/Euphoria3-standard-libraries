--------------------------------------------------------------------------------
--	Application: datetime.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Program: (euphoria)(demos)(std)datetime.ex
-- Description: test program for Eu3's datetime routines
------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2021.01.01
--Status: operational
--Changes:]]]
--* dealt with 'eui' vs 'euiw'
--
--==Testing datetime routines
--
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
include std/datetime.e   -- for all routines & constants
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant CLOSURE = "\n*** Press ENTER to close screen ***"
constant LIB = "Date/Time routines"
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
function card(integer i)
    if i = 1 then return "st"
    elsif i = 2 then return "nd"
    elsif i = 3 then return "rd"
    else return "th"
    end if
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
procedure main()
    sequence cmdline
    integer days
    datetime NextWeek
    datetime Now
    datetime Y2020
	Now = now()
	puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "*** Testing " & LIB & " ***" & EOL)
    puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "--- 'now()' ---" & EOL)
    puts(SCREEN, "The date now is: ")
    printf(SCREEN, "%02d-%02d-%4d; time %02d:%02d:%02d" & EOL,
				{Now[3], Now[2], Now[1], Now[4], Now[5], Now[6]})
	puts(SCREEN, "--- default 'format()' ---")
    puts(SCREEN, format(Now, "") & EOL)
    days = years_day(Now)			
    printf(SCREEN, "It is the %d%s day of the year" & EOL, {days, card(days)})
    puts(SCREEN, "In a week's time it will be: ")
    NextWeek = add(Now, 7, DAYS)
    printf(SCREEN, "%02d-%02d-%4d" & EOL, {NextWeek[3], NextWeek[2], NextWeek[1]})           
    printf(SCREEN, "In that time %d minutes will have elapsed" & EOL, {diff(Now, NextWeek)/60})
    puts(SCREEN, "--- 'days_in_month()' ---" & EOL)
    Y2020 = {2020, 2, 12, 00, 00, 00}
    printf(SCREEN, "In %d there were %d days in Feb and %d overall" & EOL,
                {Y2020[1], days_in_month(Y2020), days_in_year(Y2020)})
    cmdline = command_line()
    if equal(cmdline[1], "euiw") then
        puts(SCREEN, EOL & repeat('-', length(CLOSURE)))
        puts(SCREEN, CLOSURE)
        if getc(0) then end if
    end if
end procedure
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2021.01.01
--Status: operational
--Changes:]]]
--* defined internal card function
--* changed 2004 to 2020
--* added test of ##diff##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.12.18
--Status: operational
--Changes:]]]
--* added test of ##years_day##
--* added test of ##add##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.03.19
--Status: operational
--Changes:]]]
--* added test of ##format##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.03.05
--Status: operational
--Changes:]]]
--* created
--------------------------------------------------------------------------------
�1.0