# `chrome-devtools-mcp` — per-host launcher for the Chrome DevTools MCP.
#
# Same build-time branch as open-design-mcp (the flake already knows which
# host it's evaluating, so stdenv.isDarwin collapses per host): zenith needs
# the home-manager profile path because chrome-devtools-mcp can't auto-detect
# Chrome on NixOS; nadir auto-detects /Applications/Google Chrome.app, so no
# flag at all there.
#
# writeShellScriptBin on purpose (not writeShellApplication): wSA hard-sets
# PATH to its runtimeInputs, which would hide `pnpx` from the user profile.
# Ambient PATH is fine — every other `pnpx` server in .agents/mcp.json
# already relies on it.
{ pkgs, ... }:
pkgs.writeShellScriptBin "chrome-devtools-mcp" (
  if pkgs.stdenv.isDarwin then
    ''
      exec pnpx chrome-devtools-mcp@latest --category-extensions
    ''
  else
    ''
      exec pnpx chrome-devtools-mcp@latest --category-extensions \
        --executablePath /etc/profiles/per-user/adophilus/bin/google-chrome-stable
    ''
)
