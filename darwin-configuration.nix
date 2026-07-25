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
        "steam" "steam-unwrapped" "discord" "legcord" "obsidian" "osu-lazar"
      ];
  };

  # Hostname — nadir (the celestial opposite of zenith). Sets HostName
  # (terminal/ssh prompt), LocalHostName (Bonjour .local), ComputerName (Finder).
  networking.hostName = "nadir";
  networking.localHostName = "nadir";
  networking.computerName = "Nadir";

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
    '';
  };

  # Fish shell — enabled at system level so it's on PATH for the login shell.
  programs.fish.enable = true;

  # home-manager CANNOT set the login shell on macOS — only nix-darwin (or
  # manual `chsh`) can. This makes fish the login shell for adophilus.
  environment.shells = [ "${pkgs.fish}/bin/fish" ];
  users.users.adophilus = {
    shell = pkgs.fish;
    home = "/Users/adophilus";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMOszuqNs3PhCKOhCejkol4u4/vRgLP1s2vCT9nJo4D adophilus@nadir"
    ];
  };

  # Fonts — installed so macOS CoreText (and kitty) can see them.
  fonts.packages = [ pkgs.nerd-fonts.hurmit ];

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
    # GUI apps (.app bundles)
    casks = [
      "legcord"
      "whatsapp"
      "figma"
      # media
      "vlc"
      "obs"
      "shotcut"
      # private browsing
      "tor-browser"
      "mullvad-browser"
      # crypto
      "monero-wallet"
      "electrum"
      # other
      "transmission"
      "gnucash"
      # work
      "lark"
      # "ghostty"  # disabled — using kitty as daily driver
    ];
    # CLI tools
    brews = [
      "opencode"
    ];
  };

  # TODO (curate on the Mac): system.defaults.* (dock/finder), more casks.
}
