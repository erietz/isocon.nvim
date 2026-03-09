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
  hues = {                  -- OKLCH hue angles in degrees (all optional)
    red     = 25,
    green   = 145,
    yellow  = 85,
    blue    = 260,
    magenta = 325,
    cyan    = 200,
  },
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

The six hues are fixed by default in OKLCH (all overridable via `hues`):

| Color   | Angle | Notes |
|---------|------:|-------|
| red     |  25°  | Warm red — lower drifts pink, higher drifts orange |
| yellow  |  85°  | Pure yellow — lower is orange, higher is yellow-green |
| green   | 145°  | Mid green — lower is lime, higher is teal |
| cyan    | 200°  | Teal-cyan — lower merges with green, higher drifts blue |
| blue    | 260°  | Prototypical blue — lower is violet, higher is indigo |
| magenta | 325°  | Clear magenta — lower is purple, higher is hot pink |

These are **not** evenly spaced, because colors are not evenly distributed around the perceptual wheel. Yellow and green dominate a large arc (~85°–180°, nearly a third of the wheel) while red and magenta occupy a much narrower band (~0°–40° and 300°–360°). OKLCH partially corrects for this compared to HSL, but the unevenness remains — so the hues are placed where each color is most unambiguously recognizable, not at equal intervals.

The result: every color you see in your editor has the same contrast against the background, and colors are as saturated as the gamut allows at that lightness.
