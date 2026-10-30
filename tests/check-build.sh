#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(/usr/bin/mktemp -d)
trap '/bin/rm -rf "$test_dir"' EXIT HUP INT TERM

# Spaces and an ampersand exercise XML path escaping in the generated plist.
output_dir="$test_dir/Build & test"
/bin/sh "$repo_dir/install.sh" --build-only "$output_dir"
app="$output_dir/Application Support/DockerShutdownReminder/Docker Shutdown Reminder.app"
agent="$output_dir/LaunchAgents/local.docker-shutdown-reminder.plist"

test -x "$app/Contents/MacOS/applet"
/usr/bin/codesign --verify --strict "$app"
/usr/bin/cmp "$repo_dir/stop-docker.sh" "$app/Contents/Resources/stop-docker.sh"
/usr/bin/cmp "$repo_dir/shutdown-worker.sh" "$app/Contents/Resources/shutdown-worker.sh"
/usr/bin/plutil -lint "$agent"

value() {
    /usr/bin/plutil -extract "$1" raw -o - "$agent"
}

test "$(value Label)" = local.docker-shutdown-reminder
test "$(value LimitLoadToSessionType)" = Aqua
test "$(value ProgramArguments)" = 3
test "$(value ProgramArguments.0)" = /usr/bin/open
test "$(value ProgramArguments.1)" = -W
test "$(value ProgramArguments.2)" = "$app"
test "$(value StandardOutPath)" = "$output_dir/Application Support/DockerShutdownReminder/launchd.log"
test "$(value StandardErrorPath)" = "$output_dir/Application Support/DockerShutdownReminder/launchd-error.log"
test "$(value StartCalendarInterval)" = 5

index=0
while [ "$index" -lt 5 ]; do
    test "$(value "StartCalendarInterval.$index.Weekday")" = "$((index + 1))"
    test "$(value "StartCalendarInterval.$index.Hour")" = 17
    test "$(value "StartCalendarInterval.$index.Minute")" = 30
    index=$((index + 1))
done

echo 'Build checks passed: signed app, bundled helpers, escaped paths and weekday schedule.'
