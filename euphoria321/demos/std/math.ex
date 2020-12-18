--------------------------------------------------------------------------------
--	Application: math.ex
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Program: (euphoria)(examples)(std)math.ex
-- Description: test program for Eu3's math routines
------
--[[[Version: 3.2.1.13
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.05.03
--Status: operational
--Changes:]]]
--* added tests for ##gcd##
--
--==Testing math routines
--
--
------
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--/*
--=== Includes
--*/
--------------------------------------------------------------------------------
include std/math.e   -- for abs, arccos, arcsin, max
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant CLOSURE = "\n*** Press ENTER to close screen ***"
constant LIB = "Mathematical routines"
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
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
procedure heading()
	puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
    puts(SCREEN, "*** Testing " & LIB & " ***" & EOL)
    puts(SCREEN, repeat('-', length(LIB) + 16) & EOL)
end procedure
--------------------------------------------------------------------------------
procedure sub_heading(sequence lib)
	printf(SCREEN, "--- Testing '%s' ---" & EOL, {lib})
end procedure
--------------------------------------------------------------------------------
procedure new_page()
	puts(SCREEN, "***Press ENTER for new screen***")
	if getc(0) then
	    
	end if
	clear_screen()
    heading()
end procedure
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
--/*
--==== Running
--*/
--------------------------------------------------------------------------------
procedure main()
    sequence a
	integer i
	sequence nums
    sequence s
	sequence x
	i = -4
	x = {10.5, -12, 3}
    heading()
    sub_heading("abs")
	puts(SCREEN, "x = ")?x	
	puts(SCREEN, "abs(x) = ")?abs(x)	
	printf(SCREEN, "i = %d; ", i)	
	printf(SCREEN, "abs(i) = %d\n", abs(i))
	sub_heading("arccos")
	s = {-1, 0, 1}
	puts(SCREEN, "s = ")?s	
	puts(SCREEN, "arccos(s) = ")?arccos(s)	
	sub_heading("arcsin")
	puts(SCREEN, "arcsin(s) = ")?arcsin(s)
	sub_heading("max")
	a = {10, 15.4, 3} 	
	puts(SCREEN, "a = ")?a	
	printf(SCREEN, "max(a) = %f\n", max(a))
	puts(SCREEN, "Testing if 43 is in range 2-75: ")
	printf(SCREEN, "result = %d\n", ensure_in_range(43, {2, 75}))
	puts(SCREEN, "Testing if 86 is in range 2-75: ")
	printf(SCREEN, "result = %d\n", ensure_in_range(86, {2, 75}))
	sub_heading("trunc")
	printf(SCREEN, "trunc(9.4) -> %d\n", trunc(9.4))
	puts(SCREEN, "trunc({81, -3.5, -9.999, 5.5}) ->")
	?trunc({81, -3.5, -9.999, 5.5})
	sub_heading("frac")
	printf(SCREEN, "frac(9.4) -> %g\n", frac(9.4))
	puts(SCREEN, "frac({81, -3.5, -9.999, 5.5}) -> ")
	?frac({81, -3.5, -9.999, 5.5})
	sub_heading("ceil")
	nums = {8, -5, 3.14, 4.89, -7.62, -4.3}
	puts(SCREEN, "ceil({8, -5, 3.14, 4.89, -7.62, -4.3}) -> ")
	?ceil(nums)
	sub_heading("intdiv")
	printf(SCREEN, "intdiv(101, 5) -> %g\n", intdiv(101, 5))
	new_page()
	sub_heading("round")
	printf(SCREEN, "round(5.2, 1) -> %g\n", round(5.2, 1))
	puts(SCREEN, "round({4.12, 4.67, -5.8, -5.21}, 10) -> ")
				?round({4.12, 4.67, -5.8, -5.21}, 10)
	printf(SCREEN, "round(12.2512, 100) -> %g\n", round(12.2512, 100))
	sub_heading("trig values")
	printf(SCREEN, "atan2(10.5, 3.1) = %g\n", atan2(10.5, 3.1))
	printf(SCREEN, "deg2rad(194) = %g\n", deg2rad(194))
	printf(SCREEN, "rad2deg(3.385938749) = %g\n", rad2deg(3.385938749))
	sub_heading("logs")
	printf(SCREEN, "log10(12) = %g\n",log10(12))
	sub_heading("Hyperbolics")
	printf(SCREEN, "cosh(0.7) = %g\n", {cosh(0.7)})
	printf(SCREEN, "sinh(0.7) = %g\n", {sinh(0.7)})
	printf(SCREEN, "tanh(0.7) = %g\n", {tanh(0.7)})
	printf(SCREEN, "arcsinh(1) = %g\n", {arcsinh(1)})
	printf(SCREEN, "arccosh(1) = %g\n", {arccosh(1)})
	printf(SCREEN, "arctanh(1/2) = %g\n", {arctanh(1/2)})
	sub_heading("Statistics")
	printf(SCREEN, "sum({10, 20, 30}) = %g\n", {sum({10, 20, 30})})
	printf(SCREEN, "sum({10.5, {11.2} , 8.1}) = %g\n", {sum({10.5, {11.2} , 8.1})})
	printf(SCREEN, "product({10, 20, 30}) = %g\n", {product({10, 20, 30})})
	printf(SCREEN, "product({10.5, {11.2} , 8.1}) = %g\n",
				{product({10.5, {11.2} , 8.1})})
	new_page()
	sub_heading("shift_bits")
	printf(SCREEN, "shift_bits(7, -3) = %g\n", {shift_bits(7, -3)})
	printf(SCREEN, "shift_bits(0, -9) = %g\n", {shift_bits(0, -9)})
	printf(SCREEN, "shift_bits(4, -7) = %g\n", {shift_bits(4, -7)})
	printf(SCREEN, "shift_bits(8, -4) = %g\n", {shift_bits(8, -4)})
--	printf(SCREEN, "shift_bits(0xFE427AAC, -7) = %x\n", {shift_bits(#FE427AAC, -7)})
	printf(SCREEN, "shift_bits(-7, -3) = %x\n", {shift_bits(-7, -3)})
	printf(SCREEN, "shift_bits(131, 0) = %g\n", {shift_bits(131, 0)})
	printf(SCREEN, "shift_bits(184.464, 0) = %g\n", {shift_bits(184.464, 0)})
--	printf(SCREEN, "shift_bits(999_999_999_999_999, 0) = %x\n", {shift_bits(999999999999999, 0)})
	printf(SCREEN, "shift_bits(184, 3) = %g\n", {shift_bits(184, 3)})
	printf(SCREEN, "shift_bits(48, 2) = %g\n", {shift_bits(48, 2)})
	printf(SCREEN, "shift_bits(121, 3) = %g\n", {shift_bits(121, 3)})
	printf(SCREEN, "shift_bits(0xFE427AAC, 7) = %x\n", {shift_bits(#FE427AAC, 7)})
	printf(SCREEN, "shift_bits(-7, 3) = %x\n", {shift_bits(-7, 3)})
	puts(SCREEN, "shift_bits({48, 121}, 2) = ") ? shift_bits({48, 121}, 2)
	new_page()
	sub_heading("rotate_bits")
	printf(SCREEN, "rotate_bits(7, -3) = %x\n", {rotate_bits(7, -3)})
	printf(SCREEN, "rotate_bits(0, -9) = %x\n", {rotate_bits(0, -9)})
	printf(SCREEN, "rotate_bits(4, -7) = %x\n", {rotate_bits(4, -7)})
	printf(SCREEN, "rotate_bits(8, -4) = %x\n", {rotate_bits(8, -4)})
--	printf(SCREEN, "rotate_bits(0xFE427AAC, -7) = #%x\n", {rotate_bits(#FE427AAC, -7)})
	printf(SCREEN, "rotate_bits(-7, -3) = %x\n", {rotate_bits(-7, -3)})
--	new_page()
	sub_heading("gcd")
	printf(SCREEN, "gcd(76.3, -114) = %d\n", {gcd(76.3, -114)})	-- 38
	printf(SCREEN, "gcd(0, -114) = %d\n", {gcd(0, -114)})	-- 114
	printf(SCREEN, "gcd(0, 0) = %d\n", {gcd(0, 0)})	-- 0 (This is often regarded as an error condition)
    puts(SCREEN, EOL & repeat('-', length(CLOSURE)))
    puts(SCREEN, CLOSURE)
    if getc(0) then end if
end procedure
--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.12
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.03.08
--Status: operational
--Changes:]]]
--* added tests for ##rotate_bits##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.11
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.02.21
--Status: operational
--Changes:]]]
--* added tests for ##shift_bits##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.10
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.02.11
--Status: operational
--Changes:]]]
--* added test for ##product##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.02.03
--Status: operational
--Changes:]]]
--* added test for ##arctanh##
--* added test for ##sum##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2020.01.12
--Status: operational
--Changes:]]]
--* added test for ##tanh##
--* added test for ##arcsinh##
--* added test for ##arccosh##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.12.30
--Status: operational
--Changes:]]]
--* added test for ##cosh##
--* added test for ##sinh##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.12.19
--Status: operational
--Changes:]]]
--* added test for ##log10##
--* added test for ##atan2##
--* added test for ##rad2deg##
--* added test for ##deg2rad##
--* heading defined
--* new_page defined
--* thus added pagination
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.11.30
--Status: operational
--Changes:]]]
--* added tests for ##round##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.11.24
--Status: operational
--Changes:]]]
--* added test for ##ceil##
--* added test for ##intdiv##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.11.16
--Status: operational
--Changes:]]]
--* created
--* added tests for ##frac##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.11.07
--Status: operational
--Changes:]]]
--* created
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.10.19
--Status: operational
--Changes:]]]
--* created
--* added tests for ##ensure_in_range##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2019.03.22
--Status: operational
--Changes:]]]
--* created
--* added test for ##abs##
--* added test for ##arccos##
--* added test for ##arcsin##
--* added test for ##max##
--------------------------------------------------------------------------------

