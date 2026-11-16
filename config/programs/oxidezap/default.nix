# OxideZap — unofficial native WhatsApp client (prebuilt nightly, pinned in
# pkgs/oxidezap). GPUI window + session daemon; pairing happens on first
# launch (QR from the phone), unlinkable anytime from Linked devices.
{ lib, pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../../pkgs/oxidezap/default.nix { })
  ];
}
