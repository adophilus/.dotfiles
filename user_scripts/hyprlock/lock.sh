#!/usr/bin/env bash

# Cache the current wallpaper path
# WALLPAPER=$(awww query | grep -oP 'image: \K.*' | head -1)
WALLPAPER=$(hyprctl hyprpaper listactive | head -1 | awk -F '=' '{print $2}' | xargs)

# Copy wallpaper to cache location (hyprlock reads static path)
cp "$WALLPAPER" ~/.cache/current_wallpaper

# Launch hyprlock
hyprlock
