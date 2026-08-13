{
  pkgs,
  pkgs-deprecated,
  lib,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    # ponytail: pinned to 25.11 cos 26.05 HEAD has 0.12+ (incompatible with AstroNvim).
    # Current pinned flake.lock has 0.11.6, but next `nix flake update` bumps to 0.12.4.
    # Remove this when AstroNvim supports 0.12+.
    package = pkgs-deprecated.neovim-unwrapped;
    sideloadInitLua = true;
    withRuby = false; # adopt new home-manager default (silences deprecation warning)
    withPython3 = false;
  };

  # Sync Neovim config from nix store. Uses rsync --update so that
  # lazy-lock.json written by :Lazy update in ~/.config/nvim is preserved
  # (it's newer than the repo copy until you copy it back).
  home.activation.copyNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run ${pkgs.rsync}/bin/rsync --archive --update ${../../../home/.config/nvim}/ $HOME/.config/nvim/
    run chmod --recursive u+w $HOME/.config/nvim
  '';

  home.activation.copyNvimPlugins = lib.hm.dag.entryAfter [ "writeBoundary" "copyNvimConfig" ] ''
    run ${pkgs.rsync}/bin/rsync --archive ${../../../home/.config/my-astronvim-plugins}/ $HOME/.config/nvim/lua/plugins/
    run chmod --recursive u+w $HOME/.config/nvim/lua/plugins
  '';
}
