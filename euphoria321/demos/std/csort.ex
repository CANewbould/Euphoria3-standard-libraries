--****
-- === csort.ex
--
-- Demo of custom_sort(), routine_id() The Euphoria custom_sort routine is passed the 
-- routine id of the comparison function to be used when sorting.
--

-- ==== Version
--
-- Version 3.2.1.0
--
-- Edited v4.0.5 so now runs on Eu3.2.1
-- custom_sort given full set of arguments
-- any_key given full set of arguments
-- STDIN = 1 used throughout
--

include std/sort.e -- contains custom_sort()
include std/console.e	-- contains any_key()

constant NAME = 1,
	POPULATION = 2,
	STDIN = 1

constant statistics = {
	 { "Canada", 27.4 },
	 { "United States", 255.6 },
	 { "Brazil", 150.8 },
	 { "Denmark", 5.2 },
	 { "Sweden", 8.7 },
	 { "France", 56.9 },
	 { "Germany", 80.6 },
	 { "Netherlands", 15.2 },
	 { "Italy", 58 },
	 { "New Zealand", 3.4 }
}

function compare_name(sequence a, sequence b)
	-- Compare two sequences (records) according to NAME.
	return compare(a[NAME], b[NAME])
end function

function compare_pop(sequence a, sequence b)
	-- Compare two sequences (records) according to POPULATION.
	-- Note: comparing b vs. a, rather than a vs. b, makes 
	-- the bigger population come first.
	return compare(b[POPULATION], a[POPULATION])
end function

sequence sorted_by_pop, sorted_by_name
integer by_pop, by_name

by_pop = routine_id("compare_pop")
by_name = routine_id("compare_name")

sorted_by_pop = custom_sort(by_pop, statistics, {}, ASCENDING)
sorted_by_name = custom_sort(by_name, statistics, {}, ASCENDING)

puts(STDIN, "sorted by population\t\t  sorted by name\n\n")
for i = 1 to length(sorted_by_pop) do
	printf(STDIN, "%13s %6.1f\t\t%13s %6.1f\n",
		sorted_by_pop[i] & sorted_by_name[i])
end for

any_key("", STDIN)
