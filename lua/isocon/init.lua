-- isocon/init.lua — Public API
local M = {}

local defaults = {
  background   = '#1a1a2e',
  contrast     = 4.5,
  bright_boost = 1.35,
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})
end

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

  -- Auto-set vim.o.background based on luminance
  local bg_rgb = color.hex_to_rgb(cfg.background)
  local Y_bg   = color.wcag_luminance(bg_rgb.r, bg_rgb.g, bg_rgb.b)
  vim.o.background = Y_bg < 0.18 and 'dark' or 'light'

  -- Apply highlight groups
  for group, spec in pairs(require('isocon.highlights').get(p)) do
    vim.api.nvim_set_hl(0, group, spec)
  end

  -- Terminal colors (16 ANSI colors)
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
