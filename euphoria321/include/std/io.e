--------------------------------------------------------------------------------
--	Library: io.e
--------------------------------------------------------------------------------
-- Notes:
--
--
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)io.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2020.12.01
--Status: operational; incomplete
--Changes:]]]
--* ##get_integer16## defined
--* ##put_integer16## defined
--* ##put_integer32## defined
--
------
--==Euphoria Standard library: io
--===Constants
--* ##BINARY_MODE##
--* ##DOS_TEXT##
--* ##EOF##
--* ##LOCK_EXCLUSIVE##
--* ##LOCK_SHARED##
--* ##TEXT_MODE##
--* ##UNIX_TEXT##
--
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.1.1.
--* ##append_lines##
--* ##flush##
--* ##get_bytes##
--* ##get_integer16##
--* ##get_integer32##
--* ##lock_file##
--* ##put_integer16##
--* ##put_integer32##
--* ##read_file##
--* ##read_lines##
--* ##seek##
--* ##unlock_file##
--* ##where##
--* ##write_file##
--* ##write_lines##
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
include machine.e as machine    -- for allocate
include os.e	-- for LINUX, UNIX, WINDOWS
include search.e as search  -- for match_replace
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
global constant BINARY_MODE = 1
global constant DOS_TEXT = 4
global constant EOF = -1
global constant LOCK_SHARED = 1
global constant LOCK_EXCLUSIVE = 2
global constant TEXT_MODE = 2
global constant UNIX_TEXT = 3
--------------------------------------------------------------------------------
--/*
--=== Euphoria types
--*/
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
global type file_number(integer fn) -- a handle to an opened file
    return fn > 2
end type
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
atom mem0 mem0 = machine:allocate(4)
atom mem1 mem1 = mem0 + 1
atom mem2 mem2 = mem0 + 2
atom mem3 mem3 = mem0 + 3
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
global function append_lines(sequence file, sequence lines)	-- appends a sequence of lines to a file
	object fn
  	fn = open(file, "a")
	if fn < 0 then return -1 end if
	for i = 1 to length(lines) do
		puts(fn, lines[i])
		puts(fn, '\n')
	end for
	close(fn)
	return 1
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##file##: either a file path or the handle to an open file
--# ##lines##: the sequence of lines to write
--
-- Returns:
--
-- an **integer**: 1 on success, -1 on failure.
--
-- Errors:
--
-- If some line of text cannot be written a runtime error will occur.
--
-- Comments:
--
-- ##file## is opened, written to and then closed.
--*/
--------------------------------------------------------------------------------
global procedure flush(file_number fn)	-- flushes out the buffer associated with an opened file
    machine_proc(M_FLUSH, fn)
end procedure
--------------------------------------------------------------------------------
--/*
-- Parameters:
-- 		# ##fn##: the handle to the file or device to close.
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
-- even if the memory buffer is not full. To do this you must call flush(fn),
-- where fn is the file number of a file open for writing or appending.
--
-- When a file is closed, (see close()), all buffered data is flushed out.
--  When a program terminates, all open files are flushed and closed
--  automatically. Use flush() when another process may need to
--  see all of the data written so far, but you are not ready
--   to close the file yet. flush() is also used in crash routines, where files may not be closed in the cleanest possible way.
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
global function get_integer16(file_number fh)   -- reads the next two bytes from a file and returns them as a single integer.
    integer c -- a positive byte integer from 0 to 255 or -1
	c = getc(fh)
	poke(mem0, c)
	c = getc(fh)
	if c = -1 then
		return -1
	end if
	poke(mem1, c)
	return peek2u(mem0)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##fh##: the handle to an open file to read from.
--
-- Returns:
--	An **atom**, made of the bytes that could be read from the file.
--  When an end of file marker is encountered, returns ##-1##.
--
-- Notes:
--* This function is normally used with files opened in binary mode, "rb".
--* Assumes that there at least two bytes available to be read.
--*/
--------------------------------------------------------------------------------
global function get_integer32(file_number fh)   -- reads the next four bytes from a file and returns them as a single integer.
	poke(mem0, getc(fh))
	poke(mem1, getc(fh))
	poke(mem2, getc(fh))
	poke(mem3, getc(fh))
	return peek4u(mem0)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##fh##: the handle to an open file to read from.
--
-- Returns:
--		An **atom**, made of the bytes that could be read from the file.
--
-- Notes:
--     * This function is normally used with files opened in binary mode, "rb".
--     * Assumes that there at least four bytes available to be read.
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
global procedure put_integer16(integer fh, integer val) -- writes the supplied integer as two bytes to a file
    poke2(mem0, val)
	puts(fh, peek({mem0, 2}))
end procedure
--------------------------------------------------------------------------------
--/*
--Parameters:
--# //fh//: the handle to an open file with write access
--# //val//: the integer to be written
--
--Notes:
--
-- This function is normally used with files opened in binary mode, //"wb"//.
--*/
--------------------------------------------------------------------------------
global procedure put_integer32(integer fh, integer val) -- writes the supplied integer as four bytes to a file
    poke4(mem0, val)
	puts(fh, peek({mem0, 4}))
end procedure
--------------------------------------------------------------------------------
--/*
--Parameters:
--# //fh//: the handle to an open file with write access
--# //val//: the integer to be written
--
--Notes:
--
-- This function is normally used with files opened in binary mode, //"wb"//.
--*/
--------------------------------------------------------------------------------
global function read_file(object file, integer as_text) -- read the contents of a file as a single sequence of bytes
	integer fn
	integer len
	sequence ret
	integer success
    if as_text = 0 then as_text = BINARY_MODE end if    -- set default
	if sequence(file) then
		fn = open(file, "rb")
	else
		fn = file
	end if
	if fn < 0 then return EOF end if
    -- seek & where not yet defined
	success = machine_func(M_SEEK, {fn, -1})    --seek(fn, -1)
	len = machine_func(M_WHERE, fn)    -- where(fn)
	success = machine_func(M_SEEK, {fn, 0})    --seek(fn, 0)
	ret = repeat(0, len)
	for i = 1 to len do
		ret[i] = getc(fn)
	end for
	if sequence(file) then
		close(fn)
	end if
	if platform() = WINDOWS then
		-- Remove any extra -1 (EOF) characters in case file
		-- had been opened in Windows 'text mode'.
		for i = len to 1 by -1 do
			if ret[i] != -1 then
				if i != len then
					ret = ret[1 .. i]
				end if
				exit
			end if
		end for
	end if
	if as_text = BINARY_MODE then
		return ret
	end if
	-- Treat as a text file.
	fn = find(26, ret) -- Any Ctrl-Z found?
	if fn then
		-- Ok, so truncate the file data
		ret = ret[1 .. fn - 1]
	end if
	-- Convert Windows endings
	ret = search:match_replace({13,10}, ret, {10}, 0)
	if length(ret) > 0 then
		if ret[$] != 10 then
			ret &= 10
		end if
	else
		ret = {10}
	end if
	return ret
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		# ##file## : either a file path or the handle to an open file.
--      # ##as_text## : **BINARY_MODE** (the default) assumes //binary mode// that
--                     causes every byte to be read in,
--                     and **TEXT_MODE** assumes //text mode// that ensures that
--                     lines end with just a Ctrl-J (NewLine) character,
--                     and the first byte value of 26 (Ctrl-Z) is interpreted as End-Of-File.
--
-- Returns:
--
--		An **object**, either
--      * ##EOF##
--      * a **sequence** holding the entire file contents.
--
-- Notes:
--
-- * When using BINARY_MODE, each byte in the file is returned as an element in
--   the return sequence.
-- * When not using BINARY_MODE, the file will be interpreted as a text file. This
-- means that all line endings will be transformed to a single 0x0A character and
-- the first 0x1A character (Ctrl-Z) will indicate the end of file (all data after this
-- will not be returned to the caller.)
--*/
--------------------------------------------------------------------------------
global function read_lines(object file) -- reads the contents of a file as a sequence of lines
	object fn
    object ret
    object y
	if sequence(file) then
		if length(file) = 0 then
			fn = 0
		else
			fn = open(file, "r")
		end if
	else
		fn = file
	end if
	if fn < 0 then return -1 end if
	ret = {}
    y = gets(fn)
	while sequence(y) do
		if y[$] = '\n' then
			y = y[1..$-1]
		end if
		ret = append(ret, y)
		if fn = 0 then
			puts(2, '\n')
		end if
		y = gets(fn)
	end while
	if sequence(file) and length(file) != 0 then
		close(fn)
	end if
	return ret
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--		##file## : either a file path or the handle to an open file.
--                 If this is an empty string, STDIN (the console) is used.
--
-- Returns:
--
--		An **object**, either
--      * ##-1##
--      * a **sequence** made of lines from the file, as ##gets## could read them.
--
-- Notes:
--
-- If ##file## is a sequence, the file will be closed on completion.
-- Otherwise, it will remain open, but at end of file.
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
global function write_file(object file, sequence data, integer as_text)	-- writes a sequence of bytes to a file
	integer fn
	if as_text != BINARY_MODE then
		-- Truncate at first Ctrl-Z
		fn = find(26, data)
		if fn then
			data = data[1..fn-1]
		end if
		-- Ensure last line has a line-end marker.
		if length(data) > 0 then
			if data[$] != 10 then
				data &= 10
			end if
		else
			data = {10}
		end if
		if as_text = TEXT_MODE then
			-- Standardize all line endings
			data = search:match_replace({13,10}, data, {10}, 0)
		elsif as_text = UNIX_TEXT then
			data = search:match_replace({13,10}, data, {10}, 0)
		elsif as_text = DOS_TEXT then
			data = search:match_replace({13,10}, data, {10}, 0)
			data = search:match_replace({10}, data, {13,10}, 0)
		end if
	end if
	if sequence(file) then
		if as_text = TEXT_MODE then
			fn = open(file, "w")
		else
			fn = open(file, "wb")
		end if
	else
		fn = file
	end if
	if fn < 0 then return -1 end if
	puts(fn, data)
	if sequence(file) then
		close(fn)
	end if
	return 1
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##file##: either a file path or the handle to an open file
--# ##data##: the sequence of bytes to write
--# ##as_text##: one of
--  ** ##BINARY_MODE## - assumes //binary mode// that
--                     causes every byte to be written out as is,
--  ** ##TEXT_MODE## - assumes //text mode// that causes a NewLine
--                     to be written out according to the operating system's
--                     end of line convention. On //Unix// this is Control+J and on
--                     //Windows// this is the pair ##{Ctrl-L, Ctrl-J}##.
--  ** ##UNIX_TEXT## - ensures that lines are written out with //Unix// style
--                     line endings (Control+J).
--  ** ##DOS_TEXT## - ensures that lines are written out with //Windows// style
--                     line endings ##{Ctrl-L, Ctrl-J}##.
-- Returns:
--
-- an **integer**: 1 on success, -1 on failure.
--
-- Errors:
--
--If ##puts## cannot write ##data##, a runtime error will occur.
--
-- Notes:
-- * When ##file## is a file handle, the file is not closed after writing is
-- finished. When ##file## is a file name, it is opened, written to
-- and then closed.
-- * When writing the file in ony of the text modes, the file is truncated
-- at the first Control+Z character in the input data.
--*/
--------------------------------------------------------------------------------
global function write_lines(object file, sequence lines)-- write a sequence of lines to a file
	object fn
	if sequence(file) then
    	fn = open(file, "w")
	else
		fn = file
	end if
	if fn < 0 then return -1 end if
	for i = 1 to length(lines) do
		puts(fn, lines[i])
		puts(fn, '\n')
	end for
	if sequence(file) then
		close(fn)
	end if
	return 1
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##file## : an object, either a file path or the handle to an open file
--# ##lines## : the sequence of lines to write
--
-- Returns:
--
-- an **integer**: 1 on success, -1 on failure
--
-- Errors:
--
--If ##puts## cannot write some line of text, a runtime error will occur.
--
-- Comments:
--
--If ##file## was a sequence, the file will be closed on completion.
-- Otherwise, it will remain open, but positioned at the end of the file.
--
-- Whatever integer the lines in ##lines## holds will be truncated to its
-- 8 lowest bits so as to fall in the 0..255 range.
--*/
--------------------------------------------------------------------------------
--/*
--==== Defined instances
--*/
--------------------------------------------------------------------------------
global constant SCREEN = 1  -- Screen (Standard Output Device)
global constant STDIN = 0   -- Standard Input
global constant STDERR = 2  -- Standard Error
global constant STDOUT = 1  -- Standard Output
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2019.02.25
--Status: operational; incomplete
--Changes:]]]
--* ##write_file## defined
--* ##UNIX_TEXT## defined
--* ##DOS_TEXT## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2019.02.05
--Status: operational; incomplete
--Changes:]]]
--* ##write_lines## defined
--* ##append_lines## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.11.28
--Status: operational; incomplete
--Changes:]]]
--* modified ##read_lines##
--------------------------------------------------------------------------------
--??
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.12
--Status: operational; incomplete
--Changes:]]]
--* defined ##read_lines##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.12
--Status: created; operational; incomplete
--Changes:]]]
--* defined ##read_file##
--* defined associated constants
--* added constants to list
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.10
--Status: created; operational; incomplete
--Changes:]]]
--* copied from 3.2.0
--* defined ##EOF##
--* defined ##SCREEN##
--* defined ##STDERR##
--* defined ##STDIN##
--* defined ##STDOUT##
--* defined ##get_integer32##
--* made ##file_number## type global
--* modified type for ##get_integer32##
--------------------------------------------------------------------------------
�19.12
