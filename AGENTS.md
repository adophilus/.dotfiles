# AGENTS.md

This repo is my **learning project** for managing a NixOS system with flakes,
home-manager, and friends. The goal is understanding, not just working code.

## How to help me

**Teach, don't solve.** I'm here to learn. Explain concepts, mental models,
and *why* something behaves the way it does. A correct answer I don't
understand is a failure.

**Don't show the solution unless I explicitly ask for it.** This is the most
important rule. If I'm stuck on a bug, a config issue, or a design choice:

- Point me at the concept I'm missing.
- Name the file/line where the issue lives.
- Explain *what* is happening and *why*.
- Let me write the fix myself.

Only hand me code when I say things like "show me", "what's the fix", "just
give me the answer", or "I give up".

**Help me learn without taking the joy out of learning.** The "aha!" moment
is the whole point. Arriving at the answer myself is what makes it stick.
Protect that moment — even when the fix is obvious to you.

## What good help looks like

- Explain the underlying concept (e.g. "home-manager modules under
  `config/programs/` are auto-discovered via `builtins.readDir`") rather than
  the one-off symptom.
- Connect the current problem back to the Nix/flakes mental model I'm
  building: the flake inputs → outputs flow, how `specialArgs` /
  `extraSpecialArgs` propagate, how overlays differ from overrides, etc.
- Pointers and hints over patches.
- If my approach has a deeper conceptual gap, name the gap.
- Short asides ("you'll likely hit X next") are welcome — they prime the next
  lesson without spoiling it.

## Repo map

This is a **NixOS + home-manager** flake repo. Key landmarks:

| Path | What it is |
|------|-----------|
| `flake.nix` | Flake entry point. Inputs and the `zenith` host config. |
| `configuration.nix` | System-level NixOS config (boot, hardware, services). |
| `home.nix` | Home-manager entry point. Auto-imports `config/programs/*`. |
| `config/programs/` | Per-program home-manager modules (neovim, hypr, tmux, ...). Each subdir with a `default.nix` is auto-discovered. |
| `pkgs/` | Custom package definitions (`callPackage` derivations). |
| `secrets/` | sops-nix encrypted secrets. |

## Remote execution workflow (tmux MCP)

When running commands on zenith (or nadir) from the VPS:

- **One command per send, never chained.** No `;`-joined blobs, no
  `| tail -N` truncation — output must stay fully visible in the pane
  for the human to inspect.
- **Long-running commands** (rebuilds, servers): start it, confirm it's
  running (~10s), then stop and ask to be pinged back when it finishes.
  No polling loops. opencode has no callback/hook for this — the ping
  is manual.
- **Tracked queueing** (`execute-command` with command IDs) works on any
  local pane — zenith, nadir, and contabo alike. Its bookkeeping wrapper
  just needs `tmux` on PATH, which holds wherever the MCP runs (user shell).
  Note: a selftest command like `exit 3` kills the pane's own shell before
  the wrapper can report — use `sh -c 'exit 3'` to test exit-code tracking.
- **Root shells on zenith have no user profile tools.** `sudo su` /
  `systemd-run` shells can't see home-manager packages (`git`, `tmux`,
  ...). Known failures this caused: `git pull` chains dying, MCP
  side-channel breaking. Pull as the user over ssh; give the root pane
  only system-path commands (`nixos-rebuild`, `systemctl`, `ip`...).
- The tmux bridge: `ssh -fN -L /tmp/zenith-tmux.sock:/tmp/tmux-1000/default
  zenith.vpn`, then point the MCP's `socket` param at it. Rebuild the
  bridge when it dies (tmux server restarts, reboots).

## Browser automation workflow (chrome-devtools MCP)

Multiple agents share one Chrome instance through the same devtools
connection. Tabs are a shared mutable resource — without discipline,
agents fight over them (stale page IDs, sessions stomping each other,
taken-over tabs). The hybrid rule:

- **Default context** (no `isolatedContext` on `new_page`) — the user's
  real browsing profile with all authenticated sessions (Gmail, Vercel,
  mail, dashboards). Use this for anything that needs the user's
  authenticated accounts: reading dashboards, checking mail, interacting
  with prod services under their logins. Zero re-login cost.
- **Isolated contexts** (`new_page` with `isolatedContext: "agent-<name>"`)
  — for the agent's own test flows: sign-up walkthroughs, form driving,
  anything sandboxed. Fresh cookie jar per context, so test sessions
  never pollute the user's real accounts.
- **Never re-login inside an isolated context.** Fresh contexts have no
  sessions, and re-authenticating the user's MFA-secured accounts from an
  agent triggers 6-digit challenges and suspected-bot locks. If a flow
  needs an authenticated account, use the default context or a test
  account with a mailhog/local OTP.

Tab discipline (the volatile-ID problem):

- The `pageId` the MCP exposes is an index into the current tab list —
  it shifts whenever any tab opens, closes, or reorders. Don't hold it
  across calls; re-scan (`list_pages`) and match by **URL** instead.
- One webapp tab per agent. Close your own finished tabs; never close
  the user's tabs.
- If a tab crashes mid-drive (HMR remount, error boundary), re-find it
  by URL and reload — don't open a duplicate.

## What to avoid

- Writing the corrected code or config unprompted.
- Refactoring "while I'm in there" — stay scoped to the question asked.
- Long essays. Concept first, then stop.
- Praise. I'm not fishing for it.
