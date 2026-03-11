--- isocon/init.lua
--- Public API for the isocon colorscheme.
--- Call `setup()` to configure options, then `load()` (or `:colorscheme isocon`)
--- to apply the theme.  `setup()` is optional — `load()` falls back to defaults.

local M = {}

local defaults = require("isocon.defaults")

--- Returns the default config for the current vim.o.background setting.
---@return IsoconConfig
local function get_defaults()
	return vim.o.background == "light" and defaults.light or defaults.dark
end

--- Store user config, merged over defaults.
--- Calling setup() is optional; load() uses defaults if setup() was never called.
---@param opts? IsoconConfig
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", get_defaults(), opts or {})
end

--- Apply the colorscheme to the current Neovim session.
--- Clears existing highlights, regenerates the palette from the stored config,
--- sets all highlight groups, and configures the 16 terminal colors.
--- `vim.o.background` is set automatically based on the background luminance.
function M.load()
	local cfg = M.config or get_defaults()

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") then
		vim.cmd("syntax reset")
	end
	vim.g.colors_name = "isocon"

	local color = require("isocon.color")
	local palette = require("isocon.palette")

	local p = palette.generate(cfg)

	-- Auto-detect dark/light from background luminance and inform Neovim,
	-- so plugins that branch on vim.o.background behave correctly
	local bg_rgb = color.hex_to_rgb(cfg.background)
	local Y_bg = color.wcag_luminance(bg_rgb.r, bg_rgb.g, bg_rgb.b)
	vim.o.background = Y_bg < 0.18 and "dark" or "light"

	-- Apply all highlight groups
	for group, spec in pairs(require("isocon.highlights").get(p)) do
		vim.api.nvim_set_hl(0, group, spec)
	end

	-- Map palette colors to the 16 ANSI terminal slots:
	--   0–7:  normal colors (black, red, green, yellow, blue, magenta, cyan, white)
	--   8–15: bright variants
	vim.g.terminal_color_0 = p.bg
	vim.g.terminal_color_1 = p.red
	vim.g.terminal_color_2 = p.green
	vim.g.terminal_color_3 = p.yellow
	vim.g.terminal_color_4 = p.blue
	vim.g.terminal_color_5 = p.magenta
	vim.g.terminal_color_6 = p.cyan
	vim.g.terminal_color_7 = p.fg
	vim.g.terminal_color_8 = p.bg_subtle
	vim.g.terminal_color_9 = p.br_red
	vim.g.terminal_color_10 = p.br_green
	vim.g.terminal_color_11 = p.br_yellow
	vim.g.terminal_color_12 = p.br_blue
	vim.g.terminal_color_13 = p.br_magenta
	vim.g.terminal_color_14 = p.br_cyan
	vim.g.terminal_color_15 = p.fg
end

--- Print the 16 ANSI terminal colors for the current config to the messages area.
--- Useful for copying values into terminal emulator configs.
function M.print_colors()
	local cfg = M.config or get_defaults()
	local p = require("isocon.palette").generate(cfg)

	local slots = {
		{ 0, "black   ", p.bg },
		{ 1, "red     ", p.red },
		{ 2, "green   ", p.green },
		{ 3, "yellow  ", p.yellow },
		{ 4, "blue    ", p.blue },
		{ 5, "magenta ", p.magenta },
		{ 6, "cyan    ", p.cyan },
		{ 7, "white   ", p.fg },
		{ 8, "br_black   ", p.bg_subtle },
		{ 9, "br_red     ", p.br_red },
		{ 10, "br_green   ", p.br_green },
		{ 11, "br_yellow  ", p.br_yellow },
		{ 12, "br_blue    ", p.br_blue },
		{ 13, "br_magenta ", p.br_magenta },
		{ 14, "br_cyan    ", p.br_cyan },
		{ 15, "br_white   ", p.fg },
	}

	print("isocon terminal colors:")
	for _, s in ipairs(slots) do
		print(string.format("  %2d  %s  %s", s[1], s[2], s[3]))
	end
end

return M
