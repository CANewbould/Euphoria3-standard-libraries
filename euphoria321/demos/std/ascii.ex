--------------------------------------------------------------------------------
-- Demonstatration: ascii.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- It is not using text_rows in any way - needs changing
--------------------------------------------------------------------------------
--/*
--= Program: (euphoria3.2.1)(demos)ascii.ex
-- Description: displays ASCII / code page chart in 50 lines-per-screen mode
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.05.03
--Status: operational
--Changes:]]]
--* modified from official 4.0.5 version
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
include std/console.e
include std/graphics.e
include std/graphcst.e
include std/os.e
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
constant SCREEN = 1
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Routines
--
--------------------------------------------------------------------------------
procedure main()
	integer rows
	rows = text_rows(50)

	for i = 0 to 255 do
		if remainder(i, 8) = 0 then
			puts(SCREEN, '\n')
		end if
		if platform() = LINUX then
			if i = 128 then
				if getc(0) then
				end if
			end if
		end if
		if remainder(i, 32) = 0 then
			puts(SCREEN, '\n')
		end if
		printf(SCREEN, "%3d: ", i)
		if i = 0 then
			puts(SCREEN, "NUL ")
		elsif i = 9 then
			puts(SCREEN, "TAB ")
		elsif i= 10 then
			puts(SCREEN, "LF  ")
		elsif i = 13 then
			puts(SCREEN, "CR  ")
		else
			puts(SCREEN, i)
			puts(SCREEN, "   ")
		end if
	end for

	puts(SCREEN, "\n\nPress Enter to close the screen...")
	if getc(0) then end if
end procedure
--------------------------------------------------------------------------------
--/*
-- == Usage
-- {{{
-- /euphoria3.2.1/bin/eu3 ascii
-- }}}
--
-- Close the screen display by ENTER when finished
--*/
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


