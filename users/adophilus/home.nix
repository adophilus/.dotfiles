{ config, pkgs, lib, ... }:

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
      "zoom"
      "code"
      "vscode"
      # "vscode-fhs"
      "discord"
      "obsidian"
    ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    package =
      (import (fetchTarball "channel:nixos-unstable") { }).neovim-unwrapped;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nyancat
    zapzap
    tree

    xorg.xf86videointel
    intel-media-driver

    blender
    gtypist
    zathura
    scrcpy

    # Nix stuff
    nixfmt-classic
    manix

    biome
    sbt

    # wireshark
    stunnel
    socat

    # xdg-desktop-portal-wlr
    wget

    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    # xdg-desktop-portal-wlr
    # xdg-desktop-portal-gtk
    waybar

    # neovim
    # (import (fetchTarball "channel:nixos-unstable") {}).neovim
    maven

    # AI stuff
    # ollama
    (import (fetchTarball "channel:nixos-unstable") { }).ollama
    (import (fetchTarball "channel:nixos-unstable") { }).aider-chat

    # Tmux stuff
    # tmux
    (import (fetchTarball "channel:nixos-unstable") { }).tmux
    tmuxinator

    sshfs

    vim

    deno

    appimage-run

    google-cloud-sdk

    rust-analyzer
    cargo-watch
    cargo
    rustc

    acpi

    postman
    bruno

    jq
    kubo
    inetutils
    gnumake
    beekeeper-studio

    tor
    tor-browser

    turso-cli
    sqld
    sqlite
    neovide
    fzf
    lua-language-server
    direnv
    openssl
    solc
    zoom-us
    libva
    libva-utils
    vaapiVdpau
    curlFull
    firefox
    obs-studio
    libsForQt5.qt5ct
    qt6.full
    # openshot-qt
    shotcut
    wayvnc
    python311Packages.pyftpdlib
    poetry
    python311Packages.pip
    ffmpeg
    php
    php82Packages.composer
    php82Packages.phpstan
    php82Extensions.mbstring
    php82Extensions.iconv
    gimp
    mailhog
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
    (import (fetchTarball "channel:nixos-23.11") { }).fcitx5
    # fcitx5
    nchat
    ntfs3g
    mpv
    vlc
    # libvlc
    nodePackages.pnpm
    nodePackages.yarn
    d2
    android-tools
    hypridle
    hyprcursor
    nwg-look
    swappy
    hyprpicker
    obsidian
    grim
    vscode
    # vscode-fhs
    gh
    flyctl
    firefox
    google-chrome
    mdbook
    openjdk
    hyprpaper
    hyprlock
    spotifywm
    webcord
    air
    ags
    cliphist
    slurp
    wl-clipboard

    # bun
    (import (fetchTarball "channel:nixos-unstable") { }).bun

    anyrun
    gitoxide
    dive
    podman-tui
    podman-compose
    go
    nodejs
    python3
    ripgrep
    bottom
    lazygit
    gitui
    zellij
    fish
    gjs
    wayshot
    foot
    kitty
    starship
    vivaldi
    vivaldi-ffmpeg-codecs
    # nixosStable.vivaldi
    # nixosStable.vivaldi-ffmpeg-codecs
    discord
    git
    git-lfs
    fuzzel
    brightnessctl
    wofi
    zip
    unzip
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
  home.sessionVariables = { EDITOR = "nvim"; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
