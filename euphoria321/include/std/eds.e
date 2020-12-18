--------------------------------------------------------------------------------
--	Library: eds.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)eds.e
-- Description: Re-writing (where necessary) existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.02.21
--(c) Copyright: 2007 Rapid Deployment Software
--Status: operational; incomplete
--Changes:]]]
--* created (using RDS definitions)
--* ##db_create## defined
--* associated constants defined
--* ##db_open## defined
--* ##db_select## defined
--* ##db_close## defined
--* ##db_create_table## defined
--* ##db_select_table## defined
--
------
--==Euphoria Standard library: eds
--
-- This library contains the functionality to run the Euphoria Database System
-- (eds).
--
-- The principle on which the EDS system works is that although 
-- more than one database may be open at any one time, one, and only one,
-- database is "current", and that this is the
-- database which you can work on. Likewise only one table within the current
-- database can be worked on.
--
-- Database File Format
--=== Header
--* byte 0: magic number for this file-type: 77
--* byte 1: version number (major)
--* byte 2: version number (minor)
--* byte 3: 4-byte pointer to block of table headers
--* byte 7: number of free blocks
--* byte 11: 4-byte pointer to block of free blocks
--    
--===block of table headers: 
--* -4: allocated size of this block (for possible reallocation) 
--* 0: number of table headers currently in use
--* 4: table header1
--* 16: table header2
--* 28: etc. 
--    
--===table header: 0: pointer to the name of this table
--* 4: total number of records in this table
--* 8: number of blocks of records
--* 12: pointer to the index block for this table
--
--    There are two levels of pointers. The logical array of key pointers 
--    is split up across many physical blocks. A single index block 
--    is used to select the correct small block. This allows 
--    inserts and deletes to be made without having to shift a 
--    large number of key pointers. Only one small block needs to 
--    be adjusted. This is particularly helpful when the table contains 
--    many thousands of records.
--
--===index block (one per table):
--* -4: allocated size of index block
--* 0: number of records in 1st block of key pointers
--* 4: pointer to 1st block
--* 8: number of records in 2nd "                   "
--* 12: pointer to 2nd block
--* 16: etc.
--
--===block of key pointers (many per table): 
--* -4: allocated size of this block in bytes
--* 0: key pointer 1
--* 4: key pointer 2
--* 8: etc.
--
--===free list - in ascending order of address
--*                 -4: allocated size of block of free blocks
--*                  0: address of 1st free block
--*                  4: size of 1st free block
--*                  8: address of 2nd free block
--*                 12: size of 2nd free block
--*                 16: etc.
--
--    The key value and the data value for a record are allocated space
--    as needed. A pointer to the data value is stored just before the 
--    key value. Euphoria objects, key and data, are stored in a compact form.
--    All allocated blocks have the size of the block in bytes, stored just 
--    before the address.
--
-- The following correspond to the contents of the Open Euphoria's standard
-- library and has been tested/amended to function with Eu3.1.1.

-- The following are globally defined:
--===Constants
--* ##DB_EXISTS_ALREADY##
--* ##DB_LOCK_EXCLUSIVE##
--* ##DB_LOCK_FAIL##
--* ##DB_LOCK_NO##
--* ##DB_LOCK_SHARED##
--* ##DB_OPEN_FAIL##
--* ##DB_OK##
--===Types
--===Routines
--* ##db_close##
--* ##db_create##
--* ##db_create_table##
--* ##db_open##
--* ##db_select##
--* ##db_select_table##
--
-- Utilise this routine by adding the following statement to your module:
--<eucode>include std/eds.e</eucode>
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
include io.e	-- for lock_file, unlock_file
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant DB_MAGIC = 77
constant DB_MAJOR = 3
constant DB_MINOR = 0
constant FREE_COUNT = 7
constant FREE_LIST = 11
-- initial sizes for various things:
constant INIT_FREE = 5
constant INIT_INDEX = 10
constant INIT_RECORDS = 50
constant INIT_TABLES = 5
constant NO_CURRENT_DB = -1
constant NO_CURRENT_TABLE = -1
constant SIZEOF_TABLE_HEADER = 16
constant TABLE_HEADERS = 3
constant TABLE_NOT_FOUND = -1
constant UNSET = -1
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant DB_EXISTS_ALREADY = -2
global constant DB_LOCK_EXCLUSIVE = 2 -- read and write the database
global constant DB_LOCK_FAIL = -3
global constant DB_LOCK_NO = 0       -- don't bother with file locking
global constant DB_LOCK_SHARED = 1   -- read the database
global constant DB_OK = 0
global constant DB_OPEN_FAIL = -1
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
integer current_db	current_db = NO_CURRENT_DB
integer current_lock
atom current_table	current_table = NO_CURRENT_TABLE
sequence db_file_nums	db_file_nums = {}
sequence db_lock_methods	db_lock_methods = {}
sequence db_names	db_names = {}
sequence key_pointers
atom mem0	mem0 = allocate(4)
atom mem1	mem1 = mem0 + 1
atom mem2	mem2 = mem0 + 2
atom mem3	mem3 = mem0 + 3
sequence memseq	memseq = {mem0, 4}
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer db_fatal_id	-- exception handler
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
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function add_extension(sequence this)
    if not find('.', this) then
		this &= ".edb"
    end if
    return this
end function
--------------------------------------------------------------------------------
procedure default_fatal(sequence msg)	-- default fatal error handler - you can override this
    puts(SCREEN, "Fatal Database Error: " & msg & '\n')
    ?1/0 -- to see call stack
end procedure
db_fatal_id = routine_id("default_fatal") -- you can set it to your own handler
--------------------------------------------------------------------------------
procedure fatal(sequence msg)
    call_proc(db_fatal_id, {msg})
end procedure
--------------------------------------------------------------------------------
function get4()	-- reads 4-byte value at current position in database file
    poke(mem0, getc(current_db))
    poke(mem1, getc(current_db))
    poke(mem2, getc(current_db))
    poke(mem3, getc(current_db))
    return peek4u(mem0)
end function
--------------------------------------------------------------------------------
function get_string()	-- reads a 0-terminated string at current position in database file
    integer c
    sequence s    
    s = ""
    while TRUE do
		c = getc(current_db)
		if c = -1 then
		    fatal("string is missing 0 terminator")
		elsif c = 0 then
		    exit
		end if
		s &= c
    end while
    return s
end function
--------------------------------------------------------------------------------
procedure initialise(sequence path, integer db, integer lock_method)
    current_db = db
    current_lock = lock_method
    current_table = NO_CURRENT_TABLE
    db_names = append(db_names, path)
    db_lock_methods = append(db_lock_methods, lock_method)
    db_file_nums = append(db_file_nums, db)
end procedure
--------------------------------------------------------------------------------
procedure put1(integer x)	-- writes 1 byte to current database file
    puts(current_db, x)
end procedure
--------------------------------------------------------------------------------
procedure put4(atom x)	-- writes 4 bytes to current database file (x is 32-bits max)
    poke4(mem0, x) -- faster than doing divides etc.
    puts(current_db, peek(memseq))
end procedure
--------------------------------------------------------------------------------
procedure putn(sequence s)	-- write a sequence of bytes to current database file   
    puts(current_db, s)
end procedure
--------------------------------------------------------------------------------
procedure safe_seek(atom pos)	-- seeks to a position in the current db file    
    if seek(current_db, pos) != 0 then
		fatal(sprintf("seek to position %d failed!\n", pos))
    end if
end procedure
--------------------------------------------------------------------------------
function table_find(sequence name)	-- finds a table, given its name; returns table pointer
	atom name_ptr
	atom nt
    atom tables
	atom t_header
    sequence tname   
    safe_seek(TABLE_HEADERS)
    tables = get4()
    safe_seek(tables)
    nt = get4()
    t_header = tables+4
    for i = 1 to nt do
		safe_seek(t_header)
		name_ptr = get4()
		safe_seek(name_ptr)
		tname = get_string()
		if equal(tname, name) then
		    -- found it
		    return t_header
		end if
		t_header += SIZEOF_TABLE_HEADER
    end for
    return TABLE_NOT_FOUND
end function
--------------------------------------------------------------------------------
function db_allocate(atom n)	-- allocates (at least) n bytes of space in the database file.
-- The usable size + 4 is stored in the 4 bytes before the returned address.
-- Upon return, the file pointer points at the allocated space, so data
-- can be stored into the space immediately without a seek.
-- When space is allocated at the end of the file, it will be exactly
-- n bytes in size, and the caller must fill up all the space immediately.
	atom addr
    integer free_count
    atom free_list
    sequence remaining
	atom size
	atom size_ptr
    safe_seek(FREE_COUNT)
    free_count = get4()
    if free_count > 0 then
		free_list = get4()
		safe_seek(free_list)
		size_ptr = free_list + 4
		for i = 1 to free_count do
		    addr = get4()
		    size = get4()
		    if size >= n+4 then
			-- found a big enough block
			if size >= n+16 then 
			    -- loose fit: shrink first part, return 2nd part
			    safe_seek(addr-4)
			    put4(size-n-4) -- shrink the block
			    safe_seek(size_ptr)
			    put4(size-n-4) -- update size on free list too
			    addr += size-n-4
			    safe_seek(addr-4)
			    put4(n+4)
			else    
			    -- close fit: remove whole block from list and return it
			    remaining = get_bytes(current_db, (free_count-i) * 8)
			    safe_seek(free_list+8*(i-1))
			    putn(remaining)
			    safe_seek(FREE_COUNT)
			    put4(free_count-1)
			    safe_seek(addr-4)
			    put4(size) -- in case size was not updated by db_free()
			end if
			return addr
		    end if
		    size_ptr += 8
		end for
    end if
    -- no free block available - point to end of file
    safe_seek(-1) -- end of file
    put4(n+4)
    return where(current_db)
end function
--------------------------------------------------------------------------------
procedure db_free(atom p)
-- Put a block of storage onto the free list in order of address.
-- Combine the new free block with any adjacent free blocks.
    atom psize, i, size, addr, free_list, free_list_space
    atom new_space, to_be_freed, prev_addr, prev_size
    integer free_count
    sequence remaining
    safe_seek(p-4)
    psize = get4()    
    safe_seek(FREE_COUNT)
    free_count = get4()
    free_list = get4()
    safe_seek(free_list-4)
    free_list_space = get4()-4
    if free_list_space < 8 * (free_count+1) then
		-- need more space for free list
		new_space = floor(free_list_space * 3 / 2)
		to_be_freed = free_list
		free_list = db_allocate(new_space)
		safe_seek(free_list-4)
		safe_seek(FREE_COUNT)
		free_count = get4() -- db_allocate may have changed it
		safe_seek(FREE_LIST)
		put4(free_list)
		safe_seek(to_be_freed)
		remaining = get_bytes(current_db, 8*free_count)
		safe_seek(free_list)
		putn(remaining)
		putn(repeat(0, new_space-length(remaining)))
		safe_seek(free_list)
    else
		new_space = 0
    end if    
    i = 1
    prev_addr = 0
    prev_size = 0
    while i <= free_count do
		addr = get4()
		size = get4()
		if p < addr then
		    exit 
		end if
		prev_addr = addr
		prev_size = size
		i += 1
    end while    
    if i > 1 and prev_addr + prev_size = p then
		-- combine with previous block 
		safe_seek(free_list+(i-2)*8+4)
		if i < free_count and p + psize = addr then
		    -- combine space for all 3, delete the following block
		    put4(prev_size+psize+size) -- update size on free list (only)
		    safe_seek(free_list+i*8)
		    remaining = get_bytes(current_db, (free_count-i)*8)
		    safe_seek(free_list+(i-1)*8)
		    putn(remaining)
		    free_count -= 1
		    safe_seek(FREE_COUNT)
		    put4(free_count)
		else
		    put4(prev_size+psize) -- increase previous size on free list (only)
		end if
    elsif i < free_count and p + psize = addr then
		-- combine with following block - only size on free list is updated
		safe_seek(free_list+(i-1)*8)
		put4(p)
		put4(psize+size)
    else
		-- insert a new block, shift the others down
		safe_seek(free_list+(i-1)*8)
		remaining = get_bytes(current_db, (free_count-i+1)*8)
		free_count += 1
		safe_seek(FREE_COUNT)
		put4(free_count)
		safe_seek(free_list+(i-1)*8)
		put4(p)
		put4(psize)
		putn(remaining)
    end if
    if new_space then
	db_free(to_be_freed) -- free the old space
    end if
end procedure
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global procedure db_close()	-- closes the current database
    integer index
    if current_db = NO_CURRENT_DB then
		return
    end if
    -- unlock the database
    if current_lock then
		unlock_file(current_db, {})
    end if
    close(current_db)
    -- delete info for current_db
    index = find(current_db, db_file_nums)
	   db_names = db_names[1..index-1] & db_names[index+1..$]
       db_file_nums = db_file_nums[1..index-1] & db_file_nums[index+1..$]
    db_lock_methods = db_lock_methods[1..index-1] & db_lock_methods[index+1..$]
    current_db = -1 
end procedure
--------------------------------------------------------------------------------
global function db_create(sequence path, integer lock_method)	-- creates a new database in the file given by path; it becomes the current database
    integer db
    path = add_extension(path)
    -- see if it already exists
    db = open(path, "rb")
    if db != UNSET then
		-- don't destroy an existing db - let user delete himself
		close(db)
		return DB_EXISTS_ALREADY
    end if
    -- file must exist before "ub" can be used
    db = open(path, "wb")
    if db = UNSET then
		return DB_OPEN_FAIL
    end if
    close(db)
    -- get read and write access, "ub"
    db = open(path, "ub")
    if db = -1 then
		return DB_OPEN_FAIL
    end if
    if lock_method = DB_LOCK_SHARED then
		-- shared lock doesn't make sense for create
		lock_method = DB_LOCK_NO
    end if
    if lock_method = DB_LOCK_EXCLUSIVE then
		if not lock_file(db, LOCK_EXCLUSIVE,{}) then
		    return DB_LOCK_FAIL
		end if
    end if
    initialise(path, db, lock_method)
    -- initialize the header
    put1(DB_MAGIC) -- so we know what type of file it is
    put1(DB_MAJOR) -- major version
    put1(DB_MINOR) -- minor version
    -- 3:
    put4(19)  -- pointer to tables
    -- 7:
    put4(0)   -- number of free blocks
    -- 11:
    put4(23 + INIT_TABLES * SIZEOF_TABLE_HEADER + 4)   -- pointer to free list
    -- 15: initial table block:
    put4( 8 + INIT_TABLES * SIZEOF_TABLE_HEADER)  -- allocated size
    -- 19:
    put4(0)   -- number of tables that currently exist
    -- 23: initial space for tables
    putn(repeat(0, INIT_TABLES * SIZEOF_TABLE_HEADER)) 
    -- initial space for free list
    put4(4+INIT_FREE*8)   -- allocated size
    putn(repeat(0, INIT_FREE * 8))
    return DB_OK
end function
--------------------------------------------------------------------------------
--/*
--Parameters:
--# ##path##: the (path/file) name for the database
--# ##lock_method##: the method for locking the file (one of
-- ##DB_LOCK_NO##, ##DB_LOCK_EXCLUSIVE## - r/w, DB_LOCK_SHARED - ro)
--
-- Returns:
--
-- an **integer**: one of ##DB_EXISTS_ALREADY##, ##DB_OPEN_FAIL##,
-- ##DB_LOCK_FAIL##, ##DB_OK##
--
-- Errors:
--
-- ##DB_OPEN_FAIL## is returned if the file cannot be created 
-- or the file exists but, for some reason cannot be
-- opened.
--
-- ##DB_LOCK_FAIL## is returned if it is not possible to claim r/w rights on
-- the file.
--*/
--------------------------------------------------------------------------------
global function db_open(sequence path, integer lock_method)	-- opens an existing database file; it becomes the current database
	-- If the lock fails, the caller should wait a few seconds 
	-- and then call again. 
    integer db
	integer magic    
    path = add_extension(path)
    if lock_method = DB_LOCK_NO or 
       lock_method = DB_LOCK_EXCLUSIVE then
		-- get read and write access, "ub"
		db = open(path, "ub")
    else
		-- DB_LOCK_SHARED
		db = open(path, "rb")
    end if
    if db = UNSET then
		return DB_OPEN_FAIL
    end if
    if lock_method = DB_LOCK_EXCLUSIVE then
		if not lock_file(db, LOCK_EXCLUSIVE, {}) then
		    close(db)
		    return DB_LOCK_FAIL
		end if
    elsif lock_method = DB_LOCK_SHARED then
		if not lock_file(db, LOCK_SHARED, {}) then
		    close(db)
		    return DB_LOCK_FAIL
		end if
    end if
    magic = getc(db)
    if magic != DB_MAGIC then
		close(db)
		return DB_OPEN_FAIL
    end if
    initialise(path, db, lock_method)
    return DB_OK
end function
--------------------------------------------------------------------------------
--/*
--Parameters:
--# ##path##: the (path/file) name for the database
--# ##lock_method##: the method for locking the file (one of
-- ##DB_LOCK_NO##, ##DB_LOCK_EXCLUSIVE## - r/w, DB_LOCK_SHARED - ro)
--
-- Returns:
--
-- an **integer**: one of ##DB_OPEN_FAIL##, ##DB_LOCK_FAIL##, ##DB_OK##
--
-- Errors:
--
-- ##DB_OPEN_FAIL## is returned if the file cannot be opened.
--
-- ##DB_LOCK_FAIL## is returned if it is not possible to claim the requested
-- rights on the file.
--
-- Notes:
--
-- If the lock fails, the caller should wait a few seconds 
-- and then call again.
--*/
--------------------------------------------------------------------------------
global function db_select(sequence path)	-- choose a new, already open, database to be the current database
    integer index
    path = add_extension(path)
    index = find(path, db_names)
    if index = 0 then 
		return DB_OPEN_FAIL 
    end if
    current_db = db_file_nums[index]
    current_lock = db_lock_methods[index]
    current_table = -1
    return DB_OK
end function
--------------------------------------------------------------------------------
--/*
--Parameter:
--# ##path##: the (path/file) name for the database
--
-- Returns:
--
-- an **integer**: ##DB_OPEN_FAIL## if the file has not been registered, or
-- ##DB_OK##, if successful.
--------------------------------------------------------------------------------
global function db_select_table(sequence name)	-- lets table with the given name be the current table
    atom block_ptr
	atom block_size
    integer blocks
	integer k    
	atom index
	atom nkeys
    atom table
    table = table_find(name)
    if table = -1 then
		return DB_OPEN_FAIL
    end if  
    if current_table = table then
		return DB_OK -- nothing to do
    end if
    current_table = table
    -- read in all the key pointers for the current table
    safe_seek(table+4)
    nkeys = get4()
    blocks = get4()
    index = get4()
    key_pointers = repeat(0, nkeys)
    k = 1
    for b = 0 to blocks-1 do
		safe_seek(index)
		block_size = get4()
		block_ptr = get4()
		safe_seek(block_ptr)
		for j = 1 to block_size do
		    key_pointers[k] = get4()
		    k += 1
		end for
		index += 8
    end for
    return DB_OK
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##name##: the name of the table to select
--
-- Returns:
--
-- an **integer**: ##DB_OPEN_FAIL## or ##DB_OK##
--*/
--------------------------------------------------------------------------------
global function db_create_table(sequence name)	-- creates a new table in the current database file
	atom index_ptr
    atom name_ptr
	atom newsize
	atom newtables
	atom nt
	atom records_ptr
    sequence remaining
    atom size
	atom table
	atom tables    
    table = table_find(name)
    if table != -1 then
		return DB_EXISTS_ALREADY
    end if
    -- increment number of tables
    safe_seek(TABLE_HEADERS)
    tables = get4()
    safe_seek(tables-4)
    size = get4()
    nt = get4()+1
    if nt*SIZEOF_TABLE_HEADER + 8 > size then
		-- enlarge the block of table headers
		newsize = floor(size * 3 / 2)
		newtables = db_allocate(newsize)
		put4(nt)
		-- copy all table headers to the new block
		safe_seek(tables+4)
		remaining = get_bytes(current_db, (nt-1)*SIZEOF_TABLE_HEADER)
		safe_seek(newtables+4)
		putn(remaining)
		-- fill the rest
		putn(repeat(0, newsize - 4 - (nt-1)*SIZEOF_TABLE_HEADER))
		db_free(tables)
		safe_seek(TABLE_HEADERS)
		put4(newtables)
		tables = newtables
    else
		safe_seek(tables)
		put4(nt)
    end if    
    -- allocate initial space for 1st block of record pointers
    records_ptr = db_allocate(INIT_RECORDS * 4)
    putn(repeat(0, INIT_RECORDS * 4))
    -- allocate initial space for the index
    index_ptr = db_allocate(INIT_INDEX * 8)
    put4(0)  -- 0 records 
    put4(records_ptr) -- point to 1st block
    putn(repeat(0, (INIT_INDEX-1) * 8))	
    -- store new table
    name_ptr = db_allocate(length(name)+1)
    putn(name & 0)   
    safe_seek(tables+4+(nt-1)*SIZEOF_TABLE_HEADER)
    put4(name_ptr)
    put4(0)  -- start with 0 records total
    put4(1)  -- start with 1 block of records in index
    put4(index_ptr)
    if db_select_table(name) then
    end if
    return DB_OK
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##name##: the name of the table to select
--
-- Returns:
--
-- an **integer**: one of ##DB_EXISTS_ALREADY##, ##DB_OK##
--
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
