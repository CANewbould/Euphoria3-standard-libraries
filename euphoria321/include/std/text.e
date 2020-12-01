--------------------------------------------------------------------------------
--	Library: text.e
--------------------------------------------------------------------------------
-- Notes:
--
-- lower & upper are still defined as per eu3.1.2
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)text.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.07.17
--Status: operational; complete in Eu3 terms
--Changes:]]]
--* ##format## defined
--
------
--==Euphoria Standard library: text
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##format##
--* ##lower##
--* ##proper##
--* ##sprint##
--* ##trim##
--* ##trim_head##
--* ##trim_tail##
--* ##upper##
--* ##wrap##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/text.e</eucode>
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
include convert.e as convert -- for int_to_bits
include error.e as error -- for crash
include math.e as math -- for abs
include pretty.e as pretty -- for pretty_sprint
include search.e as search -- for begins
include sequence.e as stdseq -- for reverse
include types.e as types -- for t-lower, t_upper
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant TO_LOWER = 'a' - 'A'
constant WHITE_SPACE = " \t\r\n" 
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
global function format(sequence format_pattern, object arg_list) -- formats a set of arguments into a string, based on a supplied pattern
	integer align
	integer alt
	integer argl
	integer argn
	sequence argtext
	integer binout
	integer bwz
	integer cap
	object currargv
	integer decs
	object envsym
	object envvar
	integer ep
	integer hexout
	integer i
	sequence idname
	integer in_token
	integer istext
	integer msign
	integer pos
	object prevargv
	integer psign
	sequence result
	integer sp
	integer spacer
	integer tch
	integer tend
	integer trimming
	integer tsep
	integer width
	integer zfill
	if atom(arg_list) then
		arg_list = {arg_list}
	end if
	result = ""
	in_token = 0
	i = 0
	tend = 0
	argl = 0
	spacer = 0
	prevargv = 0
    while i < length(format_pattern) do
    	i += 1
    	tch = format_pattern[i]
    	if not in_token then
    		if tch = '[' then
    			in_token = 1
    			tend = 0
				cap = 0
				align = 0
				psign = 0
				msign = 0
				zfill = 0
				bwz = 0
				spacer = 0
				alt = 0
    			width = 0
    			decs = -1
    			argn = 0
    			hexout = 0
    			binout = 0
    			trimming = 0
    			tsep = 0
    			istext = 0
    			idname = ""
    			envvar = ""
    			envsym = ""
    		else
    			result &= tch
    		end if
    	else
			if tch  = ']' then
				in_token = 0
				tend = i
			elsif tch = '[' then
				result &= tch
				while i < length(format_pattern) do
					i += 1
					if format_pattern[i] = ']' then
						in_token = 0
						tend = 0
						exit
					end if
				end while
			elsif find(tch, {'w', 'u', 'l'})  then
				cap = tch
			elsif tch = 'b' then
				bwz = 1
			elsif tch = 's' then
				spacer = 1
			elsif tch = 't' then
				trimming = 1
			elsif tch = 'z' then
				zfill = 1
			elsif tch = 'X' then
				hexout = 1
			elsif tch = 'B' then
				binout = 1
			elsif find(tch, {'c', '<', '>'}) then
				align = tch
			elsif tch = '+' then
				psign = 1
			elsif tch = '(' then
				msign = 1
			elsif tch = '?' then
				alt = 1
			elsif tch = 'T' then
				istext = 1
			elsif tch = ':' then
				while i < length(format_pattern) do
					i += 1
					tch = format_pattern[i]
					pos = find(tch, "0123456789")
					if pos = 0 then
						i -= 1
						exit
					end if
					width = width * 10 + pos - 1
					if width = 0 then
						zfill = '0'
					end if
				end while
			elsif tch = '.' then
				decs = 0
				while i < length(format_pattern) do
					i += 1
					tch = format_pattern[i]
					pos = find(tch, "0123456789")
					if pos = 0 then
						i -= 1
						exit
					end if
					decs = decs * 10 + pos - 1
				end while
			elsif tch = '{' then
				sp = i + 1
				i = sp
				while i < length(format_pattern) do
					if format_pattern[i] = '}' then
						exit
					end if
					if format_pattern[i] = ']' then
						exit
					end if
					i += 1
				end while
				idname = trim(format_pattern[sp .. i-1]) & '='
				if format_pattern[i] = ']' then
					i -= 1
				end if
				for j = 1 to length(arg_list) do
					if sequence(arg_list[j]) then
						if search:begins(idname, arg_list[j]) then
							if argn = 0 then
								argn = j
								exit
							end if
						end if
					end if
					if j = length(arg_list) then
						idname = ""
						argn = -1
					end if
				end for
			elsif tch = '%' then
				sp = i + 1
				i = sp
				while i < length(format_pattern) do
					if format_pattern[i] = '%' then
						exit
					end if
					if format_pattern[i] = ']' then
						exit
					end if
					i += 1
				end while
				envsym = trim(format_pattern[sp .. i-1])
				if format_pattern[i] = ']' then
					i -= 1
				end if
				envvar = getenv(envsym)
				argn = -1
				if atom(envvar) then
					envvar = ""
				end if
			elsif find(tch, {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}) then
				if argn = 0 then
					i -= 1
					while i < length(format_pattern) do
						i += 1
						tch = format_pattern[i]
						pos = find(tch, "0123456789")
						if pos = 0 then
							i -= 1
							exit
						end if
						argn = argn * 10 + pos - 1
					end while
				end if
			elsif tch = ',' then
				if i < length(format_pattern) then
					i +=1
					tsep = format_pattern[i]
				end if
			end if
			if tend > 0 then
    			-- Time to replace the token.
    			argtext = ""
    			if argn = 0 then
    				argn = argl + 1
    			end if
    			argl = argn
    			if argn < 1 or argn > length(arg_list) then
    				if length(envvar) > 0 then
    					argtext = envvar
	    				currargv = envvar
    				else
    					argtext = ""
	    				currargv =""
	    			end if
				else
					if string(arg_list[argn]) then
						if length(idname) > 0 then
							argtext = arg_list[argn][length(idname) + 1 .. $]
						else
							argtext = arg_list[argn]
						end if
					elsif integer(arg_list[argn]) then
						if istext then
							argtext = {and_bits(0xFFFF_FFFF, math:abs(arg_list[argn]))}
							
						elsif bwz != 0 and arg_list[argn] = 0 then
							argtext = repeat(' ', width)
							
						elsif binout = 1 then
							argtext = stdseq:reverse(convert:int_to_bits(arg_list[argn], 32), 0, 0) + '0'
							for ib = 1 to length(argtext) do
								if argtext[ib] = '1' then
									argtext = argtext[ib .. $]
									exit
								end if
							end for
						elsif hexout = 0 then
							argtext = sprintf("%d", arg_list[argn])
							if zfill != 0 and width > 0 then
								if argtext[1] = '-' then
									if width > length(argtext) then
										argtext = '-' & repeat('0', width - length(argtext)) & argtext[2..$]
									end if
								else
									if width > length(argtext) then
										argtext = repeat('0', width - length(argtext)) & argtext
									end if
								end if
							end if
							if arg_list[argn] > 0 then
								if psign then
									if zfill = 0 then
										argtext = '+' & argtext
									elsif argtext[1] = '0' then
										argtext[1] = '+'
									end if
								end if
							elsif arg_list[argn] < 0 then
								if msign then
									if zfill = 0 then
										argtext = '(' & argtext[2..$] & ')'
									else
										if argtext[2] = '0' then
											argtext = '(' & argtext[3..$] & ')'
										else
											-- Don't need the '(' prefix as its just going to
											-- be trunctated to fit the requested width.
											argtext = argtext[2..$] & ')'
										end if
									end if
								end if
							end if
						else
							argtext = sprintf("%x", arg_list[argn])
							if zfill != 0 and width > 0 then
								if width > length(argtext) then
									argtext = repeat('0', width - length(argtext)) & argtext
								end if
							end if
						end if
					elsif atom(arg_list[argn]) then
						if istext then
							argtext = {and_bits(0xFFFF_FFFF, math:abs(floor(arg_list[argn])))}
						else
							if hexout then
								argtext = sprintf("%x", arg_list[argn])
								if zfill != 0 and width > 0 then
									if width > length(argtext) then
										argtext = repeat('0', width - length(argtext)) & argtext
									end if
								end if
							else
								argtext = trim(sprintf("%15.15g", arg_list[argn]))
								-- Remove any leading 0 after e+
								while ep != 0 with entry do
									argtext = remove(argtext, ep+2)
								entry
									ep = match("e+0", argtext)
								end while
								if zfill != 0 and width > 0 then
									if width > length(argtext) then
										if argtext[1] = '-' then
											argtext = '-' & repeat('0', width - length(argtext)) & argtext[2..$]
										else
											argtext = repeat('0', width - length(argtext)) & argtext
										end if
									end if
								end if
								if arg_list[argn] > 0 then
									if psign  then
										if zfill = 0 then
											argtext = '+' & argtext
										elsif argtext[1] = '0' then
											argtext[1] = '+'
										end if
									end if
								elsif arg_list[argn] < 0 then
									if msign then
										if zfill = 0 then
											argtext = '(' & argtext[2..$] & ')'
										else
											if argtext[2] = '0' then
												argtext = '(' & argtext[3..$] & ')'
											else
												argtext = argtext[2..$] & ')'
											end if
										end if
									end if
								end if
							end if
						end if
					else
						if alt != 0 and length(arg_list[argn]) = 2 then
							object tempv
							if atom(prevargv) then
								if prevargv != 1 then
									tempv = arg_list[argn][1]
								else
									tempv = arg_list[argn][2]
								end if
							else
								if length(prevargv) = 0 then
									tempv = arg_list[argn][1]
								else
									tempv = arg_list[argn][2]
								end if
							end if
							if string(tempv) then
								argtext = tempv
							elsif integer(tempv) then
								if istext then
									argtext = {and_bits(0xFFFF_FFFF, math:abs(tempv))}
							
								elsif bwz != 0 and tempv = 0 then
									argtext = repeat(' ', width)
								else
									argtext = sprintf("%d", tempv)
								end if
							elsif atom(tempv) then
								if istext then
									argtext = {and_bits(0xFFFF_FFFF, math:abs(floor(tempv)))}
								elsif bwz != 0 and tempv = 0 then
									argtext = repeat(' ', width)
								else
									argtext = trim(sprintf("%15.15g", tempv))
								end if
							else
								argtext = pretty:pretty_sprint( tempv,
											{2,0,1,1000,"%d","%.15g",32,127,1,0}
											)
							end if
						else
							argtext = pretty:pretty_sprint( arg_list[argn],
										{2,0,1,1000,"%d","%.15g",32,127,1,0}
										)
						end if
						-- Remove any leading 0 after e+
						while ep != 0 with entry do
							argtext = remove(argtext, ep+2)
						entry
							ep = match("e+0", argtext)
						end while
					end if
	    			currargv = arg_list[argn]
    			end if
    			if length(argtext) > 0 then
					if cap = 'u' then
						argtext = upper(argtext)
					elsif cap = 'l' then
						argtext = lower(argtext)
					elsif cap = 'w' then
						argtext = proper(argtext)
					else
						error:crash("logic error: 'cap' mode in format.")
					end if
					if atom(currargv) then
						if find('e', argtext) = 0 then
							-- Only applies to non-scientific notation.
							if decs != -1 then
								pos = find('.', argtext)
								if pos then
									if decs = 0 then
										argtext = argtext [1 .. pos-1 ]
									else
										pos = length(argtext) - pos
										if pos > decs then
											argtext = argtext[ 1 .. $ - pos + decs ]
										elsif pos < decs then
											argtext = argtext & repeat('0', decs - pos)
										end if
									end if
								elsif decs > 0 then
									argtext = argtext & '.' & repeat('0', decs)
								end if
							end if
						end if
					end if
    				if align = 0 then
    					if atom(currargv) then
    						align = '>'
    					else
    						align = '<'
    					end if
    				end if
    				if atom(currargv) then
	    				if tsep != 0 and zfill = 0 then
	    					integer dpos
	    					integer dist
	    					integer bracketed
	    					if binout or hexout then
	    						dist = 4
	    					else
	    						dist = 3
	    					end if
	    					bracketed = (argtext[1] = '(')
	    					if bracketed then
	    						argtext = argtext[2 .. $-1]
	    					end if
	    					dpos = find('.', argtext)
	    					if dpos = 0 then
	    						dpos = length(argtext) + 1
	    					else
	    						if tsep = '.' then
	    							argtext[dpos] = ','
	    						end if
	    					end if
	    					while dpos > dist do
	    						dpos -= dist
	    						if dpos > 1 then
	    							argtext = argtext[1.. dpos - 1] & tsep & argtext[dpos .. $]
	    						end if
	    					end while
	    					if bracketed then
	    						argtext = '(' & argtext & ')'
	    					end if
	    				end if
					end if
    				if width <= 0 then
    					width = length(argtext)
    				end if
    				if width < length(argtext) then
    					if align = '>' then
    						argtext = argtext[ $ - width + 1 .. $]
    					elsif align = 'c' then
    						pos = length(argtext) - width
    						if remainder(pos, 2) = 0 then
    							pos = pos / 2
    							argtext = argtext[ pos + 1 .. $ - pos ]
    						else
    							pos = floor(pos / 2)
    							argtext = argtext[ pos + 1 .. $ - pos - 1]
    						end if
    					else
    						argtext = argtext[ 1 .. width]
    					end if
    				elsif width > length(argtext) then
						if align = '>' then
							argtext = repeat(' ', width - length(argtext)) & argtext
    					elsif align = 'c' then
    						pos = width - length(argtext)
    						if remainder(pos, 2) = 0 then
    							pos = pos / 2
    							argtext = repeat(' ', pos) & argtext & repeat(' ', pos)
    						else
    							pos = floor(pos / 2)
    							argtext = repeat(' ', pos) & argtext & repeat(' ', pos + 1)
    						end if
    					else
							argtext = argtext & repeat(' ', width - length(argtext))
						end if
    				end if
    				result &= argtext
    			else
    				if spacer then
    					result &= ' '
    				end if
    			end if
   				if trimming then
   					result = trim(result)
   				end if
    			tend = 0
		    	prevargv = currargv
			end if
		end if
	end while
	return result
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //format_pattern//: the pattern string that contains zero or more tokens
--# //arg_list//: zero or more arguments used in token replacement
--
-- Returns:
-- a string **sequence**: the original //format_pattern//,
-- but with tokens replaced by the corresponding arguments.
--
-- Notes:
--
-- The //format_pattern// string contains text and argument tokens. The resulting string
-- is the same as the format string except that each token is replaced by an
-- item from the argument list.
--
-- A token has the form **##[<Q>]##**, where <Q> is are optional qualifier codes.
--
-- The qualifier. ##<Q>## is a set of zero or more codes that modify the default
-- way that the argument is used to replace the token. The default replacement
-- method is to convert the argument to its shortest string representation and
-- use that to replace the token. This may be modified by the following codes,
-- which can occur in any order.
-- |= Qualifier |= Usage                                              |
-- |  N         | ('N' is an integer) The index of the argument to use|
-- | {id}       | Uses the argument that begins with "id=" where "id" \\
--                is an identifier name.                              |
-- | %envvar%   | Uses the Environment Symbol 'envar' as an argument  |
-- |  w         | For string arguments, if capitalizes the first\\
--                letter in each word                                 |
-- |  u         | For string arguments, it converts it to upper case. |
-- |  l         | For string arguments, it converts it to lower case. |
-- |  <         | For numeric arguments, it left justifies it.        |
-- |  >         | For string arguments, it right justifies it.        |
-- |  c         | Centers the argument.                               |
-- |  z         | For numbers, it zero fills the left side.           |
-- |  :S        | ('S' is an integer) The maximum size of the\\
--                resulting field. Also, if 'S' begins with '0' the\\
--                field will be zero-filled if the argument is an integer|
-- |  .N        | ('N' is an integer) The number of digits after\\
--                 the  decimal point                                 |
-- |  +         | For positive numbers, show a leading plus sign      |
-- |  (         | For negative numbers, enclose them in parentheses   |
-- |  b         | For numbers, causes zero to be all blanks           |
-- |  s         | If the resulting field would otherwise be zero\\
--                length, this ensures that at least one space occurs\\
--                between this token's field                          |
-- |  t         | After token replacement, the resulting string up to this point is trimmed. |
-- |  X         | Outputs integer arguments using hexadecimal digits. |
-- |  B         | Outputs integer arguments using binary digits.      |
-- |  ?         | The corresponding argument is a set of two strings. This\\
--                uses the first string if the previous token's argument is\\
--                not the value 1 or a zero-length string, otherwise it\\
--                uses the second string.                             |
-- |  [         | Does not use any argument. Outputs a left-square-bracket symbol |
-- |  ,X        | Insert thousands separators. The <X> is the character\\
--                to use. If this is a dot "." then the decimal point\\
--                is rendered using a comma. Does not apply to zero-filled\\
--                fields.                         \\
--                N.B. if hex or binary output was specified, the \\
--                separators are every 4 digits otherwise they are \\
--                every three digits. |
-- |  T         | If the argument is a number it is output as a text character, \\
--                otherwise it is output as text string |
--
-- Clearly, certain combinations of these qualifier codes do not make sense and in
-- those situations, the rightmost clashing code is used and the others are ignored.
--
-- Any tokens in the format that have no corresponding argument are simply removed
-- from the result. Any arguments that are not used in the result are ignored.
--
-- Any sequence argument that is not a string will be converted to its
-- //pretty// format before being used in token replacement.
--
-- If a token is going to be replaced by a zero-length argument, all white space
-- following the token until the next non-whitespace character is not copied to
-- the result string.
--
-- Examples:
-- <eucode>
-- format("Cannot open file '[]' - code []", {"/usr/temp/work.dat", 32})
-- -- "Cannot open file '/usr/temp/work.dat' - code 32"
--
-- format("Err-[2], Cannot open file '[1]'", {"/usr/temp/work.dat", 32})
-- -- "Err-32, Cannot open file '/usr/temp/work.dat'"
--
-- format("[4w] [3z:2] [6] [5l] [2z:2], [1:4]", {2009,4,21,"DAY","MONTH","of"})
-- -- "Day 21 of month 04, 2009"
--
-- format("The answer is [:6.2]%", {35.22341})
-- -- "The answer is  35.22%"
--
-- format("The answer is [.6]", {1.2345})
-- -- "The answer is 1.234500"
--
-- format("The answer is [,,.2]", {1234.56})
-- -- "The answer is 1,234.56"
--
-- format("The answer is [,..2]", {1234.56})
-- -- "The answer is 1.234,56"
--
-- format("The answer is [,:.2]", {1234.56})
-- -- "The answer is 1:234.56"
--
-- format("[] [?]", {5, {"cats", "cat"}})
-- -- "5 cats"
--
-- format("[] [?]", {1, {"cats", "cat"}})
-- -- "1 cat"
--
-- format("[<:4]", {"abcdef"})
-- -- "abcd"
--
-- format("[>:4]", {"abcdef"})
-- -- "cdef"
--
-- format("[>:8]", {"abcdef"})
-- -- "  abcdef"
--
-- format("seq is []", {{1.2, 5, "abcdef", {3}}})
-- -- `seq is {1.2,5,"abcdef",{3}}`
--
-- format("Today is [{day}], the [{date}]", {"date=10/Oct/2012", "day=Wednesday"})
-- -- "Today is Wednesday, the 10/Oct/2012"
--
-- format("'A' is [T]", 65)
-- -- `'A' is A`
-- </eucode>
--
-- See Also:
--   [[:sprintf]]
--
--*/
--------------------------------------------------------------------------------
global function lower(object x)	-- converts atom or sequence to lower case
    return x + (x >= 'A' and x <= 'Z') * TO_LOWER
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   An **atom** or **sequence**, the lowercase version of ##x##.
--*/
--------------------------------------------------------------------------------
global function sprint(object x)	-- return the string representation of any Euphoria data object 
    sequence s				 
    if atom(x) then
		return sprintf("%.10g", x)
    else
		s = "{"
		for i = 1 to length(x) do
		    s &= sprint(x[i])  
		    if i < length(x) then
				s &= ','
		    end if
		end for
		if s[$] = ',' then
			s[$] = '}'
		else
			s &= '}'
		end if
		return s
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   A **sequence**, a string representation of ##x##.
--
-- Notes:
--
-- This is exactly the same as ##print(fn, x)##, except that the output is returned as a sequence of characters, rather
-- than being sent to a file or device. ##x## can be any Euphoria object.
--
-- The atoms contained within ##x## will be displayed to a maximum of 10 significant digits,
-- just as with ##print##.
--*/
--------------------------------------------------------------------------------
global function trim(sequence source, object what, integer ret_index)	-- trims all items in the supplied set from both the left end (head/start) and right end (tail/end) of a sequence
	integer rpos
	integer lpos
	if atom(what) then
		what = {what}
	end if
	lpos = 1
	while lpos <= length(source) do
		if not find(source[lpos], what) then
			exit
		end if
		lpos += 1
	end while
	rpos = length(source)
	while rpos > lpos do
		if not find(source[rpos], what) then
			exit
		end if
		rpos -= 1
	end while
	if ret_index then
		return {lpos, rpos}
	else
		if lpos = 1 then
			if rpos = length(source) then
				return source
			end if
		end if
		if lpos > length(source) then
			return {}
		end if
		return source[lpos..rpos]
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##source## : the sequence to trim.
--   # ##what## : the set of item to trim from ##source## (defaults to ##" \t\r\n"##).
--   # ##ret_index## : If zero (the default) returns the trimmed sequence, otherwise
--                    it returns a 2-element sequence containing the index of the
--                    leftmost item and rightmost item **not** in ##what##.
--
-- Returns:
--
--   A **sequence**, if ##ret_index## is zero, which is the trimmed version of ##source##
--   A **2-element sequence**, if ##ret_index## is not zero, in the form ##{left_index, right_index}## .
--*/
--------------------------------------------------------------------------------
global  function trim_head(sequence source, object what, integer ret_index)	-- trims all items in the supplied set from the leftmost (start or head) of a sequence
	integer lpos
	if atom(what) then
		what = {what}
	end if
	lpos = 1
	while lpos <= length(source) do
		if not find(source[lpos], what) then
			exit
		end if
		lpos += 1
	end while
	if ret_index then
		return lpos
	else
		return source[lpos .. $]
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##source##: the sequence to trim
--   # ##what##: the set of item to trim from ##source##
--   # ##ret_index##: If zero (the default) returns the trimmed sequence, otherwise
--                    it returns the index of the leftmost item **not** in ##what##
--
-- Returns:
--
--   A **sequence**, if ##ret_index## is zero, which is the trimmed version of ##source##\\
--   A **integer**, if ##ret_index## is not zero, which is index of the leftmost
--                  element in ##source## that is not in ##what##.
--*/
--------------------------------------------------------------------------------
global function trim_tail(sequence source, object what, integer ret_index)	-- trims all items in the supplied set from the rightmost (end or tail) of a sequence
    integer rpos
    if atom(what) then
	what = {what}
    end if
    rpos = length(source)
    while rpos > 0 do
	if not find(source[rpos], what) then
	    exit
	end if
	rpos -= 1
    end while
    if ret_index then
	return rpos
    else
	return source[1..rpos]
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##source##: the sequence to trim
--   # ##what##: the set of item to trim from ##source##
--   # ##ret_index## : If zero then returns the trimmed sequence, otherwise
--                    it returns a 2-element sequence containing the index of the
--                    leftmost item and rightmost item **not** in ##what##.
--
-- Returns:
--
--   A **sequence**, if ##ret_index## is zero, which is the trimmed version of ##source##\\
--   A **integer**, if ##ret_index## is not zero, which is index of the rightmost
--                  element in ##source## that is not in ##what##.
--*/
--------------------------------------------------------------------------------
global function upper(object x)	-- convert atom or sequence to upper case
    return x - (x >= 'a' and x <= 'z') * TO_LOWER
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x##: any Euphoria object.
--
-- Returns:
--
--   An **atom** or **sequence**, the uppercase version of ##x##.
--*/
--------------------------------------------------------------------------------
global function proper(sequence x)	-- converts a text sequence to capitalized words
	integer pos
	integer inword
	integer convert
	sequence res
	inword = 0	-- Initially not in a word
	convert = 1	-- Initially convert text
	res = x		-- Work on a copy of the original, in case we need to restore.
	for i = 1 to length(res) do
		if integer(res[i]) then
			if convert then
				-- Check for upper case
				pos = types:t_upper(res[i])
				if pos = 0 then
					-- Not upper, so check for lower case
					pos = types:t_lower(res[i])
					if pos = 0 then
						-- Not lower so check for digits
						-- n.b. digits have no effect on if its in a word or not.
						pos = t_digit(res[i])
						if pos = 0 then
							-- not digit so check for special word chars
							pos = t_specword(res[i])
							if pos then
								inword = 1
							else
								inword = 0
							end if
						end if
					else
						if inword = 0 then
							-- start of word, so convert only lower to upper.
							if pos <= 26 then
								res[i] = upper(res[i]) -- Convert to uppercase
							end if
							inword = 1	-- now we are in a word
						end if
					end if
				else
					if inword = 1 then
						-- Upper, but as we are in a word convert it to lower.
						res[i] = lower(res[i]) -- Convert to lowercase
					else
						inword = 1	-- now we are in a word
					end if
				end if
			end if
		else
			-- A non-integer means this is NOT a text sequence, so
			-- only convert sub-sequences.
			if convert then
				-- Restore any values that might have been converted.
				for j = 1 to i-1 do
					if atom(x[j]) then
						res[j] = x[j]
					end if
				end for
				-- Turn conversion off for the rest of this level.
				convert = 0
			end if
			if sequence(res[i]) then
				res[i] = proper(res[i])	-- recursive conversion
			end if
		end if
	end for
	return res
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##x## : A text sequence.
--
-- Returns:
--
--   A **sequence**, the capitalized Version of ##x##
--
-- Comments:
-- A text sequence is one in which all elements are either characters or
-- text sequences. This means that if a non-character is found in the input,
-- it is not converted. However this rule only applies to elements on the
-- same level, meaning that sub-sequences could be converted if they are
-- actually text sequences.
--*/
--------------------------------------------------------------------------------
global function wrap(string content, integer width, string wrap_with, string wrap_at)	-- wraps text to a column width
	sequence result
	integer split_at
	if length(content) < width then
		return content
	end if
	result = ""
	while length(content) do
		-- Find the first whitespace before width
		split_at = 0
		for i = width to 1 by -1 do
			if find(content[i], wrap_at) then
				split_at = i
				exit
			end if
		end for
		if split_at = 0 then
			-- Cannot split at width or less, try the closest thing to width
			for i = width to length(content) do
				if find(content[i], wrap_at) then
					split_at = i
					exit
				end if
			end for
			-- Didn't find any place to split, attache the entire string
			if split_at = 0 then
				if length(result) then
					result &= wrap_with
				end if
				result &= content
				exit
			end if
		end if
		if length(result) then
			result &= wrap_with
		end if
		result &= trim(content[1..split_at], WHITE_SPACE, 0)
		content = trim(content[split_at + 1..$], WHITE_SPACE, 0)
		if length(content) < width then
			result &= wrap_with & content
			exit
		end if
	end while
	return result
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   * ##content## - content to wrap
--   * ##width## - width to wrap at
--   * ##wrap_with## - string of character(s) to wrap with
--   * ##wrap_at## - string of characters to wrap at
--
-- Returns:
--
--   A **sequence** containing the wrapped text (line-by-line)
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.09.25
--Status: operational; complete in Eu3 terms
--Changes:]]]
--* ##wrap## - corrected error
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.02
--Status: operational; complete in Eu3 terms
--Changes:]]]
--* defined ##wrap##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.01
--Status: operational; incomplete
--Changes:]]]
--* defined ##proper##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.12.31
--Status: operational; incomplete
--Changes:]]]
--* defined ##trim_tail##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.12.30
--Status: operational; incomplete
--Changes:]]]
--* defined ##trim_head##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.12.22
--Status: operational; incomplete
--Changes:]]]
--* defined ##trim##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.10
--Status: operational; incomplete
--Changes:]]]
--* copied from eu3.2.0
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.20
--Status: created; incomplete
--Changes:]]]
--* defined ##sprint##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.17
--Status: created; incomplete
--Changes:]]]
--* defined ##lower##
--------------------------------------------------------------------------------
