{
  config,
  pkgs,
  lib,
  inputs,
  pkgs-unstable,
  end4dots,
  wifitui,
  ...
}:
{
  imports = [
    # inputs.zen-browser.homeModules.beta
    inputs.zen-browser.homeModules.twilight
    # inputs.zen-browser.homeModules.twilight-official
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "adophilus";
  home.homeDirectory = "/home/adophilus";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

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
        # "vscode-fhs"
        "discord"
        "obsidian"
        "osu-lazer"
      ];

    # permittedInsecurePackages = [ "beekeeper-studio-5.1.5" ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs-unstable; [
    # Social media
    # zapzap
    # telegram-desktop
    # nchat

    pavucontrol
    qpwgraph

    tree

    activitywatch

    # osu-lazer

    # Video drivers
    # xorg.xf86videointel
    intel-media-driver
    libva
    libva-utils
    # vaapiVdpau
    libva-vdpau-driver

    # pulseaudioFull

    # blender
    # gtypist

    # PDF readers
    zathura

    # Email clients
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
    # wireshark
    stunnel
    socat
    wget
    inetutils
    curlFull

    # Java
    openjdk
    maven

    # lua
    lua
    lua51Packages.luarocks
    lua-language-server

    waybar

    # AI
    ollama
    # aider-chat

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

    # google
    google-cloud-sdk

    # rust
    cargo
    rustc

    acpi

    # API clients
    # postman
    # bruno
    # httpie-desktop

    # sqlite
    # turso-cli
    # sqld
    sqlite

    # IPFS
    # kubo

    jq
    gnumake
    # beekeeper-studio
    fzf
    direnv
    openssl
    # solc
    # libsForQt5.qt5ct
    # qt6.full

    # VNC
    # wayvnc
    # realvnc-vnc-viewer

    # python
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

    # Graphics apps
    # gimp
    obs-studio
    # openshot-qt
    shotcut
    imagemagick

    # Networking
    blueman
    wifitui.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Torrent
    deluge

    # wireplumber
    # dunst
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
    gtk3
    # (import (fetchTarball "channel:nixos-23.11") { }).fcitx5
    fcitx5

    # Video players
    mpv
    vlc
    # libvlc
    d2

    # Android
    android-tools
    nwg-look

    obsidian
    grim

    # Code editors
    # vscode
    # zed-editor-fhs
    code-cursor-fhs
    # windsurf
    # antigravity-fhs
    vscode-fhs

    # Dev tools
    gh
    flyctl

    # Drives
    udiskie

    # Browser
    tor-browser
    vivaldi
    vivaldi-ffmpeg-codecs
    firefox
    google-chrome
    mullvad-browser

    # Password management
    gopass
    gopass-jsonapi
    # gnupg

    mdbook
    ags

    # Music
    pkgs.spotifywm
    pkgs.sayonara
    # spotdl

    # Arduino
    # arduino-ide

    # Clipboard
    cliphist
    slurp
    tesseract
    swappy

    # Wayland
    wl-clipboard
    waypaper
    wlogout

    # Hyprland
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

    # Nodejs
    biome
    deno
    nodejs
    bun
    nodePackages.pnpm
    nodePackages.yarn

    # Go
    go
    air

    # top variants
    bottom
    powertop
    btop

    # Disk analysis
    gdu

    gjs
    wayshot
    foot

    # Networking
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
    # zellij

    # File manager
    yazi

    # Calculator
    libqalculate

    # Discord
    discord

    # Git
    gitoxide
    git-lfs
    gitui
    lazygit

    fuzzel
    brightnessctl
    wofi
    rofi

    # Documentation
    tldr
    zeal

    # archive
    zip
    unzip

    # zig
    zig

    penpot-desktop
    figma-linux

    rustscan

    file
    rclone
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/bottom".source = ./.config/bottom;
    # ".config/nvim".source = ./.config/nvim;
    # ".config/fish".source = ./.config/fish;
    ".config/kitty".source = ./.config/kitty;
    # ".config/tmux".source = ./.config/tmux;
    ".config/tmuxinator".source = ./.config/tmuxinator;
    # ".config/waybar".source = ./.config/waybar;
    ".config/zellij".source = ./.config/zellij;
    ".config/ghostty".source = ./.config/ghostty;

    ".config/ags".source = "${end4dots}/.config/ags";
    ".config/anyrun".source = "${end4dots}/.config/anyrun";
    # ".config/fontconfig".source = "${end4dots}/.config/fontconfig";
    ".config/foot".source = "${end4dots}/.config/foot";
    ".config/fuzzel".source = "${end4dots}/.config/fuzzel";
    # ".config/mpv".source = "${end4dots}/.config/mpv";
    ".config/qt5ct".source = "${end4dots}/.config/qt5ct";
    # ".config/wlogout".source = "${end4dots}/.config/wlogout";
    ".config/zshrc.d".source = "${end4dots}/.config/zshrc.d";
    ".config/chrome-flags.conf".source = "${end4dots}/.config/chrome-flags.conf";
    # ".config/code-flags.conf".source = "${end4dots}/.config/code-flags.conf";
    # ".config/starship.toml".source = "${end4dots}/.config/starship.toml";
    # ".config/thorium-flags.conf".source =
    #   "${end4dots}/.config/thorium-flags.conf";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/adophilus/etc/profile.d/hm-session-vars.sh
  #
  # home.sessionVariables = { EDITOR = "nvim"; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    package = pkgs.neovim-unwrapped;
  };

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

      # mods = [
      #   "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
      #   "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
      #   "c6813222-6571-4ba6-8faf-58f3343324f6" # Disable Rounded Corners
      #   "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      #   "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
      #   "cb15abdb-0514-4e09-8ce5-722cf1f4a20f" # Hide Extension Name
      #   "803c7895-b39b-458e-84f8-a521f4d7a064" # Hide Inactive Workspaces
      #   "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
      #   "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
      #   "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
      # ];
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

  programs.git = {
    enable = true;
    userName = "Adophilus";
    userEmail = "uchenna19of@gmail.com";
    package = pkgs-unstable.git;
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./.config/fish/config.fish;
  };

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   systemd = {
  #     enable = true;
  #     variables = [ "--all" ];
  #   };
  #   # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   # extraConfig = builtins.readFile ./hypr/hyprland.conf;
  # };

  # programs.voxtype = {
  #   enable = true;
  #   # 'vulkan' is the safest bet for graphics acceleration on NixOS
  #   package = voxtype.packages.${pkgs.system}.vulkan;
  #
  #   # This downloads the AI model automatically
  #   # model.name = "base.en";
  #   # model.name = "large-v3";
  #   # model.name = "tiny";
  #   model.path =
  #     # "/home/adophilus/.local/share/voxtype/models/ggml-large-v3.bin";
  #     "/home/adophilus/.local/share/voxtype/models/ggml-small.en.bin";
  #
  #   # service.enable = true; # Starts the background listener
  #
  #   settings = {
  #     hotkey = {
  #       enabled = false; # Use compositor keybindings
  #       # key = "SCROLLLOCK";
  #     };
  #
  #     whisper = { language = "en"; };
  #     output = {
  #       # mode = "type"; # It will "type" the words into your active window
  #       mode = "clipboard";
  #       notification = {
  #         on_recording_start = false; # Notify when PTT activates
  #         on_recording_stop = false; # Notify when transcribing
  #         on_transcription = true; # Show transcribed text
  #       };
  #     };
  #
  #     audio = {
  #       # Audio input device ("default" uses system default)
  #       # List devices with: pactl list sources short
  #       device = "default";
  #
  #       # Sample rate in Hz (whisper expects 16000)
  #       sample_rate = 16000;
  #
  #       # Maximum recording duration in seconds (safety limit)
  #       max_duration_secs = 60;
  #     };
  #   };
  # };

  xdg.desktopEntries.scrcpy = {
    name = "scrcpy";
    genericName = "Android Remote Control";
    # This fixes your rendering issue and avoids the messy /bin/sh shell wrap
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

  services.activitywatch = {
    enable = true;
    # Use the Wayland-native watcher instead of the default X11 ones
    watchers = {
      aw-watcher-window.package = pkgs-unstable.awatcher;
      aw-watcher-afk.package = pkgs-unstable.awatcher;
    };
  };

  services.swayosd.enable = true;
  services.hypridle.enable = true;
}
