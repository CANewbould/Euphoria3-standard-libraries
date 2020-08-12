--------------------------------------------------------------------------------
--	Demo: queens.ex
--
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--=Application: (demos)(std)queens.ex 
-- Description:  solves the N queens problem - how to place N queens on an NxN
-- chess board so they do not attack each other
--
------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.05.01
--Status: operational; complete
--Changes:]]]
--* moved from v4.0.5
--* converted to CAN's standard format
--
------
--==The Queens' Problem
--
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
constant N = 8 -- try some other sizes
constant ROW = 1, COLUMN = 2
constant TRUE = 1, FALSE = 0
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
type square(sequence x)
-- a square on the board
    return length(x) = 2
end type
--------------------------------------------------------------------------------
type row(integer x)
-- a row on the board
    return x >= 1 and x <= N
end type
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
integer soln    soln = 0 -- solution number
--------------------------------------------------------------------------------
--
--=== Routines
--
--------------------------------------------------------------------------------
function threat(square q1, square q2)   -- do two queens threaten each other?
    if q1[COLUMN] = q2[COLUMN] then
	return TRUE
    elsif q1[ROW] - q1[COLUMN] = q2[ROW] - q2[COLUMN] then
	return TRUE
    elsif q1[ROW] + q1[COLUMN] = q2[ROW] + q2[COLUMN] then
	return TRUE
    elsif q1[ROW] = q2[ROW] then
	return TRUE
    else
	return FALSE
    end if
end function
--------------------------------------------------------------------------------
function conflict(square q, sequence queens)    -- Would square p cause a conflict with other queens on board so far?
    for i = 1 to length(queens) do
	if threat(q, queens[i]) then
	    return TRUE
	end if
    end for
    return FALSE
end function
--------------------------------------------------------------------------------
procedure print_board(sequence queens)  -- print a solution, showing the Queens on the board
    integer k
    position(1, 1)
    printf(1, "Solution #%d\n\n  ", soln)
    for c = 'a' to 'a' + N - 1 do
	printf(1, "%2s", c)
    end for
    puts(1, "\n")
    for r = 1 to N do
	printf(1, "%2d ", r)
	for c = 1 to N do
	    if find({r,c}, queens) then
		puts(1, "Q ")
	    else
		puts(1, ". ")
	    end if
	end for
	puts(1, "\n")
    end for
    puts(1, "\nPress Enter. (q to quit) ")
    while TRUE do
	k = get_key()
	if k = 'q' then
	    abort(0)
	elsif k != -1 then
	    exit
	end if
    end while
end procedure
--------------------------------------------------------------------------------
procedure place_queen(sequence queens)
-- place queens on a NxN chess board
-- (recursive procedure)
    row r -- only need to consider one row for each queen
    if length(queens) = N then
	soln += 1
	print_board(queens)
	return
    end if
    r = length(queens)+1
    for c = 1 to N do
	if not conflict({r,c}, queens) then
	    place_queen(append(queens, {r,c}))
	end if
    end for
end procedure
--------------------------------------------------------------------------------
procedure main()
    clear_screen()
    place_queen({})
end procedure
--------------------------------------------------------------------------------
-- Execution
--------------------------------------------------------------------------------
main()
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

