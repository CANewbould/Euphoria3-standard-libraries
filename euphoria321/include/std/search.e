--------------------------------------------------------------------------------
--	Library: search.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)search.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version:3.2.1.4
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2020.12.18
--Status: operational; incomplete
--Changes:]]]
--* ##begins## defined
--
------
--==Euphoria Standard library: search
--===Constants
--
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##begins##
--* ##find_any##
--* ##match_replace##
--* ##rfind##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/search.e</eucode>
--
------
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
include sequence.e	-- for replace
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant FALSE = 0
constant TRUE = 1
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
global function begins(object sub_text, sequence full_text) -- tests whether a sequence is the head of another one
    integer lenf
    integer lens
    lenf = length(full_text)
    if lenf = 0 then return 0
    end if
    if atom(sub_text) then
	if equal(sub_text, full_text[1]) then
	    return TRUE
	else
	    return FALSE
	end if
    end if
    lens = length(sub_text)
    if lens > lenf then
	return FALSE
    end if
    if equal(sub_text, full_text[1..lens]) then
	return TRUE
    else
	return FALSE
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //sub_text//: the possible leading sub-sequence
--# //full_text//: the full sequence to search
--
-- Returns:
--
-- a **boolean**: //TRUE// if //sub_text// begins //full_text//
--
-- Notes:
--
--  If //sub_text// is an empty sequence, this returns //TRUE// unless //full_text// 
--  is also an empty sequence.  When they are both empty sequences this returns 
--  //FALSE//.
--
-- Example:
-- <eucode>s = begins("abc", "abcdef")
-- -- s is 1
-- s = begins("bcd", "abcdef")
-- -- s is 0</eucode>
--
-- See Also:
--
-- ##ends##, ##head##
--*/
--------------------------------------------------------------------------------
global function find_any(object needles, sequence haystack, integer start)	-- finds, inside a sequence, any element from a list
	if start <= 0 or start > length(haystack) then start = 1 end if
	if atom(needles) then
		needles = {needles}
	end if
	for i = start to length(haystack) do
		if find(haystack[i], needles) then
			return i
		end if
	end for
	return 0
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##needles##: the list of items to look for
--# ##haystack##: the sequence to search in
--# ##start##: the starting point of the search
--
-- Returns:
--
-- an **integer**: the smallest index in ##haystack## where any element of 
--##needles## is found, or 0 if no needle is found.
--
-- Notes:
--
-- This function may be applied either to a string sequence or a complex
-- sequence.
--*/
--------------------------------------------------------------------------------
global function match_replace(object needle, sequence haystack, object replacement, integer max)    -- finds a "needle" in a "haystack", and replace any, or only the first few, occurrences with a replacement
	integer cnt
    integer needle_len
	integer posn
	integer replacement_len
	integer scan_from
	if max < 0 then
		return haystack
	end if	
	cnt = length(haystack)
	if max != 0 then
		cnt = max
	end if	
	if atom(needle) then
		needle = {needle}
	end if
	if atom(replacement) then
		replacement = {replacement}
	end if
	needle_len = length(needle) - 1
	replacement_len = length(replacement)
	scan_from = 1
	posn = match_from(needle, haystack, scan_from)
	while posn do
		haystack = replace(haystack, replacement, posn, posn + needle_len)
		cnt -= 1
		if cnt = 0 then
			exit
		end if
		scan_from = posn + replacement_len
    	posn = match_from(needle, haystack, scan_from)
	end while
	return haystack
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--
--		# ##needle##: an non-empty sequence or atom to search and perhaps replace
--		# ##haystack##: a sequence to be inspected
--		# ##replacement##: an object to substitute for any (first) instance of ##needle##
--		# ##max##: an integer, 0 to replace all occurrences
--
-- Returns:
--
--		A **sequence**: the modified ##haystack##.
--
-- Notes:
--
-- Replacements will not be made recursively on the part of ##haystack## that was already changed.
--
-- If ##max## is 0 or less, any occurrence of ##needle## in ##haystack## will be replaced by ##replacement##. Otherwise, only the first ##max## occurrences are.
--
-- If either ##needle## or ##replacement## are atoms they will be treated as if you had passed in a 
-- length-1 sequence containing the said atom. 
--
-- If ##needle## is an empty sequence, an error will be raised and your program will exit. 
--*/
--------------------------------------------------------------------------------
global function rfind(object needle, sequence haystack, integer start)	-- finds a needle in a haystack in reverse order
	integer len
	len = length(haystack)
	if start = 0 then start = len end if
	if (start > len) or (len + start < 1) then
	    return 0
	end if
	if start < 1 then
	    start = len + start
	end if
	for i = start to 1 by -1 do
	    if equal(haystack[i], needle) then
		return i
	    end if
	end for
	return 0
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##needle##: the object to search for
--   # ##haystack##: the sequence to search in
--   # ##start##: the starting index position (default [0] -> length(##haystack##))
--     
-- Returns:
--
--   an **integer**: 0 if no instance of ##needle## can be found in ##haystack## before
--   ##start##; otherwise the highest such index.
--
-- Notes: 
--
--   If ##start## is less than 1, it will be added once to length(##haystack##)
--   to designate a position counted backwards. Thus, if ##start## is -1, the
--   first element to be queried in ##haystack## will be ##haystack[$-1]##,
--   then ##haystack[$-2]## and so on.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version:3.2.1.3
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.03.11
--Status: operational; incomplete
--Changes:]]]
--* ##find_any## defined
--------------------------------------------------------------------------------
--[[[Version:3.2.1.2
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.18
--Status: created; incomplete
--Changes:]]]
--* defined ##rfind##
--------------------------------------------------------------------------------
--[[[Version:3.2.1.1
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2018.11.28
--Status: created; incomplete
--Changes:]]]
--* added reference to ##sequence.e##
--------------------------------------------------------------------------------
--[[[Version:3.2.1.0
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.09.12
--Status: created; incomplete
--Changes:]]]
--* defined ##match_replace##
--------------------------------------------------------------------------------
�45.12
