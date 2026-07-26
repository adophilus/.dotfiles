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
      pkgs-unstable.gopass-jsonapi
    ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.firefoxpwa # Linux-only (not on x86_64-darwin)
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

      # Declarative essentials — pinned tabs in Zen's Essentials sidebar.
      # ⚠ Close Zen before rebuild (activation needs exclusive access to
      # zen-sessions.jsonlz4). Omit pinsForceAction to keep existing pins
      # as normal tabs; set to "remove" to delete undeclared pins.
      pins = {
        "Gmail" = {
          id = "c174dca4-e48c-43f2-a7ec-09cfc34c566b";
          url = "https://mail.google.com";
          position = 101;
          isEssential = true;
        };
        "Discord" = {
          id = "4f655856-378f-4694-9633-f15207eb0edf";
          url = "https://discord.com/app";
          position = 102;
          isEssential = true;
        };
        "keybr" = {
          id = "4747adea-8354-471e-8f58-415ff5ca3f4b";
          url = "https://www.keybr.com";
          position = 103;
          isEssential = true;
        };
        "X" = {
          id = "567b2f3c-ea78-4ad6-93b7-a85a8bc29db8";
          url = "https://x.com";
          position = 104;
          isEssential = true;
        };
        "LinkedIn" = {
          id = "cb1ec737-39dd-45cf-aa07-721436cbac71";
          url = "https://www.linkedin.com";
          position = 105;
          isEssential = true;
        };
        "Super Productivity" = {
          id = "e6a47b03-c431-4a58-9228-cf80af35b162";
          url = "https://app.super-productivity.com";
          position = 106;
          isEssential = true;
        };
      };
      pinsForce = true;
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
        {
          slug = "react-devtools";
          guid = "@react-devtools";
        }
      ];
    };
  };
}
