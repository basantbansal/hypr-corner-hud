#!/usr/bin/env bash

# Single instance lock using flock
LOCKFILE="/tmp/corner_hud_daemon.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

while true; do
    if ! pgrep -f "quickshell -p $HOME/.config/corner-hud" >/dev/null 2>&1; then
        quickshell -p "$HOME/.config/corner-hud" >/dev/null 2>&1 &
    fi
    sleep 2
done
