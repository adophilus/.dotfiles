<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

## Machines

The user's fleet — three machines on a WireGuard mesh (10.100.0.0/24, hub = contabo). If unsure which one you're running on: `hostname`.

| Machine | What it is | WireGuard | mDNS (home LAN only) |
|---|---|---|---|
| contabo | NixOS VPS, mesh hub (public: 80/443 + 51820/udp only — ssh is tunnel-only) | 10.100.0.1 | — |
| zenith | NixOS laptop (user: adophilus) | 10.100.0.2 | zenith.local |
| nadir | Intel Mac, nix-darwin (user: adophilus) | 10.100.0.3 | nadir.local |

- `.local` names resolve on the home LAN only; tunnel IPs work from anywhere.
- Reaching machines: over the tunnel (`ssh root@10.100.0.1`, `ssh adophilus@10.100.0.2/.3`) — spoke-to-spoke (zenith↔nadir) is NOT routed through the hub; those two reach each other over LAN.
- All three are configured declaratively via nix flakes (repos: `dotfiles` for zenith/nadir, `vps` for contabo) — imperative system state is usually a bug, not a feature.
