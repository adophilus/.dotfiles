{
  pkgs,
  pkgs-unstable,
  ...
}:
let
  mkPluginUrl = slug: "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  mkExtensionEntry =
    {
      guid,
      slug,
      pinned ? false,
    }:
    let
      base = {
        install_url = mkPluginUrl slug;
        installation_mode = "force_installed";
      };
    in
    if pinned then
      {
        "${guid}" = base // {
          default_area = "navbar";
        };
      }
    else
      { "${guid}" = base; };
  mkExtensionSettings = builtins.foldl' (acc: entry: acc // mkExtensionEntry entry) { };
in
{
  programs.zen-browser = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.firefoxpwa
      pkgs-unstable.gopass-jsonapi
    ];

    profiles.default = {
      settings = {
        "zen.workspaces.continue-where-left-off" = true;
        "zen.workspaces.natural-scroll" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.view.compact.hide-toolbar" = true;
        "zen.view.compact.animate-sidebar" = false;
        "zen.welcome-screen.seen" = true;
        "zen.urlbar.behavior" = "float";

        # ── Hardware video decode (VA-API) for calls/meet ──
        # iGPU = Intel UHD 620 (Kaby Lake-R), iHD driver. Supports H.264,
        # HEVC, VP8, VP9 decode in hardware (verified via `vainfo`).
        # Without these, WebRTC video is software-decoded on the CPU.
        "media.ffmpeg.vaapi.enabled" = true; # master VA-API switch
        "media.hardware-video-decoding.force-enabled" = true; # bypass blocklist
        "media.ffmpeg.low-latency.enabled" = true; # KEY for WebRTC VA-API
        "media.rdd-process.enabled" = true; # RDD is where VA-API decode runs
        "gfx.webrender.all" = true; # HW WebRender required or VA-API is silently disabled
        "media.av1.enabled" = false; # UHD 620 has no AV1 decode → would hit CPU
      };

      mods = [
        "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
      ];
    };

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      ExtensionSettings = mkExtensionSettings [
        {
          slug = "proton-pass";
          guid = "78272b6fa58f4a1abaac99321d503a20@proton.me";
          pinned = true;
        }
        {
          slug = "markdown-viewer";
          guid = "markdown-viewer@outofindex.com";
        }
      ];
    };
  };
}
