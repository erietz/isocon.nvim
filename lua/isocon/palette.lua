--- isocon/palette.lua
--- Generates the full named color palette from a config table.
--- All chromatic colors are computed so that their WCAG contrast ratio
--- against the background matches `opts.contrast`.

local color = require('isocon.color')

local M = {}

--- Default OKLCH hue angles for each semantic color role.
--- Values are chosen to be perceptually recognizable as their named color.
--- See the README for a full explanation of each choice.
---@type table<string, number>
local DEFAULT_HUES = {
  red     = 25,   -- warm red; lower drifts pink, higher drifts orange
  green   = 145,  -- mid green; lower is lime, higher is teal
  yellow  = 85,   -- pure yellow; lower is orange, higher is yellow-green
  blue    = 260,  -- prototypical blue; lower is violet, higher is indigo
  magenta = 325,  -- clear magenta; lower is purple, higher is hot pink
  cyan    = 200,  -- teal-cyan; lower merges with green, higher drifts blue
}

--- Iteration order for the six chromatic hues.
---@type string[]
local NAMES = { 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan' }

--- Generate the complete isocon palette from a config table.
---
--- For each of the six semantic hues the function:
---   1. Binary-searches Oklab L so the color's WCAG luminance equals Y_fg.
---   2. Finds the maximum sRGB-gamut chroma at that (L, H).
---   3. Uses 75 % of max chroma for the normal variant.
---   4. Uses min(100 % max_chroma, normal × bright_boost) for the bright variant.
---
--- Achromatic colors (fg, fg_dim) are produced by the same luminance search
--- at C = 0.  Background variants are nudged ±0.04 / ±0.02 in Oklab L.
---
--- Individual hues can be overridden via `opts.hues`; any key not provided
--- falls back to the DEFAULT_HUES value.
---
---@param opts { background: string, contrast: number, bright_boost: number, hues?: table<string, number> }
---@return table Palette with the following string keys (all hex unless noted):
---   bg, fg, fg_dim, bg_subtle, bg_float,
---   red, green, yellow, blue, magenta, cyan,
---   br_red, br_green, br_yellow, br_blue, br_magenta, br_cyan,
---   cursor_fg, cursor_bg,
---   is_dark (boolean)
function M.generate(opts)
  local bg_hex       = opts.background   or '#1a1a2e'
  local contrast     = opts.contrast     or 4.5
  local bright_boost = opts.bright_boost or 1.35
  local hues         = vim.tbl_extend('force', DEFAULT_HUES, opts.hues or {})

  -- Parse background and derive its WCAG luminance
  local bg_rgb = color.hex_to_rgb(bg_hex)
  local Y_bg   = color.wcag_luminance(bg_rgb.r, bg_rgb.g, bg_rgb.b)

  -- Luminance below 0.18 is treated as a dark background
  local is_dark = Y_bg < 0.18

  -- Target luminance for normal foreground text at the requested contrast ratio
  local Y_fg = color.luminance_for_contrast(Y_bg, contrast)

  -- Dim foreground for comments and line numbers: half the contrast ratio,
  -- clamped to a minimum of 1.5:1 to stay visible
  local dim_cr = math.max(1.5, contrast * 0.5)
  local Y_dim  = color.luminance_for_contrast(Y_bg, dim_cr)

  -- Achromatic (C=0) lightness values for fg and fg_dim
  local L_fg  = color.L_for_luminance(Y_fg,  0, 0)
  local L_dim = color.L_for_luminance(Y_dim, 0, 0)

  local fg_rgb  = color.oklch_to_rgb(L_fg,  0, 0)
  local dim_rgb = color.oklch_to_rgb(L_dim, 0, 0)

  -- Background variants: nudge the background's Oklab L slightly
  -- while preserving its hue and chroma so the shift feels neutral
  local bg_oklch = color.rgb_to_oklch(bg_rgb.r, bg_rgb.g, bg_rgb.b)

  local subtle_L = is_dark
    and math.min(1, bg_oklch.L + 0.04)
    or  math.max(0, bg_oklch.L - 0.04)
  local subtle_rgb = color.oklch_to_rgb(subtle_L, bg_oklch.C, bg_oklch.H)

  local float_L = is_dark
    and math.min(1, bg_oklch.L + 0.02)
    or  math.max(0, bg_oklch.L - 0.02)
  local float_rgb = color.oklch_to_rgb(float_L, bg_oklch.C, bg_oklch.H)

  local palette = {
    bg        = bg_hex,
    fg        = color.rgb_to_hex(fg_rgb.r,     fg_rgb.g,     fg_rgb.b),
    fg_dim    = color.rgb_to_hex(dim_rgb.r,    dim_rgb.g,    dim_rgb.b),
    bg_subtle = color.rgb_to_hex(subtle_rgb.r, subtle_rgb.g, subtle_rgb.b),
    bg_float  = color.rgb_to_hex(float_rgb.r,  float_rgb.g,  float_rgb.b),
    is_dark   = is_dark,
  }

  -- Generate each chromatic color and its bright variant
  for _, name in ipairs(NAMES) do
    local H = hues[name]

    -- Find L that hits Y_fg at a representative mid-chroma.
    -- C=0.15 is used as the search chroma so L accounts for hue-dependent
    -- lightness shifts; the actual chroma is set separately below.
    local L = color.L_for_luminance(Y_fg, 0.15, H)

    -- Maximum in-gamut chroma at this (L, H)
    local cmax = color.max_chroma(L, H)

    -- Normal color: 75 % of max chroma for a saturated but not extreme look
    local C_normal   = cmax * 0.75
    local rgb_normal = color.oklch_to_rgb(L, C_normal, H)
    palette[name]    = color.rgb_to_hex(rgb_normal.r, rgb_normal.g, rgb_normal.b)

    -- Bright color: boosted chroma, capped at the gamut boundary
    local C_bright   = math.min(cmax, C_normal * bright_boost)
    local rgb_bright = color.oklch_to_rgb(L, C_bright, H)
    palette['br_' .. name] = color.rgb_to_hex(rgb_bright.r, rgb_bright.g, rgb_bright.b)
  end

  -- Cursor: inverted fg/bg for maximum visibility
  palette.cursor_fg = palette.bg
  palette.cursor_bg = palette.fg

  return palette
end

return M
