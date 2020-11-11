--------------------------------------------------------------------------------
--	Library: math.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)math.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.2.1.23
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.07.08
--Status: operational; incomplete
--Changes:]]]
--* ##gcd## defined
--* ##max## re-defined
--* ##min## re-defined
--* ##product## re-defined
--
------
--==Euphoria Standard library: math
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##abs##(object) : object
--* ##arccos##(trig_range) : object
--* ##arccosh##(object)	:	object
--* ##arcsin##(trig_range) : object
--* ##arcsinh##(object)	:	object
--* ##arctanh##(object)	:	object	
--* ##atan2##(atom, atom)	:	atom
--* ##ceil##(object)	:	object
--* ##cosh##(object)    :       object
--* ##deg2rad##(object)	:	object
--* ##ensure_in_list##(object, sequence, integer) : object
--* ##ensure_in_range##(object, sequence) : object
--* ##exp##(atom)	:	atom
--* ##fib##(integer)    :       atom
--* ##frac##(object) : object
--* ##gcd##(atom, atom) : atom
--* ##intdiv##(object, object)	:	object
--* ##larger_of##(object, object)	 : object 
--* ##log10##(object)	:	object
--* ##max##(object) : atom
--* ##min##(object) : atom
--* ##mod##(object, object)	:	object
--* ##or_all##(object) : atom
--* ##product##(object)	:	atom
--* ##rad2deg##(object)	:	object
--* ##round##(object, object)	:	object
--* ##rotate_bits##(object, integer)	:	object
--* ##shift_bits##(object, integer)	:	object
--* ##sign##(object)	:	object
--* ##sinh##(object)    :       object
--* ##smaller_of##(object, object) : object
--* ##sum##(object)	:	atom
--* ##tanh##(object)    :       object
--* ##trunc##(object) :	 object
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/math.e</eucode>
--
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
include error.e	as error
include mathcons.e as mathcons	-- for MINF, PI, PINF
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant PI_HALF =  PI / 2.0  -- this is pi/2
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
type abs_below_1(object x)
    if atom(x) then
        return x > -1.0 and x < 1.0
    end if
    for i = 1 to length(x) do
        if not abs_below_1(x[i]) then
            return 0
        end if
    end for
    return 1
end type
--------------------------------------------------------------------------------
type not_below_1(object x)
    if atom(x) then
        return x >= 1.0
    end if
    for i=1 to length(x) do
        if not not_below_1(x[i]) then
            return 0
        end if
    end for
    return 1
end type
--------------------------------------------------------------------------------
type trig_range(object x)
--  values passed to arccos and arcsin must be [-1, +1]
    if atom(x) then
		return x >= -1 and x <= 1
    else
		for i = 1 to length(x) do
		    if not trig_range(x[i]) then
			return 0
		    end if
		end for
		return 1
    end if
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
integer sign_id
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
global function abs(object this)-- returns the absolute value of all numbers in an object
	object t
	if atom(this) then
		if this >= 0 then
			return this
		else
			return - this
		end if
	end if
	for i = 1 to length(this) do
		t = this[i]
		if atom(t) then
			if t < 0 then
				this[i] = - t
			end if
		else
			this[i] = abs(t)
		end if
	end for
	return this
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: the source object
--
-- Returns:
-- an **object**: the same shape as ##this##.
--
-- When ##this## is an atom, the result is the same if not less than zero;
-- but negatived otherwise.
--
-- When ##this## is a sequence, ##abs## applies to all its elements,
-- no matter how deeply nested.
--
-- Example:
-- <eucode>x = abs({10.5, -12, 3})
-- -- x is {10.5, 12, 3}
--
-- i = abs(-4)
-- -- i is 4</eucode>
--
-- See Also:
-- ##sign##
--*/
--------------------------------------------------------------------------------
global function arccos(trig_range value)	--  returns an angle given its cosine
    return PI_HALF - 2 * arctan(value / (1.0 + sqrt(1.0 - value * value)))
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##value##: an object, each atom containing a cosine value.
--
-- Returns:
--
--   an **object**, the same shape as ##value##.
-- Each element of the result is an atom, representing an angle whose cosine is
-- the corresponding element in the source.
--
-- Errors:
--
--   If any atom in ##value## is not in the -1..1 range, as it cannot be a
-- cosine of a real number, an error occurs.
--
-- Notes:
--
-- A value between 0 and ##PI## radians will be returned.
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- ##arccos## is not as fast as ##arctan##.
--
-- Example:
-- <eucode>s = arccos({-1,0,1})
-- -- s is {3.141592654, 1.570796327, 0}</eucode>
--
-- See Also:
--##cos##, ##PI##, ##arctan##
--*/
--------------------------------------------------------------------------------
global  function arccosh(not_below_1 this)	-- computes the reverse hyperbolic cosine of an object
    return log(this + sqrt(this*this-1))
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this## : the object to process
--
-- Returns:
--
-- an **object**, the same shape as ##this##, each atom of which is transformed.
--
-- Errors:
--
-- Since ##cosh only takes values not below 1, an argument below 1 causes a
-- //type// error.
--
-- Notes:
--
-- The hyperbolic cosine grows like the logarithm function.
--
-- Example 1:
-- <eucode>?arccosh(1) -- prints out 0</eucode>

--*/
--------------------------------------------------------------------------------
global function arcsin(trig_range value)	--  returns angle(s) in radians
    return 2 * arctan(value / (1.0 + sqrt(1.0 - value * value)))
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--		# ##value## : an object, each atom containing a sine value.
--
-- Returns:
--
--		An **object**, the same shape as ##value##.
-- When ##value## is an atom, the result is an atom,
-- an angle whose sine is ##value##.
--
-- Errors:
--
--	If any atom in ##value## is not in the -1..1 range, it cannot be the sine
-- of a real number, and an error occurs.
--
-- Notes:
--
-- A value between ##-PI/2## and ##+PI/2## (radians) inclusive will be returned.
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- ##arcsin## is not as fast as ##arctan##.
--
-- Example:
-- <eucode>s = arcsin({-1,0,1})
-- s is {-1.570796327, 0, 1.570796327}</eucode>
--
-- See Also:
-- ##arccos##, ##sin##
--*/
--------------------------------------------------------------------------------
global function arcsinh(object this)	-- computes the reverse hyperbolic sine of an object
    return log(this + sqrt(1+this*this))
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this##: the object to process
--
-- Returns:
--
-- an **object**, the same shape as ##this##, with each atom operated on.
--
-- Notes:
--
-- The hyperbolic sine grows like the logarithm function.
--
-- Example 1:
-- <eucode>?arcsinh(1) -- prints out 0.881374</eucode>
--*/
--------------------------------------------------------------------------------
global function arctanh(abs_below_1 this)	-- computes the reverse hyperbolic tangent of an object
    return log((1+this)/(1-this))/2
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this## : the object to process
--
-- Returns:
--
-- an **object**, the same shape as ##this##, each atom of which has
-- beeb acted upon.
--
-- Errors:
--
-- Since tanh only takes values between -1 and +1 excluded,
-- an out of range argument causes an error.
--
-- Notes:
--
-- The hyperbolic cosine grows like the logarithm function.
--
-- Example 1:
-- <eucode>? arctanh(1/2) -- prints out 0.549306</eucode>
--
-- See Also:
--
-- ##arccos##, ##arcsinh##, ##cosh##
--*/
--------------------------------------------------------------------------------
global function atan2(atom y, atom x)	-- calculate the arctangent of a ratio
	if x > 0 then
		return arctan(y/x)
	elsif x < 0 then
		if y < 0 then
			return arctan(y/x) - mathcons:PI
		else
			return arctan(y/x) + mathcons:PI
		end if
	elsif y > 0 then
		return mathcons:HALFPI
	elsif y < 0 then
		return -(mathcons:HALFPI)
	else
		return 0
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##y##: the numerator of the ratio
--# ##x##: the denominator of the ratio
--
-- Returns:
--
-- an **atom**, which is equal to arctan(##y##/##x##),
-- except that it can handle zero denominator and is more accurate.
--
-- Example 1:
-- <eucode>a = atan2(10.5, 3.1)
-- -- a is 1.283713958</eucode>
--*/
--------------------------------------------------------------------------------
global function ceil(object value)	-- the next integer equal or greater than the argument
	return -floor(-value)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##value##: the source, each atom of which processed, no matter how deeply nested
--
-- Returns:
--
--	an **object**, having the same shape as ##value##.
-- Each atom in ##value##  is returned as an integer that is the smallest
-- integer equal to or greater than the corresponding atom in ##value##.
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- ##ceil(X)## is 1 more than ##floor(X)## for non-integers.
-- For integers, ##X = floor(X) = ceil(X)##.
--*/
--------------------------------------------------------------------------------
global function deg2rad(object angle) -- converts an angle measured in degrees to an angle measured in radians
    return angle * mathcons:DEGREES_TO_RADIANS
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##angle##: the object to be converted
--
-- Returns:
--
--	an **object**, the same shape as ##angle##, all atoms of which have been
-- multiplied by PI/180.
--
-- Notes:
--
-- This function may be applied to an atom or sequence.
-- All atoms will be converted, no matter how deeply nested.
--
-- A flat angle is PI radians and 180 degrees.
--
-- Example 1:
--
-- <eucode>x = deg2rad(194)
-- -- x is 3.385938749</eucode>
--*/
--------------------------------------------------------------------------------
global function ensure_in_list(object item, sequence list, integer deflt)	-- ensures that an object is in a list of values
    if length(list) = 0 then
        return item
    end if
    if find(item, list) = 0 then
        if deflt >= 1 and deflt <= length(list) then
            return list[deflt]
        else
            return list[1]
        end if
    end if
    return item
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##item##: the object to look for
--# ##list##: the sequence of elements that ##item## might be a member of
--# ##deflt##: the index of the list item to return if ##item## is not found.
-- Defaults to 1.
--
-- Returns:
--
-- an **object**: the list item of index ##deflt## (if ##item## is not in ##list##)
-- or ##item##.
--
-- Notes:
--
-- If ##deflt## is set to an invalid index, the first item on the list is returned instead
-- when ##item## is not on the list.
--*/
--------------------------------------------------------------------------------
global function ensure_in_range(object item, sequence range_limits)	-- ensures that the an object is in a list
    if length(range_limits) < 2 then
        return item
    end if
    if compare(item, range_limits[1]) < 0 then
        return range_limits[1]
    end if
    if compare(item, range_limits[$]) > 0 then
        return range_limits[$]
    end if
    return item
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##item##: the object to look for
--# ##list##: a sequence of elements that ##item## might be a member of
--
-- Returns:
--
-- an object:
-- if item is lower than the first item in the range_limits then the first item;
-- if item is higher than the last element in the range_limits it returns the
-- last item;
-- otherwise ##item## is returned.
--
-- Example:
--
--<eucode>integer user_data user_data = 43
--object valid_data valid_data = ensure_in_range(user_data, {2, 75})
--printf(1, "Result = %d\n", valid_data)</eucode>
--*/
--------------------------------------------------------------------------------
global function exp(atom this)  -- computes some power of E
    return power(mathcons:E, this)
end function
--------------------------------------------------------------------------------
--/*
--Parameter:
--# ##this##: the source value
--
--Return:
--
-- an **atom**: the exponential of ##this##
--*/
--------------------------------------------------------------------------------
global function cosh(object this)       -- the hyperbolic cosine
    return (exp(this)+exp(-this))/2
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this##: the object to convert
--
-- Returns:
--
-- an **object**, the same shape as ##this##, each atom of which has
-- been converted.
--
-- Notes:
--
-- The hyperbolic cosine grows like the exponential function.
--
-- For all reals, ##power(cosh(x), 2) - power(sinh(x), 2) = 1##. Compare 
-- with ordinary trigonometry.
--
-- Example 1:
-- <eucode>? cosh(0.7) -- prints out 1.2552</eucode>
--*/
--------------------------------------------------------------------------------
global function fib(integer this)  -- computes a chosen term in the Fibonacci Series
    return floor((power(mathcons:PHI, this) / sqrt(5)) + 0.5)
end function
--------------------------------------------------------------------------------
--*
--Parameter:
--# ##this## : the index in the Fibonacci Series
--
-- Returns:
--
-- an **atom**: the Fibonacci Number specified by ##this##.
--
-- Notes:
--
-- * Note that due to the limitations of the floating point implementation,
-- only values less than 76 are accurate on Windows platforms, and 
-- 69 on other platforms (due to rounding differences in the native C
-- runtime libraries).
--
-- Example 1:
-- <eucode>? fib(6)
-- -- output ... 
-- -- 8</eucode>
--*/
--------------------------------------------------------------------------------
global function frac(object this)	-- returns fractional portions of numbers
    object temp 
    temp = abs(this)
    return call_func(sign_id, {this}) * (temp - floor(temp))
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##value##: any Euphoria object
--
-- Returns:
--
--an **object**, with the shape as ##this##. Each item in the 
-- returned object will exactly correspond to the item
-- in ##this##, but with the integer portion removed.
--
-- Notes:
--
-- Note that ##trunc(this) + frac(this) = this##
--
-- Example 1:
-- <eucode>a = frac(9.4)
-- -- a is 0.4</eucode>
--
-- Example 2:
-- <eucode>s = frac({81, -3.5, -9.999, 5.5})
-- -- s is {0, -0.5, -0.999, 0.5}</eucode>
--*/
--------------------------------------------------------------------------------
function iif(integer test, object true, object false)
	if test then return true
	else return false
	end if
end function
--------------------------------------------------------------------------------
global function gcd(atom a, atom b) -- the greater common divisor of the two atoms
	-- use Euclid's algorithm
	-- ensure positive values
	a = abs(a)
	b = abs(b)
	-- strip off any fractional part
	a = floor(a)
	b = floor(b)
	if b = 0 then return a
	else return gcd(b, remainder(a, b))
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //a//: one of the atoms to consider
--# //b// : the other atom.
--
-- Returns:
--
-- a positive **integer**, which is the largest value that evenly divides
-- into both parameters.
--
-- Notes:
--
-- * Signs are ignored; atoms are rounded down to integers.
-- * If both parameters are zero, 0 is returned.
-- * If one parameter is zero, the other parameter is returned.
--
-- Parameters and return value are atoms so as to take mathematical integers up to ##power(2,53)##.
--
-- Examples:
-- <eucode>? gcd(76.3, -114) --> 38
-- ? gcd(0, -114) --> 114
-- ? gcd(0, 0) --> 0 (This is often regarded as an error condition)</eucode>
--
--*/
--------------------------------------------------------------------------------
global function intdiv(object this, object that)	-- integer division of two objects	
	return call_func(sign_id, {this}) * ceil(abs(this)/abs(that))
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: the source (to be divided)
--# ##that##: the divisor
--
-- Returns:
--
-- an **object**, which will be a sequence if either ##this## or ##that##
-- is a sequence. 
--
-- Notes:
--
-- * This calculates how many non-empty sets when ##this##
-- is divided by ##that##.
-- * The result's sign is the same as the ##this##'s sign.
--
--*/
--------------------------------------------------------------------------------
global function larger_of(object this, object that)	-- returns the larger of two objects
    if compare(this, that) > 0 then
	    return this
    else
	    return that
    end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: an object
--# ##that##: another object
--
-- Returns:
-- an **object**: whichever of ##this## and ##that## is the larger
--
-- Notes:
--
-- Introduced in v4.0.3
--
-- Example:
-- <eucode>? larger_of(10, 15.4) -- returns 15.4
-- ? larger_of("cat", "dog") -- returns "dog"
-- ? larger_of("apple", "apes") -- returns "apple"
-- ? larger_of(10, 10) -- returns 10</eucode>
--
-- See Also:
--	##max##, ##compare##, ##smaller_of##
--*/
--------------------------------------------------------------------------------
global function log10(object value)	-- returns the base 10 logarithm of an object
	return log(value) * mathcons:INVLN10
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##value## : an object to be converted
--
-- Returns:
--
--an **object**, the same shape as ##value##.
-- When ##value## is an atom, raising 10 to the returned atom yields ##value## back.
--
-- Errors:
--
-- If any atom in ##value## is not greater than zero, its logarithm is not a real
-- number and an error occurs.
--
-- Notes:
--
-- This function may be applied to an atom or to all elements
-- of a sequence. 
-- All atoms will be converted, no matter how deeply nested.
--
-- ##log10##() is proportional to ##log##() by a factor of ##1/log(10)##, 
-- which is about ##0.435##.
--
-- Example 1:
--
-- <eucode>a = log10(12)
-- -- a is 1.07918125</eucode>
--*/
--------------------------------------------------------------------------------
global function max(object this)	-- computes the maximum value among all the argument's elements
    atom l
    atom last
    if atom(this) then
	    return this
	else -- sequence
		l = length(this)	
		if l = 0 then return 0
		elsif l = 1 then return this[1]
		elsif l = 2 then return iif(this[1] > this[2], this[1], this[2])
		else last = max(this[1..$-1]) return iif(this[$] > last, this[$], last)
		end if
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--		# ##this##: the object to analyse 
--
-- All atoms will be inspected, no matter how deeply nested.
--
-- Returns:
--
--an **atom**: the maximum of all atoms in the object
--
-- Notes:
--
-- This function may be applied to an atom or to a sequence of any shape.
--
-- Example 1:
-- <eucode>a = max({10,15.4,3})
-- -- a is 15.4</eucode>
--
-- See Also:
--##min##, ##compare##, ##flatten##
--*/
--------------------------------------------------------------------------------
global function min(object this)	-- computes the minimum value among all the argument's elements
	atom l
	atom last
	if atom(this) then return this
	else -- sequence
		l = length(this)	
		if l = 0 then return 0
		elsif l = 1 then return this[1]
		elsif l = 2 then return iif(this[1] < this[2], this[1], this[2])
		else last = min(this[1..$-1]) return iif(this[$] < last, this[$], last)
		end if
	end if
	end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--		# ##this##: the object to analyse 
--
-- All atoms will be inspected, no matter how deeply nested.
--
-- Returns:
--
--an **atom**: the minimum of all atoms in the object
--
-- Notes:
--
-- This function may be applied to an atom or to a sequence of any shape.
--*/
--------------------------------------------------------------------------------
global function mod(object this, object that)   -- returns a modulus with base that
	if equal(call_func(sign_id, {this}), call_func(sign_id, {that})) then
		return remainder(this, that)
	end if
	return this - that * floor(this / that)
end function
--------------------------------------------------------------------------------
--/*
-- This function computes the remainder of the division of two objects using
-- floored division.
--
-- Parameters:
--		# ##this## : any Euphoria object.
--		# ##that## : any Euphoria object.
--
-- Returns:
--
--	An **object**, the shape of which depends on ##dividend##'s and
-- ##divisor##'s. For two atoms, this is the remainder of dividing ##dividend##
-- by ##divisor##, with ##divisor##'s sign.
--
-- Notes:
--
-- * There is a integer ##N## such that ##dividend## = N * ##divisor## + result.
-- * The result is non-negative and has lesser magnitude than ##divisor##.
-- n needs not fit in an Euphoria integer.
-- *  The result has the same sign as the dividend.
-- * The arguments to this function may be atoms or sequences. The rules for
-- [[:operations on sequences]] apply, and determine the shape of the returned object.
-- * When both arguments have the same sign, ##mod## and ##remainder##
-- return the same result. 
-- * This differs from ##remainder## in that when the operands' signs are different
-- this function rounds ##dividend/divisior## away from zero whereas ##remainder## rounds
-- towards zero.
--*/
--------------------------------------------------------------------------------
global function or_all(object a)	-- ors together all atoms in the argument, no matter how deeply nested
	atom b
	if atom(a) then
		return a
	end if
	b = 0
	for i = 1 to length(a) do
		if atom(a[i]) then
			b = or_bits(b, a[i])
		else
			b = or_bits(b, or_all(a[i]))
		end if
	end for
	return b
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##a##: an object, all atoms of which will be added up, no matter how nested
--
-- Returns:
--
--	an **atom**, the result of or'ing all atoms in ##a##
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
-- It performs ##or_bits##() operations repeatedly.
--
-- See Also:
--		##sum##, ##product##, ##or_bits##
--*/
--------------------------------------------------------------------------------
global function product(object this)-- the product of all the atom in the argument, no matter how deeply nested
	atom ret
	if atom(this) then return this
	else -- sequence
		ret = 1
		for i = 1 to length(this) do
			if atom(this[i]) then
				ret *= this[i]
			else
				ret *= product(this[i])
			end if
		end for
		return ret
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: the source object
--
-- Returns:
--
-- an **atom**: the product of all atoms in ##flatten##(//this//).
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- Example 1:
-- <eucode>a = product({10, 20, 30})-- a is 6000
-- a = product({10.5, {11.2} , 8.1})-- a is 952.56</eucode>
--
-- See Also:
--
--	##sum##, ##or_all##
--*/
--------------------------------------------------------------------------------
global function rad2deg (object angle)	-- converts an angle measured in radians to an angle measured in degrees
   return angle * mathcons:RADIANS_TO_DEGREES
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##angle##: the object to be converted
--
-- Returns:
--		An **object**, the same shape as ##angle##, all atoms of which were multiplied by 180/PI.
--
-- Notes:
--
-- This function may be applied to an atom or sequence.
-- All atoms will be converted, no matter how deeply nested.
--
-- A flat angle is PI radians and 180 degrees.
--
-- Example 1:
--
-- <eucode>x = rad2deg(3.385938749)
-- -- x is 194</eucode>
--*/
--------------------------------------------------------------------------------
global function round(object a, object precision)	-- returns the objects's elements rounded to a set precision
	integer len
	sequence s
	object t
	object u
	precision = abs(precision)
	if atom(a) then
		if atom(precision) then
			return floor(0.5 + (a * precision )) / precision
		end if
		len = length(precision)
		s = repeat(0, len)
		for i = 1 to len do
			t = precision[i]
			if atom (t) then
				s[i] = floor( 0.5 + (a * t)) / t
			else
				s[i] = round(a, t)
			end if
		end for
		return s
	elsif atom(precision) then
		len = length(a)
		s = repeat(0, len)
		for i = 1 to len do
			t = a[i]
			if atom(t) then
				s[i] = floor(0.5 + (t * precision)) / precision
			else
				s[i] = round(t, precision)
			end if
		end for
		return s
	end if
	len = length(a)
	if len != length(precision) then
		error:crash("The lengths of the two supplied sequences do not match.", 0)
	end if
	s = repeat(0, len)
	for i = 1 to len do
		t = precision[i]
		if atom(t) then
			u = a[i]
			if atom(u) then
				s[i] = floor(0.5 + (u * t)) / t
			else
				s[i] = round(u, t)
			end if
		else
			s[i] = round(a[i], t)
		end if
	end for
	return s
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##value##: the source: each atom of which will be acted upon, no matter how deeply nested
--# ##precision##: the rounding precision(s)
--
-- Returns:
--
-- an **object**: the same shape as ##value##, with all atoms within rounded
-- as determined by ##precision##.
-- When ##value## is an atom, the result is that atom rounded to the nearest
-- integer multiple of ##precision##.
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
--*/
--------------------------------------------------------------------------------
global function shift_bits(object source_number, integer shift_distance)	-- moves the bits in the input value by the specified distance
	integer lSigned
	if sequence(source_number) then
		for i = 1 to length(source_number) do
			source_number[i] = shift_bits(source_number[i], shift_distance)
		end for
		return source_number
	end if
	source_number = and_bits(source_number, #FFFFFFFF)
	if shift_distance = 0 then
		return source_number
	end if
	if shift_distance < 0 then
		source_number *= power(2, -shift_distance)
	else
		lSigned = 0
		-- Check for the sign bit so we don't propagate it.
		if and_bits(source_number, #80000000) then
			lSigned = 1
			source_number = and_bits(source_number, #7FFFFFFF)
		end if
		source_number /= power(2, shift_distance)
		if lSigned and shift_distance < 32 then
			-- Put back the sign bit now shifted
			source_number = or_bits(source_number, power(2, 31-shift_distance))
		end if
	end if
	return and_bits(source_number, #FFFFFFFF)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##source_number##: the value(s) whose bits are to be moved
--# ##shift_distance##: the number of bits to be moved by
--
--Returns:
--
-- an **object**: the same shape as ##source_number##, being a copy
-- with all the bits shifted, thus with all elements containing 32-bit integers.
--
--Notes:
--* If ##source_number## is a sequence, each element is shifted.
--* The value(s) in ##source_number## are first truncated to a 32-bit integer.
--* The output is truncated to a 32-bit integer.
--* Vacated bits are replaced with zero.
--* If ##shift_distance## is negative, the bits in ##source_number## are moved left.
--* If ##shift_distance## is positive, the bits in ##source_number## are moved right.
--* If ##shift_distance## is zero, the bits in ##source_number## are not moved.
--
-- Example:
-- <eucode>? shift_bits(7, -3) --> 56
-- ? shift_bits(0, -9) --> 0
-- ? shift_bits(4, -7) --> 512
-- ? shift_bits(8, -4) --> 128
-- ? shift_bits(0xFE427AAC, -7) --> 0x213D5600
-- ? shift_bits(-7, -3) --> -56  which is 0xFFFFFFC8 
-- ? shift_bits(131, 0) --> 131
-- ? shift_bits(184.464, 0) --> 184
-- ? shift_bits(999_999_999_999_999, 0) --> -1530494977 which is 0xA4C67FFF
-- ? shift_bits(184, 3) -- 23
-- ? shift_bits(48, 2) --> 12
-- ? shift_bits(121, 3) --> 15
-- ? shift_bits(0xFE427AAC, 7) -->  0x01FC84F5
-- ? shift_bits(-7, 3) --> 0x1FFFFFFF
-- ? shift_bits({48, 121}, 2) --> {12, 30}</eucode>
--
-- See Also:
--
-- ##rotate_bits##
--*/
--------------------------------------------------------------------------------
global function rotate_bits(object source_number, integer shift_distance)	-- rotates the bits in the input value by the specified distance
	integer lRest
	atom lSave
	atom lTemp
	if sequence(source_number) then
		for i = 1 to length(source_number) do
			source_number[i] = rotate_bits(source_number[i], shift_distance)
		end for
		return source_number
	end if
	source_number = and_bits(source_number, #FFFFFFFF)
	if shift_distance = 0 then
		return source_number
	end if
	if shift_distance < 0 then
		lSave = not_bits(power(2, 32 + shift_distance) - 1) 	
		lRest = 32 + shift_distance
	else
		lSave = power(2, shift_distance) - 1
		lRest = shift_distance - 32
	end if
	lTemp = shift_bits(and_bits(source_number, lSave), lRest)
	source_number = shift_bits(source_number, shift_distance)
	return or_bits(source_number, lTemp)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--
--# ##source_number##: value(s) whose bits will be be rotated
--# ##shift_distance##: number of bits to be moved by 
--
-- Returns:
--
-- Atom(s) containing a 32-bit integer. A single atom in ##source_number## is an atom, or
-- a sequence in the same form as ##source_number## containing 32-bit integers.
--
-- Notes:
--
-- * If ##source_number## is a sequence, each element is rotated.
-- * The value(s) in ##source_number## are first truncated to a 32-bit integer.
-- * The output is truncated to a 32-bit integer.
-- * If ##shift_distance## is negative, the bits in ##source_number## are rotated left.
-- * If ##shift_distance## is positive, the bits in ##source_number## are rotated right.
-- * If ##shift_distance## is zero, the bits in ##source_number## are not rotated.
--
-- Example 1:
-- <eucode>? rotate_bits(7, -3) --> 38
-- ? rotate_bits(0, -9) --> 0
-- ? rotate_bits(4, -7) --> 200
-- ? rotate_bits(8, -4) --> 80
-- ? rotate_bits(0xFE427AAC, -7) --> 0x213D567F
-- ? rotate_bits(-7, -3) --> -49  which is 0xFFFFFFCF
-- ? rotate_bits(131, 0) --> 131
-- ? rotate_bits(184.464, 0) --> 184
-- ? rotate_bits(999_999_999_999_999, 0) --> -1530494977 which is 0xA4C67FFF
-- ? rotate_bits(184, 3) -- 23
-- ? rotate_bits(48, 2) --> 12
-- ? rotate_bits(121, 3) --> 536870927
-- ? rotate_bits(0xFE427AAC, 7) -->  0x59FC84F5
-- ? rotate_bits(-7, 3) --> 0x3FFFFFFF
-- ? rotate_bits({48, 121}, 2) --> {12, 1073741854}</eucode>
--
-- See Also:
--
--  ##shift_bits##
--*/
--------------------------------------------------------------------------------
global function sign(object a)	-- returns -1, 0 or 1 for each element according to it being negative, zero or positive
    -- small so normally it will be inlined 
    return (a > 0) - (a < 0)
end function
sign_id = routine_id("sign")
--------------------------------------------------------------------------------
--/*
-- Parameter:
--		# ##a## : an object, each atom of which will be acted upon, no matter how deeply nested.
--
-- Returns:
--
--		An **object**, the same shape as ##a##. When ##a## is an atom, the result is -1 if ##a## is less than zero, 1 if greater and 0 if equal.
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- For an atom, ##sign(x)## is the same as ##compare##(x,0).
--*/
--------------------------------------------------------------------------------
global function smaller_of(object this, object that)	-- returns the smaller of two objects
	if compare(this, that) < 0 then
		return this
	else
		return that
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##this##: an object
--# ##that##: another object
--
-- Returns:
-- an **object**: whichever of ##this## and ##that## is the smaller
--
-- Notes:
--
-- Introduced in v4.0.3
--
-- Example:
-- <eucode>? smaller_of(10, 15.4) -- returns 10
-- ? smaller_of("cat", "dog") -- returns "cat"
-- ? smaller_of("apple", "apes") -- returns "apes"
-- ? smaller_of(10, 10) -- returns 10</eucode>
--
-- See Also:
--		##min##, ##compare##, ##larger_of##
--*/
--------------------------------------------------------------------------------
global function sinh(object this)	-- computes the hyperbolic sine of an object
    return (exp(this)-exp(-this))/2
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this##: the object to process
--
-- Returns:
--
-- an **object**, the same shape as ##this##, each atom of which has been
-- acted upon.
--
-- Notes:
--
-- The hyperbolic sine grows like the exponential function.
--
-- For all reals, ##power(cosh(x), 2) - power(sinh(x), 2) = 1##. Compare 
-- with ordinary trigonometry.
--
-- Example 1:
--
-- <eucode>? sinh(0.7) 	-- prints out 0.758584</eucode>
--
-- See Also:
--
-- ##cosh##, ##sin##, ##arcsinh##
--*/
--------------------------------------------------------------------------------
global function sum(object thus)	-- compute the sum of all atoms in the argument, no matter how deeply nested
	atom result
	if atom(thus) then return thus
	else -- sequence
		result = 0
		for i = 1 to length(thus) do
			if atom(thus[i]) then
				result += thus[i]
			else
				result += sum(thus[i])
			end if
		end for
		return result
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this## : an object, all atoms of which will be added up, no matter how nested.
--
-- Returns:
--
-- an **atom**: the sum of all atoms in ##flatten##(##this##).
--
-- Notes:
--
-- This function may be applied to an atom or to all elements of a sequence.
--
-- Example 1:
-- <eucode> a = sum({10, 20, 30}) -- a is 60
-- a = sum({10.5, {11.2} , 8.1}) -- a is 29.8</eucode>
--
-- See Also:
--
-- ##product##, ##or_all##
--*/
--------------------------------------------------------------------------------
global function tanh(object this)	-- computes the hyperbolic tangent of an object
    return sinh(this)/cosh(this)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this## : the object to process
--
-- Returns:
--
-- an **object**, the same shape as ##this##, with each atom converted
--
-- Notes:
--
-- The hyperbolic tangent takes values from -1 to +1.
--
-- ##tanh##() is the ratio ##sinh() / cosh()##.
--
-- Example 1:
-- <eucode>? tanh(0.7) -- prints out 0.604368</eucode>

--*/
--------------------------------------------------------------------------------
global function trunc(object this)	-- returns the fractional portion of a number
	return sign(this) * floor(abs(this))
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##this##: any Euphoria object
--
-- Returns:
--
--An **object**, the shape of which depends on ##x##'s.
-- Each item in the returned object will be the same corresponding items
-- in ##x## except with the integer portion removed.
--
-- Notes:
--
-- Note that ##trunc(x) + frac(x) = x##
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.22
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.03.06
--Status: operational; incomplete
--Changes:]]]
--* ##rotate_bits## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.21
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.02.21
--Status: operational; incomplete
--Changes:]]]
--* ##shift_bits## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.20
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.02.11
--Status: operational; incomplete
--Changes:]]]
--* ##product## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.19
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.02.03
--Status: operational; incomplete
--Changes:]]]
--* ##arctanh## defined
--* ##sum## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.18
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.01.12
--Status: operational; incomplete
--Changes:]]]
--* ##tanh## defined
--* ##arcsinh## defined
--* ##arccosh## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.17
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.12.30
--Status: operational; incomplete
--Changes:]]]
--* ##sinh## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.16
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.12.20
--Status: operational; incomplete
--Changes:]]]
--* ##exp## defined
--* ##fib## defined
--* ##cosh## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.15
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.12.19
--Status: operational; incomplete
--Changes:]]]
--* ##atan2## defined
--* ##rad2deg## defined
--* ##deg2rad## defined
--* ##log10## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.14
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.11.30
--Status: operational; incomplete
--Changes:]]]
--* ##round## defined
--* documentation of routines completed
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.13
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.11.24
--Status: operational; incomplete
--Changes:]]]
--* ##ceil## defined
--* ##intdiv## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.12
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.11.16
--Status: operational; incomplete
--Changes:]]]
--* ##frac## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.11
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.11.07
--Status: operational; incomplete
--Changes:]]]
--* ##trunc## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.10
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.10.25
--Status: operational; incomplete
--Changes:]]]
--* ##ensure_in_list## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.9
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.10.19
--Status: operational; incomplete
--Changes:]]]
--* ##ensure_in_range## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.8
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.05.01
--Status: operational; incomplete
--Changes:]]]
--* ##or_all## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.04.13
--Status: operational; incomplete
--Changes:]]]
--* ##larger_of## defined
--* ##smaller_of## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.03.22
--Status: operational; incomplete
--Changes:]]]
--* ##abs## defined, including embedded example
--* ##arccos## - added example to text
--* ##arcsin## - added example to text
--* ##max## - added example to text
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.29
--Status: operational; incomplete
--Changes:]]]
--* ##max## defined
--* ##min## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.12.16
--Status: operational; incomplete
--Changes:]]]
--* modified ##mod## as ##sign## not previously defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.27
--Status: operational; incomplete
--Changes:]]]
--* documented ##arcsin##
--* defined ##mod##
--* defined ##sign##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.23
--Status: created; incomplete
--Changes:]]]
--* documented ##arccos##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.10
--Status: created; incomplete
--Changes:]]]
--* defined ##arccos##
--* defined ##arcsin##
--* included ##mathcons.e##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1 
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.09
--Status: created; incomplete
--Changes:]]]
--* defined ##mod##
--
--------------------------------------------------------------------------------
