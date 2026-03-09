-- isocon/color.lua — Pure color math, no side effects
-- Pipeline: hex ↔ sRGB ↔ linear sRGB ↔ Oklab ↔ OKLCH

local M = {}

-- sRGB gamma linearization
function M.linearize(c)
  if c <= 0.04045 then
    return c / 12.92
  else
    return ((c + 0.055) / 1.055) ^ 2.4
  end
end

function M.delinearize(c)
  if c <= 0.0031308 then
    return 12.92 * c
  else
    return 1.055 * (c ^ (1.0 / 2.4)) - 0.055
  end
end

function M.hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  return { r = r, g = g, b = b }
end

function M.rgb_to_hex(r, g, b)
  r = math.max(0, math.min(1, r))
  g = math.max(0, math.min(1, g))
  b = math.max(0, math.min(1, b))
  return string.format('#%02x%02x%02x',
    math.floor(r * 255 + 0.5),
    math.floor(g * 255 + 0.5),
    math.floor(b * 255 + 0.5))
end

-- WCAG relative luminance from linear sRGB
function M.wcag_luminance(r, g, b)
  local lr = M.linearize(r)
  local lg = M.linearize(g)
  local lb = M.linearize(b)
  return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb
end

-- Oklab conversion (Björn Ottosson's reference matrices)
local function linear_rgb_to_oklab(r, g, b)
  -- M1: linear sRGB → LMS cone space
  local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

  -- Cube root
  local l_ = l ^ (1/3)
  local m_ = m ^ (1/3)
  local s_ = s ^ (1/3)

  -- M2: LMS → Oklab
  return
    0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
    1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
    0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
end

local function oklab_to_linear_rgb(L, a, b_)
  local l_ = L + 0.3963377774 * a + 0.2158037573 * b_
  local m_ = L - 0.1055613458 * a - 0.0638541728 * b_
  local s_ = L - 0.0894841775 * a - 1.2914855480 * b_

  local l = l_ * l_ * l_
  local m = m_ * m_ * m_
  local s = s_ * s_ * s_

  return
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end

function M.oklch_to_rgb(L, C, H)
  local h_rad = H * math.pi / 180
  local a = C * math.cos(h_rad)
  local b = C * math.sin(h_rad)
  local r, g, bv = oklab_to_linear_rgb(L, a, b)
  return {
    r = math.max(0, math.min(1, M.delinearize(r))),
    g = math.max(0, math.min(1, M.delinearize(g))),
    b = math.max(0, math.min(1, M.delinearize(bv))),
  }
end

function M.rgb_to_oklch(r, g, b)
  local lr = M.linearize(r)
  local lg = M.linearize(g)
  local lb = M.linearize(b)
  local L, a, bv = linear_rgb_to_oklab(lr, lg, lb)
  local C = math.sqrt(a * a + bv * bv)
  local H = math.atan(bv, a) * 180 / math.pi
  if H < 0 then H = H + 360 end
  return { L = L, C = C, H = H }
end

-- Check if a color is within sRGB gamut (with small epsilon)
local function in_gamut(r, g, b)
  local eps = 1e-4
  return r >= -eps and r <= 1 + eps
     and g >= -eps and g <= 1 + eps
     and b >= -eps and b <= 1 + eps
end

-- Binary search for maximum chroma at given (L, H) within sRGB gamut
function M.max_chroma(L, H)
  local lo, hi = 0, 0.4
  for _ = 1, 20 do
    local mid = (lo + hi) / 2
    local rgb = M.oklch_to_rgb(L, mid, H)
    -- Check linear values before delinearize clamping
    local h_rad = H * math.pi / 180
    local a = mid * math.cos(h_rad)
    local b = mid * math.sin(h_rad)
    local r, g, bv = oklab_to_linear_rgb(L, a, b)
    if in_gamut(r, g, bv) then
      lo = mid
    else
      hi = mid
    end
  end
  return lo
end

-- Compute target WCAG luminance for a desired contrast ratio
-- Dark bg: lighter fg; Light bg: darker fg
function M.luminance_for_contrast(Y_bg, cr)
  local Y_fg
  if Y_bg < 0.18 then
    -- dark background: fg is lighter
    Y_fg = cr * (Y_bg + 0.05) - 0.05
  else
    -- light background: fg is darker
    Y_fg = (Y_bg + 0.05) / cr - 0.05
  end
  return math.max(0, math.min(1, Y_fg))
end

-- Binary search for Oklab L value that hits a target WCAG luminance
-- at fixed C and H (achromatic when C=0)
function M.L_for_luminance(Y_target, C, H)
  local lo, hi = 0, 1
  for _ = 1, 30 do
    local mid = (lo + hi) / 2
    local rgb = M.oklch_to_rgb(mid, C, H)
    local Y = M.wcag_luminance(rgb.r, rgb.g, rgb.b)
    if Y < Y_target then
      lo = mid
    else
      hi = mid
    end
  end
  return (lo + hi) / 2
end

return M
