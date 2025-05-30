vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- For format toggling, set to true by default
vim.g.autoformat = true

local opt = vim.opt

opt.autowrite = true           -- Enable auto write
opt.breakindent = true         -- Enable break indent
opt.clipboard = "unnamedplus"  -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3           -- Hide * markup for bold and italic
opt.confirm = true             -- Confirm to save changes before exiting modified buffer
opt.cursorline = true          -- Enable highlighting of the current line
opt.expandtab = true           -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.hlsearch = true        -- Set highlight on search
opt.ignorecase = true      -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3
opt.list = true            -- Show some invisible characters (tabs...
opt.listchars = {
  trail = "␣",
  -- This is now handled by snacks.nvim indent functionality
  leadmultispace = "│ ",
  tab = "⇥ ",
}
opt.mouse = "a"                    -- Enable mouse mode
opt.number = true                  -- Print line number
opt.pumblend = 10                  -- Popup blend
opt.pumheight = 10                 -- Maximum number of entries in a popup
opt.relativenumber = true          -- Relative line numbers
opt.scrolloff = 4                  -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winpos", "winsize" }
opt.shiftround = true              -- Round indent
opt.shiftwidth = 2                 -- Size of an indent
opt.shortmess:append({ S = true }) -- Do not show search count message when searching, this is shown in lualine
opt.shortmess:append({ C = true }) -- Do not show messages while scanning for ins-completion items
opt.showmode = false               -- Dont show mode since we have a statusline
opt.sidescrolloff = 8              -- Columns of context
opt.signcolumn = "yes"             -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true               -- Don't ignore case with capitals
opt.smartindent = true             -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitkeep = "screen"
opt.splitbelow = true    -- Put new windows below current
opt.splitright = true    -- Put new windows right of current
opt.tabstop = 4          -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200               -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5                -- Minimum window width
opt.wrap = false                   -- Disable line wrap
opt.cmdheight = 0                  -- Only show command-line bar when in use
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r`\", \"\"))",
      ["*"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r`\", \"\"))",
    },
    cache_enabled = 0,
  }
end

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
