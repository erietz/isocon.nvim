--- generate_extras.lua
--- Generates ghostty, tmux, and fish theme files from isocon palettes.
--- Works with plain `lua` (defaults only) or `nvim --headless -l` (picks up user config).

-- Set up package.path so we can require isocon modules without Neovim
local source = debug.getinfo(1, "S").source:gsub("^@", "")
local script_dir = source:match("(.*/)") or "./"
package.path = script_dir
	.. "lua/?.lua;"
	.. script_dir
	.. "lua/?/init.lua;"
	.. package.path

local palette = require("isocon.palette")
local defaults = require("isocon.defaults")

local function get_config(variant)
	if vim then
		local ok, isocon = pcall(require, "isocon")
		if ok and isocon.config then
			return isocon.config
		end
	end
	return variant == "light" and defaults.light or defaults.dark
end

-- Strip leading # from hex color
local function bare(hex)
	return hex:gsub("^#", "")
end

-- Build the 16-color ANSI table from a palette
local function ansi(p)
	return {
		[0] = p.bg,
		[1] = p.red,
		[2] = p.green,
		[3] = p.yellow,
		[4] = p.blue,
		[5] = p.magenta,
		[6] = p.cyan,
		[7] = p.fg,
		[8] = p.fg_dim,
		[9] = p.br_red,
		[10] = p.br_green,
		[11] = p.br_yellow,
		[12] = p.br_blue,
		[13] = p.br_magenta,
		[14] = p.br_cyan,
		[15] = p.fg,
	}
end

-- Ghostty theme
local function gen_ghostty(p)
	local a = ansi(p)
	local lines = {
		"background = " .. bare(p.bg),
		"foreground = " .. bare(p.fg),
		"cursor-color = " .. bare(p.cursor_bg),
		"cursor-text = " .. bare(p.cursor_fg),
		"selection-background = " .. bare(p.bg_visual),
		"selection-foreground = " .. bare(p.fg),
	}
	for i = 0, 15 do
		lines[#lines + 1] = "palette = " .. i .. "=#" .. bare(a[i])
	end
	return table.concat(lines, "\n") .. "\n"
end

-- Tmux theme
local function gen_tmux(p)
	local label = p.is_dark and "Dark" or "Light"
	local lines = {
		"# Isocon " .. label .. " theme for tmux",
		"",
		string.format('set -g status-style "bg=%s,fg=%s"', p.bg, p.fg),
		string.format('set -g message-style "bg=%s,fg=%s"', p.bg_visual, p.fg),
		string.format(
			'set -g message-command-style "bg=%s,fg=%s"',
			p.bg_visual,
			p.fg
		),
		string.format('set -g mode-style "bg=%s,fg=%s"', p.bg_visual, p.fg),
		string.format('set -g pane-border-style "fg=%s"', p.bg_subtle),
		string.format('set -g pane-active-border-style "fg=%s"', p.blue),
		string.format('set -g window-status-current-style "fg=%s,bold"', p.blue),
		string.format('set -g window-status-style "fg=%s"', p.fg),
	}
	return table.concat(lines, "\n") .. "\n"
end

-- Fish theme
local function gen_fish(p)
	local label = p.is_dark and "Dark" or "Light"
	local lines = {
		"# Isocon " .. label .. " theme for fish",
		"",
		"set -g fish_color_normal " .. bare(p.fg),
		"set -g fish_color_command " .. bare(p.blue),
		"set -g fish_color_keyword " .. bare(p.magenta),
		"set -g fish_color_quote " .. bare(p.green),
		"set -g fish_color_redirection " .. bare(p.cyan),
		"set -g fish_color_end " .. bare(p.magenta),
		"set -g fish_color_error " .. bare(p.red),
		"set -g fish_color_param " .. bare(p.fg),
		"set -g fish_color_comment " .. bare(p.fg_dim),
		"set -g fish_color_selection --background=" .. bare(p.bg_visual),
		"set -g fish_color_search_match --background=" .. bare(p.bg_visual),
		"set -g fish_color_operator " .. bare(p.cyan),
		"set -g fish_color_escape " .. bare(p.magenta),
		"set -g fish_color_autosuggestion " .. bare(p.fg_dim),
		"set -g fish_pager_color_progress " .. bare(p.fg_dim),
		"set -g fish_pager_color_prefix " .. bare(p.blue),
		"set -g fish_pager_color_completion " .. bare(p.fg),
		"set -g fish_pager_color_description " .. bare(p.fg_dim),
	}
	return table.concat(lines, "\n") .. "\n"
end

-- Write a file, creating parent directories as needed
local function write_file(path, content)
	-- Create parent dirs
	local dir = path:match("(.+)/[^/]+$")
	if dir then
		os.execute('mkdir -p "' .. dir .. '"')
	end
	local f = assert(io.open(path, "w"))
	f:write(content)
	f:close()
end

-- Generate for both variants
local base = script_dir or "./"
for _, variant in ipairs({ "dark", "light" }) do
	local cfg = get_config(variant)
	if variant == "light" and cfg.background == defaults.dark.background then
		cfg = defaults.light
	elseif
		variant == "dark" and cfg.background == defaults.light.background
	then
		cfg = defaults.dark
	end
	local p = palette.generate(cfg)

	local dir = base .. "extras/" .. variant .. "/"
	write_file(dir .. "isocon-" .. variant .. ".ghostty", gen_ghostty(p))
	write_file(dir .. "isocon-" .. variant .. ".tmux", gen_tmux(p))
	write_file(dir .. "isocon-" .. variant .. ".fish", gen_fish(p))

	print("Generated " .. variant .. " extras in " .. dir)
end
