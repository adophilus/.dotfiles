{ config, pkgs, lib, inputs, pkgs-unstable, end4dots, ... }:

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

  nixpkgs.config.allowUnfreePredicate = pkg:
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
    ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs-unstable; [
    # Social media
    zapzap

    tree

    fish

    # Video drivers
    # xorg.xf86videointel
    intel-media-driver
    libva
    libva-utils
    vaapiVdpau

    # blender
    gtypist

    # PDF readers
    zathura

    # ADB tools
    scrcpy

    # Nix
    nixfmt-classic
    manix

    # Scala
    sbt

    # Networking
    # wireshark
    stunnel
    socat
    wget
    inetutils
    curlFull

    # xdg-desktop-portal-wlr
    # xdg-desktop-portal
    # xdg-desktop-portal-hyprland
    # xdg-desktop-portal-wlr
    # xdg-desktop-portal-gtk

    # Java
    maven

    # lua
    lua
    lua51Packages.luarocks

    waybar

    # AI
    ollama
    aider-chat

    # tmux
    tmux
    tmuxinator

    neovide
    vim
    sshfs

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
    beekeeper-studio
    fzf
    lua-language-server
    direnv
    openssl
    solc
    libsForQt5.qt5ct
    qt6.full

    # wayvnc
    pkgs.wayvnc

    # python
    python3
    python311Packages.pyftpdlib
    poetry
    python311Packages.pip
    ffmpeg
    mitmproxy

    # PHP
    php
    # php82Packages.composer
    # php82Packages.phpstan
    php82Extensions.mbstring
    php82Extensions.iconv

    # graphics apps
    gimp
    obs-studio
    shotcut

    # torrent
    deluge

    wireplumber
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

    # video players
    mpv
    vlc
    # libvlc
    d2

    # android
    android-tools
    nwg-look
    swappy

    obsidian
    grim

    # code editor
    vscode
    # vscode-fhs
    gh
    flyctl

    # Browser
    # tor
    tor-browser
    vivaldi
    vivaldi-ffmpeg-codecs
    firefox
    google-chrome

    mdbook
    openjdk
    spotifywm
    webcord
    air
    ags

    # Clipboard
    cliphist
    slurp

    # Wayland
    wl-clipboard

    # Hyprland
    hypridle
    hyprcursor
    hyprpaper
    hyprlock
    hyprpicker

    # Containers
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

    openshot-qt

    anyrun
    gitoxide
    dive
    ripgrep
    bottom
    lazygit
    gitui
    zellij
    gjs
    wayshot
    foot
    kitty
    starship
    discord
    git-lfs
    fuzzel
    brightnessctl
    wofi

    # Documentation
    tldr

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
    ".config/nvim".source = ./.config/nvim;
    ".config/fish".source = ./.config/fish;
    ".config/kitty".source = ./.config/kitty;
    ".config/tmux".source = ./.config/tmux;
    ".config/tmuxinator".source = ./.config/tmuxinator;
    ".config/waybar".source = ./.config/waybar;
    ".config/zellij".source = ./.config/zellij;

    ".config/ags".source = "${end4dots}/.config/ags";
    ".config/anyrun".source = "${end4dots}/.config/anyrun";
    # ".config/fontconfig".source = "${end4dots}/.config/fontconfig";
    ".config/foot".source = "${end4dots}/.config/foot";
    ".config/fuzzel".source = "${end4dots}/.config/fuzzel";
    ".config/mpv".source = "${end4dots}/.config/mpv";
    ".config/qt5ct".source = "${end4dots}/.config/qt5ct";
    ".config/wlogout".source = "${end4dots}/.config/wlogout";
    ".config/zshrc.d".source = "${end4dots}/.config/zshrc.d";
    ".config/chrome-flags.conf".source = "${end4dots}/.config/chrome-flags.conf";
    ".config/code-flags.conf".source = "${end4dots}/.config/code-flags.conf";
    ".config/starship.conf".source = "${end4dots}/.config/starship.conf";
    ".config/thorium-flags.conf".source = "${end4dots}/.config/thorium-flags.conf";
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
    # vimdiffAlias = true;
    package = pkgs-unstable.neovim-unwrapped;
  };

  programs.git = {
    enable = true;
    userName = "Adophilus";
    userEmail = "uchenna19of@gmail.com";
    package = pkgs-unstable.git;
  };

  # programs.fish = {
  #   enable = true;
  #   # shellInit = builtins.readFile ./fish/config.fish;
  # };

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   extraConfig = builtins.readFile ./hypr/hyprland.conf;
  # };
}
