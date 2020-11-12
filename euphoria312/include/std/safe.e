--------------------------------------------------------------------------------
--	Library: safe.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)safe.e
-- Description: Re-allocation of existing Eu3 libraries into standard libraries
------
--[[[Version: 3.1.2.1
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2018.05.11
--Status: created; incomplete
--Changes:]]]
--* defined init
--* defined constants and variables
--* added all re-written routines from ##machine.e## to L654 in safe.e (eu3)
--
------
--==Euphoria Standard library: safe
--===Routines
-- The following routines are part of the Eu3.1.1 installation and deliver
-- exactly the same functionality as those defined in Open Euphoria's standard
--library of the same name.
--* ##allocate##
--* ##bytes_to_int##
--* ##call##
--* ##check_all_blocks##
--* ##c_func##
--* ##c_proc##
--* ##free##
--* ##int_to_bytes##
--* ##mem_copy##
--* ##mem_set##
--* ##peek##
--* ##peek4s##
--* ##peek4u##
--* ##poke##
--* ##poke##
--* ##register_block##
--* ##unregister_block##
--
-- Utilise these routines by adding the following statement to your module:
--<eucode>include std/safe.e</eucode>
--
--*/
--------------------------------------------------------------------------------
--/*
--==Interface
--*/
--------------------------------------------------------------------------------
with type_check
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
constant BAD = 0
constant BORDER_SPACE = 40
constant leader = repeat('@', BORDER_SPACE)
constant LOW_ADDR = power(2, 20)-1  -- biggest address accessible to 16-bit real mode
constant MAX_ADDR = power(2, 32) - 1	-- biggest address on a 32-bit machine
constant M_SOUND = 1
constant OK = 1
constant M_ALLOC = 16,
	 M_FREE = 17,
	 M_ALLOC_LOW = 32,
	 M_FREE_LOW = 33,
	 M_INTERRUPT = 34,
	 M_SET_RAND = 35,
	 M_USE_VESA = 36,
	 M_CRASH_MESSAGE = 37,
	 M_TICK_RATE = 38,
	 M_GET_VECTOR = 39,
	 M_SET_VECTOR = 40,
	 M_LOCK_MEMORY = 41,
	 M_A_TO_F64 = 46,
	 M_F64_TO_A = 47,
	 M_A_TO_F32 = 48,
	 M_F32_TO_A = 49,
	 M_CRASH_FILE = 57,
	 M_CRASH_ROUTINE = 66
constant trailer = repeat('%', BORDER_SPACE)
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant REG_DI = 1      
global constant REG_SI = 2
global constant REG_BP = 3
global constant REG_BX = 4
global constant REG_DX = 5
global constant REG_CX = 6
global constant REG_AX = 7
global constant REG_FLAGS = 8 -- on input: ignored; on output: low bit has carry flag for; success/fail
global constant REG_ES = 9
global constant REG_DS = 10
global constant REG_LIST_SIZE = 10
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
type far_addr(sequence a)   -- protected mode far address {seg, offset}
    return length(a) = 2 and integer(a[1]) and machine_addr(a[2])
end type
--------------------------------------------------------------------------------
type low_machine_addr(atom a)   -- a legal low machine address 
    return a > 0 and a <= LOW_ADDR and floor(a) = a
end type
--------------------------------------------------------------------------------
type machine_addr(atom a)	-- a 32-bit non-null machine address 
    return a > 0 and a <= MAX_ADDR and floor(a) = a
end type
--------------------------------------------------------------------------------
type natural(integer x)
    return x >= 0
end type
--------------------------------------------------------------------------------
type positive_int(integer x)
    return x >= 1
end type
--------------------------------------------------------------------------------
type register_list(sequence r)  -- a list of register values
    return length(r) = REG_LIST_SIZE
end type
--------------------------------------------------------------------------------
type sequence_8(sequence s) -- an 8-element sequence
    return length(s) = 8
end type
--------------------------------------------------------------------------------
type sequence_4(sequence s) -- a 4-element sequence
    return length(s) = 4
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
atom allocation_num allocation_num = 0
atom mem mem = allocate(4)
sequence safe_address_list safe_address_list = {}	-- include the starting address and length of any acceptable areas of memory for peek/poke here. Set allocation number to 0.
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global integer check_calls check_calls = 1
global integer edges_only edges_only = (platform()=2)
--------------------------------------------------------------------------------
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function bad_address(atom a)    -- show address in decimal and hex  
    return sprintf(" ADDRESS!!!! %d (#%08x)", {a, a})
end function
--------------------------------------------------------------------------------
procedure die(sequence msg) -- Terminate with a message.
    puts(1, "\n\n" & msg & "\n\n")
    ? 1/0 -- force traceback
end procedure
--------------------------------------------------------------------------------
procedure init(sequence title)
    puts(2, title)
end procedure
--------------------------------------------------------------------------------
procedure original_call(atom addr)
    call(addr)
end procedure
--------------------------------------------------------------------------------
function original_c_func(integer i, sequence s)
    return c_func(i, s)
end function
--------------------------------------------------------------------------------
procedure original_c_proc(integer i, sequence s)
    c_proc(i, s)
end procedure
--------------------------------------------------------------------------------
procedure original_mem_copy(atom target, atom source, atom len)
    mem_copy(target, source, len)
end procedure
--------------------------------------------------------------------------------
procedure original_mem_set(atom target, atom value, integer len)
    mem_set(target, value, len)
end procedure
--------------------------------------------------------------------------------
function original_peek(object x)
    return peek(x) -- Euphoria's normal peek
end function
--------------------------------------------------------------------------------
function original_peek4s(object x)
    return peek4s(x) -- Euphoria's normal peek4s
end function
--------------------------------------------------------------------------------
function original_peek4u(object x)
    return peek4u(x) -- Euphoria's normal peek
end function
--------------------------------------------------------------------------------
procedure original_poke(atom a, object v)
    poke(a, v)
end procedure
--------------------------------------------------------------------------------
procedure original_poke4(atom a, object v)
    poke4(a, v)
end procedure
--------------------------------------------------------------------------------
function prepare_block(atom a, integer n)   -- set up an allocated block so we can check it for corruption
    if a = 0 then
    	die("OUT OF MEMORY!")
    end if
    original_poke(a, leader)
    a += BORDER_SPACE
    original_poke(a+n, trailer)
    allocation_num += 1
--  if allocation_num = ??? then 
--      trace(1) -- find out who allocated this block number
--  end if  
    safe_address_list = prepend(safe_address_list, {a, n, allocation_num})
    return a
end function
--------------------------------------------------------------------------------
function safe_address(atom start, integer len)  -- is it ok to read/write all addresses from start to start+len-1?
    sequence block
    atom block_start
    atom block_upper
    atom upper    
    if len = 0 then
	return OK
    end if    
    upper = start + len
    -- search the list of safe memory blocks:
    for i = 1 to length(safe_address_list) do
    	block = safe_address_list[i]
    	block_start = block[1]
    	if edges_only then
    	    -- addresses are considered safe as long as 
    	    -- they aren't in any block's border zone
    	    if start <= 3 then
    		return BAD -- null pointer (or very small address)
    	    end if
    	    if block[3] >= 1 then
    		-- an allocated block with a border area
    		block_upper = block_start + block[2]
    		if (start >= block_start - BORDER_SPACE and 
    		    start < block_start) or 
    		   (start >= block_upper and 
    		    start < block_upper + BORDER_SPACE) then
    		    return BAD    		
    		elsif (upper > block_start - BORDER_SPACE and
    		       upper <= block_start) or
    		      (upper > block_upper and
    		      upper < block_upper + BORDER_SPACE) then
    		    return BAD    		
    		elsif start < block_start - BORDER_SPACE and
    		    upper > block_upper + BORDER_SPACE then
    		    return BAD
    		end if
    	    end if
    	else
    	    -- addresses are considered safe as long as 
    	    -- they are inside an allocated or registered block
    	    if start >= block_start then 
    		block_upper = block_start + block[2]
    		if upper <= block_upper then
    		    if i > 1 then
    			-- move block i to the top and move 1..i-1 down
    			if i = 2 then
    			    -- common case, subscript is faster than slice:
    			    safe_address_list[2] = safe_address_list[1]
    			else
    			    safe_address_list[2..i] = safe_address_list[1..i-1]
    			end if
    			safe_address_list[1] = block
    		    end if
    		    return OK
    		end if
    	    end if
    	end if
    end for
        if edges_only then
    	return OK  -- not found in any border zone
    else
    	return BAD -- not found in any safe block
    end if
end function
--------------------------------------------------------------------------------
procedure show_byte(atom m) -- display byte at memory location m
    integer c    
    c = original_peek(m)
    if c <= 9 then
    	printf(1, "%d", c)
    elsif c < 32 or c > 127 then
    	printf(1, "%d #%02x", {c, c})
    else
    	if c = leader[1] or c = trailer[1] then
    	    printf(1, "%s", c)
    	else
    	    printf(1, "%d #%02x '%s'", {c, c, c})
    	end if
    end if
    puts(1, ",  ")
end procedure
--------------------------------------------------------------------------------
procedure show_block(sequence block_info)   -- display a corrupted block and die
    integer bad
    integer id
    integer len
    integer p
    atom start    
    start = block_info[1]
    len = block_info[2]
    id = block_info[3]
    printf(1, "BLOCK# %d, START: #%x, SIZE %d\n", {id, start, len})
    -- check pre-block
    bad = 0
    for i = start-BORDER_SPACE to start-1 do
    	p = original_peek(i)
    	if p != leader[1] or bad then
    	    bad += 1
    	    if bad = 1 then
        		puts(1, "DATA WAS STORED ILLEGALLY, JUST BEFORE THIS BLOCK:\n")
        		puts(1, "(" & leader[1] & " characters are OK)\n")
        		printf(1, "#%x: ", i)
    	    end if
    	    show_byte(i)
    	end if
    end for
    puts(1, "\nDATA WITHIN THE BLOCK:\n")
    printf(1, "#%x: ", start)
    if len <= 30 then
    	-- show whole block
    	for i = start to start+len-1 do
    	    show_byte(i)
    	end for 
    else
    	-- first part of block
    	for i = start to start+14 do
    	    show_byte(i)
    	end for 
    	-- last part of block
    	puts(1, "\n ...\n")
    	printf(1, "#%x: ", start+len-15)
    	for i = start+len-15 to start+len-1 do
    	    show_byte(i)
    	end for 
    end if
    bad = 0
    -- check post-block
    for i = start+len to start+len+BORDER_SPACE-1 do
    	p = original_peek(i)
    	if p != trailer[1] or bad then
    	    bad += 1
    	    if bad = 1 then
        		puts(1, "\nDATA WAS STORED ILLEGALLY, JUST AFTER THIS BLOCK:\n")
        		puts(1, "(" & trailer[1] & " characters are OK)\n")
        		printf(1, "#%x: ", i)
    	    end if
    	    show_byte(i)
    	end if
    end for 
    die("")
end procedure
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
without warning
--------------------------------------------------------------------------------
-- Overwriting
--------------------------------------------------------------------------------
global procedure call(atom addr)    -- safe call - machine code must start in block that we own
    if safe_address(addr, 1) then
    	original_call(addr)
    	if check_calls then
    	    check_all_blocks() -- check for any corruption
    	end if
    else
    	die(sprintf("BAD CALL ADDRESS!!!! %d\n\n", addr))
    end if
end procedure
--------------------------------------------------------------------------------
global function c_func(integer i, sequence s)
    object r    
    r = original_c_func(i, s)
    if check_calls then
    	check_all_blocks()
    end if 
    return r
end function
--------------------------------------------------------------------------------
global procedure c_proc(integer i, sequence s)
    original_c_proc(i, s)
    if check_calls then
    	check_all_blocks()
    end if
end procedure
--------------------------------------------------------------------------------
global procedure mem_copy(machine_addr target, machine_addr source, natural len)    -- safe mem_copy
    if not safe_address(target, len) then 
    	die("BAD MEM_COPY TARGET" & bad_address(target))
    elsif not safe_address(source, len) then
    	die("BAD MEM_COPY SOURCE" & bad_address(source))
    else
    	original_mem_copy(target, source, len)
    end if
end procedure
--------------------------------------------------------------------------------
global procedure mem_set(machine_addr target, atom value, natural len)  -- safe mem_set
    if safe_address(target, len) then
    	original_mem_set(target, value, len)
    else
    	die("BAD MEM_SET" & bad_address(target))
    end if
end procedure
--------------------------------------------------------------------------------
global function peek(object x)  -- safe version of peek 
    atom a    
    integer len
    if atom(x) then
    	len = 1
    	a = x
    else
    	len = x[2]
    	a = x[1]
    end if
    if safe_address(a, len) then
    	return original_peek(x)
    else
    	die("BAD PEEK" & bad_address(a))
    end if
end function
--------------------------------------------------------------------------------
global function peek4s(object x)    -- safe version of peek4s 
    atom a
    integer len    
    if atom(x) then
    	len = 4
    	a = x
    else
    	len = x[2]*4
    	a = x[1]
    end if
    if safe_address(a, len) then
    	return original_peek4s(x)
    else
    	die("BAD PEEK4S" & bad_address(a))
    end if
end function
--------------------------------------------------------------------------------
global function peek4u(object x)    -- safe version of peek4u 
    atom a
    integer len    
    if atom(x) then
    	len = 4
    	a = x
    else
    	len = x[2]*4
    	a = x[1]
    end if
    if safe_address(a, len) then
    	return original_peek4u(x)
    else
    	die("BAD PEEK4U" & bad_address(a))
    end if
end function
--------------------------------------------------------------------------------
global procedure poke(atom a, object v) -- safe version of poke 
    integer len    
    if atom(v) then
    	len = 1
    else
    	len = length(v)
    end if
    if safe_address(a, len) then
    	original_poke(a, v)
    else
    	die("BAD POKE" & bad_address(a))
    end if
end procedure
--------------------------------------------------------------------------------
global procedure poke4(atom a, object v)    -- safe version of poke4 
    integer len    
    if atom(v) then
    	len = 4
    else
    	len = length(v)*4
    end if
    if safe_address(a, len) then
    	original_poke4(a, v)
    else
    	die("BAD POKE4" & bad_address(a))
    end if
end procedure
--------------------------------------------------------------------------------
-- others
--------------------------------------------------------------------------------
global function allocate(positive_int n)    -- allocate memory block and add it to safe list
    atom a
    a = machine_func(M_ALLOC, n+BORDER_SPACE*2)
    return prepare_block(a, n)
end function
--------------------------------------------------------------------------------
global function bytes_to_int(sequence s)    -- converts 4-byte peek() sequence into an integer value
    if length(s) = 4 then
	   poke(mem, s)
    else    
	   poke(mem, s[1..4])
    end if
    return peek4u(mem)
end function
--------------------------------------------------------------------------------
global procedure check_all_blocks() -- Check all allocated blocks for corruption of the leader and trailer areas. 
    atom a
    sequence block
    integer n    
    for i = 1 to length(safe_address_list) do
    	block = safe_address_list[i]
    	if block[3] >= 1 then
    	    -- a block that we allocated
    	    a = block[1]
    	    n = block[2]
    	    if not equal(leader, original_peek({a-BORDER_SPACE, BORDER_SPACE})) 
            then
    		    show_block(block)
    	    elsif not equal(trailer, original_peek({a+n, BORDER_SPACE})) then
                show_block(block)
    	    end if          
    	end if
    end for
end procedure
--------------------------------------------------------------------------------
global procedure free(machine_addr a)   -- free address a - make sure it was allocated
    integer n    
    for i = 1 to length(safe_address_list) do
	if safe_address_list[i][1] = a then
	    -- check pre and post block areas
	    if safe_address_list[i][3] <= 0 then
    		die("ATTEMPT TO FREE A BLOCK THAT WAS NOT ALLOCATED!")
	    end if
	    n = safe_address_list[i][2]
	    if not equal(leader, original_peek({a-BORDER_SPACE, BORDER_SPACE})) then
    		show_block(safe_address_list[i])
	    elsif not equal(trailer, original_peek({a+n, BORDER_SPACE})) then
    		show_block(safe_address_list[i])
	    end if          
	    machine_proc(M_FREE, a-BORDER_SPACE)
	    -- remove it from list
	    safe_address_list = 
			safe_address_list[1..i-1] &
			safe_address_list[i+1..$]
	    return
	end if
    end for
    die("ATTEMPT TO FREE USING AN ILLEGAL ADDRESS!")
end procedure
--------------------------------------------------------------------------------
global function int_to_bytes(atom x)    -- returns value of x as a sequence of 4 bytes 
-- that you can poke into memory 
--      {bits 0-7,  (least significant)
--       bits 8-15,
--       bits 16-23,
--       bits 24-31} (most significant)
-- This is the order of bytes in memory on 386+ machines.
    integer a
    integer b
    integer c
    integer d    
    a = remainder(x, #100)
    x = floor(x / #100)
    b = remainder(x, #100)
    x = floor(x / #100)
    c = remainder(x, #100)
    x = floor(x / #100)
    d = remainder(x, #100)
    return {a, b, c, d}
end function
--------------------------------------------------------------------------------
global procedure register_block(machine_addr block_addr, positive_int block_len)	-- registers an externally-acquired block of memory as being safe to use
    allocation_num += 1
    safe_address_list = prepend(safe_address_list, {block_addr, block_len,
       -allocation_num})
end procedure
--------------------------------------------------------------------------------
global procedure unregister_block(machine_addr block_addr)  -- remove an external block of memory from the safe address list
    for i = 1 to length(safe_address_list) do
    	if safe_address_list[i][1] = block_addr then
    	    if safe_address_list[i][3] >= 0 then
        		die("ATTEMPT TO UNREGISTER A NON-EXTERNAL BLOCK")
    	    end if
    	    safe_address_list = safe_address_list[1..i-1] &
    				safe_address_list[i+1..$]
    	    return
    	end if  
    end for
    die("ATTEMPT TO UNREGISTER A BLOCK THAT WAS NOT REGISTERED!")
end procedure
--------------------------------------------------------------------------------
--
--==== Defined instances
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--==== Initialisation
--
--------------------------------------------------------------------------------
init("\n\t\tUsing safe.e - the debug version of machine.e\n")
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.1.2.0
--Euphoria Versions: 3.1.1 upwards
--Author: C A Newbould
--Date: 2017.08.22
--Status: created; incomplete
--Changes:]]]
--* defined ##register_block##
--------------------------------------------------------------------------------
