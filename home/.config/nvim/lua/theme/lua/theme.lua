local M = {}

M.palette = {
    -- palette
    red = "#cc6666",
    green = "#bdb968",
    yellow = "#f0c674",
    blue = "#81a2be",
    magenta = "#b193ba",
    cyan = "#7fb2c8",
    silver = "#acbcc3",
    charcoal = "#708499",
    teal = "#749689",
    beige = "#ebd2a7",
    orange = "#de935f",
    purple = "#b08cba",
    -- base
    bg = "#272b30",
    text = "#afb4c3",
    strong_text = "#80838f",
    faded_text = "#686d75",
    strong_faded_text = "#464b50",
    -- lines
    thin_line = "#2f3337",
    thick_line = "#73787d",
    -- floats
    float_bg = "#30353b",
    -- bars
    bar_bg = "#2c323c",
    bar_text = "#b5bac8",
    bar_faded_text = "#70757d",
    -- shades
    white = "#ffffff",
    darker_gray = "#2c323c",
    lighter_gray = "#3e4452",
    -- git
    diff_add_bg = "#3a413b",
    diff_delete_bg = "#443c3f",
    -- terminal
    brightBlack = "#636363",
    brightRed = "#a04041",
    brightGreen = "#8b9440",
    brightYellow = "#ec9c62",
    brightBlue = "#5d7f9a",
    brightMagenta = "#82658c",
    brightCyan = "#5e8d87",
    brightWhite = "#6d757d",
}

local function apply()
    local lush = require("lush")

    local palette = M.palette

    vim.o.background = "dark"

    vim.g.terminal_color_0 = palette.bg -- Black
    vim.g.terminal_color_1 = palette.red -- Red
    vim.g.terminal_color_2 = palette.green -- Green
    vim.g.terminal_color_3 = palette.yellow -- Yellow
    vim.g.terminal_color_4 = palette.blue -- Blue
    vim.g.terminal_color_5 = palette.magenta -- Magenta
    vim.g.terminal_color_6 = palette.cyan -- Cyan
    vim.g.terminal_color_7 = palette.white -- White
    vim.g.terminal_color_8 = palette.brightBlack -- Bright Black
    vim.g.terminal_color_9 = palette.brightRed -- Bright Red
    vim.g.terminal_color_10 = palette.brightGreen -- Bright Green
    vim.g.terminal_color_11 = palette.brightYellow -- Bright Yellow
    vim.g.terminal_color_12 = palette.brightBlue -- Bright Blue
    vim.g.terminal_color_13 = palette.brightMagenta -- Bright Magenta
    vim.g.terminal_color_14 = palette.brightCyan -- Bright Cyan
    vim.g.terminal_color_15 = palette.brightWhite -- Bright White

    local color = {}

    for key, value in pairs(palette) do
        color[key] = lush.hsl(value)
    end

    -- LSP/Linters mistakenly show `undefined global` errors in the spec, they may
    -- support an annotation like the following. Consult your server documentation.
    ---@diagnostic disable: undefined-global
    local theme = lush(function(fn)
        local sym = fn.sym

        return {
            Normal({ fg = color.text, bg = color.bg }), -- Normal text

            -- Common vim syntax groups used for all kinds of code and markup.
            -- Commented-out groups should chain up to their preferred (*) group
            -- by default.
            --
            -- See :h group-name
            --
            -- Uncomment and edit if you want more specific syntax highlighting.

            Comment({ fg = color.faded_text }), -- Any comment

            Constant({ fg = color.silver }), -- (*) Any constant
            String({ fg = color.green }), --   A string constant: "this is a string"
            Character({ fg = color.teal }), --   A character constant: 'c', '\n'
            Number({ fg = color.yellow }), --   A number constant: 234, 0xff
            Boolean({ fg = color.yellow }), --   A boolean constant: TRUE, false
            Float({ fg = color.yellow }), --   A floating point constant: 2.3e10

            Identifier({ fg = color.beige }), -- (*) Any variable name
            Function({ fg = color.cyan }), --   Function name (also: methods for classes)

            Statement({ fg = color.purple }), -- (*) Any statement
            -- Conditional    { }, --   if, then, else, endif, switch, etc.
            -- Repeat         { }, --   for, do, while, etc.
            -- Label          { }, --   case, default, etc.
            Operator({ fg = Normal.fg }), --   "sizeof", "+", "*", etc.
            Keyword({ fg = color.purple }), --   any other keyword
            -- Exception      { }, --   try, catch, throw

            PreProc({ fg = color.magenta }), -- (*) Generic Preprocessor
            Include({ fg = color.blue, bold = true }), --   Preprocessor #include
            -- Define         { }, --   Preprocessor #define
            Macro({ fg = color.orange }), --   Same as Define
            -- PreCondit      { }, --   Preprocessor #if, #else, #endif, etc.

            Type({ fg = color.cyan }), -- (*) int, long, char, etc.
            Typedef({ Type }), --   A typedef
            -- StorageClass   { }, --   static, register, volatile, etc.
            -- Structure      { }, --   struct, union, enum, etc.

            Special({ fg = color.silver }), -- (*) Any special symbol
            -- SpecialChar    { }, --   Special character in a constant
            -- Tag            { }, --   You can use CTRL-] on this
            -- Delimiter      { }, --   Character that needs attention
            -- SpecialComment { }, --   Special things inside a comment (e.g. '\n')
            -- Debug          { }, --   Debugging statements

            Underlined({ gui = "underline" }), -- Text that stands out, HTML links
            -- Ignore         { }, -- Left blank, hidden |hl-Ignore| (NOTE May be invisible here in template)
            -- Error          { }, -- Any erroneous construct
            -- Todo           { }, -- Anything that needs extra attention; mostly the keywords TODO FIXME and XXX

            -- Tree-Sitter syntax groups.
            --
            -- See :h treesitter-highlight-groups, some groups may not be listed,
            -- submit a PR fix to lush-template!
            --
            -- Tree-Sitter groups are defined with an "@" symbol, which must be
            -- specially handled to be valid lua code, we do this via the special
            -- sym function. The following are all valid ways to call the sym function,
            -- for more details see https://www.lua.org/pil/5.html
            --
            -- sym("@text.literal")
            -- sym('@text.literal')
            -- sym"@text.literal"
            -- sym'@text.literal'
            --
            -- For more information see https://github.com/rktjmp/lush.nvim/issues/109

            -- sym"@text.literal"      { }, -- Comment
            -- sym"@text.reference"    { }, -- Identifier
            -- sym"@text.title"        { }, -- Title
            -- sym"@text.uri"          { }, -- Underlined
            -- sym"@text.underline"    { }, -- Underlined
            -- sym"@text.todo"         { }, -- Todo
            sym("@comment")({ Comment }), -- Comment
            -- sym "@punctuation"      { }, -- Delimiter
            sym("@constant")({ Constant }), -- Constant
            -- sym"@constant.builtin"  { }, -- Special
            -- sym"@constant.macro"    { }, -- Define
            -- sym"@define"            { }, -- Define
            sym("@macro")({ Macro }), -- Macro
            sym("@string")({ String }), -- String
            -- sym"@string.escape"     { }, -- SpecialChar
            -- sym"@string.special"    { }, -- SpecialChar
            sym("@character")({ Character }), -- Character
            -- sym "@character.special" { }, -- SpecialChar
            sym("@number")({ Number }), -- Number
            sym("@boolean")({ Boolean }), -- Boolean
            sym("@float")({ Float }), -- Float
            sym("@function")({ Function }), -- Function
            -- sym"@function.builtin"  { }, -- Special
            -- sym"@function.macro"    { }, -- Macro
            -- sym"@parameter"         { }, -- Identifier
            -- sym"@method"            { }, -- Function
            -- sym"@field"             { }, -- Identifier
            -- sym"@property"          { }, -- Identifier
            sym("@constructor")({ Special }), -- Special
            -- sym"@conditional"       { }, -- Conditional
            -- sym"@repeat"            { }, -- Repeat
            -- sym"@label"             { }, -- Label
            sym("@operator")({ Operator }), -- Operator
            sym("@keyword")({ Keyword }), -- Keyword
            -- sym"@exception"         { }, -- Exception
            sym("@variable")({ Identifier }), -- Identifier
            sym("@type")({ Type }), -- Type
            sym("@type.definition")({ Typedef }), -- Typedef
            -- sym"@storageclass"      { }, -- StorageClass
            -- sym"@structure"         { }, -- Structure
            -- sym"@namespace"         { }, -- Identifier
            sym("@include")({ Include }), -- Include
            -- sym"@preproc"           { }, -- PreProc
            -- sym"@debug"             { }, -- Debug
            -- sym"@tag"               { }, -- Tag

            -- The following are the Neovim (as of 0.8.0-dev+100-g371dfb174) highlight
            -- groups, mostly used for styling UI elements.
            -- Comment them out and add your own properties to override the defaults.
            -- An empty definition `{}` will clear all styling, leaving elements looking
            -- like the 'Normal' group.
            -- To be able to link to a group, it must already be defined, so you may have
            -- to reorder items as you go.
            --
            -- See :h highlight-groups
            --
            Conceal({ fg = color.faded_text }), -- Placeholder characters substituted for concealed text (see 'conceallevel')
            Cursor({ reverse = true }), -- Character under the cursor
            -- lCursor      { }, -- Character under the cursor when |language-mapping| is used (see 'guicursor')
            -- CursorIM     { }, -- Like Cursor, but used when in IME mode |CursorIM|
            CursorColumn({ bg = Normal.bg.lighten(20) }), -- Screen-column at the cursor, when 'cursorcolumn' is set.
            CursorLine({ bg = Normal.bg.lighten(6) }), -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
            IblIndent({ fg = color.thin_line }),
            VirtColumn({ fg = color.thin_line }),
            ColorColumn({ fg = color.thin_line }), -- Columns set with 'colorcolumn'
            Directory({ fg = color.text }), -- Directory names (and other special names in listings)

            -- Git
            GitAdded({ fg = color.green }),
            GitChanged({ fg = color.blue }),
            GitDeleted({ fg = color.red }),

            diffAdded({ GitAdded }),
            diffChanged({ GitChanged }),
            diffDeleted({ GitDeleted }),

            DiffAdd({ bg = color.diff_add_bg.mix(Normal.bg, 80) }), -- Diff mode: Added line |diff.txt|
            DiffChange({ bg = color.blue.saturate(20).mix(Normal.bg, 85) }), -- Diff mode: Changed line |diff.txt|
            DiffDelete({ fg = color.faded_text, bg = color.bg }), -- Diff mode: Deleted line |diff.txt|
            DiffText({ bg = color.cyan.mix(Normal.bg, 70) }), -- Diff mode: Changed text within a changed line |diff.txt|

            -- Diffview
            DiffviewDiffAdd({ bg = color.diff_add_bg }),
            DiffviewDiffAddText({ bg = color.diff_add_bg.mix(color.green, 25).lighten(3) }),
            DiffviewDiffDelete({ bg = color.diff_delete_bg }),
            DiffviewDiffDeleteText({ bg = color.diff_delete_bg.mix(color.red, 35) }),
            DiffviewDiffFill({ fg = color.faded_text, bg = color.bg }),

            -- Gitsigns
            GitSignsAdd({ GitAdded }),
            GitSignsChange({ GitChanged }),
            GitSignsDelete({ GitDeleted }),
            GitSignsAddPreview({ fg = color.green, DiffviewDiffAdd }),
            GitSignsDeletePreview({ fg = color.red, DiffviewDiffDelete }),
            GitSignsAddInline({ DiffviewDiffAddText }),
            GitSignsDeleteInline({ DiffviewDiffDeleteText }),

            -- EndOfBuffer  { }, -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
            -- TermCursor   { }, -- Cursor in a focused terminal
            -- TermCursorNC { }, -- Cursor in an unfocused terminal
            -- ErrorMsg     { }, -- Error messages on the command line
            -- VertSplit    { }, -- Column separating vertically split windows
            Folded({ fg = color.bg, bg = color.charcoal }), -- Line used for closed folds
            FoldColumn({ fg = color.charcoal, bg = color.bg }), -- 'foldcolumn'
            SignColumn({ fg = color.text, bg = color.bg }), -- Column where |signs| are displayed
            -- IncSearch    { }, -- 'incsearch' highlighting; also used for the text replaced with ":s///c"
            -- Substitute   { }, -- |:substitute| replacement text highlighting
            LineNr({ fg = color.strong_faded_text }), -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
            CursorLineNr({ fg = LineNr.fg.lighten(15), bold = true }), -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
            MatchParen({ fg = color.white, bg = color.cyan.darken(50) }), -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
            MsgArea({ fg = color.strong_text }), -- Area for messages and cmdline
            ModeMsg({ MsgArea }), -- 'showmode' message (e.g., "-- INSERT -- ")
            -- MsgSeparator { }, -- Separator for scrolled messages, `msgsep` flag of 'display'
            -- MoreMsg      { }, -- |more-prompt|
            NonText({ fg = color.cyan }), -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
            NormalFloat({ fg = color.text, bg = color.float_bg }), -- Normal text in floating windows.
            -- NormalNC     { }, -- normal text in non-current windows
            Pmenu({ fg = color.text, bg = color.float_bg }), -- Popup menu: Normal item.
            PmenuSel({ Pmenu, bg = Pmenu.bg.lighten(10) }), -- Popup menu: Selected item.
            PmenuSbar({ bg = Pmenu.bg.lighten(5) }), -- Popup menu: Scrollbar.d
            PmenuThumb({ bg = Pmenu.bg.lighten(15) }), -- Popup menu: Thumb of the scrollbar.
            -- Question     { }, -- |hit-enter| prompt and yes/no questions
            -- QuickFixLine { }, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
            Search({ fg = color.bg, bg = color.cyan }), -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
            SpecialKey({ fg = color.faded_text }), -- Unprintable characters: text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
            -- SpellBad     { }, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
            -- SpellCap     { }, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
            -- SpellLocal   { }, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
            -- SpellRare    { }, -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
            StatusLine({ bg = color.bar_bg }), -- Status line of current window
            StatusLineNC({ StatusLine }), -- Status lines of not-current windows. Note: If this is equal to "StatusLine" Vim will use "^^^" in the status line of the current window.
            TabLine({ bg = color.bar_bg }), -- Tab pages line, not active tab page label
            TabLineFill({ bg = TabLine.bg }), -- Tab pages line, where there are no labels
            TabLineSel({ bg = TabLine.bg.lighten(5) }), -- Tab pages line, active tab page label
            Title({ fg = color.magenta, bold = true }), -- Titles for output from ":set all", ":autocmd" etc.
            -- NB!: VertSplit is dynamic. See functions below.
            VertSplit({ fg = color.bg }), -- Vertical split line
            Visual({ bg = Normal.bg.lighten(18) }), -- Visual mode selection
            -- VisualNOS    { }, -- Visual mode selection when vim is "Not Owning the Selection".
            -- WarningMsg   { }, -- Warning messages
            Whitespace({ fg = color.faded_text }), -- "nbsp", "space", "tab" and "trail" in 'listchars'
            Winseparator({ VertSplit }), -- Separator between window splits. Inherts from |hl-VertSplit| by default, which it will replace eventually.
            -- WildMenu     { }, -- Current match in 'wildmenu' completion

            -- These groups are for the native LSP client and diagnostic system. Some
            -- other LSP clients may use these groups, or use their own. Consult your
            -- LSP client's documentation.

            -- See :h lsp-highlight, some groups may not be listed, submit a PR fix to lush-template!
            --
            LspReferenceText({ bg = Visual.bg.darken(30) }), -- Used for highlighting "text" references
            LspReferenceRead({ LspReferenceText }), -- Used for highlighting "read" references
            LspReferenceWrite({ LspReferenceText }), -- Used for highlighting "write" references
            LspInlayHint({ Comment, bold = true }),
            LspCodeLens({ LspInlayHint }), -- Used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
            -- LspCodeLensSeparator        { } , -- Used to color the seperator between two or more code lens.
            -- LspSignatureActiveParameter { } , -- Used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.

            -- See :h diagnostic-highlights, some groups may not be listed, submit a PR fix to lush-template!
            --
            DiagnosticError({ fg = color.red }), -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
            DiagnosticWarn({ fg = color.yellow }), -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
            DiagnosticInfo({ fg = color.blue }), -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
            DiagnosticHint({ fg = color.silver }), -- Used as the base highlight group. Other Diagnostic highlights link to this by default (except Underline)
            -- DiagnosticVirtualTextError { } , -- Used for "Error" diagnostic virtual text.
            -- DiagnosticVirtualTextWarn  { } , -- Used for "Warn" diagnostic virtual text.
            -- DiagnosticVirtualTextInfo  { } , -- Used for "Info" diagnostic virtual text.
            -- DiagnosticVirtualTextHint  { } , -- Used for "Hint" diagnostic virtual text.
            DiagnosticUnderlineError({ DiagnosticError, undercurl = true }), -- Used to underline "Error" diagnostics.
            DiagnosticUnderlineWarn({ DiagnosticWarn, undercurl = true }), -- Used to underline "Warn" diagnostics.
            DiagnosticUnderlineInfo({ DiagnosticInfo, undercurl = true }), -- Used to underline "Info" diagnostics.
            DiagnosticUnderlineHint({ DiagnosticHint, undercurl = true }), -- Used to underline "Hint" diagnostics.
            DiagnosticFloatingErrorLabel({ fg = color.float_bg, bg = DiagnosticError.fg }),
            DiagnosticFloatingWarnLabel({ fg = color.float_bg, bg = DiagnosticWarn.fg }),
            DiagnosticFloatingInfoLabel({ fg = color.float_bg, bg = DiagnosticInfo.fg }),
            DiagnosticFloatingHintLabel({ fg = color.float_bg, bg = DiagnosticHint.fg }),
            -- DiagnosticFloatingError    { } , -- Used to color "Error" diagnostic messages in diagnostics float. See |vim.diagnostic.open_float()|
            -- DiagnosticFloatingWarn     { } , -- Used to color "Warn" diagnostic messages in diagnostics float.
            -- DiagnosticFloatingInfo     { } , -- Used to color "Info" diagnostic messages in diagnostics float.
            -- DiagnosticFloatingHint     { } , -- Used to color "Hint" diagnostic messages in diagnostics float.
            -- DiagnosticSignError        { } , -- Used for "Error" signs in sign column.
            -- DiagnosticSignWarn         { } , -- Used for "Warn" signs in sign column.
            -- DiagnosticSignInfo         { } , -- Used for "Info" signs in sign column.
            -- DiagnosticSignHint         { } , -- Used for "Hint" signs in sign column.

            StatusBarSegmentNormal({ fg = color.bar_text, bg = color.bar_bg }),
            StatusBarSegmentFaded({ fg = color.bar_faded_text, bg = color.bar_bg }),
            StatusBarDiagnosticError({ fg = DiagnosticError.fg, bg = color.bar_bg }),
            StatusBarDiagnosticWarn({ fg = DiagnosticWarn.fg, bg = color.bar_bg }),
            StatusBarDiagnosticInfo({ fg = DiagnosticInfo.fg, bg = color.bar_bg }),
            StatusBarDiagnosticHint({ fg = DiagnosticHint.fg, bg = color.bar_bg }),

            FloatTitle({ fg = color.bg, bg = color.cyan, bold = true }),

            IndentBlanklineChar({ fg = color.thin_line }),
            IndentBlanklineContextChar({ fg = IndentBlanklineChar.fg.lighten(25) }),

            TodoComment({ fg = color.purple }),
            FixmeComment({ fg = color.purple }),
            HackComment({ fg = color.yellow }),
            PriorityComment({ fg = color.orange }),

            MiniStarterSection({ fg = color.text, bg = color.bg, bold = true }),
            MiniStarterFooter({ Comment }),

            NoiceCmdline({ bg = color.bar_bg }),
            NoiceLspProgressTitle({ fg = color.bar_faded_text, bg = color.bar_bg }),
            NoiceLspProgressClient({ fg = color.charcoal, bg = color.bar_bg }),
            NoiceLspProgressSpinner({ fg = color.yellow.mix(color.bar_bg, 50), bg = color.bar_bg }),

            ZenBg({ fg = color.text, bg = color.bg }),

            WinShiftMove({ bg = Normal.bg.lighten(7) }),

            TabsVsSpaces({ fg = color.faded_text, underline = true }),

            FlashCurrent({ fg = Normal.bg, bg = color.green, bold = true }),
            FlashMatch({ fg = Normal.bg, bg = color.cyan }),
            FlashLabel({ fg = Normal.bg, bg = color.purple, bold = true }),
            FlashPrompt({ bg = color.bar_bg }),
            FlashPromptIcon({ bg = color.bar_bg }),

            MiniCursorword({ bg = Normal.bg.lighten(10) }),

            NvimSurroundHighlight({ fg = Normal.bg, bg = color.cyan }),

            TelescopeNormal({ bg = color.float_bg }),
            TelescopeMatching({ fg = color.charcoal }),
            TelescopeSelection({ bg = Normal.bg.lighten(9) }),
            TelescopeBorder({ fg = color.faded_text, bg = color.float_bg }), -- this is used for telescope titles
            TelescopeResultsDiffAdd({ GitAdded }),
            TelescopeResultsDiffChange({ GitChanged }),
            TelescopeResultsDiffDelete({ GitDeleted }),
            TelescopePromptCounter({ Comment }),

            SagaNormal({ bg = color.bg }),

            NeoTreeRootName({ fg = color.strong_text, bold = true }),
            NeoTreeDirectoryIcon({ fg = color.faded_text }),
            NeoTreeFileIcon({ fg = color.faded_text }),
            NeoTreeIndentMarker({ IndentBlanklineChar }),
            NeoTreeGitAdded({ fg = color.green }),
            NeoTreeGitUntracked({ fg = color.green }),
            NeoTreeGitModified({ fg = color.blue }),
            NeoTreeGitStaged({ fg = color.green }),
            NeoTreeGitIgnored({ fg = color.faded_text }),

            NotifyINFOIcon({ fg = color.blue }),
            NotifyINFOTitle({ fg = color.blue }),
            NotifyINFOBody({ fg = color.text, bg = color.float_bg }),
            NotifyINFOBorder({ fg = color.float_bg, bg = color.float_bg }),
            NotifyWARNIcon({ fg = color.yellow }),
            NotifyWARNTitle({ fg = color.yellow }),
            NotifyWARNBody({ fg = color.text, bg = color.float_bg }),
            NotifyWARNBorder({ fg = color.float_bg, bg = color.float_bg }),
            NotifyERRORIcon({ fg = color.red }),
            NotifyERRORTitle({ fg = color.red }),
            NotifyERRORBody({ fg = color.red, bg = color.float_bg }),
            NotifyERRORBorder({ fg = color.float_bg, bg = color.float_bg }),
        }
    end)

    lush(theme)

    vim.api.nvim_exec_autocmds("User", { pattern = "ThemeApplied" })
end

function M.apply()
    vim.opt.termguicolors = true

    if vim.g.colors_name then
        vim.cmd("hi clear")
        vim.cmd("syntax reset")
    end

    vim.g.colors_name = "theme"

    apply()
end

return M
