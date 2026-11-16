{
  lib,
  pkgs,
  ...
}:

{
  # Static charcoal snippet (palette source of truth:
  # home/.config/ghostty/themes/charcoal) symlinked into the vault.
  # No matugen — charcoal is a fixed palette, so a nix-store symlink
  # is simpler than the old generated-file indirection.
  home.file."Documents/pensive/.obsidian/snippets/charcoal.css".source = ./charcoal.css;

  # Enable "charcoal" and retire "matugen-theme" in appearance.json.
  # Idempotent jq merge — preserves any other snippet toggles. Obsidian
  # rewrites this file from memory on quit, so rebuild with Obsidian
  # closed (or the next rebuild re-applies).
  home.activation.obsidianCharcoalSnippet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    APPEARANCE="$HOME/Documents/pensive/.obsidian/appearance.json"
    if [ -f "$APPEARANCE" ]; then
      ${lib.getExe pkgs.jq} '.enabledCssSnippets = ((.enabledCssSnippets // []) - ["matugen-theme"] | if index("charcoal") then . else . + ["charcoal"] end)' "$APPEARANCE" > "$APPEARANCE.tmp" && mv "$APPEARANCE.tmp" "$APPEARANCE"
    fi
  '';
}
