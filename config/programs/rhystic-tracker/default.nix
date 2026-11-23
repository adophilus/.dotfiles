# Rhystic Tracker — MTG Arena match tracker (prebuilt Tauri bin-package).
# Darwin-only. zenith's linux auto-discovery imports this module too, but no
# linux branch references the let-bound callPackage, so the derivation is
# never forced and stays out of zenith's closure. The linux artifact in
# pkgs/rhystic-tracker is broken anyway (installPhase can't find the binary
# in the linux tarball) — fix that first if linux support is ever wanted.
#
# Darwin install: link the .app into ~/Applications. Spotlight can't index
# symlinked .apps (mdworker doesn't follow symlinks into the store — see
# darwin-configuration.nix cask notes), but Raycast resolves symlinks, so
# it stays launchable.
{ pkgs, lib, ... }:

let
  rhystic-tracker = pkgs.callPackage ../../../pkgs/rhystic-tracker/default.nix { };
in
{
  home.file."Applications/Rhystic Tracker.app" = lib.mkIf pkgs.stdenv.isDarwin {
    source = "${rhystic-tracker}/Applications/Rhystic Tracker.app";
  };
}
