--------------------------------------------------------------------------------
--	Library: types.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)types.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2020.07.17
--Status: operational; incomplete
--Changes:]]]
--* defined **t_display**
--
------
--==Euphoria Standard library: types
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--*
--===Constants
--* ##FALSE##
--* ##NO_ROUTINE_ID##
--* ##TRUE##
--===Types
-- The following types are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##ascii_string##
--* ##boolean##
--* ####cstring####
--* ##integer_array##
--* ##number_array##
--* ##sequence_array##
--* ##string##
--* ##t_alpha##
--* ##t_ascii##
--* ##t_boolean##
--* ##t_byte_array##
--* ##t_consonant##
--* ##t_digit##
--* **t_display**
--* ##t_lower##
--* ##t_space##
--* ##t_specword##
--* ##t_upper##
--* ##t_vowel##
--
-- Utilise these routines, types and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/types.e</eucode>
--
------
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--/*
--=== Includes
--*/
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
global constant FALSE = (1=0)
global constant NO_ROUTINE_ID = -99999	-- flag for no routine_id supplied
global constant TRUE = (1=1)
--------------------------------------------------------------------------------
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
integer alpha_id
integer ascii_id
integer boolean_id
integer byte_id
integer consonant_id
integer digit_id
integer display_id
integer lower_id
integer space_id
integer specword_id
integer test_type_id
integer upper_id
integer vowel_id
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--/*
--=== Euphoria types
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global type boolean(object this)   -- FALSE or TRUE
	return find(this, {1, 0}) != 0
end type
--------------------------------------------------------------------------------
global type cstring(sequence this)    -- a sequence that only contains zero or more non-null byte characters
    if length(this) = 0 then
	return TRUE
    else
	for i = 1 to length(this) do
	    if this[i] < 1 then
		return FALSE
	    end if
	    if this[i] > 255 then
		return FALSE
	    end if
	end for
	return TRUE
    end if
end type
--------------------------------------------------------------------------------
global type integer_array(sequence this)	--  a sequence that contains only integers  - zero or more	
    if length(this) = 0 then
		return TRUE
	else
		for i = 1 to length(this) do
			if not integer(this[i]) then
				return FALSE
			end if
		end for
		return TRUE
	end if
end type
--------------------------------------------------------------------------------
global type number_array(sequence this)	--  a sequence that contains only numbers  - zero or more	
    if length(this) = 0 then
		return TRUE
	else
		for i = 1 to length(this) do
			if not atom(this[i]) then
				return FALSE
			end if
		end for
		return TRUE
	end if
end type
--------------------------------------------------------------------------------
global type sequence_array(sequence this)	--  a sequence that contains only sequences  - zero or more	
    if length(this) = 0 then
		return TRUE
	else
		for i = 1 to length(this) do
			if not sequence(this[i]) then
				return FALSE
			end if
		end for
		return TRUE
	end if
end type
--------------------------------------------------------------------------------
global type string(integer_array this)   -- an array solely comprising byte characters (integers in the range [0 to 255])
    if length(this) = 0 then
	return TRUE
    else
	for i = 1 to length(this) do
	    if this[i] < 0 then
		return FALSE
	    end if
	    if this[i] > 255 then
		return FALSE
	    end if
	end for
	return TRUE
    end if
end type
--------------------------------------------------------------------------------
global type ascii_string(integer_array this)   -- an array solely comprising ascii characters (integers in the range [0 to 127])
	for i = 1 to length(this) do
		if this[i] < 0 then
			return FALSE
		end if
		if this[i] > 127 then
			return FALSE
		end if
	end for
	return TRUE
end type
--------------------------------------------------------------------------------
global type t_alpha(object this)	-- an alphabetic character or a sequence of alphabetic characters
    return call_func(test_type_id, {this, alpha_id})
end type
--------------------------------------------------------------------------------
global type t_ascii(object this)	-- an ascii character or a sequence of ascii characters
	return call_func(test_type_id, {this, ascii_id})
end type
--------------------------------------------------------------------------------
global type t_boolean(object this)	-- a boolean character or a sequence of booleans
	return call_func(test_type_id, {this, boolean_id})
end type
--------------------------------------------------------------------------------
global type t_byte_array(sequence this)	-- a byte or a sequence of bytes
    return call_func(test_type_id, {this, byte_id})
end type
--------------------------------------------------------------------------------
global type t_consonant(object this)	-- a consonant or a sequence of consonants
	return call_func(test_type_id, {this, consonant_id})
end type
--------------------------------------------------------------------------------
global type t_digit(object this)	-- a digit character or a sequence of digit characters
	return call_func(test_type_id, {this, digit_id})
end type
--------------------------------------------------------------------------------
global type t_display(object this) -- a character or sequence of characters that can be displayed
	return call_func(test_type_id, {this, display_id})
end type
--------------------------------------------------------------------------------
global type t_lower(object this)	-- a lowercase character or a sequence of lowercase characters and/or strings
	return call_func(test_type_id, {this, lower_id})
end type
--------------------------------------------------------------------------------
global type t_space(object this)	-- a whitespace character or a sequence of whitespace characters and/or strings
	return call_func(test_type_id, {this, space_id})
end type
--------------------------------------------------------------------------------
global type t_specword(object this)	-- a special word character or a sequence of special word characters and/or strings
	return call_func(test_type_id, {this, specword_id})
end type
--------------------------------------------------------------------------------
global type t_upper(object this)	-- an uppercase character or a sequence of uppercase characters and/or strings
	return call_func(test_type_id, {this, upper_id})
end type
--------------------------------------------------------------------------------
global type t_vowel(object this)	-- a vowel or a sequence of vowels
	return call_func(test_type_id, {this, vowel_id})
end type
--------------------------------------------------------------------------------
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function alpha(object this)
    return call_func(lower_id, {this}) or call_func(upper_id, {this})
end function
alpha_id = routine_id("alpha")
--------------------------------------------------------------------------------
function ascii(object this)
    return this >= 0 and this <= 127
end function
ascii_id = routine_id("ascii")
--------------------------------------------------------------------------------
function bool(object this)
    return this = 0 or this = 1
end function
boolean_id = routine_id("bool")
--------------------------------------------------------------------------------
function byte(object this)
    return this >= 0 and this <= 255
end function
byte_id = routine_id("byte")
--------------------------------------------------------------------------------
function consonant(object this)
    return find(this, "bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ")
end function
consonant_id = routine_id("consonant")
--------------------------------------------------------------------------------
function digit(object this)
    return this >= 48 and this <= 57
end function
digit_id = routine_id("digit")
--------------------------------------------------------------------------------
function display(object this)
	return find(this, {{' ', '~'}, "  ", "\t\t", "\n\n", "\r\r", {8,8}, {7,7}})
end function
display_id = routine_id("display")
--------------------------------------------------------------------------------
function lowr(object this)	-- converts atom or sequence to lower case
    return this >= 97 and this <= 122
end function
lower_id = routine_id("lowr")
--------------------------------------------------------------------------------
function space(object this)
    return (this >= 9 and this <= 12) or this = 160
end function
space_id = routine_id("space")
--------------------------------------------------------------------------------
function specword(object this)
    return this = "_"
end function
specword_id = routine_id("specword")
--------------------------------------------------------------------------------
function test_type(object this, integer rid)
	if atom(this) then
		return call_func(rid, {this})
	else	-- sequence
		if length(this) = 0 then
			return FALSE
		end if
		for i = 1 to length(this) do
			if not call_func(rid, {this[i]}) then
				return FALSE
			end if
		end for
		return TRUE
	end if
end function
test_type_id = routine_id("test_type")
--------------------------------------------------------------------------------
function uppr(object this)	-- convert atom or sequence to upper case
    return this >= 65 and this <= 90
end function
upper_id = routine_id("uppr")
--------------------------------------------------------------------------------
function vowel(object this)
    return find(this, "aeiouAEIOU")
end function
vowel_id = routine_id("vowel")
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--/*
--==== Defined instances
--*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.10.11
--Status: operational; incomplete
--Changes:]]]
--* defined ##NO_ROUTINE_ID##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.12
--Status: operational; incomplete
--Changes:]]]
--* defined ##cstring##
--* defined ##t_alpha##
--* defined ##t_vowel##
--* defined ##t_consonant##
--* defined ##t_byte_array##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.06
--Status: operational; incomplete
--Changes:]]]
--* defined ##integer_array##
--* defined ##number_array##
--* defined ##sequence_array##
--* modified definition of ##string## (based on ##integer_array##)
--* defined ##ascii_string##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.05
--Status: operational; incomplete
--Changes:]]]
--* defined ##t_ascii##
--* defined ##t_digit##
--* defined ##t_space##
--* defined ##t_specword##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.04
--Status: operational; incomplete
--Changes:]]]
--* defined (local) test_type routine
--* re-defined ##t_upper## using test_type
--* re-defined ##t_lower## using test_type
--* defined ##t_boolean##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.03
--Status: operational; incomplete
--Changes:]]]
--* removed char_test (local)
--* defined ##t_upper##
--* defined ##t_lower## 
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2019.01.02
--Status: operational; incomplete
--Changes:]]]
--* defined ##char_test##
--* modified definition of ##boolean##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.10.23
--Status: operational; incomplete
--Changes:]]]
--* defined ##string##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and later
--Author: C A Newbould
--Date: 2017.10.13
--Status: operational; incomplete
--Changes:]]]
--* defined ##TRUE## & ##FALSE##
--* defined ##boolean##
--------------------------------------------------------------------------------
