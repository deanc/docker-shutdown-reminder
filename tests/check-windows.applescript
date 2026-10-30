on run argv
set reminderScript to load script (POSIX file (item 1 of argv))
set scenarios to {{2026, 10, 26, 8, 59, "2026-10-23"}, {2026, 10, 26, 9, 0, ""}, {2026, 10, 26, 17, 29, ""}, {2026, 10, 26, 17, 30, "2026-10-26"}, {2026, 10, 26, 23, 59, "2026-10-26"}, {2026, 10, 27, 0, 0, "2026-10-26"}, {2026, 10, 27, 8, 59, "2026-10-26"}, {2026, 10, 27, 9, 0, ""}, {2026, 10, 30, 8, 59, "2026-10-29"}, {2026, 10, 30, 9, 0, ""}, {2026, 10, 30, 17, 29, ""}, {2026, 10, 30, 17, 30, "2026-10-30"}, {2026, 10, 31, 0, 0, "2026-10-30"}, {2026, 10, 31, 23, 59, "2026-10-30"}, {2026, 11, 1, 9, 0, "2026-10-30"}, {2026, 11, 1, 23, 59, "2026-10-30"}, {2026, 11, 2, 8, 59, "2026-10-30"}, {2026, 11, 2, 9, 0, ""}, {2026, 10, 25, 0, 0, "2026-10-23"}, {2026, 10, 25, 23, 59, "2026-10-23"}}
repeat with scenario in scenarios
	set moment to current date
	set time of moment to 12 * hours
	set day of moment to 1
	set year of moment to item 1 of scenario
	set month of moment to item 2 of scenario
	set day of moment to item 3 of scenario
	set time of moment to (item 4 of scenario) * hours + (item 5 of scenario) * minutes
	set actual to reminderScript's reminderWindow(moment)
	if actual is not (item 6 of scenario) then error "Incorrect window for " & (moment as text) & ": " & actual
end repeat
return (count scenarios) & " reminder-window checks passed, including morning cutoffs, weekends and DST." as text
end run
