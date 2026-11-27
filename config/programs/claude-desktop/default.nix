# Claude Desktop on Linux — repackaged from Anthropic's official Linux .deb
# by aaddrick/claude-desktop-debian (nothing in nixpkgs; see the input
# comment in flake.nix). The -fhs variant wraps the Electron app in an FHS
# env that ships node/uv/docker so MCP servers configured in the app
# (npx/uvx/docker invocations) actually resolve. The bare `claude-desktop`
# package is much smaller but breaks MCP — not worth it here.
#
# Linux-only: zenith auto-discovers this dir (default.nix); nadir's darwin
# module allowlist in flake.nix deliberately doesn't include it.
{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
  ];
}
