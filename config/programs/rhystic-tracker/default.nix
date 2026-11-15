# Rhystic Tracker — MTG Arena match tracker (prebuilt Tauri bin-package).
# Linux-only: excluded from darwinHomeManagerModules, so nadir never
# imports this module (auto-discovery only feeds zenith's module list).
{ pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../../pkgs/rhystic-tracker/default.nix { })
  ];
}
