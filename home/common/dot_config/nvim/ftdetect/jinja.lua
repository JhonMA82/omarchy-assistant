-- Detección de plantillas Jinja con lenguaje anfitrión.
-- `lib.rs.jinja` → rust, `Cargo.toml.jinja` → toml, `x.jinja` → jinja.
-- Tiene prioridad sobre la extensión `.jinja` de Neovim.
vim.filetype.add({
	-- Ojo: vim.filetype.add ancla los patrones con ^...$ automáticamente,
	-- por eso la clave no lleva ^ ni $.
	pattern = {
		[".*%.jinja"] = function(path)
			local base = path:gsub("%.jinja$", "")
			return vim.filetype.match({ filename = base }) or "jinja"
		end,
	},
})
