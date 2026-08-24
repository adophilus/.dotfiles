---
name: process-compose
description: Interact with running process-compose instances via the client CLI (logs, status, stats, ports, restart) instead of parsing the TUI buffer with tmux capture-pane. Use whenever reading logs, checking process status/stats, or starting/stopping/restarting processes managed by process-compose.
---

# process-compose via client CLI

Every running `process-compose up` instance exposes an HTTP server (default
`:8080`) **alongside** the TUI. Client subcommands are REST clients against
that server — they work against the exact instance a human is watching in
tmux, without touching the TUI.

## Core rule

**Never parse the TUI buffer (`capture-pane`) to get process-compose data.**
Logs, status, stats, ports, restarts — all of it is one CLI call away and
parse-safe. tmux is only for *starting* `process-compose up` and driving its
interactive TUI.

## Connection

```bash
process-compose -p $PC_PORT <command>   # PC_PORT from the workspace .env (direnv); default 8080
```

If `$PC_PORT` is empty, find the instance: `pgrep -af "process-compose up"`.
Multiple concurrent workspaces = multiple ports — always target the right one.

## Reads (verified on v1.120.0)

```bash
# status + stats (mem, cpu, restarts, readiness, PIDs) — JSON, parse-safe
process-compose -p $PC_PORT process list -o json

# one process, table row
process-compose -p $PC_PORT process get <name>

# logs — last 100 lines
process-compose -p $PC_PORT process logs -n 100 <name>

# logs — multiple processes, no name prefixes
process-compose -p $PC_PORT process logs --raw-log -n 50 a,b

# listening ports of a process
process-compose -p $PC_PORT process ports <name>

# readiness gate: exit 0 when all ready; nonzero + "FTL processes are not ready: ..." when not
process-compose -p $PC_PORT project is-ready

# project summary incl. memory
process-compose -p $PC_PORT project state --with-memory
```

Discover process names with `process list` first (names = yaml keys, e.g.
`admin`, `core-service`).

## Control

```bash
process-compose -p $PC_PORT process restart <name>   # replaces TUI Ctrl-R + tmux send-keys
process-compose -p $PC_PORT process start <name>
process-compose -p $PC_PORT process stop <name>
process-compose -p $PC_PORT process logs truncate <name>   # clear buffer
process-compose -p $PC_PORT down                     # stop everything
```

## Gotchas

- `logs -f` (follow) **never returns** — don't run it bare in the agent shell.
  Use `-n` with a line count, or run follow inside a tmux window.
- The log buffer is in-memory and bounded (`log_length` config); for full
  history use the process's `log_path` file if configured.
- `project is-ready` failing with a red `FTL` line is a *readiness signal*
  (it names the failing processes), not a CLI error.
- Client output may include ANSI colors; `process list -o json` is the
  parse-safe path.
- `restart` waits the process's availability backoff between stop/start —
  allow a few seconds before expecting readiness.

## Still tmux (not via CLI)

- Starting the stack: `process-compose up --port $PC_PORT` (long-running →
  dedicated tmux window).
- Full restart after workspace `.env` changes (direnv must reload in the
  parent shell — CLI can't do that).
- Anything about the TUI's own visuals.

## Optional: built-in MCP server (not enabled here)

process-compose (≥ v1.94) ships an author-endorsed MCP server: add an
`mcp_server: {host, port, expose_control_tools}` block to the yaml and point
an MCP client at `http://localhost:<port>/sse` for native `pc_*` tools
(incl. BM25 log search). Per-workspace port juggling + MCP registration
overhead — only worth it if CLI shelling becomes a bottleneck. SSE transport
keeps the TUI enabled (stdio transport spawns a *new* instance — wrong for
attaching to an existing one).
