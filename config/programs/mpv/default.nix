{ lib, ... }:

{
  home.activation.copyMpvConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run rm -rf $HOME/.config/mpv
    run cp -r ${../../../home/.config/mpv} $HOME/.config/mpv
    run chmod -R u+w $HOME/.config/mpv
  '';
}
