{ lib, ... }:

{
  # Matugen generates theme files at runtime, so the target must be writable.
  home.activation.copyMatugenConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -rf $HOME/.config/matugen
    run cp -r ${../../../home/.config/matugen} $HOME/.config/matugen
    run chmod -R u+w $HOME/.config/matugen
  '';
}
