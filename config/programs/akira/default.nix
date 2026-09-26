# Akira — native GTK3/Vala design tool (pre-alpha, curiosity-driven).
# Linux-only: excluded from darwinHomeManagerModules, so nadir never
# imports this module (auto-discovery only feeds zenith's module list).
{ lib, pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../../pkgs/akira/default.nix { })
  ];
}
