{ config, pkgs, lib, inputs, pkgs-unstable, end4dots, wifitui, ... }:

{
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
    allowUnfreePredicate = pkg:
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
    zapzap
    telegram-desktop
    nchat

    pavucontrol
    qpwgraph

    tree

    osu-lazer

    # Video drivers
    # xorg.xf86videointel
    intel-media-driver
    libva
    libva-utils
    # vaapiVdpau
    libva-vdpau-driver

    # blender
    gtypist

    # PDF readers
    zathura

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

    waybar

    # AI
    ollama
    aider-chat

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

    # openapi
    postman
    bruno

    # sqlite
    turso-cli
    sqld
    sqlite

    kubo
    jq
    gnumake
    # beekeeper-studio
    fzf
    lua-language-server
    direnv
    openssl
    solc
    # libsForQt5.qt5ct
    # qt6.full

    # VNC
    wayvnc
    realvnc-vnc-viewer

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
    # php82Packages.composer
    # php82Packages.phpstan
    php82Extensions.mbstring
    php82Extensions.iconv

    # Crypto
    monero-gui
    electrum

    # Graphics apps
    gimp
    obs-studio
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
    vscode
    zed-editor-fhs
    code-cursor
    windsurf
    antigravity-fhs

    # vscode-fhs
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
    # gnupg

    mdbook
    ags

    # Music
    pkgs.spotifywm
    # spotdl

    # Arduino
    arduino-ide

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

    httpie-desktop

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

    ripgrep
    bottom
    gjs
    wayshot
    foot

    # Terminal
    kitty
    ghostty
    starship
    zellij

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

    # Video editing
    # openshot-qt

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
    ".config/mpv".source = "${end4dots}/.config/mpv";
    ".config/qt5ct".source = "${end4dots}/.config/qt5ct";
    # ".config/wlogout".source = "${end4dots}/.config/wlogout";
    ".config/zshrc.d".source = "${end4dots}/.config/zshrc.d";
    ".config/chrome-flags.conf".source =
      "${end4dots}/.config/chrome-flags.conf";
    ".config/code-flags.conf".source = "${end4dots}/.config/code-flags.conf";
    # ".config/starship.toml".source = "${end4dots}/.config/starship.toml";
    ".config/thorium-flags.conf".source =
      "${end4dots}/.config/thorium-flags.conf";
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

  services.swayosd.enable = true;
  services.hypridle.enable = true;
}
