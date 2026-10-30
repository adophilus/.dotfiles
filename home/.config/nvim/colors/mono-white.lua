-- Mono-white: pure monochrome light (grayscale, zero hue) — same gray ladder
-- as ghostty themes/mono-white. Deliberately pinned light: does not follow
-- vim.o.background.

vim.cmd "highlight clear"
vim.o.background = "light" -- deliberate: this theme is light regardless of the terminal
vim.g.colors_name = "mono-white"

local C = {
  bg = "#ffffff", bg_soft = "#fafafa", panel = "#e1e1e1",
  fg = "#000000", ink = "#000000", ink_soft = "#1f1f1f",
  strong = "#333333", body = "#404040",
  dim = "#757575", muted = "#8f8f8f", faint = "#a1a1a1",
  sel = "#bfbfbf", border = "#c2c2c2", raised = "#d9d9d9",
  red = "#000000", green = "#333333", yellow = "#333333",
  blue = "#333333", magenta = "#333333", cyan = "#333333",
}

-- terminal palette slots 0-15 (mirrors ghostty mono-white exactly)
for i, hex in ipairs({
  "#e1e1e1", "#666666", "#666666", "#666666", "#666666", "#666666", "#666666", "#7f7f7f",
  "#c2c2c2", "#333333", "#333333", "#333333", "#333333", "#333333", "#333333", "#000000",
}) do
  vim.g["terminal_color_" .. (i - 1)] = hex
end

local hi = vim.api.nvim_set_hl

-- UI
hi(0, "Normal", { fg = C.fg, bg = C.bg })
hi(0, "NormalFloat", { fg = C.fg, bg = C.bg_soft })
hi(0, "FloatBorder", { fg = C.border, bg = C.bg_soft })
hi(0, "FloatTitle", { fg = C.ink, bg = C.bg_soft, bold = true })
hi(0, "Cursor", { fg = C.bg, bg = "#000000" })
hi(0, "CursorLine", { bg = "#f2f2f2" })
hi(0, "CursorLineNr", { fg = C.dim, bold = true })
hi(0, "LineNr", { fg = C.faint })
hi(0, "SignColumn", { bg = C.bg })
hi(0, "FoldColumn", { fg = C.muted, bg = C.bg })
hi(0, "Visual", { fg = C.fg, bg = C.sel })
hi(0, "Search", { fg = C.fg, bg = C.raised })
hi(0, "IncSearch", { fg = "#ffffff", bg = C.body })
hi(0, "CurSearch", { link = "IncSearch" })
hi(0, "MatchParen", { fg = C.ink, bg = C.raised, bold = true })
hi(0, "Pmenu", { fg = C.fg, bg = C.bg_soft })
hi(0, "PmenuSel", { fg = C.fg, bg = C.panel })
hi(0, "StatusLine", { fg = C.fg, bg = C.panel })
hi(0, "StatusLineNC", { fg = C.dim, bg = C.bg_soft })
hi(0, "WinSeparator", { fg = C.border })
hi(0, "NonText", { fg = "#c8c8c8" })
hi(0, "Whitespace", { fg = "#c8c8c8" })
hi(0, "Conceal", { fg = C.dim })
hi(0, "Title", { fg = C.ink, bold = true })
hi(0, "Directory", { fg = C.body, bold = true })

-- diagnostics / git — pure monochrome: emphasis via weight, not hue
hi(0, "Error", { fg = C.red, bold = true, underline = true })
hi(0, "ErrorMsg", { fg = C.red, bold = true })
hi(0, "WarningMsg", { fg = C.yellow, bold = true })
hi(0, "MoreMsg", { fg = C.green })
hi(0, "Added", { fg = "#333333", bold = true })
hi(0, "Removed", { fg = "#666666" })
hi(0, "Changed", { fg = "#404040", bold = true })
hi(0, "DiffAdd", { fg = "#333333", bg = "#f0f0f0" })
hi(0, "DiffDelete", { fg = "#666666", bg = "#e6e6e6" })
hi(0, "DiffChange", { fg = "#404040", bg = "#e1e1e1" })
hi(0, "DiffText", { fg = C.ink, bg = "#d4d4d4", bold = true })

-- syntax (near-black ladder, emphasis via darkness)
hi(0, "Comment", { fg = C.muted, italic = true })
hi(0, "String", { fg = C.body })
hi(0, "Character", { link = "String" })
hi(0, "Constant", { fg = C.strong })
hi(0, "Number", { link = "Constant" })
hi(0, "Boolean", { link = "Constant" })
hi(0, "Float", { link = "Constant" })
hi(0, "Identifier", { fg = "#393939" })
hi(0, "Function", { fg = C.ink_soft })
hi(0, "Statement", { fg = "#000000" })
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
