--------------------------------------------------------------------------------
--	Application: console.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- Awaiting test of display routine
--------------------------------------------------------------------------------
--/*
--= Program: (euphoria)(examples)(std)console.ex
-- Description: test program for Eu3's console routines
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.03.29
--Status: operational; incomplete
--Changes:]]]
--* created
--* added full range of tests
--
--==Testing console routines
--
-- This "application" show-cases the examples embedded in the documentation for
-- Euphoria.
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
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
constant CLOSURE = "\n*** Press ENTER to close screen ***"
constant EOL = '\n'
constant LIB = "Console routines"
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
    integer age
	integer n
	sequence name
	sequence s
	puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "*** Testing " & LIB & " ***" & EOL)
    puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "--- Testing get_key ---" & EOL)
	n = get_key()
	if n = -1 then
	    puts(SCREEN, "No key waiting.\n")
	end if
    puts(SCREEN, "--- Testing prompt_number ---" & EOL)
	age = prompt_number("What is your age? ", {0, 150})
    puts(SCREEN, "--- Testing prompt_string ---" & EOL)
	name = prompt_string("What is your name? ")
    puts(SCREEN, "--- Testing any_key ---" & EOL)
	any_key("Press Any Key to clear the screen", SCREEN)
	clear_screen()
	puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "*** Testing " & LIB & " ***" & EOL)
    puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "--- Testing characters on screen ---" & EOL)
    puts(SCREEN, "A 'T' will appear towards the bottom of the screen"
				& EOL
				& "When you are ready hit a key to clear screen again"
				& EOL)
    s = get_screen_char(2, 5, 0)
    put_screen_char(25, 10, s)
    n = wait_key()
	clear_screen()
    puts(SCREEN, "--- Displaying text images ---"
				& EOL
				& "You will see upper-case letters in different colours"
				& " half way down the screen"
				& EOL
				& "When you are ready hit a key to clear screen again"
				& EOL)
	display_text_image({15,1}, {{'A', WHITE, 'B', GREEN},
                           		{'C', RED+16*WHITE},
                           		{'D', BLUE}})
    n = wait_key()
	clear_screen()
    puts(SCREEN, "--- Testing cursor ---"
				& EOL
				& "You will see the shape of the cursor change"
				& EOL)
    cursor(BLOCK_CURSOR)
	puts(SCREEN, EOL & repeat('-', length(CLOSURE)))
    puts(SCREEN, CLOSURE)
    if getc(0) then end if
end procedure
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
