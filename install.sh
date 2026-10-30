#!/bin/sh
set -eu

if [ "$(/usr/bin/uname -s)" != Darwin ]; then
    echo 'This reminder requires macOS.' >&2
    exit 1
fi
build_only=false
case $# in
    0) ;;
    2)
        if [ "$1" != --build-only ] || [ -z "$2" ]; then
            echo 'Usage: sh install.sh [--build-only OUTPUT_DIRECTORY]' >&2
            exit 2
        fi
        build_only=true
        /bin/mkdir -p "$2"
        output_dir=$(CDPATH='' cd -- "$2" && pwd)
        ;;
    *)
        echo 'Usage: sh install.sh [--build-only OUTPUT_DIRECTORY]' >&2
        exit 2
        ;;
esac

if [ "$build_only" = false ] && [ ! -x /Applications/Docker.app/Contents/Resources/bin/docker ]; then
    echo 'Install Docker Desktop in /Applications/Docker.app first.' >&2
    exit 1
fi

source_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
support="$HOME/Library/Application Support/DockerShutdownReminder"
agent="$HOME/Library/LaunchAgents/local.docker-shutdown-reminder.plist"
if [ "$build_only" = true ]; then
    support="$output_dir/Application Support/DockerShutdownReminder"
    agent="$output_dir/LaunchAgents/local.docker-shutdown-reminder.plist"
fi
app="$support/Docker Shutdown Reminder.app"

/bin/mkdir -p "$support" "$(dirname -- "$agent")"
/usr/bin/osacompile -o "$app" "$source_dir/Reminder.applescript"
/bin/cp "$source_dir/stop-docker.sh" "$app/Contents/Resources/stop-docker.sh"
/bin/cp "$source_dir/shutdown-worker.sh" "$app/Contents/Resources/shutdown-worker.sh"
/usr/bin/codesign --force --sign - "$app"
/usr/bin/codesign --verify "$app"

cat > "$agent" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>local.docker-shutdown-reminder</string>
  <key>ProgramArguments</key><array>
    <string>/usr/bin/open</string><string>-W</string>
  </array>
  <key>LimitLoadToSessionType</key><string>Aqua</string>
  <key>StartCalendarInterval</key><array>
    <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>30</integer></dict>
  </array>
  <key>StandardOutPath</key><string>STDOUT_PATH</string>
  <key>StandardErrorPath</key><string>STDERR_PATH</string>
</dict></plist>
PLIST

# Let plutil encode paths correctly, including spaces and XML characters.
/usr/bin/plutil -insert ProgramArguments.2 -string "$app" "$agent"
/usr/bin/plutil -replace StandardOutPath -string "$support/launchd.log" "$agent"
/usr/bin/plutil -replace StandardErrorPath -string "$support/launchd-error.log" "$agent"
/usr/bin/plutil -lint "$agent"
if [ "$build_only" = true ]; then
    echo "Built app and LaunchAgent in $output_dir. No schedule registered."
    exit 0
fi

domain="gui/$(/usr/bin/id -u)"
/bin/launchctl bootout "$domain/local.docker-shutdown-reminder" 2>/dev/null || true
/bin/launchctl bootstrap "$domain" "$agent"
/bin/launchctl enable "$domain/local.docker-shutdown-reminder"
echo 'Installed: weekdays at 17:30. No prompt or shutdown triggered during installation.'
