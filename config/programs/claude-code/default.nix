{
  config,
  lib,
  ...
}:

let
  # Shared cross-agent skill library — the same source that materializes
  # ~/.agents/skills. Claude Code doesn't read `.agents/` (open feature
  # requests #56193/#66352), but symlinked skill dirs ARE officially
  # supported and deduplicated, so each skill gets one symlink.
  # Out-of-store so the symlink targets the live ~/.agents path (survives
  # store-path changes on rebuild, and CC follows it to the same files).
  skillsDir = ../../../home/.agents/skills;
  skillNames = builtins.attrNames (builtins.readDir skillsDir);
in
{
  # NOTE: ~/.claude.json stays unmanaged on purpose — CC rewrites it
  # (state: OAuth session, user-scope MCP, per-project trust). CLAUDE.md IS
  # managed: the codegraph block is baked in verbatim (its markers make
  # `codegraph install` idempotent — prompt-hook never writes the file).
  # ponytail: if a future codegraph install rewrites the block, the RO
  # symlink makes it fail loudly → copy the new block into the repo.
  home.file = {
    ".claude/CLAUDE.md".source = ../../../home/.claude/CLAUDE.md;
    ".claude/settings.json".source = ../../../home/.claude/settings.json;
    ".claude/agents".source = ../../../home/.claude/agents;
  } // lib.genAttrs (map (name: ".claude/skills/${name}") skillNames) (
    path: {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills/${builtins.baseNameOf path}";
    }
  );
}
