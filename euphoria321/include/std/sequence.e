--------------------------------------------------------------------------------
--	Library: sequence.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)sequence.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2018.03.05
--Status: operational; incomplete
--Changes:]]]
--* defined ##replace##
--
------
--==Euphoria Standard library: sequence
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##binop_ok##
--* ##fetch##
--* ##insert##
--* ##remove##
--* ##replace##
--* ##reverse##
--* ##series##
--* ##splice##
--* ##store##
--* ##valid_index##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/sequence.e</eucode>
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
include types.e -- for FALSE, TRUE, boolean
--------------------------------------------------------------------------------
--
--=== Constants
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
global function binop_ok(object a, object b)    -- checks whether two objects can perform a sequence operation together
	if atom(a) or atom(b) then
		return TRUE
	end if
     -- sequence if reached here	
	if length(a) != length(b) then
		return FALSE
	end if	
	for i = 1 to length(a) do
		if not binop_ok(a[i], b[i]) then
			return FALSE
		end if
	end for	
	return TRUE    -- fall-through
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##a##: the first object to test for compatible shape
--		# ##b##: the second object
--
-- Returns:
--
--	A **boolean**: ##TRUE## if a sequence operation is valid, ##FALSE## otherwise.
--*/
--------------------------------------------------------------------------------
global function fetch(sequence source, sequence indexes)    -- retrieves an element nested arbitrarily deep within a sequence
	object x
	for i = 1 to length(indexes)-1 do
		source = source[indexes[i]]
	end for
	x = indexes[$]
	if atom(x) then
		return source[x]
	else
		return source[x[1]..x[2]]
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--	# ##source##: the sequence from which to fetch
--	# ##indexes##: a sequence of integers, the path to follow to reach the
--   element to return.
--
-- Returns:
--
--		An **object**, which is ##source[indexes[1]][indexes[2]]...[indexes[$]]##
--
-- Errors:
--
--	If the path cannot be followed to its end, an error about reading a
--  nonexistent element, or subscripting an atom, will occur.
--
-- Notes:
--
-- The last element of ##indexes## may be a pair {lower, upper}, in which case
-- a slice of the innermost referenced sequence is returned.
--*/
--------------------------------------------------------------------------------
global function insert(sequence target, object what, integer index) -- returns a new sequence, which is a copy of the target with an object inserted into it, at the stated location
    if sequence(what) then what = {what} end if
    return target[1..index-1] & what & target[index..$]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##target##: the source sequence
--		# ##what##: the object to insert into its copy
--		# ##index##: the position where ##what## should appear
--
-- Returns:
--
-- A **sequence**, which is a copy of ##target## with one more element,
-- (##what##), placed at ##index##.
--
-- Notes:
--
-- ##target## can be a sequence of any shape, and ##what## any kind of object.
--
-- The length of the returned sequence is always **length(target) + 1**.
--
-- If ##target## is a string, ##insert##ing a sequence into it yields a
-- **sequence**, thus the result is no longer a string.
--
-- This function is built into Open Euphoria 4 but is added to the library in
-- this implementation.
--*/
--------------------------------------------------------------------------------
global function remove(sequence target, integer start, integer stop)	-- removes an item, or a range of items from a sequence
	integer lg
	lg = length(target)
    if start = 0 then start = 1 end if
    if stop = 0 then stop = lg end if
	if (start < 1) or (start > lg) then return target end if
	if stop < start then stop = start end if
	return target[1..start-1] & target[stop+1..lg]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##target##: the sequence to operate on.
--# ##start##: the starting point.  Defaults to 1 if set to 0.
--# ##stop##: the end point. Defaults to the last element if set to 0.
--
-- Returns:
--
-- A **sequence**, obtained from ##target## by carving the ##start..stop## slice
-- out of it.
--
-- Notes:
--
--   A new sequence is returned.
--
-- The ##target## can be a string or a complex sequence.
--*/
--------------------------------------------------------------------------------
global function replace(sequence this, object replacement, integer start, integer stop)	-- replaces a slice of the original
		return this[1..start-1] & replacement & this[stop+1..$]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: the sequence to operate on
--# ##replacement##: the replacement value
--# ##start##: the starting point
--# ##stop##: the end point
--
-- Returns:
--
-- A **sequence**, obtained from ##this## by carving the ##start..stop## slice
-- out of it and putting the replacement there instead.
--
-- Notes:
--
--   A new sequence is returned.
--
-- The object **sequence** can be a string or a complex sequence.
--*/
--------------------------------------------------------------------------------
global function reverse(sequence target, integer pFrom, integer pTo)	-- reverses the order of elements in a sequence
    integer lLimit
    integer n
	sequence t
	integer uppr
    if pFrom = 0 then pFrom = 1 end if  -- set default
	n = length(target)
	if n < 2 then
		return target
	end if
	if pFrom < 1 then
		pFrom = 1
	end if
	if pTo < 1 then
		pTo = n + pTo
	end if
	if pTo < pFrom or pFrom >= n then
		return target
	end if
	if pTo > n then
		pTo = n
	end if
	lLimit = floor((pFrom+pTo-1)/2)
	t = target
	uppr = pTo
	for lowr = pFrom to lLimit do
		t[uppr] = target[lowr]
		t[lowr] = target[uppr]
		uppr -= 1
	end for
	return t
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##target##: the sequence to reverse.
--# ##pFrom##: the starting point.  Defaults to 1 if set to 0.
--# ##pTo##: the end point. See the notes below for how to relate to the sequence's end.
--
-- Returns:
--
--	A **sequence**, the same length as ##target##
-- and the same elements, but those with index between ##pFrom## and ##pTo##
-- appear in reverse order.
--
-- Notes:
--
-- In the result sequence, some or all top-level elements appear in reverse order compared
-- to the original sequence. This does not reverse any sub-sequences found in the original
-- sequence.
--
-- The ##pTo## parameter can be negative, which indicates an offset from the last element.
-- Thus a value of -1 refers to the second-last element.
-- 
-- A value of 0 refers to the last element.
--*/
--------------------------------------------------------------------------------
global function series(object start, object increment, integer count, integer op)   -- returns a new sequence built to a given specification
	sequence result
    if op = 0 then op = '+' end if  -- default
    -- deal with simple cases
	if count < 0 then return 0 end if
	if not binop_ok(start, increment) then return 0 end if	
	if count = 0 then return {} end if
    -- now it gets serious	
	result = repeat(0, count)
	result[1] = start
    if op = '+' then
		for i = 2 to count  do
			start += increment
			result[i] = start
		end for
	elsif op = '*' then
		for i = 2 to count do
			start *= increment
			result[i] = start
		end for
	else
		return 0
	end if
	return result
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##start##: the initial value from which to start
--# ##increment##: the value to add recursively to ##start## to produce
--    the new elements
--# ##count##:  the number of items in the returned sequence.
--# ##operation##: the type of operation used to build the series.
--    Can be either '+' for a linear series or '*' for a geometric series.
--    The default [0] is '+'.
--
-- Returns:
--
--		An **object**, either:
--*     0, on failure, or
--*     a sequence containing the series.
--
-- Notes:
--
-- * The first item in the returned series is always ##start##.
-- * A //linear// series is formed by **adding** ##increment## to ##start##.
-- * A //geometric// series is formed by **multiplying** ##increment## by ##start##.
-- * If ##count## is negative, or if ##start## **##op##** ##increment## is invalid,
-- then 0 is returned. Otherwise, a sequence is returned, of length
-- ##count+1##. This starts with ##start## and each adjacent elements differ
-- by ##increment##.
--*/
--------------------------------------------------------------------------------
global function splice(sequence target, object what, integer index) -- inserts an object as a new slice in a sequence at a given position
    return target[1..index-1] & what & target[index..$]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##target##: the sequence awaiting insertion
--		# ##what##: the object to insert
--		# ##index##: the position in ##target## where ##what## should appear
--
-- Returns:
--
--		A **sequence**, which is ##target## with one or more elements, those of ##what##,
--      inserted at locations starting at ##index##.
--
-- Notes:
--
-- ##target## can be a sequence of any shape, and ##what## any kind of object.
--
-- The length of this new sequence is the sum of the lengths of ##target## and ##what##.
--
-- ##splice## is equivalent to
-- ##insert## when ##what## is an atom, but not when it is a sequence.
--
-- Splicing a string into a string results into a new string.
--
-- This function is built into Open Euphoria 4 but is added to the library in
-- this implementation.
--*/
--------------------------------------------------------------------------------
global function store(sequence target, sequence indexes, object x)  -- stores an object at a location nested arbitrarily deep into a sequence
    sequence branch
	object last_idx
	sequence partials
    sequence result
	partials = repeat(target, length(indexes)-1)
	branch = target
	for i = 1 to length(indexes)-1 do
		branch = branch[indexes[i]]
		partials[i] = branch
	end for
	last_idx = indexes[$]
	if atom(last_idx) then
		branch[last_idx] = x
	else
		branch[last_idx[1]..last_idx[2]] = x
	end if
	partials = prepend(partials, 0) -- avoids computing temp=i+1 a few times
	for i = length(indexes)-1 to 2 by -1 do
		result = partials[i]
		result[indexes[i]] = branch
		branch = result
	end for
	target[indexes[1]] = branch
	return target
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##target##: the sequence in which to store something
--		# ##indexes##: a sequence of integers, the path to follow to reach the
--                     place where to store
--		# ##x##: the object to store.
--
-- Returns:
--
--		A **sequence**: a **copy** of ##target## with the specified place
--      ##indexes## modified by storing ##x## into it.
--
-- Errors:
--
--	If the path to storage location cannot be followed to its end, or an
--  index is not what one would expect or is not valid, an error about illegal
--  sequence operations will occur.
--
-- Notes:
--
-- If the last element of ##indexes## is a pair of integers, ##x## will be
-- stored as a slice three, the bounding indexes being given in the pair as {lower, upper}..
--
-- In Euphoria, you can never modify an object by passing it to a routine.
-- You have to get a modified copy and then assign it back to the original.
--*/
--------------------------------------------------------------------------------
global function valid_index(sequence st, object x)  -- checks whether an index exists on a sequence
	if not atom(x) then
		return 0
	end if
	if x < 1 then
		return 0
	end if
	if floor(x) > length(st) then
		return 0
	end if
	return 1
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##s## : the sequence for which to check
--		# ##x## : the index to check.
--
-- Returns:
--
-- 		A **boolean**: ##TRUE## if ##s[x]## makes sense, ##FALSE## otherwise.
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.10.13
--Status: operational; incomplete
--Changes:]]]
--* revised to include ##types.e##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.10.13
--Status: operational; incomplete
--Changes:]]]
--* minor editorial changes to documentation
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.10.05
--Status: operational; incomplete
--Changes:]]]
--* function ##insert## added from OE4
--* function ##splice## added from OE4
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.09.19
--Status: operational; incomplete
--Changes:]]]
--* function ##series## added from OE4
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.09.13
--Status: operational; incomplete
--Changes:]]]
--* function ##fetch## added from OE4
--* function ##store## added from OE4
--* function ##valid_index## added from OE4
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.09.02
--Status: operational; incomplete
--Changes:]]]
--* function ##reverse## added from eu3.2.0
--* embedded documentation for ##remove## improved
--* function ##binop_ok## added from OE4
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2017.09.01
--Status: created; incomplete
--Changes:]]]
--* function ##remove## defined
-- Changes:
--------------------------------------------------------------------------------
