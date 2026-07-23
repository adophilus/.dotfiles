{ lib, ... }:

{
  # Only copies config files — TPM manages plugins separately at runtime.
  home.activation.copyTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run rm -rf $HOME/.config/tmux
    run cp -r ${../../../.config/tmux} $HOME/.config/tmux
    run chmod -R u+w $HOME/.config/tmux
  '';
}
