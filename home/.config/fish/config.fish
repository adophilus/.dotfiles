# fish_config theme save "Catppuccin Mocha"

set -U fish_autosuggestion_enabled 0

# Vim-style key bindings (Esc for normal mode, hjkl to navigate).
# fish_hybrid_key_bindings also keeps emacs bindings (Ctrl+A/E/etc.) in insert mode.
fish_hybrid_key_bindings

set -x GOPATH "$HOME/go"
set -x BUNPATH "$HOME/.cache/.bun"
set -x PNPM_HOME "$HOME/.local/share/pnpm"
set -x DENOPATH "$HOME/.deno"
set -x CARGOPATH "$HOME/.cargo"
set -x TOOLSPATH "$HOME/.local/bin/tools"
set -x UV_BIN_PATH "$HOME/.local/bin"

fish_add_path -g "$GOPATH/bin"
fish_add_path -g "$BUNPATH/bin"
fish_add_path -g "$PNPM_HOME"
fish_add_path -g "$PNPM_HOME/bin"
fish_add_path "$HOME/.cache/.bun/bin"
fish_add_path -g "$DENOPATH/bin"
fish_add_path -g "$CARGOPATH/bin"
fish_add_path -g "$TOOLSPATH"
fish_add_path -g "$UV_BIN_PATH"
fish_add_path -g "$HOME/.local/bin"

# Point Docker-compatible tools at podman's rootless socket
set -x DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
# Avoid name collision with floci/floci image during podman inspect
set -x FLOCI_CONTAINER floci-aws

# ── Wayland bridge for headless ssh/tmux shells ──────────────────────
# sshd hands out a clean env and the tmux server freezes whatever env it
# started with, so panes never see WAYLAND_DISPLAY even after login —
# GUI apps then fail with "no wayland session". uwsm exports the session
# env to the systemd user manager, which is per-user (not per-login), so
# any shell can recover it. No-op on macOS: no systemctl, never needed.
if not set -q WAYLAND_DISPLAY; and command -q systemctl
    set -l wl (systemctl --user show-environment 2>/dev/null | string match -r '^WAYLAND_DISPLAY=(.+)$')
    and set -gx WAYLAND_DISPLAY $wl[2]
end

fzf --fish | source
direnv hook fish | source
starship init fish | source

# alias pdx "~/.local/bin/tools/plandex"

# source ~/.asdf/asdf.fish
# fish_add_path -a /home/adophilus/.foundry/bin

# fish_add_path -a /home/adophilus/.foundry/bin
