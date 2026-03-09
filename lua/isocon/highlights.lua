--- isocon/highlights.lua
--- Returns the full table of Neovim highlight group definitions.
--- Groups are organized into sections: Core UI, Syntax, Treesitter,
--- LSP semantic tokens, Diagnostics, Git diff, and Spell.

local M = {}

--- Build and return the highlight group table for the given palette.
--- Each key is a highlight group name; each value is a spec table accepted
--- by `vim.api.nvim_set_hl()` (fields: fg, bg, bold, italic, link, etc.).
---@param p table Palette produced by `require('isocon.palette').generate()`
---@return table<string, table> Map of group name → highlight spec
function M.get(p)
  local hl = {}

  --- Register a highlight group spec into the output table.
  ---@param group string Neovim highlight group name
  ---@param spec table Highlight spec (fg, bg, bold, italic, link, …)
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
  h('Function',      { fg = p.blue })

  h('Statement',     { fg = p.blue })
  h('Conditional',   { fg = p.magenta })
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
  h('@comment.error',        { fg = p.red,    bold = true })   -- ERROR/FIXME
  h('@comment.warning',      { fg = p.yellow, bold = true })   -- WARN/HACK
  h('@comment.todo',         { fg = p.yellow, bold = true })   -- TODO
  h('@comment.note',         { fg = p.cyan,   bold = true })   -- NOTE/INFO

  h('@string',               { link = 'String' })
  h('@string.escape',        { fg = p.magenta })
  h('@string.special',       { fg = p.magenta })
  h('@string.special.symbol',{ fg = p.magenta })  -- Ruby symbols, etc.
  h('@string.special.url',   { fg = p.cyan, underline = true })
  h('@string.regexp',        { fg = p.magenta })  -- new name
  h('@string.regex',         { fg = p.magenta })  -- old name

  h('@number',               { link = 'Number' })
  h('@float',                { link = 'Float' })
  h('@number.float',         { link = 'Float' }) -- new name
  h('@boolean',              { link = 'Boolean' })

  h('@character',            { link = 'Character' })

  h('@constant',             { link = 'Constant' })
  h('@constant.builtin',     { fg = p.magenta, bold = true })
  h('@constant.macro',       { fg = p.magenta })

  h('@keyword',              { link = 'Keyword' })
  h('@keyword.function',     { fg = p.blue, bold = true })
  h('@keyword.operator',     { fg = p.blue })
  h('@keyword.return',       { fg = p.red, bold = true })
  h('@keyword.import',       { fg = p.magenta })
  h('@keyword.conditional',  { link = 'Conditional' })
  h('@keyword.repeat',       { link = 'Repeat' })
  h('@keyword.exception',    { link = 'Exception' })
  h('@keyword.coroutine',    { fg = p.blue, bold = true, italic = true }) -- async/await/yield
  h('@keyword.storage',      { fg = p.blue })                              -- static, extern
  h('@keyword.modifier',     { fg = p.blue })                              -- public, private, readonly

  h('@operator',             { link = 'Operator' })
  h('@punctuation',          { fg = p.fg })
  h('@punctuation.bracket',  { fg = p.fg })
  h('@punctuation.delimiter',{ fg = p.fg })
  h('@punctuation.special',  { fg = p.magenta })

  h('@function',             { link = 'Function' })
  h('@function.call',        { fg = p.blue })
  h('@function.builtin',     { fg = p.br_cyan, bold = true })
  h('@function.macro',       { fg = p.magenta })
  h('@function.method',      { fg = p.blue })
  h('@function.method.call', { fg = p.blue })

  h('@constructor',          { fg = p.yellow })

  h('@type',                 { link = 'Type' })
  h('@type.builtin',         { fg = p.yellow, bold = true })
  h('@type.qualifier',       { fg = p.blue })
  h('@type.definition',      { fg = p.yellow })
  h('@type.parameter',       { fg = p.yellow, italic = true }) -- generic T

  h('@variable',                  { fg = p.fg })
  h('@variable.builtin',          { fg = p.red })               -- self, this, super
  h('@variable.member',           { fg = p.cyan })                -- struct fields, table keys
  h('@variable.parameter',        { fg = p.fg, italic = true }) -- function params
  h('@variable.parameter.builtin',{ fg = p.red, italic = true }) -- implicit self

  h('@property',             { fg = p.cyan })                 -- dot-access fields

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
  -- Treesitter — old node names (pre-rename compat)
  -- ────────────────────────────────────────────────
  h('@field',                { link = '@variable.member' }) -- pre-rename compat
  h('@method',               { link = '@function.method' })
  h('@method.call',          { link = '@function.method.call' })
  h('@parameter',            { link = '@variable.parameter' })
  -- @text.* (markdown / documentation parsers)
  h('@text.literal',         { link = 'String' })
  h('@text.reference',       { link = 'Identifier' })
  h('@text.title',           { link = 'Title' })
  h('@text.uri',             { fg = p.cyan, underline = true })
  h('@text.underline',       { underline = true })
  h('@text.todo',            { link = 'Todo' })
  h('@text.note',            { fg = p.cyan,   bold = true })
  h('@text.warning',         { fg = p.yellow, bold = true })
  h('@text.danger',          { fg = p.red,    bold = true })
  h('@text.diff.add',        { link = 'DiffAdd' })
  h('@text.diff.delete',     { link = 'DiffDelete' })
  h('@text.strong',          { bold = true })
  h('@text.emphasis',        { italic = true })
  h('@text.strike',          { strikethrough = true })
  -- markup (new names for markdown etc.)
  h('@markup.strong',        { bold = true })
  h('@markup.italic',        { italic = true })
  h('@markup.strikethrough', { strikethrough = true })
  h('@markup.underline',     { underline = true })
  h('@markup.heading',       { fg = p.blue, bold = true })
  h('@markup.heading.1',     { fg = p.blue,    bold = true })
  h('@markup.heading.2',     { fg = p.cyan,    bold = true })
  h('@markup.heading.3',     { fg = p.green,   bold = true })
  h('@markup.heading.4',     { fg = p.yellow })
  h('@markup.heading.5',     { fg = p.magenta })
  h('@markup.heading.6',     { fg = p.fg_dim })
  h('@markup.quote',         { fg = p.fg_dim, italic = true })
  h('@markup.math',          { fg = p.yellow })
  h('@markup.link',          { fg = p.cyan })
  h('@markup.link.label',    { fg = p.cyan })
  h('@markup.link.url',      { fg = p.cyan, underline = true })
  h('@markup.raw',           { link = 'String' })
  h('@markup.raw.block',     { link = 'String' })
  h('@markup.list',          { fg = p.fg_dim })
  h('@markup.list.checked',  { fg = p.green })
  h('@markup.list.unchecked',{ fg = p.fg_dim })

  -- ────────────────────────────────────────────────
  -- LSP semantic tokens (link to treesitter)
  -- ────────────────────────────────────────────────
  h('@lsp.type.function',        { link = '@function' })
  h('@lsp.type.method',          { link = '@function.method' })
  h('@lsp.type.variable',        { link = '@variable' })
  h('@lsp.type.parameter',       { link = '@variable.parameter' })
  h('@lsp.type.property',        { link = '@property' })
  h('@lsp.type.type',            { link = '@type' })
  h('@lsp.type.class',           { link = '@type' })
  h('@lsp.type.enum',            { link = '@type' })
  h('@lsp.type.enumMember',      { link = '@constant' })
  h('@lsp.type.interface',       { link = '@type' })
  h('@lsp.type.namespace',       { link = '@namespace' })
  h('@lsp.type.struct',          { link = '@type' })
  h('@lsp.type.decorator',       { link = '@attribute' })
  h('@lsp.type.macro',           { link = '@constant.macro' })
  h('@lsp.type.keyword',         { link = '@keyword' })
  h('@lsp.type.string',          { link = '@string' })
  h('@lsp.type.number',          { link = '@number' })
  h('@lsp.type.boolean',         { link = '@boolean' })
  h('@lsp.type.operator',        { link = '@operator' })
  h('@lsp.type.comment',         { link = '@comment' })
  h('@lsp.type.typeParameter',   { link = '@type.parameter' }) -- generic T (TS, Java, Rust)
  h('@lsp.type.lifetime',        { fg = p.magenta, italic = true }) -- Rust lifetimes
  h('@lsp.type.builtinType',     { link = '@type.builtin' })
  h('@lsp.type.selfKeyword',     { link = '@variable.builtin' })
  h('@lsp.type.selfTypeKeyword', { link = '@type.builtin' })
  h('@lsp.type.regexp',          { link = '@string.regexp' })
  h('@lsp.type.event',           { fg = p.magenta })
  h('@lsp.type.label',           { link = '@label' })

  h('@lsp.mod.deprecated',       { strikethrough = true })
  h('@lsp.mod.readonly',         { italic = true })
  h('@lsp.mod.static',           { italic = true })
  h('@lsp.mod.abstract',         { italic = true })
  h('@lsp.mod.async',            { italic = true })
  h('@lsp.mod.declaration',      {})                           -- no extra styling
  h('@lsp.mod.definition',       {})
  h('@lsp.mod.documentation',    { italic = true })
  h('@lsp.mod.modification',     {})
  h('@lsp.mod.virtual',          { italic = true })
  h('@lsp.mod.defaultLibrary',   { bold = true })              -- built-in stdlib symbols

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
