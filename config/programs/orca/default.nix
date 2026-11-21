# Orca (stablyai/orca) — the parallel-agent IDE: runs coding-agent CLIs
# (claude, pi, codex, …) each in its own git worktree, with an
# orchestration layer (Runs/Tasks/workers/decision gates) exposed back
# to the agents as MCP tools — which is what lets e.g. a Claude session
# delegate a review to a pi worker and get results back.
#
# Sourcing: not in nixpkgs (`orca` there is the GNOME screen reader;
# the `orca-ide` package PR is still open). Linux pulls from numtide's
# llm-agents.nix — see the input comment in flake.nix for why it does
# NOT follow our nixpkgs.
#
# darwin: llm-agents ships arm64-only, and nadir is Intel, so the Mac
# uses the local x64 derivation in pkgs/orca (packaged from upstream's
# `Orca-<version>-mac.zip` release asset). If upstream ever adds an
# x86_64-darwin package, drop pkgs/orca and point both platforms at
# llm-agents again.
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    (if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.callPackage ../../../pkgs/orca { }
    else
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca)
  ];
}
