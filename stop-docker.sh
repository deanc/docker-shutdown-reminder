#!/bin/sh
set -eu

# Ask Docker Desktop itself to shut down, as with its Quit menu action.
# Let Docker manage its containers; do not stop them individually first.
# This is the CLI wait limit, not a container kill timeout.
exec /Applications/Docker.app/Contents/Resources/bin/docker desktop stop --timeout 60
