--------------------------------------------------------------------------------
--	Library: sort.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)sort.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.07
--Status: operational; complete
--Changes:]]]
--* revised for 3.2.0
--* re-defined ##custom_sort##
--
------
--==Euphoria Standard library: sort
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##custom_sort##
--* ##sort##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/sort.e</eucode>
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.19
--Status: operational; complete
--Changes:]]]
--* defined ##sort##
--* defined ##ASCENDING##
--* defined ##DESCENDING##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.11
--Status: created; incomplete
--Changes:]]]
--* defined ##custom_sort##
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
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant ASCENDING = 1
global constant DESCENDING = -1
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
global function custom_sort(integer custom_compare, sequence x, object data, integer order)	-- sorts a sequence
    sequence args
    integer first
    integer gap
    integer j
    integer last
    object result
    object tempi
    object tempj
    args = {0, 0}
	if order >= 0 then
		order = -1
	else
		order = 1
	end if
	if atom(data) then
		args &= data
	elsif length(data) then
		args = append(args, data[1])
	end if
	last = length(x)
	gap = floor(last / 10) + 1
	while 1 do
		first = gap + 1
		for i = first to last do
			tempi = x[i]
			args[1] = tempi
			j = i - gap
			while 1 do
				tempj = x[j]
				args[2] = tempj
				result = call_func(custom_compare, args)
				if sequence(result) then
					args[3] = result[2]
					result = result[1]
				end if
				if compare(result, 0) != order then
					j += gap
					exit
				end if
				x[j+gap] = tempj
				if j <= gap then
					exit
				end if
				j -= gap
			end while
			x[j] = tempi
		end for
		if gap = 1 then
			return x
		else
			gap = floor(gap / 7) + 1
		end if
	end while
end function
--------------------------------------------------------------------------------
global function sort(sequence x, integer order)	-- sorts a sequence into order
	integer first
	integer gap
	integer j 
	integer last
	object tempi
	object tempj
	if order >= 0 then
		order = DESCENDING
	else
		order = ASCENDING
	end if
	last = length(x)
	gap = floor(last / 10) + 1
	while 1 do
		first = gap + 1
		for i = first to last do
			tempi = x[i]
			j = i - gap
			while 1 do
				tempj = x[j]
				if compare(tempi, tempj) != order then
					j += gap
					exit
				end if
				x[j+gap] = tempj
				if j <= gap then
					exit
				end if
				j -= gap
			end while
			x[j] = tempi
		end for
		if gap = 1 then
			return x
		else
			gap = floor(gap / 7) + 1
		end if
	end while
end function
--------------------------------------------------------------------------------
--/*
-- The elements can be atoms or sequences.
-- The standard compare() routine is used to compare elements.
--
-- The (zero) default is ##ASCENDING##.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
