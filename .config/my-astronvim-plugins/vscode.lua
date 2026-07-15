if not vim.g.vscode then return {} end -- don't do anything in non-vscode instances

local vscode = require('vscode')

local enabled = {}
vim.tbl_map(function(plugin) enabled[plugin] = true end, {
  -- core plugins
  "lazy.nvim",
  "AstroNvim",
  "astrocore",
  "astroui",
  "Comment.nvim",
  "nvim-autopairs",
  "nvim-treesitter",
  "nvim-ts-autotag",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  -- more known working
  "dial.nvim",
  "flash.nvim",
  "flit.nvim",
  "leap.nvim",
  "mini.ai",
  "mini.comment",
  "mini.move",
  "mini.pairs",
  "mini.surround",
  "ts-comments.nvim",
  "vim-easy-align",
  "vim-repeat",
  "vim-sandwich",
  "yanky.nvim",
  -- feel free to open PRs to add more support!
})

local Config = require "lazy.core.config"
-- disable plugin update checking
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
-- replace the default `cond`
Config.options.defaults.cond = function(plugin) return enabled[plugin.name] end

---@type LazySpec
return {
  -- add a few keybindings
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      local maps = assert(opts.mappings)

      -- basic actions
      -- maps.n["<Leader>q"] = function() vscode.action "workbench.action.closeWindow" end
      maps.n[":q"] = function() vscode.action "workbench.action.closeEditorsInGroup" end
      -- maps.n["<Leader>w"] = function() vscode.action "workbench.action.files.save" end
      -- maps.n["<Leader>n"] = function() vscode.action "welcome.showNewFileEntries" end
      maps.n["<Leader>n"] = function() vscode.action "workbench.action.files.newUntitledFile" end

      -- splits navigation
      maps.n["|"] = function() vscode.action "workbench.action.splitEditor" end
      maps.n["\\"] = function() vscode.action "workbench.action.splitEditorDown" end
      maps.n["<C-H>"] = function() vscode.action "workbench.action.navigateLeft" end
      maps.n["<C-J>"] = function() vscode.action "workbench.action.navigateDown" end
      maps.n["<C-K>"] = function() vscode.action "workbench.action.navigateUp" end
      maps.n["<C-L>"] = function() vscode.action "workbench.action.navigateRight" end

      -- terminal
      -- maps.n["<F7>"] = function() vscode.action "workbench.action.terminal.toggleTerminal" end
      -- maps.n["<C-'>"] = function() vscode.action "workbench.action.terminal.toggleTerminal" end
      maps.n["<Leader>th"] = function() vscode.action "workbench.action.terminal.toggleTerminal" end

      -- buffer management
      maps.n["]b"] = "<Cmd>Tabnext<CR>"
      maps.n["[b"] = "<Cmd>Tabprevious<CR>"
      maps.n["<Leader>c"] = "<Cmd>Tabclose<CR>"
      maps.n["<Leader>C"] = "<Cmd>Tabclose!<CR>"
      maps.n["<Leader>bp"] = "<Cmd>Tablast<CR>"
      maps.n["<Leader>bc"] = function() vscode.action "workbench.action.closeAllEditors" end

      -- file explorer
      maps.n["<Leader>e"] = function() vscode.action "workbench.action.toggleSidebarVisibility" end
      maps.n["<Leader>o"] = function() vscode.action "workbench.files.action.focusFilesExplorer" end

      -- indentation
      -- maps.v["<Tab>"] = function() vscode.action "editor.action.indentLines" end
      -- maps.v["<S-Tab>"] = function() vscode.action "editor.action.outdentLines" end

      -- diagnostics
      maps.n["]d"] = function() vscode.action "editor.action.marker.nextInFiles" end
      maps.n["[d"] = function() vscode.action "editor.action.marker.prevInFiles" end

      -- pickers (emulate telescope mappings)
      maps.n["<Leader>fc"] = function()
        vscode.action("workbench.action.findInFiles", { args = { query = vim.fn.expand "<cword>" } })
      end
      maps.n["<Leader>fC"] = function() vscode.action "workbench.action.showCommands" end
      maps.n["<Leader>ff"] = function() vscode.action "workbench.action.quickOpen" end
      maps.n["<Leader>fn"] = function() vscode.action "notifications.showList" end
      maps.n["<Leader>fo"] = function() vscode.action "workbench.action.openRecent" end
      maps.n["<Leader>ft"] = function() vscode.action "workbench.action.selectTheme" end
      maps.n["<Leader>fw"] = function() vscode.action "workbench.action.findInFiles" end

      -- git client
      maps.n["<Leader>gg"] = function() vscode.action "workbench.view.scm" end

      -- LSP Mappings
      maps.n["K"] = function() vscode.action "editor.action.showHover" end
      maps.n["gI"] = function() vscode.action "editor.action.goToImplementation" end
      maps.n["gd"] = function() vscode.action "editor.action.revealDefinition" end
      maps.n["gD"] = function() vscode.action "editor.action.revealDeclaration" end
      maps.n["gr"] = function() vscode.action "editor.action.goToReferences" end
      maps.n["gy"] = function() vscode.action "editor.action.goToTypeDefinition" end
      maps.n["<Leader>la"] = function() vscode.action "editor.action.quickFix" end
      maps.n["<Leader>lG"] = function() vscode.action "workbench.action.showAllSymbols" end
      maps.n["<Leader>lR"] = function() vscode.action "editor.action.goToReferences" end
      maps.n["<Leader>lr"] = function() vscode.action "editor.action.rename" end
      maps.n["<Leader>ls"] = function() vscode.action "workbench.action.gotoSymbol" end
      maps.n["<Leader>lf"] = function() vscode.action "editor.action.formatDocument" end
    end,
  },
  -- disable colorscheme setting
  { "AstroNvim/astroui", opts = { colorscheme = false } },
  -- disable treesitter highlighting
  { "nvim-treesitter/nvim-treesitter", opts = { highlight = { enable = false } } },
}
