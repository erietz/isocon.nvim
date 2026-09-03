--- isocon/defaults.lua
--- Shared default configuration for the isocon colorscheme.

local M = {}

---@class IsoconHues
---@field red number OKLCH hue angle (°) for red
---@field green number OKLCH hue angle (°) for green
---@field yellow number OKLCH hue angle (°) for yellow
---@field blue number OKLCH hue angle (°) for blue
---@field magenta number OKLCH hue angle (°) for magenta
---@field cyan number OKLCH hue angle (°) for cyan

---@class IsoconConfig
---@field background string Hex background color (e.g. "#282c34")
---@field contrast number WCAG contrast ratio target for foreground text
---@field dim_contrast number WCAG contrast ratio target for dim text (comments, line numbers)
---@field bright_boost number Multiplier for bright ANSI color chroma
---@field hues IsoconHues OKLCH hue angles (°) for each semantic color role

--- Default configuration values for dark backgrounds.
---@type IsoconConfig
M.dark = {
	background = "#062329",
	contrast = 4.5,
	dim_contrast = 2.25,
	bright_boost = 1.3,
	hues = {
		red = 0,
		green = 150,
		blue = 240,
		yellow = 60,
		magenta = 297,
		cyan = 180,
	},
}

--- Default configuration values for light backgrounds.
---@type IsoconConfig
M.light = {
	background = "#eef3ea",
	contrast = 4.5,
	dim_contrast = 3.0,
	bright_boost = 1.2,
	hues = {
		red = 25,
		green = 150,
		yellow = 85,
		blue = 260,
		magenta = 305,
		cyan = 200,
	},
}

return M
