{ lib, ... }:

{
  home.activation.copyWlogoutConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf $HOME/.config/wlogout
    run cp -r ${../../../home/.config/wlogout} $HOME/.config/wlogout
    run chmod -R u+w $HOME/.config/wlogout
  '';
}
