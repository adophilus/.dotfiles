{
  lib,
  pkgs,
  ...
}:
{
  programs.opencode = {
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
    run ${pkgs.rsync}/bin/rsync --archive ${../../../.config/opencode}/ $HOME/.config/opencode/
    run chmod --recursive u+w $HOME/.config/opencode
  '';

  home.file.".config/opencode/AGENTS.md".source = ../../../.config/opencode/AGENTS.md;
  home.file.".config/opencode/oh-my-opencode-slim.jsonc".source = ../../../.config/opencode/oh-my-opencode-slim.jsonc;
  home.file.".config/opencode/opencode.jsonc".source = ../../../.config/opencode/opencode.jsonc;

  home.activation.copyAgentsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.rsync}/bin/rsync --delete --archive ${../../../.config/.agents}/ $HOME/.agents/
    run chmod --recursive u+w $HOME/.agents
  '';
}
