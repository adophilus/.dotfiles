-- Charcoal-light: luminance-mirrored charcoal (same ramp as ghostty
-- themes/charcoal-light — HSL lightness inverted, hue tints preserved).
-- Trial companion to VyomJain6904/charcoal.nvim (dark-only). Deliberately
-- pinned light: does not follow vim.o.background.

vim.cmd "highlight clear"
vim.o.background = "light" -- deliberate: this theme is light regardless of the terminal
vim.g.colors_name = "charcoal-light"

local C = {
  bg = "#f2f2f2", bg_soft = "#ebebeb", panel = "#e1e1e1",
  fg = "#2b2b2b", ink = "#171717", ink_soft = "#1f1f1f",
  strong = "#333333", body = "#4b4b4b",
  dim = "#757575", muted = "#8f8f8f", faint = "#a1a1a1",
  sel = "#aaaaaa", border = "#cccccc", raised = "#d9d9d9",
  red = "#6f5f5f", green = "#5f6f5f", yellow = "#6f695f",
  blue = "#5f676f", magenta = "#695f6f", cyan = "#5f6f6f",
}

-- terminal palette slots 0-15 (mirrors ghostty charcoal-light exactly)
for i, hex in ipairs({
  "#e1e1e1", "#958585", "#859585", "#959085", "#858b95", "#908595", "#859395", "#7b7b7b",
  "#cccccc", "#6f5f5f", "#5f6f5f", "#6f695f", "#5f676f", "#695f6f", "#5f6f6f", "#2b2b2b",
}) do
  vim.g["terminal_color_" .. (i - 1)] = hex
end

local hi = vim.api.nvim_set_hl

-- UI
hi(0, "Normal", { fg = C.fg, bg = C.bg })
hi(0, "NormalFloat", { fg = C.fg, bg = C.bg_soft })
hi(0, "FloatBorder", { fg = C.border, bg = C.bg_soft })
hi(0, "FloatTitle", { fg = C.ink, bg = C.bg_soft, bold = true })
hi(0, "Cursor", { fg = C.bg, bg = "#0b0b0b" })
hi(0, "CursorLine", { bg = "#e8e8e8" })
hi(0, "CursorLineNr", { fg = C.dim, bold = true })
hi(0, "LineNr", { fg = C.faint })
hi(0, "SignColumn", { bg = C.bg })
hi(0, "FoldColumn", { fg = C.muted, bg = C.bg })
hi(0, "Visual", { fg = C.fg, bg = C.sel })
hi(0, "Search", { fg = C.fg, bg = C.raised })
hi(0, "IncSearch", { fg = "#f2f2f2", bg = C.body })
hi(0, "CurSearch", { link = "IncSearch" })
hi(0, "MatchParen", { fg = C.ink, bg = C.raised, bold = true })
hi(0, "Pmenu", { fg = C.fg, bg = C.bg_soft })
hi(0, "PmenuSel", { fg = C.fg, bg = C.panel })
hi(0, "StatusLine", { fg = C.fg, bg = C.panel })
hi(0, "StatusLineNC", { fg = C.dim, bg = C.bg_soft })
hi(0, "WinSeparator", { fg = C.border })
hi(0, "NonText", { fg = "#c4c4c4" })
hi(0, "Whitespace", { fg = "#c4c4c4" })
hi(0, "Conceal", { fg = C.dim })
hi(0, "Title", { fg = C.ink, bold = true })
hi(0, "Directory", { fg = C.body, bold = true })

-- diagnostics / git
hi(0, "Error", { fg = C.red, bold = true })
hi(0, "ErrorMsg", { fg = C.red })
hi(0, "WarningMsg", { fg = C.yellow })
hi(0, "MoreMsg", { fg = C.green })
hi(0, "Added", { fg = "#4f4f4f" })
hi(0, "Removed", { fg = "#7b7b7b" })
hi(0, "Changed", { fg = "#4b4b4b" })
hi(0, "DiffAdd", { fg = "#4f4f4f", bg = "#e5e5e5" })
hi(0, "DiffDelete", { fg = "#7b7b7b", bg = "#ebebeb" })
hi(0, "DiffChange", { fg = "#4b4b4b", bg = "#e1e1e1" })
hi(0, "DiffText", { fg = C.ink, bg = "#d5d5d5", bold = true })

-- syntax (mirrors charcoal's dark ramp: keyword=accent, string=soft, fn=near-ink)
hi(0, "Comment", { fg = C.muted, italic = true })
hi(0, "String", { fg = C.body })
hi(0, "Character", { link = "String" })
hi(0, "Constant", { fg = C.strong })
hi(0, "Number", { link = "Constant" })
hi(0, "Boolean", { link = "Constant" })
hi(0, "Float", { link = "Constant" })
hi(0, "Identifier", { fg = "#393939" })
hi(0, "Function", { fg = C.ink_soft })
hi(0, "Statement", { fg = "#0b0b0b" })
hi(0, "Keyword", { link = "Statement" })
hi(0, "Conditional", { link = "Statement" })
hi(0, "Repeat", { link = "Statement" })
hi(0, "Label", { link = "Statement" })
hi(0, "Exception", { link = "Statement" })
hi(0, "Operator", { fg = "#696969" })
hi(0, "PreProc", { fg = "#5f5f5f" })
hi(0, "Type", { fg = "#151515" })
hi(0, "Special", { fg = C.body })
hi(0, "Underlined", { fg = C.body, underline = true })
