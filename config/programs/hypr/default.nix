{ pkgs, lib, ... }:
{
  home.activation.copyHyprConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync --archive --delete --exclude hypridle.conf --exclude .env ${../../../.config/hypr}/ $HOME/.config/hypr/
    run chmod --recursive u+w $HOME/.config/hypr
  '';
}
