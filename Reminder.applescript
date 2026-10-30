-- Scheduled by a per-user LaunchAgent. No Docker commands run without Yes.
on run
	set windowKey to my reminderWindow((current date))
	if windowKey is "" then return
	if application id "com.docker.docker" is not running then return
	set supportFolder to (POSIX path of (path to application support from user domain)) & "DockerShutdownReminder/"
	set stateFile to supportFolder & "last-window"
	try
		if (do shell script "/bin/cat " & quoted form of stateFile) is windowKey then return
	end try
	-- Record the offer, including No or an unanswered prompt, once per window.
	do shell script "/usr/bin/printf '%s\\n' " & quoted form of windowKey & " > " & quoted form of stateFile
	activate
	try
		set answer to display dialog "Finished with Docker for now?" & return & return & "Yes will quit Docker Desktop and shut down its containers." with title "Docker Shutdown Reminder" buttons {"No", "Yes"} default button "No" cancel button "No" with icon note
	on error number -128
		return
	end try
	if button returned of answer is not "Yes" then return
	-- Ignore an old dialog accepted after the next workday's cutoff.
	if my reminderWindow((current date)) is not windowKey then return
	set helperPath to (POSIX path of (path to me)) & "Contents/Resources/shutdown-worker.sh"
	try
		-- Detach all three streams so the app can close immediately.
		do shell script "/bin/sh " & quoted form of helperPath & " > " & quoted form of (supportFolder & "shutdown.log") & " 2>&1 < /dev/null &"
	on error errorText
		activate
		display dialog "Docker could not finish shutting down:" & return & return & errorText with title "Docker Shutdown Reminder" buttons {"OK"} default button "OK" with icon caution
	end try
end run

-- Return the date of the workday being wrapped up, or an empty string.
on reminderWindow(moment)
	set dayName to weekday of moment
	set secondsToday to time of moment
	set daysBack to 0
	if dayName is Saturday then
		set daysBack to 1
	else if dayName is Sunday then
		set daysBack to 2
	else if secondsToday < 9 * hours then
		if dayName is Monday then
			set daysBack to 3
		else
			set daysBack to 1
		end if
	else if secondsToday < (17 * hours + 30 * minutes) then
		return ""
	end if
	-- Noon keeps date arithmetic away from DST's overnight clock changes.
	set anchorDate to moment + 0
	set time of anchorDate to 12 * hours
	set anchorDate to anchorDate - daysBack * days
	return (year of anchorDate as text) & "-" & my twoDigits(month of anchorDate as integer) & "-" & my twoDigits(day of anchorDate)
end reminderWindow

on twoDigits(n)
	return text -2 thru -1 of ("0" & (n as text))
end twoDigits
