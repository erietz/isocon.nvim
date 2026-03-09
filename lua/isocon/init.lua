--- isocon/init.lua
--- Public API for the isocon colorscheme.
--- Call `setup()` to configure options, then `load()` (or `:colorscheme isocon`)
--- to apply the theme.  `setup()` is optional — `load()` falls back to defaults.

local M = {}

--- Default configuration values.
---@type { background: string, contrast: number, bright_boost: number, hues: table<string, number> }
local defaults = {
  background   = '#1a1a2e', -- hex color that drives the entire palette
  contrast     = 4.5,       -- WCAG contrast ratio (AA = 4.5, AAA = 7.0)
  bright_boost = 1.35,      -- chroma multiplier for bright terminal colors (8–15)
  hues = {                  -- OKLCH hue angles (°) for each semantic color role
    red     = 25,
    green   = 145,
    yellow  = 85,
    blue    = 260,
    magenta = 325,
    cyan    = 200,
  },
}

--- Store user config, merged over defaults.
--- Calling setup() is optional; load() uses defaults if setup() was never called.
---@param opts? { background?: string, contrast?: number, bright_boost?: number, hues?: table<string, number> }
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})
end

--- Apply the colorscheme to the current Neovim session.
--- Clears existing highlights, regenerates the palette from the stored config,
--- sets all highlight groups, and configures the 16 terminal colors.
--- `vim.o.background` is set automatically based on the background luminance.
function M.load()
  local cfg = M.config or defaults

  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = 'isocon'

  local color   = require('isocon.color')
  local palette = require('isocon.palette')

  local p = palette.generate(cfg)

  -- Auto-detect dark/light from background luminance and inform Neovim,
  -- so plugins that branch on vim.o.background behave correctly
  local bg_rgb = color.hex_to_rgb(cfg.background)
  local Y_bg   = color.wcag_luminance(bg_rgb.r, bg_rgb.g, bg_rgb.b)
  vim.o.background = Y_bg < 0.18 and 'dark' or 'light'

  -- Apply all highlight groups
  for group, spec in pairs(require('isocon.highlights').get(p)) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- Map palette colors to the 16 ANSI terminal slots:
  --   0–7:  normal colors (black, red, green, yellow, blue, magenta, cyan, white)
  --   8–15: bright variants
  vim.g.terminal_color_0  = p.bg
  vim.g.terminal_color_1  = p.red
  vim.g.terminal_color_2  = p.green
  vim.g.terminal_color_3  = p.yellow
  vim.g.terminal_color_4  = p.blue
  vim.g.terminal_color_5  = p.magenta
  vim.g.terminal_color_6  = p.cyan
  vim.g.terminal_color_7  = p.fg
  vim.g.terminal_color_8  = p.bg_subtle
  vim.g.terminal_color_9  = p.br_red
  vim.g.terminal_color_10 = p.br_green
  vim.g.terminal_color_11 = p.br_yellow
  vim.g.terminal_color_12 = p.br_blue
  vim.g.terminal_color_13 = p.br_magenta
  vim.g.terminal_color_14 = p.br_cyan
  vim.g.terminal_color_15 = p.fg
end

return M
