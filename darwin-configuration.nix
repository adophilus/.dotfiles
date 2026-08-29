# macOS system-level config (nix-darwin) for the Intel Mac.
# Apply with: darwin-rebuild switch --flake .#nadir
{
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-darwin";

  # Primary user — required by recent nix-darwin for homebrew.enable (and
  # other per-user system options).
  system.primaryUser = "adophilus";

  # nixpkgs config — system-level (home-manager uses global pkgs, so this
  # belongs here, not in home.nix). Mirrors configuration.nix on zenith.
  nixpkgs.config = {
    permittedInsecurePackages = [ "electron-37.10.3" ];
    allowUnfreePredicate = pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "postman" "spotify" "google-chrome" "zoom" "code" "vscode"
        "discord" "legcord" "obsidian" "osu-lazar"
      ];
  };

  # Hostname — nadir (the celestial opposite of zenith). Sets HostName
  # (terminal/ssh prompt), LocalHostName (Bonjour .local), ComputerName (Finder).
  networking.hostName = "nadir";
  networking.localHostName = "nadir";
  networking.computerName = "Nadir";

  # /etc/hosts, replaced wholesale (nix-darwin has no networking.extraHosts).
  # Standard macOS entries + wireguard mesh names (mDNS can't cross wg — no
  # broadcast domain; and .local is reserved by mDNSResponder, hence .vpn).
  environment.etc.hosts.text = ''
    127.0.0.1 localhost
    255.255.255.255 broadcasthost
    ::1 localhost
    10.100.0.1 contabo.vpn
    10.100.0.2 zenith.vpn
    10.100.0.3 nadir.vpn
  '';

  # Set once, never change. 4 = Sonoma era. Verify on first `darwin-rebuild`.
  system.stateVersion = 4;

  # Determinate Nix manages the Nix installation itself — nix-darwin must not
  # fight it for the daemon / nix.conf. If you used upstream Nix instead, set
  # this to true (or remove it).
  nix.enable = false;

  # SSH (Remote Login) — key-only auth, mirroring zenith. macOS opens port 22
  # automatically when Remote Login is enabled (no separate firewall rule needed).
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      # Let inbound sessions carry their locale — without this every ssh
      # drops to LANG=C and starship/fish draw glyphs (❯ etc) for 1970s
      # terminals. Client side sends LANG/LC_* by default (SendEnv).
      AcceptEnv LANG LC-*
    '';
  };

  # Fish shell — enabled at system level so it's on PATH for the login shell.
  programs.fish.enable = true;

  # WireGuard client (vps tunnel, conf at ~/.config/wireguard/vps.conf).
  # macOS has no kernel wireguard — wireguard-go is the userspace data plane,
  # wg-quick uses it to create a utun device. Bring up with:
  #   sudo wg-quick up ~/.config/wireguard/vps.conf
  # (from nixpkgs 26.05 — the last release supporting x86_64-darwin)
  environment.systemPackages = with pkgs; [
    wireguard-tools
    wireguard-go
  ];

  # WireGuard tunnel at boot. macOS-native equivalent of the systemd unit the
  # Linux boxes get from networking.wireguard: wg-quick creates the utun
  # device via the userspace wireguard-go backend. The private key itself
  # lives in the sops-decrypted file (HM decrypts at darwin-rebuild; the file
  # persists across reboots on macOS, so the boot-time daemon can read it) —
  # vps.conf has no secret in it and injects the key via PostUp.
  launchd.daemons.wireguard-vps = {
    command = pkgs.writeShellScript "wireguard-vps" ''
      export PATH="${pkgs.wireguard-tools}/bin:${pkgs.wireguard-go}/bin:$PATH"
      exec ${pkgs.wireguard-tools}/bin/wg-quick up /Users/adophilus/.config/wireguard/vps.conf
    '';
    serviceConfig = {
      UserName = "root";
      RunAtLoad = true;
      # restart only on failure — a clean exit means the tunnel is
      # configured and wg-quick is done (re-running it would error).
      KeepAlive.SuccessfulExit = false;
    };
  };

  # home-manager CANNOT set the login shell on macOS — only nix-darwin (or
  # manual `chsh`) can. This makes fish the login shell for adophilus.
  environment.shells = [ "${pkgs.fish}/bin/fish" ];
  users.users.adophilus = {
    shell = pkgs.fish;
    home = "/Users/adophilus";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMOszuqNs3PhCKOhCejkol4u4/vRgLP1s2vCT9nJo4D adophilus@nadir"
      # vps (root@contabo) — reaches nadir over the wireguard tunnel
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICv8JOH5fkPP8uxOud6DRRh1UsPkSj5xjKk8uo1VxLmv root@contabo"
    ];
  };

  # Fonts — installed so macOS CoreText (and kitty) can see them.
  fonts.packages = [ pkgs.nerd-fonts.hurmit pkgs.nerd-fonts.space-mono ];

  # nix-homebrew — installs Homebrew ITSELF via Nix (into /usr/local on Intel),
  # so brew is declarative rather than curl|bash. Sits under nix-darwin's
  # homebrew module below (which manages casks/brews), and fixes the
  # "Homebrew doesn't seem to be installed" error.
  nix-homebrew = {
    enable = true;
    user = "adophilus"; # owner of the Homebrew prefix
    # NOTE: do NOT set enableRosetta on Intel (assertion fails).
    # enableFlakes does NOT exist (removed). mutableTaps defaults to true.
  };

  # Homebrew cask/brew management — driven by the brew binary nix-homebrew
  # installs above.
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall"; # remove casks/brews not listed here (declarative reconcile)
      autoUpdate = false; # skip `brew update` on each activation (faster rebuilds)
      upgrade = false; # skip `brew upgrade` on each activation
    };
    taps = [
      "nikitabobko/homebrew-tap" # aerospace tiling WM
    ];
    # GUI apps (.app bundles)
    casks = [
      "legcord"
      "whatsapp"
      "figma"
      "open-design"
      "google-chrome"
      # email — cask not home-manager pkg so Spotlight indexes the .app
      "thunderbird"
      # media
      "vlc"
      "obs"
      "shotcut"
      # games
      "epic-games"
      # private browsing
      "tor-browser"
      "mullvad-browser"
      # crypto
      "monero-wallet"
      "electrum"
      # other
      "transmission"
      "gnucash"
      "scroll-reverser" # independent trackpad/mouse scroll direction
      # work
      "lark"
      # tiling window manager (i3-style, no SIP changes)
      "nikitabobko/homebrew-tap/aerospace"
      "ghostty" # cask, not nixpkgs — Intel-Mac nix build source-builds Zig+GTK forever (see home.nix)
      # opencode-desktop removed as cask — now from the opencode flake via
      # home-manager (users/adophilus/home.nix, cross-platform packages).
    ];
    # CLI tools come from nix (home.packages); no Homebrew brews. opencode is
    # installed standalone so it doesn't pull a Homebrew node that shadows nix's.
    brews = [ ];
  };

  # ── Headless corner-machine behavior ─────────────────────────────────
  # Keep awake with the lid closed (macOS equivalent of zenith's
  # services.logind.lidSwitch = "ignore"). `disablesleep` — NOT `sleep 0`,
  # which only stops idle sleep, not lid-close sleep. Explicit Sleep from
  # the  menu still works when you want it. Keep the Mac plugged in:
  # with sleep disabled, a closed lid on battery just drains.
  # (pmset persists across boots; the activation script keeps it owned
  # by the flake.)
  system.activationScripts.postActivation.text = ''
    /usr/bin/pmset -a disablesleep 1
  '';

  # TODO (curate on the Mac): system.defaults.* (dock/finder), more casks.
}
