#!/usr/bin/env bash
# Toggle between light and dark matugen theme
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MATUGEN_CONFIG="$HOME/user_scripts/theme_matugen/matugen_config.sh"

# Detect current mode from gsettings
current=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo "")

if [[ "$current" == *"light"* ]]; then
    exec "$MATUGEN_CONFIG" --mode dark
else
    exec "$MATUGEN_CONFIG" --mode light
fi
