{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  end4dots,
  wifitui,
  gws,
  ...
}:

let
  # Auto-discover all program modules under config/programs/.
  # Each subdirectory with a default.nix is imported automatically.
  # To add a new program config: create config/programs/<name>/default.nix
  programsDir = ./config/programs;
  dirContents = builtins.readDir programsDir;
  moduleDirs = builtins.filter
    (name: dirContents.${name} == "directory")
    (builtins.attrNames dirContents);
  moduleImports = map (name: programsDir + "/${name}") moduleDirs;
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ] ++ moduleImports;

  # ── Identity ──────────────────────────────────────────────────────────
  home.username = "adophilus";
  home.homeDirectory = "/home/adophilus";
  home.stateVersion = "24.05";

  # ── Package allowlist ─────────────────────────────────────────────────
  nixpkgs.config = {
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
        "vesktop"
        "obsidian"
        "osu-lazer"
      ];
  };

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = with pkgs-unstable; [
    pavucontrol
    qpwgraph
    tree
    activitywatch

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
    lua51Packages.luarocks
    lua-language-server

    waybar

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
    python310
    python310Packages.pyftpdlib
    python310Packages.pip
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

    # Discord (Vesktop = Vencord Desktop, supports CSS themes)
    vesktop

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
    swww
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
  ];

  # ── Config file symlinks (nix store, read-only) ───────────────────────
  # For configs managed by activation scripts (copy from nix store),
  # see config/programs/*/default.nix
  home.file = {
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
  services.activitywatch = {
    enable = true;
    watchers = {
      aw-watcher-window.package = pkgs-unstable.awatcher;
      aw-watcher-afk.package = pkgs-unstable.awatcher;
    };
  };

  services.swayosd = {
    enable = true;
    topMargin = 0.9;
    stylePath = "${config.home.homeDirectory}/.config/swayosd/style.css";
  };
  # services.hypridle is managed in config/programs/hypridle/default.nix
}
