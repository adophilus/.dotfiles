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

  # Fish shell — enabled at system level so it's on PATH for the login shell.
  programs.fish.enable = true;

  # home-manager CANNOT set the login shell on macOS — only nix-darwin (or
  # manual `chsh`) can. This makes fish the login shell for adophilus.
  environment.shells = [ "${pkgs.fish}/bin/fish" ];
  users.users.adophilus = {
    shell = pkgs.fish;
    home = "/Users/adophilus";
  };

  # Fonts — installed so macOS CoreText (and kitty) can see them.
  fonts.packages = [ pkgs.nerd-fonts.hurmit ];

  # Homebrew — macOS apps/CLIs that nixpkgs can't provide on x86_64-darwin
  # (legcord, opencode, etc.). Requires Homebrew installed first:
  #   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
      # "ghostty"  # disabled — using kitty as daily driver
    ];
    # CLI tools
    brews = [
      "opencode"
    ];
  };

  # TODO (curate on the Mac): system.defaults.* (dock/finder), more casks.
}
