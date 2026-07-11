{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  end4dots,
  wifitui,
  gws,
  wstui-pkg,
  floci-pkg,
  ...
}:

let
  # Auto-discover all program modules under config/programs/.
  # Each subdirectory with a default.nix is imported automatically.
  # To add a new program config: create config/programs/<name>/default.nix
  programsDir = ./config/programs;
  dirContents = builtins.readDir programsDir;
  moduleDirs = builtins.filter (name: dirContents.${name} == "directory") (
    builtins.attrNames dirContents
  );
  moduleImports = map (name: programsDir + "/${name}") moduleDirs;

  # Legcord with VA-API hardware video decode enabled.
  # nixpkgs' legcord doesn't expose commandLineArgs (its Electron flags are
  # hardcoded in installPhase), so we re-wrap via symlinkJoin to add the
  # Chromium VA-API video decode feature. Electron 38 (≈ Chromium 142) still
  # needs this explicitly; Chromium 143+ will enable it by default.
  legcord-vapi = pkgs-unstable.symlinkJoin {
    name = "legcord";
    paths = [ pkgs-unstable.legcord ];
    buildInputs = [ pkgs-unstable.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/legcord" \
        --add-flags "--enable-features=AcceleratedVideoDecodeLinuxGL"
    '';
  };

  # floci-ui: clone the repo and run the compose stack via podman-compose
  floci-ui = pkgs.writeShellScriptBin "floci-ui" ''
    set -e
    DIR="''${FLOCI_UI_DIR:-$HOME/.local/share/floci-ui}"
    [ -d "$DIR/.git" ] || git clone --depth 1 https://github.com/floci-io/floci-ui.git "$DIR"
    cd "$DIR" || exit 1
    if [ $# -eq 0 ]; then
      exec podman-compose up
    else
      exec podman-compose "$@"
    fi
  '';
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ moduleImports;

  # ── Identity ──────────────────────────────────────────────────────────
  home.username = "adophilus";
  home.homeDirectory = "/home/adophilus";
  home.stateVersion = "24.05";

  # ── Package allowlist ─────────────────────────────────────────────────
  nixpkgs.config = {
    permittedInsecurePackages = [
      "electron-37.10.3"
    ];
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "vivaldi"
        "postman"
        "spotify"
        "google-chrome"
        "code"
        "vscode"
        "discord"
        "legcord"
        "obsidian"
        "osu-lazer"
      ];
  };

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = with pkgs-unstable; [
    pavucontrol
    qpwgraph
    tree

    tigervnc

    # Video drivers
    intel-media-driver
    libva
    libva-utils
    libva-vdpau-driver

    # PDF readers
    zathura

    # Email
    thunderbird

    # Finances
    gnucash

    just
    posting

    # Notes
    inputs.zennotes.packages.x86_64-linux.zennotes-desktop
    dos2unix
    cloudflared

    # ADB tools
    scrcpy
    adbfs-rootless

    # Nix
    nixfmt
    manix

    # Timers
    termdown

    # Networking
    stunnel
    socat
    wget
    inetutils
    curlFull

    # Java
    openjdk
    maven

    # Lua
    lua
    luaPackages.luarocks
    lua-language-server

    # Tmux
    tmux
    tmuxinator

    # Vim
    neovide
    vim

    sshfs

    # Interop
    anyrun
    appimage-run

    # Google
    google-cloud-sdk
    gws.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Rust
    cargo
    rustc

    acpi

    sqlite

    jq
    gnumake
    fzf
    direnv
    openssl

    # Python
    python3
    python3Packages.pyftpdlib
    python3Packages.pip
    poetry
    ffmpeg
    mitmproxy
    uv

    # PHP
    php
    php82Packages.composer
    php82Extensions.mbstring
    php82Extensions.iconv

    # Crypto
    monero-gui
    electrum

    # Graphics
    obs-studio
    shotcut
    imagemagick

    # Networking
    wifitui.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Torrent
    deluge

    # Notifications
    swaynotificationcenter
    libnotify
    webp-pixbuf-loader
    gtk-layer-shell
    gtk3
    gtksourceview3
    gobject-introspection
    upower
    yad
    ydotool
    libdbusmenu-gtk3

    # Video players
    pkgs.mpv
    vlc
    d2

    # Android
    android-tools
    nwg-look

    obsidian
    grim

    # Code editors
    code-cursor-fhs
    vscode-fhs

    # Dev tools
    gh
    flyctl
    gcc # C/C++ toolchain (provides cc/gcc/g++); needed for node-gyp native builds

    # Drives
    udiskie

    # Browsers
    tor-browser
    vivaldi
    vivaldi-ffmpeg-codecs
    firefox
    google-chrome
    mullvad-browser

    # Password management
    gopass
    gopass-jsonapi

    mdbook
    ags

    # Music
    pkgs.spotifywm
    pkgs.sayonara

    # Clipboard
    cliphist
    slurp
    tesseract
    grimblast

    # Wayland
    wl-clipboard
    waypaper
    wlogout

    # Hyprland ecosystem
    hypridle
    hyprcursor
    hyprpaper
    hyprsome
    pkgs.hyprlock
    hyprpicker
    hyprsunset
    hyprshade

    # Containers
    dive
    podman-tui
    podman-compose

    # Node.js
    biome
    deno
    nodejs
    pnpm
    bun

    # Go
    go
    air

    # Discord TUI client
    discordo

    # System monitors
    bottom
    powertop
    btop

    # Disk analysis
    gdu

    gjs
    wayshot
    foot

    # Networking tools
    dig
    unixtools.netstat
    unixtools.route

    ltrace
    ripgrep
    tokei
    torsocks

    # Terminal
    kitty
    ghostty
    starship

    # File manager
    yazi

    # Calculator
    libqalculate

    # Discord (Legcord — lightweight moddable client, wrapped with VA-API)
    legcord-vapi

    # WhatsApp (native GTK4 client)
    karere

    # WhatsApp (terminal client with vim motions)
    wstui-pkg

    # Git
    gitoxide
    git-lfs
    gitui
    lazygit

    # Launchers
    fuzzel
    brightnessctl
    wofi
    rofi

    # Documentation
    tldr
    zeal

    # Archive
    zip
    unzip

    # Zig
    zig

    penpot-desktop
    figma-linux

    rustscan

    file
    rclone

    # Playwright
    playwright-driver.browsers

    gnome-network-displays

    # Quickshell desktop shell
    quickshell
    qt6.qtmultimedia
    qt6.qtdeclarative
    awww
    gpu-screen-recorder
    satty
    zbar
    pamixer
    inotify-tools
    playerctl
    cava
    mpvpaper
    easyeffects

    usbutils

    # Floci — local cloud emulator for AWS/Azure
    floci-pkg
    floci-ui

    # AWS
    awscli2

    # Notes / annotation
    xournalpp

    # Productivity
    super-productivity

    # Process manager
    process-compose
  ];

  # ── Config file symlinks (nix store, read-only) ───────────────────────
  # For configs managed by activation scripts (copy from nix store),
  # see config/programs/*/default.nix
  home.file = {
    # Scripts
    ".local/bin/ytd" = {
      source = ./.local/bin/ytd;
      executable = true;
    };

    ".config/bottom".source = ./.config/bottom;
    ".config/kitty".source = ./.config/kitty;
    ".config/tmuxinator".source = ./.config/tmuxinator;
    ".config/zellij".source = ./.config/zellij;
    ".config/ghostty".source = ./.config/ghostty;

    # end-4/dots-hyprland configs (pinned flake input)
    ".config/ags".source = "${end4dots}/.config/ags";
    ".config/anyrun".source = "${end4dots}/.config/anyrun";
    ".config/foot".source = "${end4dots}/.config/foot";
    ".config/fuzzel".source = "${end4dots}/.config/fuzzel";
    ".config/qt5ct".source = "${end4dots}/.config/qt5ct";
    ".config/zshrc.d".source = "${end4dots}/.config/zshrc.d";
    ".config/chrome-flags.conf".source = "${end4dots}/.config/chrome-flags.conf";
  };

  # ── Session variables ─────────────────────────────────────────────────
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs-unstable.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
    PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
    # STARSHIP_CONFIG is set in config/programs/starship/default.nix
  };

  # ── Home Manager self-management ──────────────────────────────────────
  programs.home-manager.enable = true;

  # ── Zen Browser ───────────────────────────────────────────────────────
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
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Adophilus";
    userEmail = "uchenna19of@gmail.com";
    package = pkgs-unstable.git;
  };

  # ── Fish shell ────────────────────────────────────────────────────────
  # Uses builtins.readFile so fish can freely write fish_variables at runtime.
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./.config/fish/config.fish;
  };

  # ── Desktop entries ───────────────────────────────────────────────────
  xdg.desktopEntries.scrcpy = {
    name = "scrcpy";
    genericName = "Android Remote Control";
    exec = "scrcpy --render-driver=opengles2";
    icon = "scrcpy";
    terminal = false;
    categories = [
      "Utility"
      "RemoteAccess"
    ];
    settings = {
      StartupNotify = "false";
    };
  };

  # ── Services ──────────────────────────────────────────────────────────
  services.swayosd = {
    enable = true;
    topMargin = 0.9;
    stylePath = "${config.home.homeDirectory}/.config/swayosd/style.css";
  };
  # services.hypridle is managed in config/programs/hypridle/default.nix

  sops = {
    # age.keyFile = "/home/adophilus/.age-key.txt";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets.adophilus = {
      sopsFile = ./secrets/adophilus/.env;
      format = "dotenv";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = [ ];

    defaultApplications = {
      "text/html" = "zen-twilight.desktop";
      "x-scheme-handler/http" = "zen-twilight.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop";
      "x-scheme-handler/about" = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "zen-twilight.desktop";
      "application/x-extension-htm" = "zen-twilight.desktop";
      "application/x-extension-html" = "zen-twilight.desktop";
      "application/x-extension-shtml" = "zen-twilight.desktop";
      "application/x-extension-xhtml" = "zen-twilight.desktop";
      "application/x-extension-xht" = "zen-twilight.desktop";

      "application/pdf" = "org.pwmt.zathura.desktop";

      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "x-scheme-handler/discord" = "legcord.desktop";
      "x-scheme-handler/discord-1216669957799018608" = "discord-1216669957799018608.desktop";
      "x-scheme-handler/postman" = "Postman.desktop";
      "x-scheme-handler/figma" = "figma-linux.desktop";

      "x-scheme-handler/mailspring" = "Mailspring.desktop";
      "x-scheme-handler/mailto" = "userapp-Thunderbird-A9DVM3.desktop";
      "message/rfc822" = "userapp-Thunderbird-A9DVM3.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-A9DVM3.desktop";
      "x-scheme-handler/news" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/snews" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/nntp" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/feed" = "userapp-Thunderbird-OU2OM3.desktop";
      "application/rss+xml" = "userapp-Thunderbird-OU2OM3.desktop";
      "application/x-extension-rss" = "userapp-Thunderbird-OU2OM3.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-EEW2M3.desktop";
      "text/calendar" = "userapp-Thunderbird-EEW2M3.desktop";
      "application/x-extension-ics" = "userapp-Thunderbird-EEW2M3.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-EEW2M3.desktop";
    };

    associations.added = {
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "x-scheme-handler/mailto" = "userapp-Thunderbird-A9DVM3.desktop";
      "x-scheme-handler/mid" = "userapp-Thunderbird-A9DVM3.desktop";
      "x-scheme-handler/news" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/snews" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/nntp" = "userapp-Thunderbird-CVXNM3.desktop";
      "x-scheme-handler/feed" = "userapp-Thunderbird-OU2OM3.desktop";
      "application/rss+xml" = "userapp-Thunderbird-OU2OM3.desktop";
      "application/x-extension-rss" = "userapp-Thunderbird-OU2OM3.desktop";
      "x-scheme-handler/webcal" = "userapp-Thunderbird-EEW2M3.desktop";
      "x-scheme-handler/webcals" = "userapp-Thunderbird-EEW2M3.desktop";
      "x-scheme-handler/http" = "zen-twilight.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop";
    };
  };

  # Managing hyprland from nixos config
  # wayland.windowManager.hyprland = {
  #     enable = true;
  #     plugins = [ inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors ];
  # };

  systemd.user.services.opencode-vps-tunnel = {
    Unit = {
      Description = "VPS tunnel for OpenCode headless server";
      After = [
        "network-online.target"
        "opencode.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh -N -R $OPENCODE_SERVER_PROXY_PORT:$OPENCODE_SERVER_HOST:$OPENCODE_SERVER_PORT vps";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

}
