# gh-dash — TUI dashboard for GitHub PRs and issues (auth via gh).
# No settings managed on purpose: gh-dash ships sane default sections and
# writes ~/.config/gh-dash/config.yml on first run, which stays hand-editable
# instead of fighting a read-only nix symlink.
{ ... }:

{
  programs.gh-dash.enable = true;
}
