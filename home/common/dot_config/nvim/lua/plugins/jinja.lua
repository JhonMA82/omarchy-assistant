-- Soporte para plantillas Jinja (.jinja).
-- La detección del lenguaje anfitrión vive en ftdetect/jinja.lua
-- (`lib.rs.jinja` → rust); aquí se aseguran los parsers treesitter:
-- jinja/jinja_inline para .jinja planos y rust como anfitrión típico.
return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "jinja", "jinja_inline", "rust" })
		end,
	},
}
