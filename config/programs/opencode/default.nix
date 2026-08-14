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
      # Loopback-only + passwordless: the bridge (and local clients) hit this
      # directly over 127.0.0.1; no remote exposure (the VPS tunnel is gone).
      # NOTE: to complete the passwordless transition, remove OPENCODE_SERVER_PASSWORD
      # from users/adophilus/secrets/env via `sops`. Until then opencode still
      # enforces the old password and the bridge will 401.
      extraArgs = [
        "--hostname"
        "127.0.0.1"
        "--port"
        "4096"
      ];
      environmentFile = config.sops.secrets."adophilus/env".path;
    };
  };

  # opencode-a2a bridge: exposes opencode over the A2A protocol so pi (and other
  # A2A clients) can drive the local opencode runtime. Talks to the loopback
  # opencode web server directly — no auth, no caddy (zenith has no edge).
  # Requires A2A_STATIC_AUTH_CREDENTIALS in the sops env file; the binary comes
  # from `uv tool install opencode-a2a` (outside the Nix closure, like `pi`).
  systemd.user.services.opencode-a2a = {
    Unit = {
      Description = "opencode-a2a bridge (A2A surface for opencode)";
      After = [ "opencode.service" ];
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/opencode-a2a serve";
      Environment = [
        "OPENCODE_BASE_URL=http://127.0.0.1:4096"
        "OPENCODE_WORKSPACE_ROOT=${config.home.homeDirectory}"
        "A2A_HOST=127.0.0.1"
        "A2A_PORT=4097"
        "A2A_PUBLIC_URL=http://127.0.0.1:4097"
        "A2A_ENABLE_WORKSPACE_MUTATIONS=true"
      ];
      # A2A_STATIC_AUTH_CREDENTIALS (the bearer token pi presents) lives in the
      # sops env file alongside the provider keys.
      EnvironmentFile = config.sops.secrets."adophilus/env".path;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file.".config/opencode/AGENTS.md".source = ../../../home/.config/opencode/AGENTS.md;
  home.file.".config/opencode/oh-my-opencode-slim.jsonc".source =
    ../../../home/.config/opencode/oh-my-opencode-slim.jsonc;
  home.file.".config/opencode/opencode.jsonc".source = ../../../home/.config/opencode/opencode.jsonc;
  home.file.".config/opencode/tui.jsonc".source = ../../../home/.config/opencode/tui.jsonc;
  home.file.".config/opencode/themes".source = ../../../home/.config/opencode/themes;
  home.file.".agents".source = ../../../home/.agents;
}
