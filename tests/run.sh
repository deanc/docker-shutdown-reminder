#!/bin/sh
set -eu
repo_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(/usr/bin/mktemp -d)
trap '/bin/rm -rf "$test_dir"' EXIT HUP INT TERM

for script in install.sh uninstall.sh shutdown-worker.sh stop-docker.sh tests/run.sh tests/check-build.sh; do
    /bin/sh -n "$repo_dir/$script"
done
/usr/bin/osacompile -o "$test_dir/Reminder.scpt" "$repo_dir/Reminder.applescript"
/usr/bin/osascript "$repo_dir/tests/check-windows.applescript" "$test_dir/Reminder.scpt"
