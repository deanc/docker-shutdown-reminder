#!/bin/sh
set -eu
/bin/launchctl bootout "gui/$(/usr/bin/id -u)/local.docker-shutdown-reminder" 2>/dev/null || true
/bin/rm -f "$HOME/Library/LaunchAgents/local.docker-shutdown-reminder.plist"
echo 'Schedule removed. Application and reminder history are retained in Library/Application Support/DockerShutdownReminder.'
