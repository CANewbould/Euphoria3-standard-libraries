--------------------------------------------------------------------------------
--	Library: pretty.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (std)pretty.e
-- Description: Eu3 proxy for OE4's standard library
------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1
--Author: C A Newbould
--Date: 2018.12.14
--Status: operational; complete 
--Changes:]]]
--* modified ##pretty_print## to allow for OS variations
--* defined ##PRETTY_DEFAULT##
--
------
--==Pretty Printing
-- Routines already defined:
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
-- library of the same name.
--* ##pretty_print##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/pretty.e</eucode>
--
------
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
include os.e	-- for LINUX
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
global constant PRETTY_DEFAULT = {1, 2, 1, 78, "%d", "%.10g", 32, 127, 1000000000, 1}	-- the default parameters for MS Windows
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
integer pretty_ascii
integer pretty_ascii_max
integer pretty_ascii_min
integer pretty_chars
integer pretty_dots
integer pretty_end_col
integer pretty_file
integer pretty_fp_format
integer pretty_indent
integer pretty_int_format
integer pretty_level
integer pretty_line
integer pretty_line_count
integer pretty_line_max
integer pretty_start_col
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
procedure pretty_out(object text)	-- Output text, keeping track of line length.
	-- Buffering lines speeds up Windows console output.
    pretty_line &= text
    if equal(text, '\n') then
		puts(pretty_file, pretty_line)
		pretty_line = ""
		pretty_line_count += 1
    end if
    if atom(text) then
		pretty_chars += 1
    else
		pretty_chars += length(text)
    end if
end procedure
--------------------------------------------------------------------------------
procedure cut_line(integer n)	-- check for time to do line break
    if pretty_chars + n > pretty_end_col then
		pretty_out('\n')
		pretty_chars = 0
    end if
end procedure
--------------------------------------------------------------------------------
procedure indent()	-- indent the display of a sequence
    if pretty_chars > 0 then
		pretty_out('\n')
		pretty_chars = 0
    end if
    pretty_out(repeat(' ', (pretty_start_col-1) + 
			    pretty_level * pretty_indent))
end procedure
--------------------------------------------------------------------------------
function show(integer a)	-- show escaped characters
    if a = '\t' then
		return "\\t"
    elsif a = '\n' then
		return "\\n"
    elsif a = '\r' then
		return "\\r"
    else
		return a
    end if
end function
--------------------------------------------------------------------------------
procedure rPrint(object a)	-- recursively print a Euphoria object  
    integer all_ascii, multi_line     
    sequence sbuff
    if atom(a) then
		if integer(a) then
		    sbuff = sprintf(pretty_int_format, a)
		    if pretty_ascii then 
				if pretty_ascii >= 3 then 
				    -- replace number with display character?
				    if (a >= pretty_ascii_min and a <= pretty_ascii_max) then
						sbuff = '\'' & a & '\''  -- display char only				    
				    elsif find(a, "\t\n\r") then
						sbuff = '\'' & show(a) & '\''  -- display char only				    
				    end if
				else -- pretty ascii 1 or 2
				     -- add display character to number?
				    if (a >= pretty_ascii_min and a <= pretty_ascii_max) then
						sbuff &= '\'' & a & '\'' -- add to numeric display
				    end if
				end if
		    end if
		else    
		    sbuff = sprintf(pretty_fp_format, a)
		end if
		pretty_out(sbuff)    
    else
		-- sequence 
		cut_line(1)
		multi_line = 0
		all_ascii = pretty_ascii > 1
		for i = 1 to length(a) do
		    if sequence(a[i]) and length(a[i]) > 0 then
				multi_line = 1
				all_ascii = 0
				exit
		    end if
		    if not integer(a[i])
		    or (a[i] < pretty_ascii_min
			and (pretty_ascii < 3 or not find(a[i], "\t\r\n")))
			or a[i] > pretty_ascii_max then
				all_ascii = 0
		    end if
		end for		
		if all_ascii then
		    pretty_out('\"')
		else
		    pretty_out('{')
		end if
		pretty_level += 1
		for i = 1 to length(a) do
		    if multi_line then
				indent()
		    end if
		    if all_ascii then
				pretty_out(show(a[i]))
		    else    
				rPrint(a[i])
		    end if
		    if pretty_line_count >= pretty_line_max then
				if not pretty_dots then
				    pretty_out(" ...")
				end if
				pretty_dots = 1
				return
		    end if
		    if i != length(a) and not all_ascii then
				pretty_out(',')
				cut_line(6)
		    end if
		end for
		pretty_level -= 1
		if multi_line then
		    indent()
		end if
		if all_ascii then
		    pretty_out('\"')
		else
		    pretty_out('}')
		end if
    end if
end procedure
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global procedure pretty_print(integer fn, object x, sequence options)   -- prints an object to a file or device, using braces { , , , }, indentation, and multiple lines to show the structure
    integer n    
    -- set option defaults 
    pretty_ascii = 1             --[1] 
    pretty_indent = 2            --[2]
    pretty_start_col = 1         --[3]
    pretty_end_col = 78          --[4]
    pretty_int_format = "%d"     --[5]
    pretty_fp_format = "%.10g"   --[6]
    pretty_ascii_min = 32        --[7]
    pretty_ascii_max = 127       --[8] 
	    if (platform() = LINUX) then	-- DEL is a problem with ANSI code display
			pretty_ascii_max = 126
	    end if
    pretty_line_max = 1000000000 --[9]    
    n = length(options)
    if n >= 1 then
		pretty_ascii = options[1] 
		if n >= 2 then
		    pretty_indent = options[2]
		    if n >= 3 then
				pretty_start_col = options[3]
				if n >= 4 then
				    pretty_end_col = options[4]
				    if n >= 5 then
						pretty_int_format = options[5]
						if n >= 6 then
							pretty_fp_format = options[6]
							if n >= 7 then
								pretty_ascii_min = options[7]
								if n >= 8 then
								    pretty_ascii_max = options[8]
								    if n >= 9 then
										pretty_line_max = options[9]
								    end if
								end if
						    end if
						end if
				    end if
				end if
		    end if
		end if
    end if    
    pretty_chars = pretty_start_col
    pretty_file = fn
    pretty_level = 0 
    pretty_line = ""
    pretty_line_count = 0
    pretty_dots = 0
    rPrint(x)
    puts(pretty_file, pretty_line)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##fn##: a handle to a device or file
--# ##x##: the object to be displayed
--# ##options##: the controlling options
--
-- Several options may be supplied in s to control the presentation.
-- Pass {} to select the defaults, or set options as below:
--# display ASCII characters:
--** 0: never
--** 1: alongside any integers in the printable ASCII range 32..127 (default)
--** 2: like 1, plus display as "string" when all integers of a sequence are in the printable ASCII range
--** 3: like 2, but show *only* quoted characters, not numbers, for any integers in the printable ASCII range, as well as the whitespace characters: \t \r \n
--# amount to indent for each level of sequence nesting - default: 2
--# column we are starting at - default: 1
--# approximate column to wrap at - default: 78
--# format to use for integers - default: "%d"
--# format to use for floating-point numbers - default: "%.10g"
--# minimum value for printable ASCII - default 32
--# maximum value for printable ASCII - default 127
--# maximum number of lines to output
--
-- If the length of ##options## is less than 8, unspecified options at the
-- end of the
-- sequence will keep the default values. e.g. {0, 5} will choose
-- "never display ASCII", plus 5-character indentation, with defaults
-- for everything else.
--
-- Notes:
--
-- The display will start at the current cursor position.
-- Normally you will want to call ##pretty_print## when the cursor is in
-- column 1 (after printing a \n character).
-- If you want to start in a different column, you should call ##position##
-- and specify a value for option [3].
-- This will ensure that the first and last braces in a sequence line up vertically.
-- When specifying the format to use for integers and floating-point numbers,
-- you can add some decoration, e.g. "(%d)" or "$ %.2f"
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1
--Author: C A Newbould
--Date: 2018.12.14
--Status: operational; complete 
--Changes:]]]
--* copied from eu3.2.0 version
--------------------------------------------------------------------------------
