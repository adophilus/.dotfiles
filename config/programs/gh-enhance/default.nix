# gh-enhance — gh-dash companion for managing PR GitHub Actions.
# Binary-only module: release binary linked into gh's extensions dir —
# see the gh-dash module for the mechanism notes (gh-<name>/gh-<name>
# layout; gh ignores PATH).
{ pkgs, ... }:

{
  xdg.dataFile."gh/extensions/gh-enhance/gh-enhance".source = "${
    pkgs.callPackage ../../../pkgs/gh-enhance/default.nix { }
  }/bin/gh-enhance";
}
