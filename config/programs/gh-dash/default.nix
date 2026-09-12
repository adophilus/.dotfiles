# gh-dash — config + nix-managed extension binary.
#
# gh discovers extensions by scanning ~/.local/share/gh/extensions for
# entries NAMED gh-<name> (the prefix filter is hard-coded in gh's
# manager.list()) and executing gh-<name>/gh-<name> inside. It does NOT
# discover gh-* on PATH (verified empirically). A dir without a manifest
# is treated as a GitKind extension — executes fine, `gh extension
# upgrade` just can't update it (nix owns that). Declarative replacement
# for `gh extension install dlvhdr/gh-dash`, which would fight these
# links — remove any such clone first (`gh extension remove dash`).
#
# Config stays an activation copy (not a symlink) so dash can keep
# rewriting its own config file.
{ lib, pkgs, ... }:

{
  home.activation.copyGhDashConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config/gh-dash
    run cp -f ${../../../home/.config/gh-dash/config.yml} $HOME/.config/gh-dash/config.yml
    run chmod u+w $HOME/.config/gh-dash/config.yml
  '';

  xdg.dataFile."gh/extensions/gh-dash/gh-dash".source = "${
    pkgs.callPackage ../../../pkgs/gh-dash/default.nix { }
  }/bin/gh-dash";
}
