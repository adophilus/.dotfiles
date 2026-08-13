# fish_config theme save "Catppuccin Mocha"

set -x GOPATH "$HOME/go"
set -x BUNPATH "$HOME/.bun"
set -x DENOPATH "$HOME/.deno"
set -x CARGOPATH "$HOME/.cargo"
set -x TOOLSPATH "$HOME/.local/bin/tools"

fish_add_path -g "$GOPATH/bin"
fish_add_path -g "$BUNPATH/bin"
fish_add_path -g "$DENOPATH/bin"
fish_add_path -g "$CARGOPATH/bin"
fish_add_path -g "$TOOLSPATH"

direnv hook fish | source
starship init fish | source

alias pdx "~/.local/bin/tools/plandex"

source ~/.asdf/asdf.fish
# fish_add_path -a /home/adophilus/.foundry/bin

fish_add_path -a /home/adophilus/.foundry/bin
