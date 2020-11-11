--------------------------------------------------------------------------------
--	Library: io.e
--------------------------------------------------------------------------------
-- Notes:
--
-- NB. file_number type needs to be global in Eu3.1.3 but local here 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)io.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.10
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.09
--Status: operational; complete
--Changes:]]]
--* documented ##where##
--
------
--==Euphoria Standard library: io
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
-- library of the same name.
--* ##flush##
--* ##get_bytes##
--* ##lock_file##
--* ##seek##
--* ##unlock_file##
--* ##where##
--
-- Utilise these routines by adding the following statement to your module:
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
include get.e	-- for GET_EOF
include os.e	-- for LINUX
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant CHUNK = 100
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
-- Parameter:
--# ##fn##: the file number of a file open for writing or appending
--
-- Notes:
--
-- When you write data to a file, Euphoria normally stores the data in a memory
-- buffer until a large enough chunk of data has accumulated.
-- This large chunk can then be written to disk very efficiently.
-- Sometimes you may want to force, or flush, all data out immediately, even if
-- the memory buffer is not full.
-- To do this you must call ##flush##.
--
-- When a file is closed, all buffered data is flushed out.
-- When a program terminates, all open files are flushed and closed automatically.
--
-- Use ##flush## when another process may need to see all of the data written so
-- far, but you aren't ready to close the file yet.
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
--# ##fn##: the handle to an input stream
--# ##n##: the number of bytes to read
--
-- Returns: the bytes as a **sequence**
--
-- The sequence will be of length ##n##, except when there are fewer than ##n##
-- bytes remaining to be read in the stream.
--
-- Notes:
--
-- When ##n## > 0 and the sequence's length is less than ##n##, you know you've
-- reached the end of the stream. Eventually, an empty sequence will be returned.
--
-- This function is normally used with files opened in binary mode: "rb". 
--*/
--------------------------------------------------------------------------------
global function lock_file(file_number fn, lock_type t, byte_range r)	-- attempts to lock a file so other processes won't interfere with it.
    return machine_func(M_LOCK_FILE, {fn, t, r})
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##fn##: the handle to the file
--# ##t##: the lock type (see below for values)
--
-- In Windows this parameter is ignored, but should be an integer.
--# ##r##: a sequence of the form: {first_byte, last_byte}
--
-- The byte range can be {} if you want to lock the whole file.
--
-- Returns:
--
-- a (boolean): 1 if successful in locking the file, 0 otherwise
--
-- Notes:
--
-- When multiple processes can simultaneously access a file, some kind of
-- locking mechanism may be needed to avoid mangling the contents of the file,
-- or causing erroneous data to be read from the file.
--
-- ##lock_file## attempts to place a lock on an open file, to stop other
-- processes from using the file while your program is reading it or writing it.
-- In Linux/FreeBSD, there are two types of locks that you can request using the
-- ##t## parameter.
-- Ask for a shared lock when you intend to read a file, and you want to
-- block temporarily other processes from writing it.
-- Ask for an exclusive lock when you intend to write to a file and you want to
-- block temporarily other processes from reading or writing it.
-- It's ok for many processes to simultaneously have shared locks on the same
-- file, but only one process can have an exclusive lock, and that can happen
-- only when no other process has any kind of lock on the file. There are two
-- types of lock:
--* LOCK_SHARED = 1 
--* LOCK_EXCLUSIVE = 2
--
-- In Windows you can lock a specified portion of a file using the ##r##
-- parameter; this is a sequence of the form: {first_byte, last_byte}.
-- It indicates the first byte and last byte in the file, that the lock
-- applies to.
--
-- In the current release for Linux/FreeBSD, locks always apply to the whole
-- file, and you should specify {} for this parameter. 
--
-- If it is successful in obtaining the desired lock, ##lock_file## will return 1.
-- If unsuccessful, it will return 0.
-- ##lock_file## does not wait for other processes to relinquish their locks.
-- You may have to call it repeatedly, before the lock request is granted. 
--
-- In Linux/FreeBSD, these locks are called advisory locks, which means they
-- aren't enforced by the operating system.
-- It is up to the processes that use a particular file to cooperate with each other.
-- A process can access a file without first obtaining a lock on it.
-- In Windows locks are enforced by the operating system.  
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
--# ##fn##: the handle to the file
--# ##pos##: the desired location within the file, including EOF (-1)
--
-- Returns:
--
-- an **integer**:  0 if the seek was successful; non-zero otherwise
--
-- Notes:
--
-- For each open file there is a current byte position that is updated as a
-- result of I/O operations on the file.
-- The initial file position is 0 for files opened for read, write or update.
-- The initial position is the end of file for files opened for append.
--
-- It is possible to seek past the end of a file.
-- If you seek past the end of the file, and write some data, undefined bytes
-- will be inserted into the gap between the original end of file and your
--
-- After seeking and reading (writing) a series of bytes, you may need to call
-- ##seek## explicitly before you switch to writing (reading) bytes,
-- even though the file position should already be what you want. 
--
-- This function is normally used with files opened in binary mode.
--*/
--------------------------------------------------------------------------------
global procedure unlock_file(file_number fn, byte_range r)  -- unlocks (a portion of) an open file
    machine_proc(M_UNLOCK_FILE, {fn, r})
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##fn##: the handle to the file
--# ##r##: a range of bytes, of the form {first_byte, last_byte}
--
-- the byte range can be {} if you want to unlock the whole file.
--
-- Notes:
--
-- The same range of bytes must have been locked by a previous call
-- to ##lock_file##.
-- On Linux/FreeBSD you can currently only lock or unlock an entire file.
-- On Linux/FreeBSD, ##r## must always be {}.  
--
-- You should unlock a file as soon as possible so other processes can use it.
--
-- Any files that you have locked, will automatically be unlocked when your
-- program terminates.  
--*/
--------------------------------------------------------------------------------
global function where(file_number fn)   -- retrieves the current file position for an opened file or device
    return machine_func(M_WHERE, fn)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##fn##: the handle to the file
--
-- Returns:
--
-- an **integer**: the current file position
--
-- Notes:
--
-- This position is updated by reads, writes and seeks on the file.
-- It is the place in the file where the next byte will be read from,
-- or written to. 
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.9
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.07
--Status: operational; complete
--Changes:]]]
--* documented ##unlock_file##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.8
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.05
--Status: operational; complete
--Changes:]]]
--* documented ##seek##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.7
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.04
--Status: operational; complete
--Changes:]]]
--* documented ##lock_file##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.6
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.02
--Status: operational; complete
--Changes:]]]
--* documented ##get_bytes##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.5
--Euphoria Versions: 3.1.2 upwards 
--Author: C A Newbould
--Date: 2018.03.01
--Status: operational; complete
--Changes:]]]
--* documented ##flush##
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
