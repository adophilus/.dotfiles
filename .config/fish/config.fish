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

# Point Docker-compatible tools at podman's rootless socket
set -x DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
# Avoid name collision with floci/floci image during podman inspect
set -x FLOCI_CONTAINER floci-aws

fzf --fish | source
direnv hook fish | source
starship init fish | source

# alias pdx "~/.local/bin/tools/plandex"

# source ~/.asdf/asdf.fish
# fish_add_path -a /home/adophilus/.foundry/bin

# fish_add_path -a /home/adophilus/.foundry/bin
