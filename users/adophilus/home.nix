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
  ytd-pkg,
  lark-pkg,
  open-design-pkg,
  modules,
  homeDirectory ? "/home/adophilus",
  ...
}:

let
  # Legcord with VA-API hardware video decode enabled.
  # nixpkgs' legcord doesn't expose commandLineArgs (its Electron flags are
  # hardcoded in installPhase), so we re-wrap via symlinkJoin to add the
  # Chromium VA-API video decode feature. Electron 38 (≈ Chromium 142) still
  # needs this explicitly; Chromium 143+ will enable it by default.
  #
  # NOTE: legcord has NO nixpkgs x86_64-darwin build, so on macOS install it
  # via Homebrew (`brew install --cask legcord`) or declare it under
  # homebrew.casks in darwin-configuration.nix. This VA-API wrapper is
  # Linux-only anyway (macOS uses VideoToolbox, not VA-API).
  legcord-vapi = pkgs-unstable.symlinkJoin {
    name = "legcord";
    paths = [ pkgs-unstable.legcord ];
    buildInputs = [ pkgs-unstable.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/legcord" \
        --add-flags "--enable-features=AcceleratedVideoDecodeLinuxGL"
    '';
  };

  # d2 without playwright-driver.browsers (~7.6GB). SVG export only.
  d2-lite = pkgs.d2.overrideAttrs (_: _: { buildInputs = [ ]; });

  # tunnel: reverse SSH tunnel to the VPS via autossh.
  # Multiple simultaneous tunnels via port-based subdomains.
  # Usage: tunnel <remote-port> <local-port>
  tunnel = pkgs.writeShellScriptBin "tunnel" ''
    if [ $# -lt 2 ]; then
      echo "Usage: tunnel <remote-port> <local-port>"
      echo "  tunnel 4098 3000    # localhost:3000 → vps:4098 → https://4098.tunnel.adophilus.com"
      echo "  tunnel 4099 8080    # localhost:8080 → vps:4099 → https://4099.tunnel.adophilus.com"
      exit 1
    fi
    REMOTE_PORT=$1
    LOCAL_PORT=$2
    DOMAIN="$REMOTE_PORT.tunnel.adophilus.com"
    echo -e "\033[1m🔒 SSH Tunnel\033[0m"
    echo -e "   \033[90mlocalhost:\033[0m$LOCAL_PORT \033[90m→ vps:\033[0m$REMOTE_PORT \033[90m→\033[0m https://$DOMAIN"
    echo -e "   \033[90mauto-reconnect:\033[0m enabled   \033[90mCtrl+C to stop\033[0m"
    echo ""
    exec ${pkgs.autossh}/bin/autossh -M 0 -N \
      -o "ExitOnForwardFailure=yes" \
      -R "$REMOTE_PORT:localhost:$LOCAL_PORT" \
      vps
  '';

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

  # with-secrets: run a command with the sops-decrypted .env loaded into its
  # environment. Secrets stay scoped to that one process — not leaked into
  # your interactive shell. Usage: with-secrets opencode   (or any command)
  with-secrets = pkgs.writeShellScriptBin "with-secrets" ''
    SOPS_ENV="${config.sops.secrets."adophilus/env".path}"
    if [ ! -f "$SOPS_ENV" ]; then
      echo "with-secrets: secrets file not found at $SOPS_ENV" >&2
      exit 1
    fi
    set -a  # auto-export vars set by the sourced file
    . "$SOPS_ENV"
    set +a
    exec "$@"
  '';
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ modules;

  # ── Identity ──────────────────────────────────────────────────────────
  home.username = "adophilus";
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.05";

  # nixpkgs.config (allowUnfreePredicate + permittedInsecurePackages) now lives
  # in the system configs (configuration.nix / darwin-configuration.nix) —
  # home-manager uses global pkgs, so it belongs at the system level.

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages =
    # ── Cross-platform packages (Linux + macOS) ──
    # Verified available on x86_64-darwin (Intel Mac). Packages also present in
    # the Linux-only list below dedup cleanly (identical derivations) on Linux.
    (with pkgs-unstable; [
      # Dev basics
      tree
      just
      dos2unix
      wget
      curlFull
      jq
      fzf
      direnv
      openssl
      gnumake
      sqlite
      gh
      gcc
      ripgrep
      tldr
      zip
      unzip
      file
      nixfmt
      manix
      termdown
      cloudflared
      inetutils
      posting
      # mitmproxy  # nixpkgs build fails: msgpack<=1.1.2 required, nixpkgs has 1.2.1. Use: uvx mitmproxy
      mailhog
      autossh
      tunnel

      # Editors / terminals
      tmux
      vim
      kitty

      # Containers (on macOS: podman machine init && podman machine start)
      podman
      podman-compose

      # Languages & toolchains
      lua
      luaPackages.luarocks
      lua-language-server
      deno
      nodejs_22
      pnpm
      bun
      biome
      python3
      uv

      # Git
      gitoxide
      git-lfs
      gitui
      lazygit

      # Shell / prompt / fs / calc
      starship
      yazi
      libqalculate
      sshfs

      # Networking
      stunnel
      socat
      dig
      torsocks
      flyctl
      google-cloud-sdk
      awscli2
      rclone
      rustscan

      # Security / crypto
      age
      sops
      gopass
      gopass-jsonapi
      zbar

      # Media / docs / viewers
      ffmpeg
      imagemagick
      d2-lite
      mdbook
      tesseract
      cava
      pkgs.mpv
      xournalpp
      process-compose
      pkgs.sayonara

      # System monitors / device tools
      bottom
      btop
      gdu
      dive
      scrcpy
      android-tools
      tokei

      # Misc desktop libs
      libnotify
      webp-pixbuf-loader
      gtk3
      discordo

      # Custom — built per-host in flake.nix
      ytd-pkg
      with-secrets
    ])
    # ── Linux-only packages (Hyprland/Wayland, Linux media, containers, …) ──
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs-unstable;
      [
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

        # Lua
        lua
        luaPackages.luarocks
        lua-language-server

        # Tmux
        tmux

        sshfs

        # Interop
        anyrun
        appimage-run

        # Google
        google-cloud-sdk
        gws.packages.${pkgs.stdenv.hostPlatform.system}.default

        acpi

        sqlite

        jq
        gnumake
        fzf
        direnv
        openssl

        # Python
        python3
        ffmpeg
        # mitmproxy

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

        # Android
        android-tools
        nwg-look

        # obsidian  # removed
        grim

        # Code editors
        vscode-fhs

        # Dev tools
        gh
        flyctl
        gcc # C/C++ toolchain (provides cc/gcc/g++); needed for node-gyp native builds

        # Drives
        udiskie

        # Browsers (zen-browser is primary)
        tor-browser
        # firefox  # removed — using zen
        google-chrome
        # mullvad-browser  # commented — using zen

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
        # ghostty  # disabled — using kitty as daily driver
        starship

        # File manager
        yazi

        # Calculator
        libqalculate

        # Discord (Legcord — lightweight moddable client, wrapped with VA-API)
        # legcord-vapi  # removed — using legcord via Homebrew on Mac, evaluating on zenith

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
        # zeal

        # Archive
        zip
        unzip

        # zig  # removed

        # penpot-desktop
        figma-linux

        rustscan

        file
        rclone

        # Playwright
        # playwright-driver.browsers  # removed — massive (~500MB+)

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

        # Lark (work collab) — Linux-only: .deb-based feishu override, no darwin build
        lark-pkg
        # open-design-pkg

        # AWS
        awscli2

        # Notes / annotation
        xournalpp

        # Process manager
        process-compose
      ]
    );

  # ── Config file symlinks (nix store, read-only) ───────────────────────
  # For configs managed by activation scripts (copy from nix store),
  # see config/programs/*/default.nix
  home.file = {
    # Scripts
    # ".local/bin/ytd" = {
    #   source = ../../.local/bin/ytd;
    #   executable = true;
    # };

    ".config/bottom".source = ../../home/.config/bottom;
    ".config/kitty".source = ../../home/.config/kitty;

    # Platform-specific kitty override (borderless on Hyprland, titlebar on macOS).
    ".config/kitty-os.conf".text =
      if pkgs.stdenv.isLinux then "hide_window_decorations yes\n" else "hide_window_decorations no\n";
    ".config/zellij".source = ../../home/.config/zellij;
    # ".config/ghostty".source = ../../home/.config/ghostty;  # ghostty disabled (using kitty)

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
    # PLAYWRIGHT_BROWSERS_PATH = "${pkgs-unstable.playwright-driver.browsers}";
    # PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
    # PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
    # STARSHIP_CONFIG is set in config/programs/starship/default.nix
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  # Shell-agnostic PATH entries (bash/zsh/fish all source these via HM).
  # bun global bin (opencode) + pnpm global bin (codegraph, pi, ...).
  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.local/share/pnpm/bin"
  ];

  # ── Home Manager self-management ──────────────────────────────────────
  programs.home-manager.enable = true;

  # Re-index home-manager apps into macOS Spotlight after each rebuild.
  # home-manager symlinks .app bundles into /nix/store, which Spotlight is slow
  # to index; this forces it so the apps (kitty, firefox, …) appear in search.
  # No-op on Linux (no ~/Applications/Home Manager Apps there).
  home.activation.reindexSpotlight = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for app in "$HOME/Applications/Home Manager Apps"/*.app; do
      [ -e "$app" ] && /usr/bin/mdimport "$app" 2>/dev/null || true
    done
  '';

  # Set Zen Browser as the default web browser on macOS (http/https handlers).
  # Runs as the user (Launch Services defaults are per-user), after the apps are
  # linked. Re-applied each rebuild since macOS can reset the default browser.
  # No-op on Linux (duti is macOS-only).
  home.activation.setZenDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.optionalString pkgs.stdenv.isDarwin ''
      # Register Zen with Launch Services first (home-manager's symlinked apps
      # aren't always auto-registered, which makes duti fail with error -54),
      # then set it as the default http/https handler. Steps are non-fatal so a
      # hiccup doesn't abort the whole activation.
      for zen in "$HOME/Applications/Home Manager Apps"/Zen*.app; do
        [ -e "$zen" ] || continue
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$zen" || true
        ${pkgs.duti}/bin/duti -s app.zen-browser.zen https || true
        ${pkgs.duti}/bin/duti -s app.zen-browser.zen http || true
      done
    ''
  );

  # Zen Browser config lives in config/programs/zen-browser/default.nix
  # (single source for both hosts; previously duplicated here).

  # ── Git ───────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Adophilus";
        email = "uchenna19of@gmail.com";
      };
    };
    package = pkgs-unstable.git;
  };

  # ── Fish shell ────────────────────────────────────────────────────────
  # Uses builtins.readFile so fish can freely write fish_variables at runtime.
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ../../home/.config/fish/config.fish;
    # Wrap opencode so it always runs with the sops secrets loaded.
    # (with-secrets is a bash script, so no recursion — exec opencode finds
    # the real binary on PATH, bypassing this fish alias.)
    shellAliases.opencode = "with-secrets opencode";
  };

  # ── Desktop entries ───────────────────────────────────────────────────
  xdg.desktopEntries.scrcpy = lib.mkIf pkgs.stdenv.isLinux {
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
  services.swayosd = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    topMargin = 0.9;
    stylePath = "${config.home.homeDirectory}/.config/swayosd/style.css";
  };
  # services.hypridle is managed in config/programs/hypridle/default.nix

  sops = {
    # age.keyFile = "/home/adophilus/.age-key.txt";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets."adophilus/env" = {
      sopsFile = ./secrets/env;
      format = "dotenv";
    };
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    defaultApplicationPackages = [ ];

    defaultApplications = {
      "text/html" = "zen-twilight.desktop";
      "x-scheme-handler/http" = "zen-twilight.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop";
      "x-scheme-handler/about" = "zen-twilight.desktop";
      "x-scheme-handler/unknown" = "zen-twilight.desktop";
      "application/xhtml+xml" = "zen-twilight.desktop";
      "application/x-extension-htm" = "zen-twilight.desktop";
      "application/x-extension-html" = "zen-twilight.desktop";
      "application/x-extension-shtml" = "zen-twilight.desktop";
      "application/x-extension-xhtml" = "zen-twilight.desktop";
      "application/x-extension-xht" = "zen-twilight.desktop";

      "application/pdf" = "org.pwmt.zathura.desktop";

      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      # "x-scheme-handler/discord" = "legcord.desktop";  # legcord removed
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
}
