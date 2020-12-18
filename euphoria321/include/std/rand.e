--------------------------------------------------------------------------------
--	Library: rand.e
--------------------------------------------------------------------------------
-- Notes:
--
-- get_rand the only routine undefined - uses machine_func on OE4
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)rand.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.01
--Status: operational; incomplete
--Changes:]]]
--* defined ##set_rand##
--* defined ##chance##
--* defined ##rnd##
--* defined ##rnd_1##
--* defined ##rand_range##
--* defined ##roll##
--* defined ##sample##
--* included reference to ##sequence.e##
--
------
--==Euphoria Standard library: rand
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##chance##
--* ##rnd##
--* ##rnd_1##
--* ##rand_range##
--* ##roll##
--* ##sample##
--* ##set_rand##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/rand.e</eucode>
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--Version:
--Date:
--Author:
--Status:
-- Changes:
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--/*
--=== Includes
--*/
--------------------------------------------------------------------------------
include sequence.e  -- for remove
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_SET_RAND = 35
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
integer rnd_id
integer rnd_1_id
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
global function chance(atom my_limit, atom top_limit)   -- simulates the probability of a desired outcome
	if top_limit = 0 then top_limit = 100 end if
    return (call_func(rnd_1_id, {}) * top_limit) <= my_limit
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# my_limit : the desired chance of something happening.
--# top_limit: the maximum chance of something happening. Defaults to 100 if set to 0.
--
--Returns:
-- An integer: 1 if the desired chance happened otherwise 0.
--*/
--------------------------------------------------------------------------------
global function rand_range(atom lo, atom hi)    -- returns a random integer from a specified inclusive integer range
    atom temp
    if lo > hi then
		temp = hi
		hi = lo
		lo = temp
	end if	
	if not integer(lo) or not integer(hi) then
   		hi = call_func(rnd_id, {}) * (hi - lo)  --rnd() * (hi - lo)
   	else
		lo -= 1
   		hi = rand(hi - lo)
   	end if   	
   	return lo + hi
end function
--------------------------------------------------------------------------------
--/*
--Returns:
-- An atom, randomly drawn between lo and hi inclusive.
--*/
--------------------------------------------------------------------------------
global function rnd()   -- returns a random floating point number in the range 0 to 1
	atom a
    atom b
    atom r
    a = rand(1073741823)    -- maximum value allowed by Eu3 - not OE's(#FFFFFFFF)
    if a = 1 then return 0 end if
    b = rand(1073741823)    -- maximum value allowed by Eu3 - not OE's(#FFFFFFFF)
    if b = 1 then return 0 end if    
    if a > b then
        r = b / a
    else
        r = a / b
    end if    
    return r
end function
rnd_id = routine_id("rnd")
--------------------------------------------------------------------------------
--/*
--Returns:
-- An atom, randomly drawn between 0.0 and 1.0 inclusive.
--*/
--------------------------------------------------------------------------------
global function rnd_1() -- returns a random floating point number in the range 0 to less than 1
	atom r
    r = rnd()	
	while r >= 1.0 do
		r = rnd()
	end while	 
	return r
end function
rnd_1_id = routine_id("rnd_1")
--------------------------------------------------------------------------------
--/*
--Returns:
-- An atom, randomly drawn between 0.0 and a number less than 1.0.
--*/
--------------------------------------------------------------------------------
global function roll(object desired, integer sides) -- simulates the probability of a dice throw
	integer rolled
    if sides = 0 then sides = 6 end if  -- default parameter
	if sides < 2 then
		return 0
	end if
	if atom(desired) then
		desired = {desired}
	end if
	rolled =  rand(sides)
	if find(rolled, desired) then
		return rolled
	else
		return 0
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# desired: one or more desired outcomes.
--# sides: the number of sides on the dice. Defaults to 6 if set to 0.
--
--Returns:
-- an integer: 0 if none of the desired outcomes occurred,
-- otherwise the face number that was rolled.
--*/
--------------------------------------------------------------------------------
global function sample(sequence population, integer sample_size, integer sampling_method)   -- selects a set of random samples from a population set
	integer lChoice
	integer lIdx
	sequence lResult
	if sample_size < 1 then
		-- An empty sample requested.
		if sampling_method > 0 then
			return {{}, population}	
		else
			return {}
		end if
	end if	
	if sampling_method >= 0 and sample_size >= length(population) then
		-- Adjust maximum sample size for WOR method.
		sample_size = length(population)
	end if	
	lResult = repeat(0, sample_size)
	lIdx = 0
	while lIdx < sample_size do
		lChoice = rand(length(population))
		lIdx += 1
		lResult[lIdx] = population[lChoice]		
		if sampling_method >= 0 then
			-- WOR method so remove the item from the population
			population = remove(population, lChoice, 0)  -- default stop = start
		end if
	end while
	if sampling_method > 0 then
		return {lResult, population}	
	else
		return lResult
	end if
end function
--------------------------------------------------------------------------------
--/*
-- This can be done with either the "with-replacement" (< 0)
-- or "without-replacement" (>= 0) methods.
-- When using the "with-replacement" method, after each sample is taken it is
-- returned to the population set so that it could possible be taken again.
-- The "without-replacement" method does not return the sample so these items
-- can only ever be chosen once.
--
-- Parameters:
--# population: the set of items from which to take a sample.
--# sample_size: the number of samples to take.
--# sampling_method:
--## when < 0, "with-replacement" method used;
--## when = 0, "without-replacement" method used and a single set of samples returned;
--## when > 0, "without-replacement" method used and a sequence containing the set of samples (chosen items) and the set unchosen items, is returned.
--
-- Returns:
--
-- A sequence.
-- When sampling_method less than or equal to 0 then this is the set of samples,
-- otherwise it returns a two-element sequence; the first is the samples,
-- and the second is the remainder of the population (in the original order).
--*/
--------------------------------------------------------------------------------
global procedure set_rand(integer seed)	-- resets the random number generator
    machine_proc(M_SET_RAND, seed)
end procedure
--------------------------------------------------------------------------------
--/*
-- A given value of seed will cause the same series of
-- random numbers to be generated from the rand() function.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
