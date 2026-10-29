## Machines

The user's fleet — three machines on a WireGuard mesh (10.100.0.0/24, hub = contabo). If unsure which one you're running on: `hostname`.

| Machine | What it is | Mesh name (prefer) | WireGuard (fallback) | mDNS (home LAN only) |
|---|---|---|---|---|
| contabo | NixOS VPS, mesh hub (public: 80/443 + 51820/udp only — ssh is tunnel-only) | contabo.vpn | 10.100.0.1 | — |
| zenith | NixOS laptop (user: adophilus) | zenith.vpn | 10.100.0.2 | zenith.local |
| nadir | Intel Mac, nix-darwin (user: adophilus) | nadir.vpn | 10.100.0.3 | nadir.local |

- **Use the `.vpn` names by default** (`ssh contabo.vpn`, `opencode attach http://contabo.vpn:4096`) — they resolve on all three machines via `/etc/hosts`. Tunnel IPs are the fallback if name resolution ever breaks.
- `.local` names resolve on the home LAN only; `.vpn` names work wherever the tunnel does.
- Reaching machines: over the tunnel (`ssh root@contabo.vpn`, `ssh adophilus@zenith.vpn` / `nadir.vpn`) — spoke-to-spoke (zenith↔nadir) is NOT routed through the hub; those two reach each other over LAN.
- All three are configured declaratively via nix flakes (repos: `dotfiles` for zenith/nadir, `vps` for contabo) — imperative system state is usually a bug, not a feature.

# Browser automation workflow (chrome-devtools MCP)

Multiple agents + the user share one Chrome instance through the same
devtools connection. Tabs are a shared mutable resource — without
discipline, agents fight over them (stale page IDs, sessions stomping
each other, taken-over tabs). The hybrid rule:

- **Default context** (no `isolatedContext` on `new_page`) — the user's
  real browsing profile with all authenticated sessions. Use this for
  anything that needs the user's authenticated accounts. Zero re-login
  cost.
- **Isolated contexts** (`new_page` with `isolatedContext: "agent-<name>"`)
  — for the agent's own test flows. Fresh cookie jar per context, so test
  sessions never pollute the user's real accounts.
- **Never re-login inside an isolated context** — MFA-secured accounts +
  rapid agent logins trigger 6-digit challenges and suspected-bot locks.

Tab discipline: the `pageId` the MCP exposes is a volatile index — re-scan
(`list_pages`) and match by **URL** instead. One webapp tab per agent;
close your own finished tabs; never close the user's tabs.
