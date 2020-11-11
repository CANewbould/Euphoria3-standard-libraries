--------------------------------------------------------------------------------
--	Library: convert.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)convert.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.8
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.01.06
--Status: operational; complete
--Changes:]]]
--* expanded documentation for ##int_to_bits##
--* expanded documentation for ##int_to_bytes##
--
------
--==Euphoria Standard library: convert
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##atom_to_float32##
--* ##atom_to_float64##
--* ##bits_to_int##
--* ##bytes_to_int##
--* ##float32_to_atom##
--* ##float64_to_atom##
--* ##int_to_bits##
--* ##int_to_bytes##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/convert.e</eucode>
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.7
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.01.04
--Status: operational; incomplete
--Changes:]]]
--* expanded documentation for ##float32_to_atom##
--* expanded documentation for ##float64_to_atom##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.6
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2018.01.01
--Status: operational; incomplete
--Changes:]]]
--* expanded documentation for ##bytes_to_int##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.5
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.12.31
--Status: operational; incomplete
--Changes:]]]
--* expanded documentation for ##bits_to_int##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.4
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.12.30
--Status: operational; incomplete
--Changes:]]]
--* expanded documentation for ##atom_to_float64##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.12.19
--Status: operational; incomplete
--Changes:]]]
--* expanded documentation for ##atom_to_float32##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.17
--Status: operational; incomplete
--Changes:]]]
--* defined ##int_to_bits##
--* defined ##int_to_bytes##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.15
--Status: operational; incomplete
--Changes:]]]
--* defined ##float32_to_atom##
--* defined ##float64_to_atom##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.10
--Status: created; incomplete
--Changes:]]]
--* defined ##atom_to_float32##
--* defined ##atom_to_float64##
--* defined ##bits_to_int##
--* defined ##bytes_to_int##
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
--
--=== Includes
--
--------------------------------------------------------------------------------
include std/machine.e	-- for allocate
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
-- machine_func values
constant M_A_TO_F32 = 48
constant M_A_TO_F64 = 46
constant M_F32_TO_A = 49
constant M_F64_TO_A = 47
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
type sequence_4(sequence s)	-- a 4-element sequence
    return length(s) = 4
end type
--------------------------------------------------------------------------------
type sequence_8(sequence s)	-- an 8-element sequence
    return length(s) = 8
end type
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
atom mem mem = allocate(4)
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
global function atom_to_float32(atom a)	-- converts an atom to a sequence of 4 bytes in IEEE 32-bit format
    return machine_func(M_A_TO_F32, a)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##a##: the value to be converted
--
-- Returns:
--
-- a **sequence** of 4 single-byte values
--
-- These 4 bytes contain the representation of an IEEE floating-point number in
-- 32-bit format.
--
-- Notes:
--
-- Euphoria atoms can have values which are 64-bit IEEE floating-point numbers,
-- so you may lose precision when you convert to 32-bits
-- (16 significant digits versus 7).
-- The range of exponents is much larger in 64-bit format
-- (10 to the 308, versus 10 to the 38), so some atoms may be too large
-- or too small to represent in 32-bit format. In this case you will get one
-- of the special 32-bit values: inf or -inf (infinity or -infinity).
-- To avoid this, you can use ##atom_to_float64##.
--
-- Integer values will also be converted to 32-bit floating-point format.
--*/
--------------------------------------------------------------------------------
global function atom_to_float64(atom a)	-- converts an atom to a sequence of 8 bytes in IEEE 64-bit format
    return machine_func(M_A_TO_F64, a)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##a##: the value to be converted
--
-- Returns:
--
--		a **sequence**, of 8 bytes, which can be poked in memory to represent ##a##.
--
-- Notes:
--
-- All Euphoria atoms have values which can be represented as 64-bit IEEE
-- floating-point numbers, so you can convert any atom to 64-bit format
-- without losing any precision.
--
-- Integer values will also be converted to 64-bit floating-point format.
--*/
--------------------------------------------------------------------------------
global function bits_to_int(sequence bits)	-- gets the (positive) value of a sequence of "bits"
	atom p    
    atom value
    value = 0
    p = 1
    for i = 1 to length(bits) do
		if bits[i] then
		    value += p
		end if
		p += p
    end for
    return value
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##bits##: a sequence of bits
--
-- The least-significant bit is ##bits##[1].
--
-- Returns:
--
-- an **atom** being the result of converting the bits into a positive number
--
-- Notes:
--
-- If you print the source the bits will appear in "reverse" order, but it is
-- convenient to have increasing subscripts access bits of increasing
-- significance.
--*/
--------------------------------------------------------------------------------
global function bytes_to_int(sequence s)	-- converts 4-byte peek() sequence into an integer value
    if length(s) = 4 then
		poke(mem, s)
    else    
		poke(mem, s[1..4]) -- avoid breaking old code
    end if
    return peek4u(mem)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##s##: a sequence of bytes, with the least-significant byte first
--
-- Returns:
--
-- an **atom** being the result of converting the elements of ##s##
--
-- Notes:
--
-- The result could be greater than the integer type allows, so you should
-- assign it to an atom.
--
-- ##s## would normally contain positive values that have been read using
-- ##peek## from 4 consecutive memory locations.
--*/
--------------------------------------------------------------------------------
global function float32_to_atom(sequence_4 ieee32)	-- converts a sequence of 4 bytes in IEEE 32-bit format to an atom
    return machine_func(M_F32_TO_A, ieee32)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##ieee32##: sequence of 4 bytes
--
-- Returns: an **atom** holding the processed result
--
-- Notes:
-- 
-- The 4 bytes must contain an IEEE floating-point number in 32-bit format.
--
-- Any 32-bit IEEE floating-point number can be converted to an atom.
--*/
--------------------------------------------------------------------------------
global function float64_to_atom(sequence_8 ieee64)	-- converts a sequence of 8 bytes in IEEE 64-bit format to an atom
    return machine_func(M_F64_TO_A, ieee64)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##ieee32##: sequence of 8 bytes
--
-- Returns: an **atom** holding the processed result
--
-- Notes:
-- 
-- The 8 bytes must contain an IEEE floating-point number in 64-bit format.
--
-- Any 64-bit IEEE floating-point number can be converted to an atom.
--*/
--------------------------------------------------------------------------------
global function int_to_bits(atom x, integer nbits)	-- extracts the lower bits from an integer
	sequence bits
	atom mask
	if nbits < 1 then
		return {}
	end if
	bits = repeat(0, nbits)
	if nbits <= 32 then
		-- faster method
		mask = 1
		for i = 1 to nbits do
			bits[i] = and_bits(x, mask) and 1
			mask *= 2
		end for
	else
		-- slower, but works for large x and large nbits
		if x < 0 then
			x += power(2, nbits) -- for 2's complement bit pattern
		end if
		for i = 1 to nbits do
			bits[i] = remainder(x, 2)
			x = floor(x / 2)
		end for
	end if
	return bits
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##x##: the whole number value to be converted
--# ##nbits##: the number of bits to process
--
-- Returns:
--
-- a **sequence** containing the low-order ##nbits## bits of ##x##,
-- as 1's and 0's
--
-- The least significant bits come first.
-- For negative numbers the two's complement bit pattern is returned.
--
-- Notes:
--
-- You can use subscripting, slicing, and/or/xor/not of entire sequences etc.
-- to manipulate sequences of bits. Shifting of bits and rotating of bits are
-- easy to perform.
--*/
--------------------------------------------------------------------------------
global function int_to_bytes(atom x)	-- converts an atom that represents an integer to a sequence of 4 bytes
	integer a
	integer b
	integer c
	integer d
	a = remainder(x, #100)
	x = floor(x / #100)
	b = remainder(x, #100)
	x = floor(x / #100)
	c = remainder(x, #100)
	x = floor(x / #100)
	d = remainder(x, #100)
	return {a, b, c, d}
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##x##: the whole number value to be converted
--
-- Returns:
--
-- a **sequence** of 4 bytes
--
-- These bytes are in the order expected on the 386+,
-- i.e. least-significant byte first.
--
-- Notes:
--
-- You might use this routine prior to poking the 4 bytes into memory for use by
-- a machine language program.
--
-- The integer can be negative. Negative byte-values will be returned, but after
-- poking them into memory you will have the correct (two's complement)
-- representation for the 386+.
--
-- This function will correctly convert integer values up to 32-bits.
-- For larger values, only the low-order 32-bits are converted.
-- Euphoria's **integer** type only allows values up to 31-bits, so declare your
-- variables as **atom** if you need a larger range.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
