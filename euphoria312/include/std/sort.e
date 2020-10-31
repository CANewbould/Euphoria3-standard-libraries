--------------------------------------------------------------------------------
--	Library: sort.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)sort.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.04.10
--Status: operational; complete
--Changes:]]]
--* documented ##custom_sort##
--* documented ##sort##
--
------
--==Euphoria Standard library: sort
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##custom_sort##
--* ##sort##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/sort.e</eucode>
--
--*/
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
global function custom_sort(integer custom_compare, sequence x)	-- sorts a sequence
    integer first
    integer gap
    integer j
    integer last
    object tempi
    object tempj
    last = length(x)
    gap = floor(last / 10) + 1
    while 1 do
		first = gap + 1
		for i = first to last do
		    tempi = x[i]
		    j = i - gap
		    while 1 do
				tempj = x[j]
				if call_func(custom_compare, {tempi, tempj}) >= 0 then
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
		    gap = floor(gap / 3.5) + 1
		end if
    end while
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##custom_compare##: the routine_id of the sorting function to be used
--# ##x##: a sequence containing the elements to be sorted
--
-- The compare function must be one with two arguments similar to Euphoria's
-- ##compare##. It will similarly compare two objects and return -1, 0 or +1.
--
-- Returns:
--
-- a **sequence**, of the same length as ##x##, containing the same elements,
-- but sorted according to the declared routine
--
-- Notes:
--
-- The elements can be atoms or sequences.
--*/
--------------------------------------------------------------------------------
global function sort(sequence x, integer order)	-- sorts a sequence into order
	integer first
	integer gap
	integer j 
	integer last
	object tempi
	object tempj
	if order < 0 then
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
-- Parameters:
--# ##x##: a sequence containing the elements to be sorted
--# ##order##: the order of sorting (ASCENDING or DESCENDING);
-- the (zero) default is ##ASCENDING##
--
-- Returns:
--
-- a **sequence**, of the same length as ##x##, containing the same elements,
-- but sorted according to the declared order
--
-- Notes:
--
-- The elements can be atoms or sequences.
--
-- The standard ##compare## routine is used to compare elements.
--
-- Any negative value for ##order## will ensure a descending sort; all other
-- values will yield an ascending sort.
--
-- This routine differs from the one defined in RDS's ##sort.e## insofar as
-- there is an option to reverse the order of sorting;
-- hence the second parameter.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
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
