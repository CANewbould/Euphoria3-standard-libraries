--------------------------------------------------------------------------------
--	Library: error.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)error.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.03.19
--Status: operational; complete
--Changes:]]]
--* ##crash## defined
--* ##warning## defined
--* ##warning_file## defined
--
------
--==Euphoria Standard library: error
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##crash##
--* ##crash_file##
--* ##crash_message##
--* ##crash_routine##
--* ##warning##
--* ##warning_file##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/error.e</eucode>
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
constant M_CRASH_FILE = 57
constant M_CRASH_MESSAGE = 37
constant M_CRASH_ROUTINE = 66
constant PROMPT = "Press Enter..."
constant WARNING = "Warning: (custom_warning):\n"
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
integer std_err_handle	std_err_handle = 2 --(STDERR, by default; warning_file can change)
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
global procedure crash(sequence message, object data)	-- crashes the running program after displaying a formatted error message
	printf(2, message, data)
	-- hold screen open for user to see message
	if getc(0) then end if
	abort(1)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##fmt##: the frame of the message to be issued.
-- It may have format specifiers in it
--# ##data##: any program data to be incorporated into the message
--
-- Notes:
--
-- This routine does not behave like the equivalent routine in OE4, but attempts
-- a comparable set of actions.
--
-- Formatting is the same as with ##printf##.
--
-- The message is issued, the screen held open (for the user to see the message)
-- before aborting when the user keys ENTER.
--*/
--------------------------------------------------------------------------------
global procedure crash_file(sequence file_path)	-- specifies an alternative file path name for any diagnostic information to be written
    machine_proc(M_CRASH_FILE, file_path)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- # ##file_path##: the new error and traceback file path.
--
-- Notes:
--
-- There can be as many calls to ##crash_file## as needed. Whatever was defined last will be used
-- in case of an error at runtime, whether it was triggered by ##crash## or not.
--*/
--------------------------------------------------------------------------------
global procedure crash_message(sequence msg)	-- specifies a final message to display for your user, if Euphoria has to shut down the current program due to an error
    machine_proc(M_CRASH_MESSAGE, msg)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--     # ##msg##: the string to display. It must only contain printable characters.
--
-- Notes:
--
--     There can be as many calls to ##crash_message## as needed in a program. Whatever was defined
--     last will be used in case of a runtime error.
--*/
--------------------------------------------------------------------------------
global procedure crash_routine(integer proc)	-- specifies the routine id of a 1-parameter Euphoria function to call in the event that Euphoria must shut down the current program due to an error
    machine_proc(M_CRASH_ROUTINE, proc)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##func##: the routine_id of the function to link in.
--
-- Notes:
--
--   The supplied function must have only one parameter, which should be integer or more general. 
--   Defaulted parameters in crash routines are not supported yet.
--
--   Euphoria maintains a linked list of routines to execute upon a crash. ##crash_routine## adds 
--   a new function to the list. The routines defined first are executed last. You cannot unlink
--   a routine once it is linked, nor inspect the crash routine chain.
--
--   Currently, the crash routines are passed 0. Future versions may attempt to convey more
--   information to them. If a crash routine returns anything else than 0, the remaining
--   routines in the chain are skipped.
--
--   crash routines are not full fledged exception handlers, and they cannot resume execution at 
--   current or next statement. However, they can read the generated crash file, and might 
--   perform any action, including restarting the program.
--*/
--------------------------------------------------------------------------------
global procedure warning(sequence message)	-- causes the specified warning message to be displayed as a regular warning
	puts(std_err_handle, WARNING)
	puts(std_err_handle, message & "\n\n")
	if std_err_handle = 2 then
		puts(std_err_handle, PROMPT)
		if getc(0) then end if
	end if
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##message## : the text to display, as a double quoted literal string 
--
-- Notes:
--
-- If the calling application is run ##with warning##, the message will be
-- displayed in the console (terminal) window.
--
-- A prompt is then displayed and the screen left open for the user to note the
-- message before proceeding.
--*/
--------------------------------------------------------------------------------
global procedure warning_file(object file_path)	-- specifies a file path where to output warnings
	if atom(file_path) then
		-- close file
		if std_err_handle > 2 then	-- check
			close(std_err_handle)
			-- revert to STDERR
			std_err_handle = 2
		end if
	else	-- sequence
		std_err_handle = open(file_path, "w")
		if std_err_handle > 2 then
			--ok; write warnings as called
		else
			warning("Speficied file path not found")
		end if
	end if
end procedure
--------------------------------------------------------------------------------
--/*
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
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.09.07
--Status: created; operational; incomplete
--Changes:]]]
--* defined ##crash_file##
--* defined ##crash_message##
--* defined ##crash_routine##
--------------------------------------------------------------------------------
