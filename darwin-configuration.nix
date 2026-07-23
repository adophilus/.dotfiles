# macOS system-level config (nix-darwin) for the Intel Mac.
# Apply with: darwin-rebuild switch --flake .#mac
{
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-darwin";

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

  # TODO (curate on the Mac): Homebrew casks, system.defaults.* (dock/finder),
  # any system packages you want outside $HOME.
}
