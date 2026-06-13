{ lib, ... }:

{
  home.activation.copyCavaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/cava
    run cp -f ${../../../.config/cava}/config_base $HOME/.config/cava/config_base
    run chmod u+w $HOME/.config/cava/config_base
  '';
}
