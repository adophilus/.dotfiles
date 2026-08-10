{
  lib,
  pkgs,
  config,
  ...
}:
{
  # opencode package + web server — Linux only (no x86_64-darwin build in
  # nixpkgs; on macOS opencode is installed standalone via pnpm global). The config-file
  # deployment below (activation scripts + home.file) runs on both platforms.
  programs.opencode = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;

    web = {
      enable = true;
      extraArgs = [
        "--hostname"
        "0.0.0.0"
      ];
      environmentFile = config.sops.secrets."adophilus/env".path;
    };
  };

  systemd.user.services.opencode-vps-tunnel = {
    Unit = {
      Description = "VPS tunnel for OpenCode headless server";
      After = [
        "network-online.target"
        "opencode.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh -N -R $OPENCODE_SERVER_PROXY_PORT:$OPENCODE_SERVER_HOST:$OPENCODE_SERVER_PORT vps";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".config/opencode/AGENTS.md".source = ../../../.config/opencode/AGENTS.md;
  home.file.".config/opencode/oh-my-opencode-slim.jsonc".source =
    ../../../.config/opencode/oh-my-opencode-slim.jsonc;
  home.file.".config/opencode/opencode.jsonc".source = ../../../.config/opencode/opencode.jsonc;
  home.file.".config/opencode/tui.jsonc".source = ../../../.config/opencode/tui.jsonc;
  home.file.".config/opencode/themes".source = ../../../.config/opencode/themes;
  home.file.".agents".source = ../../../.config/.agents;
}
