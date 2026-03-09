-- isocon/palette.lua — Generate the full color palette from config
local color = require('isocon.color')

local M = {}

-- Semantic hues (OKLCH H values), chosen to be recognizable
local HUES = {
  red     = 25,
  green   = 145,
  yellow  = 85,
  blue    = 260,
  magenta = 325,
  cyan    = 200,
}

local NAMES = { 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan' }

function M.generate(opts)
  local bg_hex    = opts.background  or '#1a1a2e'
  local contrast  = opts.contrast    or 4.5
  local bright_boost = opts.bright_boost or 1.35

  -- Parse background
  local bg_rgb = color.hex_to_rgb(bg_hex)
  local Y_bg   = color.wcag_luminance(bg_rgb.r, bg_rgb.g, bg_rgb.b)

  -- Auto-detect dark/light
  local is_dark = Y_bg < 0.18

  -- Target luminance for normal foreground text
  local Y_fg = color.luminance_for_contrast(Y_bg, contrast)

  -- Target luminance for dim foreground (comments, line numbers)
  -- Use half the requested contrast ratio (clamped to ≥ 1.0)
  local dim_cr = math.max(1.5, contrast * 0.5)
  local Y_dim  = color.luminance_for_contrast(Y_bg, dim_cr)

  -- Achromatic fg and fg_dim
  local L_fg  = color.L_for_luminance(Y_fg,  0, 0)
  local L_dim = color.L_for_luminance(Y_dim, 0, 0)

  local fg_rgb  = color.oklch_to_rgb(L_fg,  0, 0)
  local dim_rgb = color.oklch_to_rgb(L_dim, 0, 0)

  -- Subtle background variant (slightly lighter/darker than bg)
  local bg_oklch = color.rgb_to_oklch(bg_rgb.r, bg_rgb.g, bg_rgb.b)
  local subtle_L = is_dark
    and math.min(1, bg_oklch.L + 0.04)
    or  math.max(0, bg_oklch.L - 0.04)
  local subtle_rgb = color.oklch_to_rgb(subtle_L, bg_oklch.C, bg_oklch.H)

  -- Float background (slightly different from bg)
  local float_L = is_dark
    and math.min(1, bg_oklch.L + 0.02)
    or  math.max(0, bg_oklch.L - 0.02)
  local float_rgb = color.oklch_to_rgb(float_L, bg_oklch.C, bg_oklch.H)

  local palette = {
    bg       = bg_hex,
    fg       = color.rgb_to_hex(fg_rgb.r,     fg_rgb.g,     fg_rgb.b),
    fg_dim   = color.rgb_to_hex(dim_rgb.r,    dim_rgb.g,    dim_rgb.b),
    bg_subtle = color.rgb_to_hex(subtle_rgb.r, subtle_rgb.g, subtle_rgb.b),
    bg_float  = color.rgb_to_hex(float_rgb.r,  float_rgb.g,  float_rgb.b),
    is_dark  = is_dark,
  }

  -- Generate 6 chromatic colors + bright variants
  for _, name in ipairs(NAMES) do
    local H = HUES[name]

    -- Find L that gives the target WCAG luminance at this hue
    -- Start with C=0.15 as a reasonable mid-chroma estimate
    local L = color.L_for_luminance(Y_fg, 0.15, H)

    -- Find max chroma at this L and H
    local cmax = color.max_chroma(L, H)

    -- Normal: 75% of max chroma
    local C_normal = cmax * 0.75
    local rgb_normal = color.oklch_to_rgb(L, C_normal, H)
    palette[name] = color.rgb_to_hex(rgb_normal.r, rgb_normal.g, rgb_normal.b)

    -- Bright: boosted chroma, capped at max
    local C_bright = math.min(cmax, C_normal * bright_boost)
    local rgb_bright = color.oklch_to_rgb(L, C_bright, H)
    palette['br_' .. name] = color.rgb_to_hex(rgb_bright.r, rgb_bright.g, rgb_bright.b)
  end

  -- Cursor color (inverted fg/bg for visibility)
  palette.cursor_fg = palette.bg
  palette.cursor_bg = palette.fg

  return palette
end

return M
