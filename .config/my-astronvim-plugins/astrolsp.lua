return {
	"AstroNvim/astrolsp",
	---@type AstroLSPOpts
	opts = {
		formatting = {
			format_on_save = {
				enabled = false,
			},
		},
		servers = {
			"nixfmt"
		}
	},
}
