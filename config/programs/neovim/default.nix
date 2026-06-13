{ pkgs, pkgs-unstable, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    package = pkgs.neovim-unwrapped;
  };

  # Sync Neovim config from nix store. Uses rsync --update so that
  # lazy-lock.json written by :Lazy update in ~/.config/nvim is preserved
  # (it's newer than the repo copy until you copy it back).
  home.activation.copyNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync -a --delete \
      ${../../../.config/nvim}/ $HOME/.config/nvim/
    run chmod -R u+w $HOME/.config/nvim
  '';
}
