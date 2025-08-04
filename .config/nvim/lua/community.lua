if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.just" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.nix" },
  { import = "astrocommunity.pack.php" },
  { import = "astrocommunity.pack.purescript" },
  -- { import = "astrocommunity.pack.typescript-deno" },
  -- { import = "astrocommunity.pack.typescript-all-in-one" },
  -- import/override with your plugins folder
  { import = "astrocommunity.recipes.ai" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.neovide" },
  { import = "astrocommunity.recipes.auto-session-restore" },
  { import = "astrocommunity.recipes.astrolsp-auto-signature-help" },
  { import = "astrocommunity.recipes.telescope-lsp-mappings" },
}
