{ lib, ... }:

{
  home.activation.copyDiffnavConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/diffnav
    run cp -f ${../../../home/.config/diffnav/config.yml} $HOME/.config/diffnav/config.yml
    run chmod u+w $HOME/.config/diffnav/config.yml
  '';
}
