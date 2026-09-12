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
# Build-time branch is now hub-only: attach mode never launches a
# browser, so the MCP needs no --executablePath — but the hub does, and
# NixOS hides Chrome from auto-detection while macOS has a stable
# /Applications path. The same branch picks the hub default: zenith owns a
# local lazy-init hub; nadir attaches to zenith's through the
# chrome-cdp-proxy on wg0 (configuration.nix). CHROME_DEVTOOLS_URL beats
# either default. A non-loopback URL means "someone else's hub": attach
# only, never launch — an unreachable foreign hub should error, not
# quietly spawn a local Chrome.
{ pkgs, ... }:
let
  chrome =
    if pkgs.stdenv.isDarwin
    then "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    else "/etc/profiles/per-user/adophilus/bin/google-chrome-stable";
  hubUrl =
    if pkgs.stdenv.isDarwin
    then "http://10.100.0.2:9222"
    else "http://127.0.0.1:9222";
in
pkgs.writeShellScriptBin "chrome-devtools-mcp" ''
  url=''${CHROME_DEVTOOLS_URL:-${hubUrl}}
  cache=$HOME/.cache/chrome-devtools-mcp

  case "$url" in
    http://127.0.0.1* | http://localhost*)
      # Local hub: lazy-init.
      if ! curl -fsS "$url/json/version" >/dev/null 2>&1; then
        mkdir -p "$cache"
        # Detached + redirected: a hub holding the stdio pipes open would
        # wedge the transport when the parent dies; a full pipe blocks
        # Chrome itself.
        # --password-store=basic: greetd auto-login types no password, so
        # the login keyring stays locked and Chrome's default store pops
        # a gcr "Unlock Login Keyring" prompt on the hub's screen, waiting
        # for a human who isn't there (and macOS Keychain does the same
        # dance on nadir). The hub is an agent-driven tool profile — no
        # keyring dependency at all.
        "${chrome}" \
          --remote-debugging-port=9222 \
          --user-data-dir="$cache/chrome-profile" \
          --no-first-run --no-default-browser-check \
          --password-store=basic \
          >>"$cache/hub.log" 2>&1 &
      fi
      ;;
  esac

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
