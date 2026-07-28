# Nix Store Cleanup

Reduced `/nix/store` from **123GB → 62GB** (61GB / 49.6% reclaimed).

## What was hogging space

### 1. Stale GC roots in `~/.projects` (~57GB)

`result` symlinks and `.direnv/` directories from old projects act as indirect
GC roots. Nix never collects anything reachable from them — even projects you
haven't touched in months.

The worst offenders:
- **Full NixOS system closures** pinned by `result` symlinks from nix-playground
  experiments (each several GB)
- **direnv shell environments** from ~60 projects (Rust, Java/Android SDK,
  PHP, Scala, Zig, Python) — each pinning its entire toolchain closure
- **Old profile generations** (8 user profiles + 2 home-manager generations)

### 2. d2 pulling playwright-driver.browsers (~7.6GB)

nixpkgs revision `b3fe958+` added `playwright-driver.browsers` to the `d2`
package's `buildInputs` unconditionally on Linux. This pulls in a full
Chromium, Firefox, and WebKit browser bundle — for a ~20MB Go binary that only
needs them for PNG/PDF/GIF export.

**Fix:** `d2-lite` override in `home.nix`:
```nix
d2-lite = pkgs.d2.overrideAttrs (_: _: { buildInputs = [ ]; });
```
SVG export works. PNG/PDF/GIF disabled. For those rare cases, use
`nix run nixpkgs#d2` (temporary, GC'd after).

### 3. open-design duplicate nixpkgs closure

The `open-design` flake input had no `inputs.nixpkgs.follows`, pulling its own
nixpkgs + home-manager closure into the store. Added follows to dedup:
```nix
open-design = {
  url = "github:nexu-io/open-design";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### 4. nixpkgs-deprecated (25.11) — kept intentionally

Considered removing (saves ~5-10GB of duplicate 25.11 closure), but it's the
only source of neovim-unwrapped **0.11.x**. The `nixos-26.05` branch HEAD has
neovim **0.12.4**, which is incompatible with the current AstroNvim setup.

Can be removed once AstroNvim supports neovim 0.12+. See the `ponytail:`
comment in `config/programs/neovim/default.nix`.

## Reproducing the cleanup

```bash
# 1. Nuke all direnv GC roots (safe — direnv recreates on next cd)
find ~/.projects -type d -name '.direnv' -exec rm -rf {} + 2>/dev/null

# 2. Remove old result symlinks (build experiments you don't need)
find ~/.projects -type l -name 'result' -delete 2>/dev/null
find ~/.projects -type l -name '.tmp' -delete 2>/dev/null

# 3. Delete old profile generations + collect everything unreachable
nix-collect-garbage -d
```

## `nix-collect-garbage` vs `sudo nix-collect-garbage`

| Without `sudo` | With `sudo` |
|---|---|
| Cleans **user** profile generations | Also cleans **system** generations + root profiles |
| The nix daemon (runs as root) still checks ALL roots during GC sweep | More thorough — purges old `nixos-rebuild` generations |

Without `sudo` is sufficient when you only have 1 system generation. Use `sudo`
when you've accumulated multiple system generations from past rebuilds.

## Preventing future pileup

### Cap system generations

In `configuration.nix`:
```nix
boot.loader.systemd-boot.configurationLimit = 5;
```

### Audit GC roots periodically

```bash
# Find all result symlinks across your home directory
find ~ -type l -name 'result' -ls 2>/dev/null

# Find all direnv gc roots
find ~ -type d -name '.direnv' 2>/dev/null

# See all gc roots (comprehensive)
nix-store --gc --print-roots | grep -v '^/nix/var/nix'

# Check the heaviest store paths
nix path-info -rS /run/current-system | sort -rk2 | head -20
```

### Trace what's pulling a dependency

```bash
nix why-depends /run/current-system /nix/store/<hash>-<package-name>
```

## Current state (2026-07-28)

| Metric | Before | After |
|---|---|---|
| `/nix/store` | 123GB | 62GB |
| Disk usage (`/dev/sda2`) | 307GB (89%) | ~246GB (~67%) |
| Store paths deleted | — | ~59,500 |
| Hard linking savings | — | 6.9GB |
