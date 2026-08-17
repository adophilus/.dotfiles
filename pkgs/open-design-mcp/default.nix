# `open-design-mcp` — MCP stdio server for Open Design (nexu-io).
#
# Built per host (build-time branch, not runtime hostname detection — the
# flake already knows which host it's evaluating): on darwin it exec's the
# macOS app's bundled daemon CLI; on Linux it's an explicit stub until
# zenith can be tested (the flake's open-design-pkg input is the likely
# future exec target there).
#
# ponytail: launcher paths below are pinned to app version 0.18.1 — breaks
# on every Open Design app update. Accepted risk.
{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "open-design-mcp";

  text =
    if pkgs.stdenv.isDarwin then
      ''
        export OD_DATA_DIR="/Users/adophilus/Library/Application Support/Open Design/namespaces/release-stable-intel/data"
        export OD_SIDECAR_IPC_PATH="/tmp/open-design/ipc/release-stable-intel/daemon.sock"
        export OD_MCP_BOOTSTRAP_COMMAND="/usr/bin/open"
        export OD_MCP_BOOTSTRAP_ARGS='["-g","-j","/Applications/Open Design.app","--args","--headless"]'
        export ELECTRON_RUN_AS_NODE="1"
        exec "/Users/adophilus/Library/Application Support/Open Design/launcher/channels/stable/namespaces/release-stable-intel/versions/0.18.1/payload/Open Design.app/Contents/Frameworks/Open Design Helper.app/Contents/MacOS/Open Design Helper" \
          "/Users/adophilus/Library/Application Support/Open Design/launcher/channels/stable/namespaces/release-stable-intel/versions/0.18.1/payload/Open Design.app/Contents/Resources/app/prebundled/daemon/daemon-cli.mjs" \
          mcp
      ''
    else
      ''
        echo "open-design-mcp: unsupported on this host (zenith/Linux untested)" >&2
        exit 1
      '';
}
