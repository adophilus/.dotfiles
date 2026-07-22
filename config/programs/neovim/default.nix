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
    package = pkgs-deprecated.neovim-unwrapped;
    sideloadInitLua = true;
  };

  # Sync Neovim config from nix store. Uses rsync --update so that
  # lazy-lock.json written by :Lazy update in ~/.config/nvim is preserved
  # (it's newer than the repo copy until you copy it back).
  home.activation.copyNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync --archive --update ${../../../.config/nvim}/ $HOME/.config/nvim/
    run chmod --recursive u+w $HOME/.config/nvim
  '';

  home.activation.copyNvimPlugins = lib.hm.dag.entryAfter [ "writeBoundary" "copyNvimConfig" ] ''
    run ${pkgs.rsync}/bin/rsync --archive ${../../../.config/my-astronvim-plugins}/ $HOME/.config/nvim/lua/plugins/
    run chmod --recursive u+w $HOME/.config/nvim/lua/plugins
  '';
}
