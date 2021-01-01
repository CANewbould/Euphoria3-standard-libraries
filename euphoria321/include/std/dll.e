--------------------------------------------------------------------------------
--	Library: dll.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)dll.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.01
--Status: created; incomplete
--Changes:]]]
--* defined ##C_DWORD##
--
------
--==Euphoria Standard library: dll
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##call_back##
--* ##define_c_func##
--* ##define_c_proc##
--* ##define_c_var##
--* ##open_dll##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/dll.e</eucode>
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
include types.e -- for FALSE, TRUE, boolean, string
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant M_CALL_BACK = 52
constant M_DEFINE_C = 51
constant M_DEFINE_VAR = 56
constant M_OPEN_DLL = 50
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant C_BOOL    = #01000004	-- same as C_INT (below)
global constant C_CHAR    = #01000001
global constant C_DOUBLE  = #03000008
global constant C_FLOAT   = #03000004
global constant C_INT     = #01000004
global constant C_LONG    = C_INT
global constant C_POINTER = #02000004	-- same as C_ULONG
global constant C_SHORT   = #01000002
global constant C_UCHAR   = #02000001
global constant C_UINT    = #02000004
global constant C_ULONG   = C_UINT
global constant C_USHORT  = #02000002
global constant NULL = 0 -- NULL pointer
global constant C_DWORD   = C_UINT
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type char(integer this)
    return (this > 31 and this < 59)
        or (this > 64 and this < 90)
        or this = 92
        or this = 95
        or (this > 96 and this < 123)
end type
--------------------------------------------------------------------------------
type filename_string(string this)  -- needed to test for open_dll
    for i = 1 to length(this) do
        if not char(this[i]) then return FALSE end if
    end for
    return TRUE    
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
global function call_back(object id)	-- return a 32-bit call-back address for a Euphoria routine
    return machine_func(M_CALL_BACK, id)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##id##: either the id returned by ##routine_id## for the function/procedure, or a pair {'+', id}.
--
-- Returns:
--
--   An **atom**, the address of the machine code of the routine. It can be
--   used by Windows, or an external C routine in a Windows .dll or Unix-like
--   shared library (.so), as a 32-bit "call-back" address for calling your
--   Euphoria routine.
--
-- Errors:
--
--   The length of ##name## should not exceed 1,024 characters.
--
-- Notes:
--
--   By default, your routine will work with the stdcall convention. On
--   Windows, you can specify its id as {'+', id}, in which case it will
--   work with the cdecl calling convention instead. On non-Microsoft
--   platforms, you should only use simple IDs, as there is just one standard
--   calling convention, i.e. cdecl.
--
--   You can set up as many call-back functions as you like, but they must all be Euphoria
--   functions (or types) with 0 to 9 arguments. If your routine has nothing to return
--   (it should really be a procedure), just return 0 (say), and the calling C routine can
--   ignore the result.
--
--   When your routine is called, the argument values will all be 32-bit unsigned (positive)
--   values. You should declare each parameter of your routine as atom, unless you want to
--   impose tighter checking. Your routine must return a 32-bit integer value.
--
--   You can also use a call-back address to specify a Euphoria routine as an exception
--   handler in the Linux/FreeBSD signal() function. For example, you might want to catch
--   the SIGTERM signal, and do a graceful shutdown. Some Web hosts send a SIGTERM to a CGI
--   process that has used too much CPU time.
--
--   A call-back routine that uses the cdecl convention and returns a floating-point result,
--   might not work with euiw. This is because the Watcom C compiler (used to build euiw) has
--   a non-standard way of handling cdecl floating-point return values.
--*/
--------------------------------------------------------------------------------
global function define_c_func(object lib, object routine_name, sequence arg_types, atom return_type)	-- defines a C function (or machine code routine)
    return machine_func(M_DEFINE_C, {lib, routine_name, arg_types, return_type})
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##lib##: either an entry point returned as an atom by ##open_dll##, or "" to denote a routine the RAM address is known.
-- 		# ##routine_name##: either the name of a procedure in a shared object or the machine address of the procedure.
-- 		# ##argtypes##: a sequence of type constants.
-- 		# ##return_type##: an atom indicating what type the function will return.
--
-- Returns:
--
-- 		A small **integer**, known as a routine id, will be returned.
--
-- Errors:
--
-- The length of ##name## should not exceed 1,024 characters.
--
-- Notes:
--
-- 		Use the returned routine id as the first argument to ##c_func## when
-- you wish to call the routine from Euphoria.
--
-- 	A returned value of -1 indicates that the procedure could not be found or linked to.
--
-- On Windows, you can add a
-- '+' character as a prefix to the function name. This indicates to Euphoria that the 
-- function uses the cdecl calling convention. By default, Euphoria assumes that C routines
-- accept the stdcall convention.
--*/
--------------------------------------------------------------------------------             
global function define_c_proc(object lib, object routine_name, sequence arg_types)	-- defines a C function with VOID return type, or where the return value will always be ignored
    return machine_func(M_DEFINE_C, {lib, routine_name, arg_types, 0})
end function
--------------------------------------------------------------------------------
--/*
-- Alternatively, defines a machine-code routine at a given address.
--
-- Parameters:
-- 		# ##lib##: either an entry point returned as an atom by ##open_dll##, or "" to denote a routine the RAM address is known.
-- 		# ##routine_name##: either the name of a procedure in a shared object or the machine address of the procedure.
-- 		# ##argtypes##: a sequence of type constants.
--
-- Returns:
--
-- 		A small **integer**, known as a routine id, will be returned.
--
-- Errors:
--
-- The length of ##name## should not exceed 1,024 characters.
--
-- Notes:
--
-- 		Use the returned routine id as the first argument to ##c_proc## when
-- you wish to call the routine from Euphoria.
--
-- 	A returned value of -1 indicates that the procedure could not be found or linked to.
--
-- On Windows, you can add
-- a '+' character as a prefix to the procedure name. This tells Euphoria that the function
-- uses the cdecl calling convention. By default, Euphoria assumes that C routines accept 
-- the stdcall convention.
--
-- When defining a machine code routine, ##lib## must be the empty sequence, "" or {}, and ##routine_name##
-- indicates the address of the machine code routine. You can poke the bytes of machine code
-- into a block of memory reserved using allocate(). On Windows, the machine code routine is
-- normally expected to follow the stdcall calling convention, but if you wish to use the
-- cdecl convention instead, you can code {'+', address} instead of address.
--
-- ##argtypes## is made of type constants, which describe the C types of arguments to the procedure. They may be used to define machine code parameters as well.
--
-- The C function that you define could be one created by the Euphoria To C Translator, in
-- which case you can pass Euphoria data to it, and receive Euphoria data back. A list of 
-- Euphoria types is shown above.
--
--     You can pass any C integer type or pointer type. You can also pass a Euphoria atom as
--     a C double or float.
--
--     Parameter types which use 4 bytes or less are all passed the same way, so it is not 
--     necessary to be exact.
--
--     Currently, there is no way to pass a C structure by value. You can only pass a pointer
-- to a structure. However, you can pass a 64 bit integer by pretending to pass two C_LONG instead. When calling the routine, pass low doubleword first, then high doubleword.
--
--     The C function can return a value but it will be ignored. If you want to use the value
--     returned by the C function, you must instead define it with ##define_c_func## and call it
--     with ##c_func##.
--*/
--------------------------------------------------------------------------------
global function define_c_var(atom lib, sequence variable_name)	-- gets the memory address where a global C variable is stored
    return machine_func(M_DEFINE_VAR, {lib, variable_name})
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##lib##: the address of a Linux or FreeBSD shared library, or Windows .dll, as returned by open_dll().
--   # ##variable_name##: the name of a public C variable defined within the library.
--
-- Returns:
--
--   An **atom**: the memory address of ##variable_name##.
--
-- Notes:
--
--   Once you have the address of a C variable, and you know its type, you can use ##peek##()
--   and ##poke##() to read or write the value of the variable. You can in the same way obtain 
--   the address of a C function and pass it to any external routine that requires a callback address.
--*/
--------------------------------------------------------------------------------
global function open_dll(sequence file_name)	-- opens a Windows dynamic link library (.dll) file, or a Unix shared library (.so) file 
	atom fh
    if length(file_name) > 0 and filename_string(file_name) then -- just one file
		return machine_func(M_OPEN_DLL, file_name)
	end if
	-- We have a list of filenames to try, try each one, when one succeeds
	-- abort the search and return it's value
	for idx = 1 to length(file_name) do
		fh = machine_func(M_OPEN_DLL, file_name[idx])
		if not fh = 0 then
			return fh
		end if
	end for
	return 0
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--   # ##file_name##: the name of the shared library to open or a sequence of filenames
--     to try to open.
--
-- Returns:
--
--   An **atom**, actually a 32-bit address. 0 is returned if the library can't be found.
--
-- Errors:
--
--   The length of ##file_name## (or any filename contained therein) should not exceed
--   1,024 characters.
--
-- Notes:
--
--   ##file_name## can be a relative or an absolute file name. Most operating systems will use
--   the normal search path for locating non-relative files.
--
--   ##file_name## can be a list of file names to try. On different Linux platforms especially,
--   the filename will not always be the same. For instance, you may wish to try opening
--   libmylib.so, libmylib.so.1, libmylib.so.1.0, libmylib.so.1.0.0. If given a sequence of
--   file names to try, the first successful library loaded will be returned. If no library
--   could be loaded, 0 will be returned after exhausting the entire list of file names.
--
--   The value returned by ##open_dll##() can be passed to ##define_c_proc##(), ##define_c_func##(),
--   or ##define_c_var##().
-- 
--   You can open the same .dll or .so file multiple times. No extra memory is used and you'll
--   get the same number returned each time.
-- 
--   Euphoria will close the library for you automatically at the end of execution.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.18
--Status: created; incomplete
--Changes:]]]
--* defined ##C_BOOL##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.10.23
--Status: created; incomplete
--Changes:]]]
--* revised to accept ##string## definition fro ##types.e##
--* defined internal type filename_string
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.10.21
--Status: created; incomplete
--Changes:]]]
--* revised to correct warning in local string routine
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.10.13
--Status: created; incomplete
--Changes:]]]
--* revised to include ##types.e##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.05
--Status: created; incomplete
--Changes:]]]
--* re-defined ##open_dll##
--* modified and extended embedded documentation
--------------------------------------------------------------------------------
