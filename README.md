# isocon

A Neovim colorscheme where every syntax color has the same WCAG contrast ratio against the background, and hues are evenly spaced in perceptual color space.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ dir = '~/path/to/isocon' }
```

## Usage

```lua
require('isocon').setup({
  background   = '#1a1a2e', -- any hex color; dark/light auto-detected
  contrast     = 4.5,       -- WCAG contrast ratio (AA = 4.5, AAA = 7.0)
  bright_boost = 1.35,      -- chroma multiplier for bright terminal colors
})
vim.cmd('colorscheme isocon')
```

Or without `setup` to use the defaults:

```lua
vim.cmd('colorscheme isocon')
```

## How it works

Every foreground color is generated from the background using the same three-step process:

**1. Target luminance** — given a background luminance `Y_bg` and desired contrast ratio `CR`, solve for the foreground luminance:
- Dark background: `Y_fg = CR × (Y_bg + 0.05) − 0.05`
- Light background: `Y_fg = (Y_bg + 0.05) / CR − 0.05`

**2. Find lightness** — binary-search the Oklab `L` value such that the color at `(L, C, H)` hits `Y_fg` exactly.

**3. Max chroma** — binary-search for the highest chroma that keeps the color inside the sRGB gamut. Normal colors use 75% of that; bright variants use 100% (or `normal × bright_boost`, whichever is smaller).

The six hues are fixed at equal perceptual intervals in OKLCH: red 25°, yellow 85°, green 145°, cyan 200°, blue 260°, magenta 325°.

The result: every color you see in your editor has the same contrast against the background, and colors are as saturated as the gamut allows at that lightness.
