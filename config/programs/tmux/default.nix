{ lib, ... }:

{
  # Copies ONLY the 2 config files (tmux.conf + tmux.conf.local) — leaves the
  # plugins/ directory (installed by TPM at runtime) untouched across rebuilds.
  home.activation.copyTmuxConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/tmux
    run cp -f ${../../../home/.config/tmux/tmux.conf} $HOME/.config/tmux/tmux.conf
    run cp -f ${../../../home/.config/tmux/tmux.conf.local} $HOME/.config/tmux/tmux.conf.local
    run chmod u+w $HOME/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf.local
  '';
}
