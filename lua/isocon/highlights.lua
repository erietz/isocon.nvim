-- isocon/highlights.lua — Highlight group definitions

local M = {}

function M.get(p)
  local hl = {}

  -- Helper: set a highlight entry
  local function h(group, spec)
    hl[group] = spec
  end

  -- ────────────────────────────────────────────────
  -- Core UI
  -- ────────────────────────────────────────────────
  h('Normal',        { fg = p.fg,     bg = p.bg })
  h('NormalNC',      { fg = p.fg_dim, bg = p.bg })
  h('NormalFloat',   { fg = p.fg,     bg = p.bg_float })
  h('FloatBorder',   { fg = p.fg_dim, bg = p.bg_float })
  h('FloatTitle',    { fg = p.blue,   bg = p.bg_float, bold = true })

  h('CursorLine',    { bg = p.bg_subtle })
  h('CursorColumn',  { bg = p.bg_subtle })
  h('CursorLineNr',  { fg = p.fg,     bg = p.bg_subtle, bold = true })
  h('LineNr',        { fg = p.fg_dim })
  h('SignColumn',    { fg = p.fg_dim, bg = p.bg })
  h('FoldColumn',    { fg = p.fg_dim, bg = p.bg })
  h('Folded',        { fg = p.fg_dim, bg = p.bg_subtle })

  h('WinSeparator',  { fg = p.fg_dim })
  h('VertSplit',     { link = 'WinSeparator' })

  h('StatusLine',    { fg = p.fg,     bg = p.bg_subtle })
  h('StatusLineNC',  { fg = p.fg_dim, bg = p.bg_subtle })

  h('TabLine',       { fg = p.fg_dim, bg = p.bg_subtle })
  h('TabLineSel',    { fg = p.fg,     bg = p.bg,        bold = true })
  h('TabLineFill',   { bg = p.bg_subtle })

  h('Visual',        { bg = p.bg_subtle, reverse = false })
  h('VisualNOS',     { link = 'Visual' })

  h('Search',        { fg = p.bg,  bg = p.yellow })
  h('IncSearch',     { fg = p.bg,  bg = p.br_yellow, bold = true })
  h('CurSearch',     { link = 'IncSearch' })
  h('Substitute',    { fg = p.bg,  bg = p.red })

  h('Pmenu',         { fg = p.fg,     bg = p.bg_float })
  h('PmenuSel',      { fg = p.bg,     bg = p.blue,    bold = true })
  h('PmenuSbar',     { bg = p.bg_subtle })
  h('PmenuThumb',    { bg = p.fg_dim })

  h('WildMenu',      { fg = p.bg, bg = p.blue })

  h('NonText',       { fg = p.fg_dim })
  h('Whitespace',    { fg = p.fg_dim })
  h('SpecialKey',    { fg = p.fg_dim })
  h('EndOfBuffer',   { fg = p.fg_dim })
  h('Conceal',       { fg = p.fg_dim })

  h('MatchParen',    { fg = p.yellow, bold = true, underline = true })

  h('QuickFixLine',  { bg = p.bg_subtle })
  h('Directory',     { fg = p.blue })
  h('Title',         { fg = p.blue, bold = true })
  h('Question',      { fg = p.green })
  h('MoreMsg',       { fg = p.green })
  h('ModeMsg',       { fg = p.fg, bold = true })
  h('WarningMsg',    { fg = p.yellow })
  h('ErrorMsg',      { fg = p.red })

  -- Cursor shapes
  h('Cursor',        { fg = p.cursor_fg, bg = p.cursor_bg })
  h('lCursor',       { link = 'Cursor' })
  h('CursorIM',      { link = 'Cursor' })

  -- ────────────────────────────────────────────────
  -- Syntax (base groups)
  -- ────────────────────────────────────────────────
  h('Comment',       { fg = p.fg_dim, italic = true })

  h('Constant',      { fg = p.magenta })
  h('String',        { fg = p.green })
  h('Character',     { fg = p.green })
  h('Number',        { fg = p.yellow })
  h('Float',         { fg = p.yellow })
  h('Boolean',       { fg = p.yellow })

  h('Identifier',    { fg = p.fg })
  h('Function',      { fg = p.cyan })

  h('Statement',     { fg = p.blue })
  h('Conditional',   { fg = p.blue })
  h('Repeat',        { fg = p.blue })
  h('Label',         { fg = p.blue })
  h('Operator',      { fg = p.fg })
  h('Keyword',       { fg = p.blue, bold = true })
  h('Exception',     { fg = p.red })

  h('PreProc',       { fg = p.magenta })
  h('Include',       { fg = p.magenta })
  h('Define',        { fg = p.magenta })
  h('Macro',         { fg = p.magenta })
  h('PreCondit',     { fg = p.magenta })

  h('Type',          { fg = p.yellow })
  h('StorageClass',  { fg = p.blue })
  h('Structure',     { fg = p.yellow })
  h('Typedef',       { fg = p.yellow })

  h('Special',       { fg = p.magenta })
  h('SpecialChar',   { fg = p.magenta })
  h('Tag',           { fg = p.blue })
  h('Delimiter',     { fg = p.fg })
  h('SpecialComment',{ fg = p.fg_dim, bold = true })
  h('Debug',         { fg = p.red })

  h('Underlined',    { underline = true })
  h('Ignore',        { fg = p.fg_dim })
  h('Error',         { fg = p.red, bold = true })
  h('Todo',          { fg = p.yellow, bold = true })

  -- ────────────────────────────────────────────────
  -- Treesitter
  -- ────────────────────────────────────────────────
  h('@comment',              { link = 'Comment' })
  h('@comment.documentation',{ fg = p.fg_dim, italic = true })

  h('@string',               { link = 'String' })
  h('@string.escape',        { fg = p.magenta })
  h('@string.special',       { fg = p.magenta })
  h('@string.regex',         { fg = p.magenta })

  h('@number',               { link = 'Number' })
  h('@float',                { link = 'Float' })
  h('@boolean',              { link = 'Boolean' })

  h('@character',            { link = 'Character' })

  h('@constant',             { link = 'Constant' })
  h('@constant.builtin',     { fg = p.magenta, bold = true })
  h('@constant.macro',       { fg = p.magenta })

  h('@keyword',              { link = 'Keyword' })
  h('@keyword.function',     { fg = p.blue, bold = true })
  h('@keyword.operator',     { fg = p.blue })
  h('@keyword.return',       { fg = p.blue, bold = true })
  h('@keyword.import',       { fg = p.magenta })
  h('@keyword.conditional',  { link = 'Conditional' })
  h('@keyword.repeat',       { link = 'Repeat' })
  h('@keyword.exception',    { link = 'Exception' })

  h('@operator',             { link = 'Operator' })
  h('@punctuation',          { fg = p.fg })
  h('@punctuation.bracket',  { fg = p.fg })
  h('@punctuation.delimiter',{ fg = p.fg })
  h('@punctuation.special',  { fg = p.magenta })

  h('@function',             { link = 'Function' })
  h('@function.call',        { fg = p.cyan })
  h('@function.builtin',     { fg = p.br_cyan, bold = true })
  h('@function.macro',       { fg = p.magenta })
  h('@function.method',      { fg = p.cyan })
  h('@function.method.call', { fg = p.cyan })

  h('@constructor',          { fg = p.yellow })

  h('@type',                 { link = 'Type' })
  h('@type.builtin',         { fg = p.yellow, bold = true })
  h('@type.qualifier',       { fg = p.blue })
  h('@type.definition',      { fg = p.yellow })

  h('@variable',             { fg = p.fg })
  h('@variable.builtin',     { fg = p.red })
  h('@variable.member',      { fg = p.fg })
  h('@variable.parameter',   { fg = p.fg })

  h('@property',             { fg = p.fg })

  h('@namespace',            { fg = p.yellow })
  h('@module',               { fg = p.yellow })
  h('@module.builtin',       { fg = p.yellow, bold = true })

  h('@attribute',            { fg = p.magenta })
  h('@attribute.builtin',    { fg = p.magenta, bold = true })

  h('@label',                { fg = p.blue })

  h('@tag',                  { fg = p.blue })
  h('@tag.attribute',        { fg = p.yellow })
  h('@tag.delimiter',        { fg = p.fg_dim })

  -- ────────────────────────────────────────────────
  -- LSP semantic tokens (link to treesitter)
  -- ────────────────────────────────────────────────
  h('@lsp.type.function',    { link = '@function' })
  h('@lsp.type.method',      { link = '@function.method' })
  h('@lsp.type.variable',    { link = '@variable' })
  h('@lsp.type.parameter',   { link = '@variable.parameter' })
  h('@lsp.type.property',    { link = '@property' })
  h('@lsp.type.type',        { link = '@type' })
  h('@lsp.type.class',       { link = '@type' })
  h('@lsp.type.enum',        { link = '@type' })
  h('@lsp.type.enumMember',  { link = '@constant' })
  h('@lsp.type.interface',   { link = '@type' })
  h('@lsp.type.namespace',   { link = '@namespace' })
  h('@lsp.type.struct',      { link = '@type' })
  h('@lsp.type.decorator',   { link = '@attribute' })
  h('@lsp.type.macro',       { link = '@constant.macro' })
  h('@lsp.type.keyword',     { link = '@keyword' })
  h('@lsp.type.string',      { link = '@string' })
  h('@lsp.type.number',      { link = '@number' })
  h('@lsp.type.operator',    { link = '@operator' })
  h('@lsp.type.comment',     { link = '@comment' })

  h('@lsp.mod.deprecated',   { strikethrough = true })
  h('@lsp.mod.readonly',     { italic = true })
  h('@lsp.mod.static',       { italic = true })
  h('@lsp.mod.abstract',     { italic = true })
  h('@lsp.mod.async',        { italic = true })

  -- ────────────────────────────────────────────────
  -- Diagnostics
  -- ────────────────────────────────────────────────
  h('DiagnosticError',           { fg = p.red })
  h('DiagnosticWarn',            { fg = p.yellow })
  h('DiagnosticInfo',            { fg = p.blue })
  h('DiagnosticHint',            { fg = p.cyan })
  h('DiagnosticOk',              { fg = p.green })

  h('DiagnosticSignError',       { fg = p.red,    bg = p.bg })
  h('DiagnosticSignWarn',        { fg = p.yellow, bg = p.bg })
  h('DiagnosticSignInfo',        { fg = p.blue,   bg = p.bg })
  h('DiagnosticSignHint',        { fg = p.cyan,   bg = p.bg })

  h('DiagnosticUnderlineError',  { undercurl = true, sp = p.red })
  h('DiagnosticUnderlineWarn',   { undercurl = true, sp = p.yellow })
  h('DiagnosticUnderlineInfo',   { undercurl = true, sp = p.blue })
  h('DiagnosticUnderlineHint',   { undercurl = true, sp = p.cyan })

  h('DiagnosticVirtualTextError',{ fg = p.red,    italic = true })
  h('DiagnosticVirtualTextWarn', { fg = p.yellow, italic = true })
  h('DiagnosticVirtualTextInfo', { fg = p.blue,   italic = true })
  h('DiagnosticVirtualTextHint', { fg = p.cyan,   italic = true })

  h('DiagnosticFloatingError',   { fg = p.red })
  h('DiagnosticFloatingWarn',    { fg = p.yellow })
  h('DiagnosticFloatingInfo',    { fg = p.blue })
  h('DiagnosticFloatingHint',    { fg = p.cyan })

  -- ────────────────────────────────────────────────
  -- Git diff
  -- ────────────────────────────────────────────────
  h('DiffAdd',    { fg = p.green,  bg = p.bg })
  h('DiffDelete', { fg = p.red,    bg = p.bg })
  h('DiffChange', { fg = p.yellow, bg = p.bg })
  h('DiffText',   { fg = p.yellow, bg = p.bg, bold = true })

  h('GitSignsAdd',    { fg = p.green })
  h('GitSignsChange', { fg = p.yellow })
  h('GitSignsDelete', { fg = p.red })

  -- ────────────────────────────────────────────────
  -- Spell
  -- ────────────────────────────────────────────────
  h('SpellBad',   { undercurl = true, sp = p.red })
  h('SpellCap',   { undercurl = true, sp = p.yellow })
  h('SpellRare',  { undercurl = true, sp = p.cyan })
  h('SpellLocal', { undercurl = true, sp = p.blue })

  return hl
end

return M
