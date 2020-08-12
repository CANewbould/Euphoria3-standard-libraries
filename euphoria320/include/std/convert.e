--------------------------------------------------------------------------------
--	Library: convert.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)convert.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.01.06
--Status: operational; complete
--Changes:]]]
--* defined ##int_to_bits##
--
------
--==Euphoria Standard library: convert
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
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
--[[[Version: 3.2.0.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.01.04
--Status: operational; incomplete
--Changes:]]]
--* defined ##float32_to_atom##
--* defined ##float64_to_atom##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.01.01
--Status: operational; incomplete
--Changes:]]]
--* defined ##bytes_to_int##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.12.30
--Status: operational; incomplete
--Changes:]]]
--* defined ##bits_to_int##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.12.30
--Status: operational; incomplete
--Changes:]]]
--* defined ##atom_to_float64##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.10.13
--Status: operational; incomplete
--Changes:]]]
--* defined ##int_to_bytes##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.04
--Status: operational; incomplete
--Changes:]]]
--* defined ##atom_to_float32##
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
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
atom mem	mem = allocate(4)
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
global function atom_to_float32(atom a) -- converts an atom to a sequence of 4 bytes in IEEE 32-bit format 
	return machine_func(M_A_TO_F32, a)
end function
--------------------------------------------------------------------------------
--/*
--Parameter:
--# a: the atom to convert
-- 
--Returns:
--
--A **sequence**, of 4 bytes, which can be poked in memory to represent a.
--
--Notes:
--Euphoria atoms can have values which are 64-bit IEEE floating-point numbers,
-- so you may lose precision when you convert to 32-bits
-- (16 significant digits versus 7).
-- The range of exponents is much larger in 64-bit format (10 to the 308,
-- versus 10 to the 38), so some atoms may be too large or too small to
-- represent in 32-bit format.
-- In this case you will get one of the special 32-bit values:
-- inf or -inf (infinity or -infinity).
-- To avoid this, you can use atom_to_float64().
--
--Integer values will also be converted to 32-bit floating-point format.
--
--On modern computers, computations on 64 bit floats are no slower than on
-- 32 bit floats.
-- Internally, the PC stores them in 80 bit registers anyway.
-- Euphoria does not support these so called long doubles.
-- Not all C compilers do, either.
--*/
--------------------------------------------------------------------------------
global function atom_to_float64(atom a)
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
global function bits_to_int(sequence bits)  -- get the (positive) value of a sequence of "bits"
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
-- 		# ##bits##: the sequence to convert.
--
-- Returns:
--
--		A positive **atom**, whose machine representation was given by ##bits##.
--
-- Notes:
--
-- An element in ##bits## can be any atom. If nonzero, it counts for 1, else
-- for 0.
--
-- The first elements in ##bits## represent the bits with the least weight in
-- the returned value. Only the 52 last bits will matter, as the PC hardware
-- cannot hold an integer with more digits than this.
--
-- If you print ##bits## the bits will appear in "reverse" order, but it is
-- convenient to have increasing subscripts access bits of increasing
-- significance.
--*/
--------------------------------------------------------------------------------
global function bytes_to_int(sequence s)    -- converts a sequence of at most 4 bytes into an atom
	if length(s) = 4 then
		poke(mem, s)
	elsif length(s) < 4 then
		poke(mem, s & repeat(0, 4 - length(s))) -- avoid breaking old code
	else
		poke(mem, s[1..4]) -- avoid breaking old code
	end if
	return peek4u(mem)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##s## : the sequence to convert
-- Returns:
--
--		an **atom**, the value of the concatenated bytes of ##s##.
--
-- Comments:
--
--	This performs the reverse operation from ##int_to_bytes##.
--
--  An atom is returned, because the converted value may be bigger
-- than that which can fit into an **integer**.
--*/
--------------------------------------------------------------------------------
global function float32_to_atom(sequence_4 ieee32)
	return machine_func(M_F32_TO_A, ieee32)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##ieee32##: the sequence to convert
--
-- Returns:
--
--		an **atom**, the same value as the FPU would see by peeking
-- ##ieee64## from RAM.
--
-- Notes:
--
-- Any 32-bit IEEE floating-point number can be converted to an atom.
--*/
--------------------------------------------------------------------------------
global function atom_to_float64(atom a)
	return machine_func(M_A_TO_F64, a)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- 		# ##a##: the atom to convert
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
global function int_to_bits(atom x, integer nbits)  -- extracts the lower bits from an integer
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
			x = floor(x/2)
		end for
	end if
	return bits
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##x## : the atom to convert
-- 		# ##nbits## : the number of bits requested.
--
-- Returns:
--
--		a **sequence**, of length ##nbits##, made up of 1's and 0's.
--
-- Notes:
--
-- ##x## should have no fractional part. If it does, then the first "bit"
-- will be an atom between 0 and 2.
--
-- The bits are returned lowest first.
--
-- For negative numbers the two's complement bit pattern is returned.
--
-- You can use operators like subscripting/slicing/and/or/xor/not on entire sequences
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
--Parameter:
--# a: the atom to convert
-- 
--Returns:
--
-- A **sequence**, of 4 bytes, lowest significant byte first.
--
-- Notes:
--
-- If the atom does not fit into a 32-bit integer, things may still work out
-- alright.
--
--* If there is a fractional part, the first element in the returned value will
-- carry it. If you poke the sequence to RAM, that fraction will be discarded
--  anyway.

--* If x is simply too big, the first three bytes will still be correct,
-- and the 4th element will be floor(x/power(2,24)).
-- If this is not a byte sized integer, some truncation may occur,
-- but usually no error.
--
-- The integer can be negative.
-- Negative byte-values will be returned, but after poking them into memory
-- you will have the correct (two's complement) representation for the 386+.
--*/
--------------------------------------------------------------------------------
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
