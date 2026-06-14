#!/usr/bin/env bash

# Reload Kitty instances
killall -USR1 .kitty-wrapped


# Reload CAVA
if pgrep -x "cava" > /dev/null; then
    # Rebuild the final config file from the base and newly generated colors
    cat ~/.config/cava/config_base ~/.config/cava/colors > ~/.config/cava/config 2>/dev/null
    # Tell CAVA to reload the config
    killall -USR1 cava
fi

# Reload SwayNC CSS styling dynamically without killing the daemon
if command -v swaync-client &> /dev/null; then
    swaync-client -rs
fi

# Restarting swayosd.service is currently the ONLY way to reload its CSS.
# WARNING: This is what causes the sound problems. Because swayosd-server 
# forcefully reconnects to an audio server on boot, restarting it causes audio drops/pops.
if systemctl --user is-active --quiet swayosd.service; then
    systemctl --user restart swayosd.service &
fi

# ==============================================================================
# GTK Live-Reload Hack
# Rapidly toggles the global theme to force GTK3 and GTK4 apps to flush 
# their caches and read the newly generated Matugen CSS.
# ==============================================================================
# ==============================================================================
# Obsidian — sync generated CSS to all vaults (hot-reloads automatically)
# ==============================================================================
OBSIDIAN_CSS="$HOME/.config/matugen/generated/obsidian-theme.css"
if [ -f "$OBSIDIAN_CSS" ]; then
    for vault_dir in "$HOME"/Documents/pensive "$HOME"/Documents/obsidian/personal "$HOME"/Documents/notes-saas; do
        if [ -d "$vault_dir/.obsidian/snippets" ]; then
            cp "$OBSIDIAN_CSS" "$vault_dir/.obsidian/snippets/matugen-theme.css"
        fi
    done
fi

wait
