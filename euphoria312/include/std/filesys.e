--------------------------------------------------------------------------------
--	Library: filesys.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)filesys.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.7
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2018.12.13
--Status: operational; complete
--Changes:]]]
--* remooved erroneous reference to ##lock_file##
--
------
--==Euphoria Standard library: filesys
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##chdir##
--* ##current_dir##
--* ##dir##
--* ##walk_dir##
--
-- Utilise these routines by adding the following statement to your module:
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
include sort.e  -- for sort
include os.e    -- for LINUX
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant DEFAULT = -2
constant M_CHDIR = 63
constant M_CURRENT_DIR = 23
constant M_DIR = 22
--------------------------------------------------------------------------------
--	Shared with other modules
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
integer SLASH
if platform() = LINUX then
    SLASH='/'
else
    SLASH='\\'
end if
--------------------------------------------------------------------------------
--	forward-references
--------------------------------------------------------------------------------
integer dir_id
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer my_dir my_dir = DEFAULT  -- it's better not to use routine_id() here, or else users will have to bind with clear routine names
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
    if atom(d) then
    	return d
    else
    	-- sort by name
    	return sort(d, ASCENDING)
    end if
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function chdir(sequence newdir)	-- changes the current directory.
    return machine_func(M_CHDIR, newdir)
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##newdir##: the required path name
--
--  Returns:
--
-- 1 - success, 0 - fail
--
-- Notes:
--
-- By setting the current directory, you can refer to files in that directory
-- using just the file name.
--
-- The function ##current_dir## will return the name of the current directory.
--
-- In WIN32 the current directory is a global property shared by all the
-- processes running under one shell.
-- I Linux/FreeBSD, a subprocess can change the current directory for itself,
-- but this won't affect the current directory of its parent process. 
--*/
--------------------------------------------------------------------------------
global function current_dir()	-- returns name of the current working directory
    return machine_func(M_CURRENT_DIR, 0)
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- A **sequence** containing the name of the current working directory.
--
-- Notes:
--
-- There will be no slash or backslash on the end of the current directory,
-- except under DOS/Windows, at the top-level of a drive, e.g. C:\.
--*/
--------------------------------------------------------------------------------
global function dir(sequence name)	-- returns directory information, given the name of a file or directory.
    return machine_func(M_DIR, name)
end function
dir_id = routine_id("dir")
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##name##: the name of the file or directory to be inspected
--
-- Returns:
--
-- a **sequence** containing the results,
-- or //-1//, if there is no file or directory with this name.
--
-- This information produced is similar to what you would get from the
-- DOS DIR command.
--
-- Each element is a sequence that describes one file or subdirectory.
--
-- Each entry contains the name, attributes and file size as well as the
-- year, month, day, hour, minute and second of the last modification.
--
-- The format of the sequence is:
-- {
--  {"name1", attributes, size, year, month, day, hour, minute, second},
--  {"name2", ...                                                     },
-- }
--
-- Notes:
--
-- In WIN32 ##name## can contain * and ? as wildcards to select multiple files.
--
-- If ##name## is a directory you may have entries for "." and "..", just as
-- with the DOS DIR command.
-- If ##name## is a file then the return value  will have just one entry,
-- i.e. length(x) will be 1.
-- If ##name## contains wildcards you may have multiple entries.
--
-- You can refer to the elements of an entry with the following constants:
--* D_NAME = 1
--* D_ATTRIBUTES = 2
--* D_SIZE = 3
--* D_YEAR = 4
--* D_MONTH = 5
--* D_DAY = 6
--* D_HOUR = 7
--* D_MINUTE = 8
--* D_SECOND = 9
--
-- The attributes element is a string sequence containing characters chosen from:
--* 'd' -- directory
--* 'r' -- read only file
--* 'h' -- hidden file
--* 's' -- system file
--* 'v' -- volume-id entry
--* 'a' -- archive file
--
-- A normal file without special attributes would just have an empty string, "",
-- in this field.
--
-- The top level directory, e.g. c:\ does not have "." or ".." entries.
--
-- This function is often used just to test if a file or directory exists.
--
-- Under WIN32, ##name## can have a long file or directory name anywhere
-- in the path. The file name returned in D_NAME will be a long file name.
--
-- Under Linux/FreeBSD, the only attribute currently available is 'd'.
--*/
--------------------------------------------------------------------------------
global function walk_dir(sequence path_name, integer your_function, integer scan_subdirs)   -- Generalized Directory Walker
    object abort_now
    object d    
    -- get the full directory information
    if my_dir = DEFAULT then
    	d = default_dir(path_name)
    else
    	d = call_func(my_dir, {path_name})
    end if
    if atom(d) then
    	return W_BAD_PATH
    end if    
    -- trim any trailing blanks or '\' characters from the path
    while length(path_name) > 0 and 
        find(path_name[$], {' ', SLASH}) do
        path_name = path_name[1..$-1]
    end while    
    for i = 1 to length(d) do
    	if find('d', d[i][D_ATTRIBUTES]) then
    	    -- a directory
    	    if not find(d[i][D_NAME], {".", ".."}) then
    		abort_now = call_func(your_function, {path_name, d[i]})
    		if not equal(abort_now, 0) then
    		    return abort_now
    		end if
    		if scan_subdirs then
    		    abort_now = walk_dir(path_name & SLASH & d[i][D_NAME],
    					 your_function, scan_subdirs)
    		    
    		    if not equal(abort_now, 0) and 
    		       not equal(abort_now, W_BAD_PATH) then
    			-- allow BAD PATH, user might delete a file or directory 
    			return abort_now
    		    end if
    		end if
    	    end if
    	else
    	    -- a file
    	    abort_now = call_func(your_function, {path_name, d[i]})
    	    if not equal(abort_now, 0) then
    		return abort_now
    	    end if
    	end if
    end for
    return 0
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##path_name##: the name of the directory to be scanned
--# ##your_function##: the routine_id of a routine supplied by the user
--# ##scan_subdirs##: a boolean value
-- if TRUE, then the subdirectories will be walked through recursively
--
-- The routine that you supply should accept the path name and ##dir## entry for
-- each file and subdirectory.
-- It should return 0 to keep going, or non-zero to stop ##walk_dir##.
-- ##walk_dir## returns 0 when it runs successfully to completion.
-- It returns -1 if it can't open the path name st.
-- Otherwise, it returns whatever non-zero value your routine returned when it
-- chose to stop walk_dir prematurely.
--
-- Notes:
--
-- This mechanism allows you to write a simple function that handles one file
-- at a time, while ##walk_dir## handles the process of walking through all the
-- files and subdirectories.
--
-- By default, the files and subdirectories will be visited in alphabetical order.
-- To use a different order, set the global integer my_dir to the routine id of
-- your own modified ##dir## function that sorts the directory entries differently.
-- See the default dir() function in file.e.
--
--The path that you supply to ##walk_dir## must not contain wildcards (* or ?).
-- Only a single directory (and its subdirectories) can be searched at one time.
--*/
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.6
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2018.02.12
--Status: operational; complete
--Changes:]]]
--* documented ##walk_dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.5
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2018.02.12
--Status: operational; complete
--Changes:]]]
--* documented ##dir##
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.4
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2018.02.11
--Status: operational; complete
--Changes:]]]
--* documented ##current_dir##
--* corrected call to ##dir## before it is declared
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.3
--Euphoria Versions: 3.1.2 upwards
--Author: C A Newbould
--Date: 2018.02.05
--Status: operational; complete
--Changes:]]]
--* documented ##chdir##
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
