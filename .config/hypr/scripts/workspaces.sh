#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# CACHING & MIGRATION
# -----------------------------------------------------------------------------
source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "workspaces"

# ============================================================================
# 1. ZOMBIE PREVENTION
# Kills any older instances of this script. When Quickshell reloads, 
# it can leave the old listener pipelines running in the background infinitely.
# ============================================================================
for pid in $(pgrep -f "workspaces.sh"); do
    if [ "$pid" != "$$" ] && [ "$pid" != "$PPID" ]; then
        kill -9 "$pid" 2>/dev/null
    fi
done

# Cleanly kill immediate children (like socat) when the script exits normally
cleanup() {
    pkill -P $$ 2>/dev/null
}
trap cleanup EXIT SIGTERM SIGINT

# --- Special Cleanup for Network/Bluetooth ---
# The network toggle starts a background bluetooth scan that must be killed explicitly.
BT_PID_FILE="$QS_RUN_WORKSPACES/bt_scan_pid"

if [ -f "$BT_PID_FILE" ]; then
    kill $(cat "$BT_PID_FILE") 2>/dev/null
    rm -f "$BT_PID_FILE"
fi

# Ensure bluetooth scan is explicitly turned off (timeout prevents deadlocks on fresh installs)
(timeout 2 bluetoothctl scan off > /dev/null 2>&1) &
# ---------------------------------------------

# Configuration: Parse from settings.json dynamically, fallback to 8
SETTINGS_FILE="$HOME/.config/hypr/settings.json"
SEQ_END=$(jq -r '.workspaceCount // 8' "$SETTINGS_FILE" 2>/dev/null)
# Double check it is a valid integer to prevent jq errors later
if ! [[ "$SEQ_END" =~ ^[0-9]+$ ]]; then
    SEQ_END=8
fi

print_workspaces() {
    # Get raw data with a timeout fallback
    spaces=$(timeout 2 hyprctl workspaces -j 2>/dev/null)
    monitors=$(timeout 2 hyprctl monitors -j 2>/dev/null)

    # Failsafe if hyprctl crashes to prevent jq from outputting errors
    if [ -z "$spaces" ] || [ -z "$monitors" ]; then return; fi

    # Generate a per-monitor workspace file.
    # Each monitor gets its own file with relative indices (1-N) matching
    # hyprsome's index system, so pills show correct state per-monitor.
    for mon in $(echo "$monitors" | jq -r '.[].name'); do
        jq -n --unbuffered \
            --argjson spaces "$spaces" \
            --argjson monitors "$monitors" \
            --arg mon "$mon" \
            --arg end "$SEQ_END" '
            ($monitors | map(select(.name == $mon))[0].activeWorkspace.id // -1) as $active_id |
            ([$spaces[] | select(.monitor == $mon)] | sort_by(.id)) as $mon_ws |
            [range(1; ($end | tonumber) + 1)] | map(
                . as $idx |
                (if $idx <= ($mon_ws | length) then $mon_ws[$idx - 1] else null end) as $ws |
                {
                    id: $idx,
                    state: (
                        if $ws != null and $ws.id == $active_id then "active"
                        elif $ws != null and ($ws.windows // 0) > 0 then "occupied"
                        else "empty"
                        end
                    ),
                    tooltip: (
                        if $ws != null and ($ws.lastwindowtitle // "") != "" then $ws.lastwindowtitle
                        else "Empty"
                        end
                    )
                }
            )
        ' > "$QS_RUN_WORKSPACES/workspaces_${mon}.tmp"

        mv "$QS_RUN_WORKSPACES/workspaces_${mon}.tmp" "$QS_RUN_WORKSPACES/workspaces_${mon}.json"
    done
}

# Print initial state
print_workspaces

# ============================================================================
# 2. THE EVENT DEBOUNCER
# Listen to Hyprland socket wrapped in an infinite loop
# ============================================================================
while true; do
    socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        case "$line" in
            workspace*|focusedmon*|activewindow*|createwindow*|closewindow*|movewindow*|destroyworkspace*)
                
                # -> THE FIX <-
                # Hyprland emits HUNDREDS of events a second when you move/resize windows.
                # This reads and discards all subsequent events arriving within a 50ms window.
                # It bundles the storm into a single UI update, completely preventing CPU clogging!
                while read -t 0.05 -r extra_line; do
                    continue
                done

                print_workspaces
                ;;
        esac
    done
    sleep 1
done
