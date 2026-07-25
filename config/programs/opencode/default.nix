{
  lib,
  pkgs,
  ...
}:
{
  # opencode package + web server — Linux only (no x86_64-darwin build in
  # nixpkgs; on macOS opencode is installed via Homebrew). The config-file
  # deployment below (activation scripts + home.file) runs on both platforms.
  programs.opencode = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;

    web = {
      enable = true;
      extraArgs = [
        "--hostname"
        "0.0.0.0"
      ];
    };
  };

  home.activation.copyOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.config
    run ${pkgs.rsync}/bin/rsync --archive ${../../../.config/opencode}/ $HOME/.config/opencode/
    run chmod --recursive u+w $HOME/.config/opencode
  '';

  home.file.".config/opencode/AGENTS.md".source = ../../../.config/opencode/AGENTS.md;
  home.file.".config/opencode/oh-my-opencode-slim.jsonc".source = ../../../.config/opencode/oh-my-opencode-slim.jsonc;
  home.file.".config/opencode/opencode.jsonc".source = ../../../.config/opencode/opencode.jsonc;
  home.file.".config/opencode/tui.jsonc".source = ../../../.config/opencode/tui.jsonc;

  home.activation.copyAgentsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync --delete --archive ${../../../.config/.agents}/ $HOME/.agents/
    run chmod --recursive u+w $HOME/.agents
  '';
}
