return {
  "zbirenbaum/copilot.lua",
  enabled = false,
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = "<C-y>",
          -- accept_word = false,
          -- accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      -- filetypes = {
      --   yaml = true,
      --   markdown = true,
      --   help = true,
      --   gitcommit = true,
      --   gitrebase = true,
      --   hgcommit = true,
      --   svn = true,
      --   cvs = true,
      --   ["."] = false,
      -- },
    })
  end,
}
