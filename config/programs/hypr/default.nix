{ pkgs, lib, ... }:

{
  # Sync Hyprland config from nix store to ~/.config/hypr on each rebuild.
  # Uses rsync --update so manual edits in ~/.config/hypr survive if they're
  # newer than the nix store copy. The target is writable so Hyprland and
  # its tools can write to it if needed.
  home.activation.copyHyprConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync -a --delete --exclude hypridle.conf \
      ${../../../.config/hypr}/ $HOME/.config/hypr/
    run chmod -R u+w $HOME/.config/hypr
  '';
}
