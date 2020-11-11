--------------------------------------------------------------------------------
--	Library: datetime.e
--------------------------------------------------------------------------------
-- Notes:
--
-- 
--------------------------------------------------------------------------------
--/*
--= Library: (euphoria)(include)(std)datetime.e
-- Description: Re-writing (where necessary) of existing OE4 standard libraries
-- for use with Eu3
------
--[[[Version: 3.2.1.5
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.03.19
--Status: operational; incomplete
--Changes:]]]
--* ##days_in_month## defined
--* ##days_in_year## defined
--* ##format## defined
--* ##to_unix## defined
--
------
--==Euphoria Standard library: datetime
--===Constants
--* ##DATE##
--* ##DAYS##
--* ##HOURS##
--* ##MINUTES##
--* ##MONTHS##
--* ##SECONDS##
--* ##WEEKS##
--* ##YEARS##
--===Types
--* ##datetime##
--===Routines
-- The following routines are part of the Open Euphoria's standard
-- library and has been tested/amended to function with Eu3.1.1.
--* ##days_in_month##
--* ##days_in_year##
--* ##format##
--* ##from_date##
--* ##is_leap_year##
--* ##new##
--* ##new_time##
--* ##now##
--* ##weeks_day##
--
-- Utilise this routine by adding the following statement to your module:
--<eucode>include std/datetime.e</eucode>
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
include types.e -- for FALSE, TRUE
--------------------------------------------------------------------------------
--/*
--=== Constants
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
constant AMPM = {"AM", "PM"}
constant DAY = 3
constant DAY_ABBRS = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
constant DAY_LENGTH_IN_SECONDS = 86400
constant DAY_NAMES = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
			"Friday", "Saturday"}
constant DAYS_PER_MONTH = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
constant EPOCH_1970 = 62135856000
constant GREGORIAN_REFORMATION = 1752
constant GREGORIAN_REFORMATION00 = 1700
constant HOUR = 4
constant MINUTE = 5
constant MONTH = 2
constant MONTH_ABBRS = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
			"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
constant MONTH_NAMES = {"January", "February", "March", "April", "May", "June", 
			"July", "August", "September", "October", "November", "December"}
constant SECOND = 6
constant YEAR = 1
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global constant YEARS = 1
global constant MONTHS = 2
global constant WEEKS = 3
global constant DAYS = 4
global constant HOURS = 5
global constant MINUTES = 6
global constant SECONDS = 7
global constant DATE = 8
--------------------------------------------------------------------------------
--
--=== Variables
--
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
integer daysInMonth_id
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--=== Euphoria types
--
--------------------------------------------------------------------------------
global type datetime(object o)  -- a sequence of length 6 in the form {year, month, day_of_month, hour, minute, second}
	if atom(o) then return FALSE end if
	if length(o) != 6 then return FALSE end if
	if not integer(o[YEAR]) then return FALSE end if
	if not integer(o[MONTH]) then return FALSE end if
	if not integer(o[DAY]) then return FALSE end if
	if not integer(o[HOUR]) then return FALSE end if
	if not integer(o[MINUTE]) then return FALSE end if
	if not atom(o[SECOND]) then return FALSE end if
	if not equal(o[1..3], {0, 0, 0}) then
		-- Special case of all zeros is allowed; used when the data is a time only.
		if o[MONTH] < 1 then return FALSE end if
		if o[MONTH] > 12 then return FALSE end if
		if o[DAY] < 1 then return FALSE end if
		if o[DAY] > call_func(daysInMonth_id, {o[YEAR], o[MONTH]}) then return FALSE end if
	end if
	if o[HOUR] < 0 then return FALSE end if
	if o[HOUR] > 23 then return FALSE end if
	if o[MINUTE] < 0 then return FALSE end if
	if o[MINUTE] > 59 then return FALSE end if
	if o[SECOND] < 0 then return FALSE end if
	if o[SECOND] >= 60 then return FALSE end if
	return TRUE
end type
--------------------------------------------------------------------------------
type extended_datetime(sequence this)
	return length(this) = 8 and datetime(this[1..6])
				and integer(this[7]) and integer(this[8])
end type
--------------------------------------------------------------------------------
--/*
--=== Routines
--*/
--------------------------------------------------------------------------------
--	Local
--------------------------------------------------------------------------------
function isLeap(integer year) -- [boolean]
	sequence ly
    ly = (remainder(year, {4, 100, 400, 3200, 80000}) = 0)
    if not ly[1] then return FALSE end if
    if year <= GREGORIAN_REFORMATION then
        return TRUE -- ly[1] can't possibly be FALSE here so set as shortcut
    else
        return ly[1] - ly[2] + ly[3] - ly[4] + ly[5]
    end if
end function
--------------------------------------------------------------------------------
function daysInMonth(integer year, integer month) -- [integer] returns the number of days in the given month
	if year = GREGORIAN_REFORMATION and month = 9 then
		return 19
	elsif month != 2 then
		return DAYS_PER_MONTH[month]
	else
		return DAYS_PER_MONTH[month] + isLeap(year)
	end if
end function
daysInMonth_id = routine_id("daysInMonth")
--------------------------------------------------------------------------------
function daysInYear(integer year) -- returns a jday_ (355, 365 or 366)
	if year = GREGORIAN_REFORMATION then
		return 355
	end if	
	return 365 + isLeap(year)
end function
--------------------------------------------------------------------------------
function julianDayOfYear(object ymd) -- returns an integer
	integer d
	integer day
	integer month
	integer year
	year = ymd[YEAR]
	month = ymd[MONTH]
	day = ymd[DAY]
	if month = 1 then return day end if
	d = 0
	for i = 1 to month - 1 do
		d += daysInMonth(year, i)
	end for
	d += day
	if year = GREGORIAN_REFORMATION and month = 9 then
		if day > 13 then
			d -= 11
		elsif day > 2 then
			return 0
		end if
	end if
	return d
end function
--------------------------------------------------------------------------------
function julianDay(object ymd) -- returns an integer
	integer greg00
	integer j
	integer year
	year = ymd[1]
	j = julianDayOfYear(ymd)
	year  -= 1
	greg00 = year - GREGORIAN_REFORMATION00
	j += (
		365 * year
		+ floor(year/4)
		+ (greg00 > 0)
			* (
				- floor(greg00/100)
				+ floor(greg00/400+.25)
			)
		- 11 * (year >= GREGORIAN_REFORMATION)
	)
	if year >= 3200 then
		j -= floor(year/ 3200)
		if year >= 80000 then
			j += floor(year/80000)
		end if
	end if
	return j
end function
--------------------------------------------------------------------------------
function datetimeToSeconds(object dt) -- returns an atom
	return julianDay(dt) * DAY_LENGTH_IN_SECONDS + (dt[4] * 60 + dt[5]) * 60 + dt[6]
end function
--------------------------------------------------------------------------------
function tolower(object x)
	return x + (x >= 'A' and x <= 'Z') * ('a' - 'A')
end function
--------------------------------------------------------------------------------
--	Shared with other modules
--------------------------------------------------------------------------------
global function days_in_month(datetime dt)	-- returns the number of days in the month
	return daysInMonth(dt[YEAR], dt[MONTH])
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##dt## : the datetime to be queried
--
-- Notes:
--
-- This takes into account whether or not it is a leap year.
--*/
--------------------------------------------------------------------------------
global function days_in_year(datetime dt)	-- returns the number of days in the year
	return daysInYear(dt[YEAR])
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##dt## : the datetime to be queried
--
-- Notes:
--
-- This takes into account whether or not it is a leap year.
--*/
--------------------------------------------------------------------------------
global function from_date(extended_datetime dt)	-- [datetime] converts a given datetime to a datetime with valid year
	return {dt[YEAR]+1900, dt[MONTH], dt[DAY], dt[HOUR], dt[MINUTE], dt[SECOND]}
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--# ##dt## : an extended datetime (dow & doy added) centred on the base date
--
-- Returns:
--
-- a "corrected" **datetime**, but corresponding to the same moment in time.
--*/
--------------------------------------------------------------------------------
global function is_leap_year(datetime dt)   -- [boolean] determines if the given datetime falls within a leap year
	return isLeap(dt[YEAR])
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
--   # ##dt##: the datetime to be queried
--
-- Returns:
--
-- a **boolean**: TRUE if leap year, FALSE otherwise.
--*/
--------------------------------------------------------------------------------
global function new(integer year, integer month, integer day, integer hour, integer minute, atom second)	-- [datetime] creates a new value
	datetime d
	d = {year, month, day, hour, minute, second}
	if equal(d, {0, 0, 0, 0, 0, 0}) then
		return from_date(date())	--now()
	else
		return d
	end if
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##year##: the full year
--# ##month##: the month (1-12)
--# ##day##: the day of the month (1-31)
--# ##hour##: the hour (0-23)
--# ##minute##: the minute (0-59)
--# ##second##: the second (0-59)
--
-- Returns:
--
-- a **datetime**, using the given values
--
--Notes:
--
-- If all values are set to zero then ##new## is equivalent to ##now##.
--*/
--------------------------------------------------------------------------------
global function new_time(integer hour, integer minute, atom second)	-- [datetime] creates a value with a zeroised date
	return new(0, 0, 0, hour, minute, second)
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##hour##: the hour (0-23)
--# ##minute##: the minute (0-59)
--# ##second##: the second (0-59)
--
-- Returns:
--
-- a **datetime** with no date values but with {hour, minute, second} set.
--*/
--------------------------------------------------------------------------------
global function now()	-- [datetime] for now
	return from_date(date())
end function
--------------------------------------------------------------------------------
--/*
-- Returns:
--
-- a **datetime** corresponding to the current moment in time.
--*/
--------------------------------------------------------------------------------
global function to_unix(datetime dt)	-- converts a datetime value to the Unix numeric format (seconds since ##EPOCH_1970##)
	return datetimeToSeconds(dt) - EPOCH_1970
end function
--------------------------------------------------------------------------------
--/*
-- Parameter:
-- # ##dt##: the datetime to be queried
--
-- Returns:
--
-- an **atom**, so this will not overflow during the winter 2038-2039.
--*/
--------------------------------------------------------------------------------
global function weeks_day(datetime dt)	-- [dow] gets the day of week of a datetime
	return remainder(julianDay(dt)-1+4094, 7) + 1
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##dt##: the datetime to be queried
--
-- Returns:
--
-- an **integer**, in the range 1 (Sunday) to 7 (Saturday)
--*/
--------------------------------------------------------------------------------
global function format(datetime d, sequence pattern)	-- formats the date according to the format pattern string
	integer in_fmt	
	integer ch
	integer tmp
	sequence res
	in_fmt = 0
	res = ""
	if equal(pattern, "") then pattern = "%Y-%m-%d %H:%M:%S" end if
	for i = 1 to length(pattern) do
		ch = pattern[i]
		if in_fmt then
			in_fmt = 0
			if ch = '%' then
				res &= '%'
			elsif ch = 'a' then
				res &= DAY_ABBRS[weeks_day(d)]
			elsif ch = 'A' then
				res &= DAY_NAMES[weeks_day(d)]
			elsif ch = 'b' then
				res &= MONTH_ABBRS[d[MONTH]]
			elsif ch = 'B' then
				res &= MONTH_NAMES[d[MONTH]]
			elsif ch = 'C' then
				res &= sprintf("%02d", d[YEAR] / 100)
			elsif ch = 'd' then
				res &= sprintf("%02d", d[DAY])
			elsif ch = 'H' then
				res &= sprintf("%02d", d[HOUR])
			elsif ch = 'I' then
				tmp = d[HOUR]
				if tmp > 12 then
					tmp -= 12
				elsif tmp = 0 then
					tmp = 12
				end if
				res &= sprintf("%02d", tmp)
			elsif ch = 'j' then
				res &= sprintf("%d", julianDayOfYear(d))
			elsif ch = 'k' then
				res &= sprintf("%d", d[HOUR])
			elsif ch = 'l' then
				tmp = d[HOUR]
				if tmp > 12 then
					tmp -= 12
				elsif tmp = 0 then
					tmp = 12
				end if
				res &= sprintf("%d", tmp)
			elsif ch = 'm' then
				res &= sprintf("%02d", d[MONTH])
			elsif ch = 'M' then
				res &= sprintf("%02d", d[MINUTE])
			elsif ch = 'p' then
				if d[HOUR] <= 12 then
					res &= AMPM[1]
				else
					res &= AMPM[2]
				end if
			elsif ch = 'P' then
				if d[HOUR] <= 12 then
					res &= tolower(AMPM[1])
				else
					res &= tolower(AMPM[2])
				end if
			elsif ch = 's' then
				res &= sprintf("%d", to_unix(d))
			elsif ch = 'S' then
				res &= sprintf("%02d", d[SECOND])
			elsif ch = 'u' then
				tmp = weeks_day(d)
				if tmp = 1 then
					res &= "7" -- Sunday
				else
					res &= sprintf("%d", weeks_day(d) - 1)
				end if
			elsif ch = 'w' then
				res &= sprintf("%d", weeks_day(d) - 1)
			elsif ch = 'y' then
			   tmp = floor(d[YEAR] / 100)
			   res &= sprintf("%02d", d[YEAR] - (tmp * 100))
			elsif ch = 'Y' then
				res &= sprintf("%04d", d[YEAR])
			else
				-- TODO: error or just add?
			end if
		elsif ch = '%' then
			in_fmt = 1
		else
			res &= ch
		end if
	end for
	return res
end function
--------------------------------------------------------------------------------
--/*
-- Parameters:
--# ##d## : a datetime which is to be printed out
--# ##pattern## : a format string, similar to the ones ##sprintf## uses, but with 
--  some Unicode encoding. The default [""] is ##"%Y-%m-%d %H:%M:%S"##.
--
-- Returns:
--
--  a **string**, with the date ##d## formatted according to the specification in ##pattern##.
--
-- Comments:
-- Pattern string can include the following specifiers~:
--
-- * ##~%%## ~-- a literal %
-- * ##%a## ~-- locale's abbreviated weekday name (e.g., Sun)
-- * ##%A## ~-- locale's full weekday name (e.g., Sunday)
-- * ##%b## ~-- locale's abbreviated month name (e.g., Jan)
-- * ##%B## ~-- locale's full month name (e.g., January)
-- * ##%C## ~-- century; like %Y, except omit last two digits (e.g., 21)
-- * ##%d## ~-- day of month (e.g, 01)
-- * ##%H## ~-- hour (00..23)
-- * ##%I## ~-- hour (01..12)
-- * ##%j## ~-- day of year (001..366)
-- * ##%k## ~-- hour ( 0..23)
-- * ##%l## ~-- hour ( 1..12)
-- * ##%m## ~-- month (01..12)
-- * ##%M## ~-- minute (00..59)
-- * ##%p## ~-- locale's equivalent of either AM or PM; blank if not known
-- * ##%P## ~-- like %p, but lower case
-- * ##%s## ~-- seconds since 1970-01-01 00:00:00 UTC
-- * ##%S## ~-- second (00..60)
-- * ##%u## ~-- day of week (1..7); 1 is Monday
-- * ##%w## ~-- day of week (0..6); 0 is Sunday
-- * ##%y## ~-- last two digits of year (00..99)
-- * ##%Y## ~-- year
--*/
--------------------------------------------------------------------------------
-- Previous versions
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.4
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.03.13
--Status: created; incomplete
--Changes:]]]
--* ##new## defined
--* ##new_time## defined
--* ##weeks_day## defined
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.3
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.03.05
--Status: created; incomplete
--Changes:]]]
--* ##now## defined
--* corrected typo
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.2
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.03.02
--Status: created; incomplete
--Changes:]]]
--* ##from_date## defined
--* local constant defined
--* local routines re-ordered
--[[[Version: 3.2.1.1
--------------------------------------------------------------------------------
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.01.11
--Status: created; incomplete
--Changes:]]]
--* defined global constants
--------------------------------------------------------------------------------
--[[[Version: 3.2.1.0
--Euphoria Versions: 3.1.1 and after
--Author: C A Newbould
--Date: 2019.01.08
--Status: created; incomplete
--Changes:]]]
--* defined local function ##isLeap##
--* defined ##is_leap_year##
--* defined ##datetime##
--------------------------------------------------------------------------------
