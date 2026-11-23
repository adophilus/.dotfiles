#!/usr/bin/env bash
# Vendor Orca's bundled agent skills into the dotfiles.
#
# Orca (stablyai/orca) ships version-matched skill guides inside its own
# package; `orca skills install` normally writes them to ~/.agents/skills —
# which here is a read-only store symlink managed by home-manager
# (config/programs/opencode/default.nix). So we install into a throwaway
# $HOME and copy the result into home/.agents/skills/, where the declarative
# whole-dir symlink picks it up on the next rebuild.
#
# Re-run after bumping the orca flake input (skills are version-matched to
# the orca build — vendored from orca 1.4.265). Skills removed upstream
# linger here; prune by hand.
#
# linear-tickets is deleted after copy: the registry marks it a legacy
# alias of orca-linear. orca-emulator targets iOS Simulator — dead weight
# on Linux, harmless as an unused skill; delete if it bothers you.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
dest="$repo/home/.agents/skills"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

HOME="$scratch" orca skills install --all
cp -r "$scratch/.agents/skills/"* "$dest/"
rm -rf "$dest/linear-tickets"

echo "Vendored into $dest — review with git diff, then rebuild."
