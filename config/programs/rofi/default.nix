{ lib, ... }:

{
  home.activation.copyRofiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf $HOME/.config/rofi
    run cp -r ${../../../.config/rofi} $HOME/.config/rofi
    run chmod -R u+w $HOME/.config/rofi
  '';
}
