{ lib, ... }:

{
  home.activation.copyLazygitConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run rm -rf $HOME/.config/lazygit
    run cp -r ${../../../.config/lazygit} $HOME/.config/lazygit
    run chmod -R u+w $HOME/.config/lazygit
  '';
}
