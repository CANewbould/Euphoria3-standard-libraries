--------------------------------------------------------------------------------
--	Library: wildcard.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (std)wildcard.e
-- Description: Eu3 proxy for OE4's standard library
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.12.15
--Status: created; complete
--Changes:]]]
--* copied from 3.2.0 version
--
------
--==Euphoria Standard library: wildcard
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##is_match##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/wildcard.e</eucode>
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
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant END_MARKER = -1
constant FALSE = (1 = 0)
constant TRUE = (1 = 1)
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
function qmatch(sequence p, sequence s)	-- find pattern p in string s
	-- p may have '?' wild cards (but not '*')
    integer k    
    if not find('?', p) then
		return match(p, s) -- fast
    end if
    -- must allow for '?' wildcard
    for i = 1 to length(s) - length(p) + 1 do
		k = i
		for j = 1 to length(p) do
		    if p[j] != s[k] and p[j] != '?' then
				k = 0
				exit
		    end if
		    k += 1
		end for
		if k != 0 then
		    return i
		end if
    end for
    return 0
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function is_match(sequence pattern, sequence string)	-- returns TRUE if string matches pattern
-- pattern can include '*' and '?' "wildcard" characters
    integer f, p, t 
    sequence match_string    
    pattern = pattern & END_MARKER
    string = string & END_MARKER
    p = 1
    f = 1
    while f <= length(string) do
	if not find(pattern[p], {string[f], '?'}) then
	    if pattern[p] = '*' then
		while pattern[p] = '*' do
		    p += 1
		end while
		if pattern[p] = END_MARKER then
		    return TRUE
		end if
		match_string = ""
		while pattern[p] != '*' do
		    match_string = match_string & pattern[p]
		    if pattern[p] = END_MARKER then
			exit
		    end if
		    p += 1
		end while
		if pattern[p] = '*' then
		    p -= 1
		end if
		t = qmatch(match_string, string[f..$])
		if t = 0 then
		    return FALSE
		else
		    f += t + length(match_string) - 2
		end if
	    else
		return FALSE
	    end if
	end if
	p += 1
	f += 1
	if p > length(pattern) then
	    return f > length(string) 
	end if
    end while
    return FALSE
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##pattern##: a wild card pattern match
--# ##string##: a file name
--
-- Returns:
--
-- a **boolean**: TRUE if the filename matches the wild card pattern;
-- FALSE otherwise
--
-- Notes: 
--
-- ##*## matches any 0 or more characters
-- ##?## matches any single character
--
-- On Linux and FreeBSD the character comparisons are case sensitive.
-- On Windows they are not.
--
-- You might use this function to check the output of the ##dir## routine for
-- file names that match a pattern supplied by the user of your program.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.21
--Status: created; complete
--Changes:]]]
--* defined ##wildcard_match##
--------------------------------------------------------------------------------
