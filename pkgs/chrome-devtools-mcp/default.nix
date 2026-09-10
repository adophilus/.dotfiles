# `chrome-devtools-mcp` — lazy-init CDP hub + attach-mode launcher.
#
# Default MCP mode launches its own Chrome on the shared default profile
# (~/.cache/chrome-devtools-mcp/chrome-profile) over a debugging *pipe*:
# one owner per user-data-dir, so concurrent MCP servers collide on the
# profile lock, and only the spawning process can drive a pipe.
#
# Instead: this wrapper keeps one long-lived "hub" Chrome running with
# --remote-debugging-port on that same profile (localStorage survives, and
# the custom dir is what stops Chrome 136+ ignoring the port), then execs
# the MCP with --browserUrl. Attach mode owns no lifecycle — any number of
# servers connect, each driving its own tab, and a dying MCP leaves the
# hub running.
#
# Hub start is lazy and race-safe: cold-starting wrappers both launch; the
# losing Chrome exits on the profile lock and every wrapper polls until
# the winner's port answers.
#
# writeShellScriptBin on purpose (not writeShellApplication): wSA hard-sets
# PATH to its runtimeInputs, which would hide `pnpx` (and `curl`) from the
# ambient PATH every other `pnpx` server in .agents/mcp.json relies on.
#
# The build-time branch is now hub-only: attach mode never launches a
# browser, so the MCP needs no --executablePath — but the hub does, and
# NixOS hides Chrome from auto-detection while macOS has a stable
# /Applications path.
{ pkgs, ... }:
let
  chrome =
    if pkgs.stdenv.isDarwin
    then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else "/etc/profiles/per-user/adophilus/bin/google-chrome-stable";
in
pkgs.writeShellScriptBin "chrome-devtools-mcp" ''
  url=http://127.0.0.1:9222
  cache=$HOME/.cache/chrome-devtools-mcp

  if ! curl -fsS "$url/json/version" >/dev/null 2>&1; then
    mkdir -p "$cache"
    # Detached + redirected: a hub holding the stdio pipes open would wedge
    # the transport when the parent dies; a full pipe blocks Chrome itself.
    "${chrome}" \
      --remote-debugging-port=9222 \
      --user-data-dir="$cache/chrome-profile" \
      --no-first-run --no-default-browser-check \
      >>"$cache/hub.log" 2>&1 &
  fi

  # Not bookkeeping — the race fix: poll whether we launched or lost.
  i=0
  until curl -fsS "$url/json/version" >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 50 ]; then
      echo "chrome-devtools-mcp: no hub on $url after 15s - see $cache/hub.log" >&2
      exit 1
    fi
    sleep 0.3
  done

  exec pnpx chrome-devtools-mcp@latest --category-extensions --browserUrl "$url"
''
