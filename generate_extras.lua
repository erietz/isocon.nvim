--- generate_extras.lua
--- Generates ghostty, tmux, and fish theme files from isocon palettes.
---
--- Two ways to run:
---   lua generate_extras.lua
---       No config available: generates BOTH stock variants from defaults.lua.
---   nvim --headless -c 'luafile generate_extras.lua' -c 'qa!'
---       Loads your init.lua first, so isocon.config reflects your tweaks;
---       generates ONLY the currently active variant (light or dark).
---
--- Note: `nvim --headless -l` does NOT load init.lua, so it cannot see your
--- config. Use `-c 'luafile ...'` (above) to pick up your tweaks.

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

-- Return the live user config if isocon.setup() has run (init.lua loaded),
-- otherwise nil.
local function get_live_config()
	if vim then
		local ok, isocon = pcall(require, "isocon")
		if ok and isocon.config then
			return isocon.config
		end
	end
	return nil
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
		"selection-background = " .. bare(p.fg),
		"selection-foreground = " .. bare(p.bg),
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
		string.format('set -g mode-style "bg=%s,fg=%s"', p.fg, p.bg),
		string.format('set -g pane-border-style "fg=%s"', p.bg_subtle),
		string.format('set -g pane-active-border-style "fg=%s"', p.blue),
		string.format(
			'set -g window-status-current-style "fg=%s,bold"',
			p.blue
		),
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
		"set -g fish_color_selection --background="
			.. bare(p.fg)
			.. " --color="
			.. bare(p.bg),
		"set -g fish_color_search_match --background="
			.. bare(p.fg)
			.. " --color="
			.. bare(p.bg),
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

-- Generate all three theme files for one config. The variant (dark/light) is
-- derived from the resolved palette, not guessed from the background hex, so a
-- tweaked background lands in the correct extras/<variant>/ directory.
local base = script_dir or "./"
local function generate(cfg)
	local p = palette.generate(cfg)
	local variant = p.is_dark and "dark" or "light"

	local dir = base .. "extras/" .. variant .. "/"
	write_file(dir .. "isocon-" .. variant .. ".ghostty", gen_ghostty(p))
	write_file(dir .. "isocon-" .. variant .. ".tmux", gen_tmux(p))
	write_file(dir .. "isocon-" .. variant .. ".fish", gen_fish(p))

	print("Generated " .. variant .. " extras in " .. dir)
end

local live = get_live_config()
if live then
	-- Loaded via nvim with init.lua: emit only the active, tweaked variant.
	generate(live)
else
	-- Plain `lua` / no config: emit both stock variants from defaults.
	generate(defaults.dark)
	generate(defaults.light)
end
