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
