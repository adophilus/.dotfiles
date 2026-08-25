{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  options.services.opencode-a2a.enable = lib.mkEnableOption "A2A bridge for opencode";

  config = lib.mkMerge [
    {
      # opencode package + web server. The home-manager module emits a systemd
      # unit on Linux and a launchd agent on darwin — the darwin branch wraps
      # `serve` in a script that sources environmentFile (launchd has no
      # EnvironmentFile= equivalent). Hub pattern: one server on 4096 holding the
      # sops secrets; TUI/browser/GUI clients attach to it.
      programs.opencode = {
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
        };
      };

      # The generated launchd agent runs with launchd's bare PATH
      # (/usr/bin:/bin:/usr/sbin:/sbin) — local MCP children resolve their
      # command[0] against it, so bare names (pnpx, node, codegraph) fail with
      # "executable not found". Merge a real PATH into the agent. On Linux this
      # option is inert (the systemd branch is live there).
      launchd.agents.opencode-web.config.EnvironmentVariables.PATH = lib.concatStringsSep ":" [
        "/etc/profiles/per-user/${config.home.username}/bin" # nix-darwin profile: pnpx, node
        "${config.home.homeDirectory}/.local/share/pnpm/bin" # pnpm globals: codegraph
        "/usr/local/bin" # Homebrew (Intel)
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];

      home.file.".config/opencode/AGENTS.md".source = ../../../home/.config/opencode/AGENTS.md;
      # Same global instructions for pi (reads ~/.pi/agent/AGENTS.md).
      # One repo source, two placements — no symlink needed. Inert on
      # machines without pi installed.
      home.file.".pi/agent/AGENTS.md".source = ../../../home/.config/opencode/AGENTS.md;
      home.file.".config/opencode/oh-my-opencode-slim.jsonc".source =
        ../../../home/.config/opencode/oh-my-opencode-slim.jsonc;
      home.file.".config/opencode/opencode.jsonc".source = ../../../home/.config/opencode/opencode.jsonc;
      home.file.".config/opencode/tui.jsonc".source = ../../../home/.config/opencode/tui.jsonc;
      home.file.".config/opencode/themes".source = ../../../home/.config/opencode/themes;
      home.file.".agents".source = ../../../home/.agents;
    }

    (lib.mkIf config.services.opencode-a2a.enable {
      # opencode-a2a bridge: exposes opencode over the A2A protocol so pi (and other
      # A2A clients) can drive the local opencode runtime. Talks to the loopback
      # opencode web server directly — no auth, no caddy (zenith has no edge).
      # Requires A2A_STATIC_AUTH_CREDENTIALS in the sops env file; the binary comes
      # from `uv tool install opencode-a2a` (outside the Nix closure, like `pi`).
      systemd.user.services.opencode-a2a = {
        Unit = {
          Description = "opencode-a2a bridge (A2A surface for opencode)";
          After = [ "opencode.service" ];
          # circuit breaker: 5 starts in 3min → unit goes to `failed` and stays down
          StartLimitIntervalSec = 180;
          StartLimitBurst = 5;
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
          EnvironmentFile = config.programs.opencode.web.environmentFile;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ];
}
