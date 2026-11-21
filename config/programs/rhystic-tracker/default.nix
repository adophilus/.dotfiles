# Rhystic Tracker — MTG Arena match tracker (prebuilt Tauri bin-package).
# Imported on zenith (linux auto-discovery) and nadir (darwinHomeManagerModules).
# Each branch is a no-op on the other platform:
#   linux — the package's bin/ + .desktop land in PATH and app menus.
#   darwin — no .desktop concept here; link the .app into ~/Applications.
#     Spotlight can't index symlinked .apps (mdworker doesn't follow
#     symlinks into the store — see darwin-configuration.nix cask notes),
#     but Raycast resolves symlinks, so it stays launchable.
{ pkgs, lib, ... }:

let
  rhystic-tracker = pkgs.callPackage ../../../pkgs/rhystic-tracker/default.nix { };
in
{
  home.packages = lib.optionals pkgs.stdenv.isLinux [ rhystic-tracker ];

  home.file."Applications/Rhystic Tracker.app" = lib.mkIf pkgs.stdenv.isDarwin {
    source = "${rhystic-tracker}/Applications/Rhystic Tracker.app";
  };
}
