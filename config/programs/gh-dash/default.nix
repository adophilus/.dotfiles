# gh-dash config (diff viewer only). The binary itself is not nix-managed
# (removed earlier); gh-dash is used via the gh extension.
{ lib, ... }:

{
  home.activation.copyGhDashConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/gh-dash
    run cp -f ${../../../home/.config/gh-dash/config.yml} $HOME/.config/gh-dash/config.yml
    run chmod u+w $HOME/.config/gh-dash/config.yml
  '';
}
