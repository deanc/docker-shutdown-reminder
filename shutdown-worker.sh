#!/bin/sh
set -eu
resource_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if /bin/sh "$resource_dir/stop-docker.sh"; then
    echo 'Docker Desktop stopped successfully.'
else
    result=$?
    echo "Shutdown did not complete (exit $result)."
    /usr/bin/osascript <<'APPLESCRIPT'
display alert "Docker Desktop did not finish quitting" message "Docker Desktop's quit command failed or did not finish within 60 seconds. Check ~/Library/Application Support/DockerShutdownReminder/shutdown.log for details." as warning buttons {"OK"} default button "OK" giving up after 300
APPLESCRIPT
    exit "$result"
fi
