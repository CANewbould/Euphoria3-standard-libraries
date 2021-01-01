--------------------------------------------------------------------------------
--	Library: mathcons.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)mathcons.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.01
--Status: created; complete
--Changes:]]]
--* //PISQR// defined
--* //INVSQ2PI// defined
--* //LN2// defined
--* //LN10// defined
--* //SQRT2// defined
--* //HALFSQRT2// defined
--* //SQRT3// defined
--* //EULER_GAMMA// defined
--* //SQRTE// defined
--* //SQRT5// defined
--* //QUARTPI// defined
--* //TWOPI// defined
--* //INVLN2// defined
--
--==Euphoria Standard library: mathcons
-- The following constants are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* //DEGREES_TO_RADIANS//
--* //E//
--* //EULER_GAMMA//
--* //HALFPI//
--* //HALFSQRT2//
--* //INVLN2//
--* //INVLN10//
--* //INVSQ2PI//
--* //LN2//
--* //LN10//
--* //MINF//
--* //PHI//
--* //PI//
--* //PINF//
--* //PISQR//
--* //QUARTPI//
--* //RADIANS_TO_DEGREES//
--* //SQRTE//
--* //SQRT2//
--* //SQRT3//
--* //SQRT5//
--* //TWOPI//
--
-- This library hold values to support the standard ##math## library.
--
-- The trig formulas were originally provided by Larry Gregg.
--
-- Utilise this support by adding the following statement to your module:
--<eucode>include std/mathcons.e</eucode>
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
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant INF = 1E308 * 1000
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant DEGREES_TO_RADIANS = 0.01745329251994329576
global constant E = 2.71828182845904523536
global constant EULER_GAMMA = 0.57721566490153286061
global constant HALFPI = 1.57079632679489661923
global constant HALFSQRT2 = 0.7071067811865475244 -- sqrt(2)/2
global constant INVLN2 = 1.44269504088896340736 -- 1 / ln(2)
global constant INVLN10 = 0.43429448190325182765 -- 1 / ln(10)
global constant INVSQ2PI = 0.39894228040143367794 -- 1 / (sqrt(2PI))
global constant LN2 = 0.69314718055994530941 -- 1 / (ln(2))
global constant LN10 = 2.30258509299404568401 -- ln(10) :: 10 = power(E, LN10)
global constant MINF = - INF 	-- Negative Infinity
global constant PHI = 1.61803398874989484820 -- phi  => Golden Ratio = (1 + sqrt(5)) / 2
global constant PI = 3.141592653589793238
global constant PINF = INF	-- Positive Infinity
global constant PISQR = 9.86960440108935861883
global constant QUARTPI = 0.78539816339744830962
global constant RADIANS_TO_DEGREES = 57.29577951308232090712
global constant SQRTE = 1.64872127070012814684 -- sqrt(E)
global constant SQRT2 = 1.4142135623730950488 -- sqrt(2)
global constant SQRT3 = 1.73205080756887729353 -- sqrt(3)
global constant SQRT5 = 2.23606797749978969641 -- sqrt(5)
global constant TWOPI = 6.28318530717958647692
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
--
--=== Routines
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.12.20
--Status: created; incomplete
--Changes:]]]
--* //E// defined
--* //PHI// defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.12.19
--Status: created; incomplete
--Changes:]]]
--* //HALFPI// defined
--* //RADIANS_TO_DEGREES// defined
--* //DEGREES_TO_RADIANS// defined
--* //INVLN10// defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.29
--Status: created; incomplete
--Changes:]]]
--* //MINF// defined
--* //PINF// defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.03.29
--Status: created; incomplete
--Changes:]]]
--* defined //PI// constant
--------------------------------------------------------------------------------
