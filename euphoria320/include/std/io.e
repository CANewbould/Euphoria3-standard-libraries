--------------------------------------------------------------------------------
--	Library: io.e
--------------------------------------------------------------------------------
-- Notes:
--
-- NB. file_number type needs to be global in Eu3.1.3 but local here 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.0)(include)(std)io.e
-- Description: Re-allocation of existing OE4 libraries into standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.0.6
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.09
--Status: created; operational; complete
--Changes:]]]
--* documented ##where##
--
------
--==Euphoria Standard library: io
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##flush##
--* ##get_bytes##
--* ##lock_file##
--* ##seek##
--* ##unlock_file##
--* ##where##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/io.e</eucode>
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
include os.e	-- for LINUX
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant CHUNK = 100
constant GET_EOF = -1   -- defined here for ease
constant M_FLUSH = 60
constant M_LOCK_FILE = 61
constant M_SEEK = 19
constant M_UNLOCK_FILE = 62
constant M_WHERE = 20
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant LOCK_SHARED = 1 
global constant LOCK_EXCLUSIVE = 2
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type byte_range(sequence r)
    if length(r) = 0 then
	   return 1
    elsif length(r) = 2 and r[1] <= r[2] then
	   return 1
    else
	   return 0
    end if
end type
--------------------------------------------------------------------------------
type file_number(integer fn)	-- NB. global in EU3.1.3
    return fn > 2
end type
--------------------------------------------------------------------------------
type file_position(integer p)
    return p >= -1
end type
--------------------------------------------------------------------------------
type lock_type(integer t)
    if platform() = LINUX then
	   return t = LOCK_SHARED or t = LOCK_EXCLUSIVE
    else
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
global procedure flush(file_number fn)	-- flushes out the buffer associated with an opened file
    machine_proc(M_FLUSH, fn)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##fn##: the handle to the file or device to close
--
-- Errors:
--
-- The target file or device must be open.
--
-- Notes:
--
-- When you write data to a file, Euphoria normally stores the data
-- in a memory buffer until a large enough chunk of data has accumulated.
-- This large chunk can then be written to disk very efficiently.
-- Sometimes you may want to force, or flush, all data out immediately,
-- even if the memory buffer is not full. To do this you must call ##flush##.
--
-- When a file is closed, (see ##close##), all buffered data is flushed out.
-- When a program terminates, all open files are flushed and closed
-- automatically. Use ##flush## when another process may need to
-- see all of the data written so far, but you are not ready
-- to close the file yet. ##flush## is also used in crash routines, where files
-- may not be closed in the cleanest possible way.
--*/
--------------------------------------------------------------------------------
global function get_bytes(file_number fn, integer n)	-- returns a sequence of n bytes (maximum) from an open file
    integer c
	integer first
	integer last
    sequence s    
    if n = 0 then
		return {}
    end if    
    c = getc(fn)
    if c = GET_EOF then
		return {}
    end if    
    s = repeat(c, n)    
    last = 1
    while last < n do
		-- for speed, read a chunk without checking for EOF
		first = last + 1
		last  = last + CHUNK
		if last > n then
		    last = n
		end if
		for i = first to last do
		    s[i] = getc(fn)
		end for
		-- check for EOF after each chunk
		if s[last] = GET_EOF then  
		    -- trim the EOF's and return
		    while s[last] = GET_EOF do
				last -= 1
		    end while 
		    return s[1..last]
		end if
    end while   
    return s
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##fn##: the handle to an open file to read from.
--		# ##n##: the number of bytes to read.
--
-- Returns:
--
--		A **sequence**, of length at most ##n##, made of the bytes that could be read from the file.
--
-- Notes:
--
--   When ##n## > 0 and the function returns a sequence of length less than ##n## you know
--  you've reached the end of file. Eventually, an
--  empty sequence will be returned.
--
--  This function is normally used with files opened in binary mode, "rb".
--  This avoids the confusing situation in text mode where Windows will convert CR LF 
--  pairs to LF.
--*/
--------------------------------------------------------------------------------
global function lock_file(file_number fn, lock_type t, byte_range r)	-- attempts to lock a file so other processes won't interfere with it.
    return machine_func(M_LOCK_FILE, {fn, t, r})
end function
--------------------------------------------------------------------------------
--/*
-- When multiple processes can simultaneously access a
-- file, some kind of locking mechanism may be needed to avoid mangling
-- the contents of the file, or causing erroneous data to be read from the file.
--
-- Parameters:
--		# ##fn##: the handle to the file or device to (partially) lock.
--		# ##t##: an integer which defines the kind of lock to apply.
--		# ##r##: a sequence, defining a section of the file to be locked, or {} for the whole file (the default).
--
-- Returns:
--
--		An **integer**, 0 on failure, 1 on success.
--
-- Errors:
--
-- The target file or device must be open.
--
-- Notes:
--
-- ##lock_file## attempts to place a lock on an open file, ##fn##, to stop
-- other processes from using the file while your program is reading it
-- or writing it.
--
-- Under Unix, there are two types of locks that
-- you can request using the ##t## parameter. (Under WINDOWS the
-- parameter ##t## is ignored, but should be an integer.)
-- Ask for a **shared** lock when you intend to read a file, and you want to
-- temporarily block other processes from writing it. Ask for an
-- **exclusive** lock when you intend to write to a file and you want to temporarily
-- block other processes from reading or writing it. It's ok for many processes to
-- simultaneously have shared locks on the same file, but only one process
-- can have an exclusive lock, and that can happen only when no other
-- process has any kind of lock on the file. Use ##LOCK_SHARED## or
-- ##LOCK_EXCLUSIVE## as appropriate.
--
-- On WINDOWS you can lock a specified portion of a file using the ##r##  parameter.
-- ##r## is a sequence of the form: ##{first_byte, last_byte}##. It indicates the first byte and
-- last byte in the file,  that the lock applies to. Specify the empty sequence ##{}##,
-- if you want to lock the whole file, or don't specify it at all, as this is the default. In the current release for Unix, locks
-- always apply to the whole file, and you should use this default value.
--
-- ##lock_file## does not wait
-- for other processes to relinquish their locks. You may have to call it repeatedly,
-- before the lock request is granted.
--
-- On Unix, these locks are called advisory locks, which means they aren't enforced
-- by the operating system. It is up to the processes that use a particular file to cooperate
-- with each other. A process can access a file without first obtaining a lock on it. On
-- Windows locks are enforced by the operating system.
--*/
--------------------------------------------------------------------------------
global function seek(file_number fn, file_position pos) -- move to any byte position in an already-opened file
    -- Seeks to a byte position in the file,
    -- or to end of file if pos is -1.
    return machine_func(M_SEEK, {fn, pos})
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##fn##: the handle to the file or device to seek()
--		# ##pos##: either an absolute 0-based position or -1 to seek to end of file.
--
-- Returns:
--
--		An **integer**: 0 on success, 1 on failure.
--
-- Errors:
--
-- The target file or device must be open.
--
-- Notes:
--
-- For each open file, there is a current byte position that is updated as a result of I/O
-- operations on the file. The initial file position is 0 for files opened for read, write
-- or update. The initial position is the end of file for files opened for append.
-- It is possible to seek past the end of a file. If you seek past the end of the file, and
-- write some data, undefined bytes will be inserted into the gap between the original end
-- of file and your new data.
--
-- After seeking and reading (writing) a series of bytes, you may need to call ##seek##
-- explicitly before you switch to writing (reading) bytes, even though the file position
-- should already be what you want.
--
-- This function is normally used with files opened in binary mode. In text mode, Windows
-- converts CR LF to LF on input, and LF to CR LF on output, which can cause great confusion
-- when you are trying to count bytes because ##seek## counts the Windows end of line sequences
-- as two bytes, even if the file has been opened in text mode.
--*/
--------------------------------------------------------------------------------
global procedure unlock_file(file_number fn, byte_range r)  -- unlocks (a portion of) an open file
    machine_proc(M_UNLOCK_FILE, {fn, r})
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##fn##: the handle to the file or device to (partially) lock.
--		# ##r##: a sequence, defining a section of the file to be locked, or {} for the whole file (the default).
--
-- Errors:
--
-- The target file or device must be open.
--
-- Notes:
--
-- You must have previously locked the
-- file using ##lock_file##. On Windows you can unlock a range of bytes within a
-- file by specifying the ##r## as {first_byte, last_byte}. The same range of bytes
-- must have been locked by a previous call to ##lock_file##. On Unix you can
-- currently only lock or unlock an entire file. ##r## should be {} when you
-- want to unlock an entire file. On Unix, ##r## must always be {}, which is the default.
--
--  You should unlock a file as soon as possible so other processes can use it.
--
-- 	Any files that you have locked, will automatically be unlocked when your program
--  terminates.
--*/
--------------------------------------------------------------------------------
global function where(file_number fn)   -- retrieves the current file position for an opened file or device
    -- Returns the current byte position in the file.
    return machine_func(M_WHERE, fn)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##fn##: the handle to the file or device to query.
--
-- Returns:
--
--		An **atom**, the current byte position in the file.
--
-- Errors:
--
-- The target file or device must be open.
--
--
-- Notes:
--
-- The file position is is the place in the file where the next byte will be read from, or 
-- written to. It is updated by reads, writes and seeks on the file. This procedure always 
-- counts Windows end of line sequences (CR LF) as two bytes even when the file number has 
-- been opened in text mode.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.5
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.07
--Status: created; operational; complete
--Changes:]]]
--* documented ##unlock_file##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.4
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.05
--Status: created; operational; complete
--Changes:]]]
--* documented ##seek##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.3
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.04
--Status: created; operational; complete
--Changes:]]]
--* documented ##lock_file##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.2
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.02
--Status: created; operational; complete
--Changes:]]]
--* documented ##get_bytes##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.1
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.03.01
--Status: created; operational; complete
--Changes:]]]
--* documented ##flush##
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.07
--Status: created; operational; complete
--Changes:]]]
--* revised for 3.2.0
--* modifed s.t. get.e not needed
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.4
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2017.08.23
--Status: operational; complete
--Changes:]]]
--* defined ##unlock_file##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.21
--Status: operational; incomplete
--Changes:]]]
--* defined ##where##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.19
--Status: operational; incomplete
--Changes:]]]
--* defined ##seek##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.17
--Status: operational; incomplete
--Changes:]]]
--* defined ##lock_file##
--* defined ##LOCK_EXCLUSIVE##
--* defined ##LOCK_SHARED##
--* added ##include os.e##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.16
--Status: operational; incomplete
--Changes:]]]
--* defined ##get_bytes##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards 
--Author: C A Newbould
--Date: 2017.08.15
--Status: created; incomplete
--Changes:]]]
--* defined ##flush##
--------------------------------------------------------------------------------
