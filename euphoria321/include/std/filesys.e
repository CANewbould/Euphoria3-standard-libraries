--------------------------------------------------------------------------------
--	Library: filesys.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (eu3.2.1)(include)(std)filesys.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.7
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.22
--Status: operational; incomplete
--Changes:]]]
--* ##dirname## defined
--* ##filename## defined
--
------
--==Euphoria Standard library: filesys
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and have been tested/amended to function with Eu3.2.1.
--* ##chdir##
--* ##create_directory##
--* ##create_file##
--* ##current_dir##
--* ##delete_file##
--* ##dir##
--* ##dirname##
--* ##filename##
--* ##pathinfo##
--* ##walk_dir##
--
-- Utilise these routines and the associated constants 
-- by adding the following statement to your module:
--<eucode>include std/filesys.e</eucode>
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
include dll.e	-- for define_c_func, open_dll & C types
include machine.e as machine	-- for allocate_string, free
include search.e as search	-- for rfind
include sort.e  -- for sort
include os.e    -- for LINUX
--------------------------------------------------------------------------------
--
--=== Constants
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant DEFAULT_DIR_SOURCE = -2    --override the dir sorting function with your own routine id
constant FAIL = FALSE
constant M_CHDIR = 63
constant M_CURRENT_DIR = 23
constant M_DIR = 22
constant NO_ROUTINE_ID = -99999
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
function IfWin(object ifWin, object other) -- local function to set slash[es]
	if platform() = WINDOWS then return ifWin
    else return other
    end if
end function
--------------------------------------------------------------------------------
global constant D_NAME = 1
global constant D_ATTRIBUTES = 2
global constant D_SIZE = 3
global constant D_YEAR = 4
global constant D_MONTH = 5
global constant D_DAY = 6
global constant D_HOUR = 7
global constant D_MINUTE = 8
global constant D_SECOND = 9
global constant SLASH = IfWin('\\', '/')
global constant SLASHES = IfWin("\\/:", "/")
global constant W_BAD_PATH = -1 -- error code
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
--=== Variables
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
integer dir_id
atom lib	-- needs to be > integer
lib = IfWin(open_dll("kernel32"), open_dll(""))
atom xCreateDirectory
xCreateDirectory = IfWin(define_c_func(lib, "CreateDirectoryA", {C_POINTER, C_POINTER}, C_BOOL),
						define_c_func(lib, "mkdir", {C_POINTER, C_INT}, C_INT))
atom xDeleteFile
xDeleteFile = IfWin(define_c_func(lib, "DeleteFileA", {C_POINTER}, C_BOOL),
					define_c_func(lib, "unlink", {C_POINTER}, C_INT))
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer my_dir my_dir = DEFAULT_DIR_SOURCE  -- it's better not to use routine_id() here, or else users will have to bind with clear routine names
--------------------------------------------------------------------------------
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function default_dir(sequence path)
-- Default directory sorting function for walk_dir().
-- * sorts by name *
    object d    
    d = call_func(dir_id, {path})
    if atom(d) then return d
    else return sort(d, ASCENDING)
    end if
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function chdir(sequence newdir)	-- sets a new value for the current directory
    return machine_func(M_CHDIR, newdir)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //newdir//: the name for the new working directory.
--
-- Returns:
--
-- an **integer**: ##0## on failure, ##1## on success.
--
-- Notes:
--
-- By setting the current directory, you can refer to files in that directory using just
-- the file name.
-- 
-- The ##current_dir## function will return the name of the current directory.
-- 
-- On //Windows// the current directory is a public property shared
-- by all the processes running under one shell. On //Unix// a subprocess
-- can change the current directory for itself, but this will not
-- affect the current directory of its parent process.
--*/
--------------------------------------------------------------------------------
global function create_directory(string name, integer mode, boolean mkparent)	-- creates a new directory
    atom pname
    integer pos
    atom ret
    if mode = 0 then
	mode = 448	-- default
    end if
    if length(name) = 0 then
	return FAIL
    end if
    -- Remove any trailing slash.
    if name[$] = SLASH then
	name = name[1..$-1]
    end if
    if mkparent != 0 then
		pos = search:rfind(SLASH, name, 0)
		if pos != 0 then
			ret = create_directory(name[1.. pos-1], mode, mkparent)
		end if
    end if
    pname = machine:allocate_string(name)
    if platform() = LINUX then
		ret = not c_func(xCreateDirectory, {pname, mode})
    elsif platform() = WINDOWS then
		ret = c_func(xCreateDirectory, {pname, 0})
		mode = mode -- get rid of not used warning
    end if
    return ret
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //name//: the name of the new directory to create
--# //mode//: on //Unix// systems, permissions for the new directory. Default [0] is 
--	//448// (all rights for owner, none for others).
--# //mkparent//: if //TRUE//the parent directories are also created if needed.
--
-- Returns:
--
-- a **boolean**: ##FALSE## on failure, ##TRUE## on success.
--
-- Notes:
--
-- ##mode## is ignored on //Windows// platforms.
--*/
--------------------------------------------------------------------------------
global function create_file(sequence name) --> [boolean] SUCCESS|FAILURE
	integer fh
	integer ret
	fh = open(name, "wb") -- fh = -1 if doesn't already exist
	ret = (fh != -1)
	if ret then close(fh) end if
	return ret
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //name//: the name of the new file to create
--
-- Returns:
--
-- a **boolean**, success [TRUE] or failure [FALSE].
--
-- Notes:
--
--* The created file will be empty, that is it has a length of zero.
--* The created file will not be open when this returns.
--
--*/
--------------------------------------------------------------------------------
global function current_dir()	-- returns name of the current working directory
    return machine_func(M_CURRENT_DIR, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- a **sequence**: the name of the current working directory
--
-- Notes:
--
-- There will be no slash or backslash on the end of the current directory, except under
-- //Windows//, at the top-level of a drive (such as ##C:\##).
--*/
--------------------------------------------------------------------------------
global function delete_file(sequence name) --> [boolean] SUCCESS|FAILURE
	atom pfilename
	integer success
	success = c_func(xDeleteFile, {pfilename})
	pfilename = machine:allocate_string(name)
	if platform() > 2 then success = not success end if
	machine:free(pfilename)
	return success
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# //name//: the name of the file to delete
--
-- Returns:
--
-- a **boolean**, success [TRUE] or failure [FALSE].
--*/
--------------------------------------------------------------------------------
global function dir(sequence name)	-- returns directory information, given the name of a file or directory.
    return machine_func(M_DIR, name)
end function
dir_id = routine_id("dir")
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //name//: the name to be looked up in the file system.
--
-- Returns:
--
-- an **object**:  -1 if no match found, else a sequence of sequence entries
--
-- Errors:
--
-- The length of //name// should not exceed 1_024 characters.
--
-- Notes:
--
-- //name// can also contain //*// and //?// wildcards to select multiple files.
--
-- The returned information is similar to what you would get from the DIR command. A sequence
-- is returned where each element is a sequence that describes one file or subdirectory.
-- 
-- If //name// refers to a **directory** you may have entries for "." and "..", just as with the 
-- DIR command. If it refers to an existing **file**, and has no wildcards, then the returned 
-- sequence will have just one entry (that is its length will be ##1##). If ##name## contains wildcards 
-- you may have multiple entries.
-- 
-- Each entry contains the name, attributes and file size as well as
-- the time of the last modification.
--
-- You can refer to the elements of an entry with the following constants~:
--  
-- <eucode>
-- global constant 
--     -- File Attributes
--     D_NAME       = 1,
--     D_ATTRIBUTES = 2,
--     D_SIZE       = 3,
--     D_YEAR       = 4,
--     D_MONTH      = 5,
--     D_DAY        = 6,
--     D_HOUR       = 7,
--     D_MINUTE     = 8,
--     D_SECOND     = 9,
--     D_MILLISECOND = 10,
--     D_ALTNAME    = 11
-- </eucode>
--
-- The attributes element is a string sequence containing characters chosen from~:
--  
-- || Attribute || Description ||
-- | 'd'         | directory
-- | 'r'         | read only file
-- | 'h'         | hidden file
-- | 's'         | system file
-- | 'v'         | volume-id entry 
-- | 'a'         | archive file
-- | 'c'         | compressed file
-- | 'e'         | encrypted file
-- | 'N'         | not indexed
-- | 'D'         | a device name
-- | 'O'         | offline
-- | 'R'         | reparse point or symbolic link
-- | 'S'         | sparse file
-- | 'T'         | temporary file
-- | 'V'         | virtual file
--
-- A normal file without special attributes would just have an empty string, ##""##, in this field.
--
-- The top level directory ( therefore c:\ does not have "." or ".." entries).
-- 
-- This function is often used just to test if a file or directory exists.
-- 
-- Under //Windows//, the argument can have a long file or directory name anywhere in 
-- the path.
-- 
-- Under //Unix//, the only attribute currently available is ##'d'## and the milliseconds
-- are always zero.
-- 
-- //Windows//: The file name returned in ##[D_NAME]## will be a long file name. If ##[D_ALTNAME]##
-- is not zero, it contains the 'short' name of the file.
--*/
--------------------------------------------------------------------------------
global function pathinfo(sequence path, integer std_slash) -- parses a fully qualified pathname
	integer slash, period, ch
	sequence dir_name, file_name, file_ext, file_full, drive_id
	sequence from_slash
	dir_name  = ""
	file_name = ""
	file_ext  = ""
	file_full = ""
	drive_id  = ""
	slash = 0
	period = 0
	for i = length(path) to 1 by -1 do
		ch = path[i]
		if period = 0 and ch = '.' then
			period = i
		elsif find(ch, SLASHES) then
			slash = i
			exit
		end if
	end for
	if slash > 0 then
		dir_name = path[1..slash-1]
		if platform() != LINUX then
			ch = find(':', dir_name)
			if ch != 0 then
				drive_id = dir_name[1..ch-1]
				dir_name = dir_name[ch+1..$]
			end if
		end if
	end if
	if period > 0 then
		file_name = path[slash+1..period-1]
		file_ext = path[period+1..$]
		file_full = file_name & '.' & file_ext
	else
		file_name = path[slash+1..$]
		file_full = file_name
	end if
	if std_slash != 0 then
		if std_slash < 0 then
			std_slash = SLASH
			if platform() != LINUX then
				from_slash = "\\"
			else
				from_slash = "/"
			end if
			dir_name = search:match_replace(from_slash, dir_name, std_slash, 0)
		else
			dir_name = search:match_replace("\\", dir_name, std_slash, 0)
			dir_name = search:match_replace("/", dir_name, std_slash, 0)
		end if
	end if
	return {dir_name, file_full, file_name, file_ext, drive_id}
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //path//: the path to parse
--# //std_slash//: a signal to indicate that the function should use the
--  OS-specific standard slash symbol (typically set to //0//)
--
-- Returns:
--
--a **sequence** of length five. Each of these elements is a string:
--* The path name. For //Windows// this excludes the drive id.
--* The full unqualified file name
--* the file name, without extension
--* the file extension
--* the drive id
--
-- Notes:
--
-- The host operating system path separator is used in the parsing.
--
-- Example 1:
-- <eucode>
-- -- WINDOWS
-- info = pathinfo("C:\\euphoria\\docs\\readme.txt")
-- -- info is {"C:\\euphoria\\docs", "readme.txt", "readme", "txt", "C"}
-- </eucode>
--
-- Example 2:
-- <eucode>
-- -- Unix variants
-- info = pathinfo("/opt/euphoria/docs/readme.txt")
-- -- info is {"/opt/euphoria/docs", "readme.txt", "readme", "txt", ""}
-- </eucode>
--
-- Example 3:
-- <eucode>
-- -- no extension
-- info = pathinfo("/opt/euphoria/docs/readme")
-- -- info is {"/opt/euphoria/docs", "readme", "readme", "", ""}
-- </eucode>
--
--*/
--------------------------------------------------------------------------------
global function dirname(sequence path, integer pcd) --> [sequence] the directory name of a fully qualified filename
	sequence data
	data = pathinfo(path, 0)
	if pcd then
		if length(data[1]) = 0 then
			return "."
		end if
	end if
	return data[1]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //path//: the path from which to extract information
--# //pcd//: if not zero and there is no directory name in //path//
--                 then "." is returned. The value //0// will just return
--                 any directory name in //path//.
--
-- Returns:
--
-- a **sequence**: the full file name part of //path//.
--
-- Notes:
--
-- The host operating system path separator is used.
--*/
--------------------------------------------------------------------------------
global function filename(sequence path) --> [sequence] the file name portion of a fully qualified filename
	sequence data
	data = pathinfo(path, 0)
	return data[2]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //path//: the path from which to extract information
--
-- Returns:
--
-- a **sequence**: the file name part of //path//.
--
-- Notes:
--
-- The host operating system path separator is used.
--*/
--------------------------------------------------------------------------------
global function fileext(sequence path) --> [sequence] the file extension of a fully qualified filename
	sequence data
	data = pathinfo(path, 0)
	return data[4]
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# //path//: the path from which to extract information
--
-- Returns:
-- a **sequence**: the file extension part of //path//.
--
-- Comments:
-- The host operating system path separator is used.
--*/
--------------------------------------------------------------------------------
global function walk_dir(sequence path_name, integer your_function, integer scan_subdirs, object dir_source)   -- Generalized Directory Walker
    object abort_now
    object d    
	object orig_func
	object source_orig_func
	object source_user_data
	sequence user_data
    user_data = {path_name, 0}
   	orig_func = your_function
	if sequence(your_function) then
		user_data = append(user_data, your_function[2])
		your_function = your_function[1]
	end if
	source_orig_func = dir_source
	if sequence(dir_source) then
		source_user_data = dir_source[2]
		dir_source = dir_source[1]
	end if
    -- get the full directory information
	if not equal(dir_source, NO_ROUTINE_ID) then
		if atom(source_orig_func) then
			d = call_func(dir_source, {path_name})
		else
			d = call_func(dir_source, {path_name, source_user_data})
		end if		
	elsif my_dir = DEFAULT_DIR_SOURCE then
		d = default_dir(path_name)
	else
		d = call_func(my_dir, {path_name})
	end if
	if atom(d) then
		return W_BAD_PATH
	end if
	for i = 1 to length(d) do
		if not find(d[i][D_NAME], {".", ".."}) then
    		user_data[2] = d[i]
    		abort_now = call_func(your_function, user_data)
    		if not equal(abort_now, 0) then
    			return abort_now
    		end if		
    		if find('d', d[i][D_ATTRIBUTES]) then
    			-- a directory
    			if scan_subdirs then
    				abort_now = walk_dir(path_name & SLASH & d[i][D_NAME],
    									 orig_func, scan_subdirs, source_orig_func)				
    				if not equal(abort_now, 0) and 
    				   not equal(abort_now, W_BAD_PATH) then
    					-- allow BAD PATH, user might delete a file or directory 
    					return abort_now
    				end if
    			end if
    		end if
		end if		
	end for
	return 0
end function
--------------------------------------------------------------------------------
--/*
-- Generalized Directory Walker
--
-- Parameters:
--# //path_name//: the name of the directory to walk through
--# //your_function//: the routine id of a function that will receive each path
--                       returned from the result of ##dir_source##, one at a time.
--                       Optionally, to include extra data for your function, ##your_function##
--                       can be a 2 element sequence, with the routine_id as the first element and other data
--                       as the second element.
--# //scan_subdirs//: //1// to also walk though subfolders, //0// to skip them all.
--# //dir_source//: a routine_id of a user-defined routine that 
--                    returns the list of paths to pass to ##your_function##.
--					  If your routine requires an extra parameter,
--                    //dir_source// may be a 2 element sequence where the first element is the
--                    routine id and the second is the extra data to be passed as the second parameter
--                    to your function.
--
-- Returns:
--
-- an **object**:
-- * ##0## on success
-- * ##W_BAD_PATH##  an error occurred
-- * anything else the custom function returned something to stop [[:walk_dir]].
--
-- Notes:
--
-- This routine will "walk" through a directory named //path_name//. For each entry in the 
-- directory, it will call a function, whose routine_id is //your_function//.
-- If //scan_subdirs// is non-zero (TRUE), then the subdirectories in
-- //path_name// will be walked through recursively in the very same way.
--
-- The routine that you supply should accept two sequences, the //path name// and //dir// entry for 
-- each file and subdirectory. It should return ##0## to keep going, ##W_SKIP_DIRECTORY## to avoid
-- scan the contents of the supplied path name (if a directory), or non-zero to stop 
-- ##walk_dir##. Returning //W_BAD_PATH// is taken as denoting some error.
--
-- This mechanism allows you to write a simple function that handles one file at a time, 
-- while ##walk_dir## handles the process of walking through all the files and subdirectories.
--
-- By default, the files and subdirectories will be visited in alphabetical order. To use 
-- a different order, use the ##dir_source## to pass the routine_id of your own modified
-- ##dir## function that sorts the directory entries differently.
--
-- The path that you supply to ##walk_dir## must not contain wildcards (//*// or //?//). Only a 
-- single directory (and its subdirectories) can be searched at one time.
--
-- For //Windows// systems, any //'/'// characters in //path_name// are replaced with //'\'//.
--
-- All trailing slash and whitespace characters are removed from //path_name//.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.6
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2021.01.19
--Status: operational; incomplete
--Changes:]]]
--* utilised local function IfWin
--* ##create_file## defined
--* ##delete_file## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2020.12.04
--Status: operational; incomplete
--Changes:]]]
--* defined ##pathinfo##
--* defined //SLASHES//
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2019.01.18
--Status: operational; incomplete
--Changes:]]]
--* defined ##create_directory##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.02.13
--Status: operational; incomplete
--Changes:]]]
--* documented ##walk_dir##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.02.12
--Status: operational; incomplete
--Changes:]]]
--* documented ##dir##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.1
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.02.11
--Status: created;operational; complete
--Changes:]]]
--* documented ##current_dir##
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2018.02.05
--Status: created;operational; complete
--Changes:]]]
--* copied from eu3.2.0
--------------------------------------------------------------------------------
--[[[Version: 3.2.0.0
--Euphoria Versions: 3.2.0 upwards
--Author: C A Newbould
--Date: 2017.09.07
--Status: created;operational; complete
--Changes:]]]
--* revised for 3.2.0
--* re-defined ##walk_dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.2
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.08.23
--Status: operational; complete
--Changes:]]]
--* defined ##walk_dir##
--* added constants for ##dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2017.08.14
--Status: created; incomplete
--Changes:]]]
--* defined ##dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.11
--Status: created; incomplete
--Changes:]]]
--* defined ##chdir##
--* defined ##current_dir##
--------------------------------------------------------------------------------
