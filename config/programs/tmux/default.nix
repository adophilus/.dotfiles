{ lib, ... }:

{
  # Only copies config files — TPM manages plugins separately at runtime.
  # Uses rsync (not rm -rf + cp) so runtime-installed plugins/ survive rebuilds.
  home.activation.copyTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run ${pkgs.rsync}/bin/rsync --archive --exclude plugins/ ${../../../.config/tmux}/ $HOME/.config/tmux/
    run chmod --recursive u+w $HOME/.config/tmux
  '';
}
