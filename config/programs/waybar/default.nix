{ pkgs, lib, ... }:

{
  # Copy Waybar theme directories to ~/.config/waybar/.
  # Active theme symlinks (config.jsonc, style.css) are managed by the
  # waybar_swap_config.sh script — this only updates the theme files themselves.
  home.activation.copyWaybarThemes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/waybar
    for theme in ${../../../.config/waybar}/*/; do
      name=$(basename "$theme")
      run rm -rf "$HOME/.config/waybar/$name"
      run cp -r "$theme" "$HOME/.config/waybar/$name"
      run chmod -R u+w "$HOME/.config/waybar/$name"
    done
    # Create default symlinks if none exist (so waybar can start on fresh install)
    if [ ! -e "$HOME/.config/waybar/config.jsonc" ]; then
      run ln -snf "$HOME/.config/waybar/horizontal_nerdy_modern/config.jsonc" "$HOME/.config/waybar/config.jsonc"
    fi
    if [ ! -e "$HOME/.config/waybar/style.css" ]; then
      run ln -snf "$HOME/.config/waybar/horizontal_nerdy_modern/style.css" "$HOME/.config/waybar/style.css"
    fi
  '';
}
