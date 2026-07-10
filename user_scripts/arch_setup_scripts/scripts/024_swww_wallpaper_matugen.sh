#!/usr/bin/env bash
# Applies the default wallpaper and generates a matching color scheme.
# Runs awww and matugen in parallel with a 6-second watchdog timeout.

set -euo pipefail

# ══════════════════════════════════════════════════════════════════════════════
# Configuration
# ══════════════════════════════════════════════════════════════════════════════

readonly WALLPAPER="${HOME}/Pictures/wallpapers/dusk_default.jpg"
readonly DAEMON_WAIT_CYCLES=20  # 2s total (20 × 0.1s)
readonly WATCHDOG_CYCLES=60    # 6s total (60 × 0.1s)

readonly -a awww_OPTS=(
    --transition-type grow
    --transition-duration 4
    --transition-fps 60
)

# ══════════════════════════════════════════════════════════════════════════════
# Dependencies
# ══════════════════════════════════════════════════════════════════════════════

sudo pacman -S --needed --noconfirm matugen awww

# ══════════════════════════════════════════════════════════════════════════════
# Validation
# ══════════════════════════════════════════════════════════════════════════════

[[ -f "$WALLPAPER" ]] || {
    printf "Error: Wallpaper '%s' not found.\n" "$WALLPAPER" >&2
    exit 1
}

# ══════════════════════════════════════════════════════════════════════════════
# Daemon Initialization
# ══════════════════════════════════════════════════════════════════════════════

if ! awww query &>/dev/null; then
    awww-daemon &>/dev/null &
    
    # Poll for daemon readiness
    cycles=$DAEMON_WAIT_CYCLES
    while ! awww query &>/dev/null && (( cycles-- > 0 )); do
        sleep 0.1
    done
    
    if ! awww query &>/dev/null; then
        printf "Error: awww-daemon failed to start within 2 seconds.\n" >&2
        exit 1
    fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# Parallel Execution
# ══════════════════════════════════════════════════════════════════════════════

(
    for i in {1..5}; do
        matugen --mode dark image "$WALLPAPER" &>/dev/null
        sleep 5
    done
) &
MATUGEN_PID=$!

awww img "$WALLPAPER" "${awww_OPTS[@]}" &>/dev/null &
awww_PID=$!

# ══════════════════════════════════════════════════════════════════════════════
# Watchdog
# ══════════════════════════════════════════════════════════════════════════════

step=0
while (( step < WATCHDOG_CYCLES )); do
    matugen_running=0
    awww_running=0
    
    if kill -0 "$MATUGEN_PID" 2>/dev/null; then matugen_running=1; fi
    if kill -0 "$awww_PID" 2>/dev/null; then awww_running=1; fi

    if [[ $matugen_running -eq 0 && $awww_running -eq 0 ]]; then
        matugen_status=0
        awww_status=0
        wait "$MATUGEN_PID" || matugen_status=$?
        wait "$awww_PID" || awww_status=$?
        
        if (( matugen_status == 0 && awww_status == 0 )); then
            printf "Wallpaper and color scheme applied successfully.\n"
        else
            printf "Warning: Task(s) failed (matugen=%d, awww=%d).\n" \
                "$matugen_status" "$awww_status"
        fi
        exit 0
    fi
    
    sleep 0.1
    ((++step))
done

printf "Timeout (6s) reached - script auto-closing.\n"
exit 0
