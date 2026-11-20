# Orca (stablyai/orca) — the parallel-agent IDE: runs coding-agent CLIs
# (claude, pi, codex, …) each in its own git worktree, with an
# orchestration layer (Runs/Tasks/workers/decision gates) exposed back
# to the agents as MCP tools — which is what lets e.g. a Claude session
# delegate a review to a pi worker and get results back.
#
# Sourcing: not in nixpkgs (`orca` there is the GNOME screen reader;
# the `orca-ide` package PR is still open), so this pulls from numtide's
# llm-agents.nix — see the input comment in flake.nix for why it does
# NOT follow our nixpkgs.
#
# Linux-only: the module is deliberately absent from
# darwinHomeManagerModules in flake.nix (upstream ships darwin builds,
# but nadir is Intel and unverified — wire it there explicitly if the
# Mac ever needs it).
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca
  ];
}
