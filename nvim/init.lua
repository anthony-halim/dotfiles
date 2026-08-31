-- ============================================================
-- This file stores the main settings, configurations, and
-- setups that are natively built into Neovim.
--
-- Anything optional lives inside the 'lua/plugins/' directory .
--
-- If it is machine-specific (private tweaks/overrides), it
-- lives inside the 'after/' directory (ignored by Git).
-- ============================================================

-- ============================================================
-- Core settings, leaders, options
-- ============================================================
do
  -- Set <space> as the leader key
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Disable Neovim Markdown settings, use normal editor settings
  vim.g.markdown_recommended_style = 0

  -- Custom toggles
  vim.g.autoformat = true -- For format toggling via :AutoFormatToggle, set to true by default

  -- Line numbers
  vim.o.number = true
  vim.o.relativenumber = true

  -- Enable mouse mode
  vim.o.mouse = "a"

  -- Command line settings
  vim.o.showmode = false -- Don't show the mode, since it's already in the status line
  vim.o.cmdheight = 0 -- Only show command-line bar when in use
  vim.o.wildmode = "longest:full,full" -- Completion behaviour
  vim.opt.shortmess:append({ S = true, C = true }) -- 'S' silence search count warning, 'C' silence scan progress messages

  -- Status line settings
  vim.o.laststatus = 3 -- Global statusline regardless of splits

  -- Insert-mode autocomplete settings
  vim.o.completeopt = "menu,menuone,noselect"
  vim.o.pumheight = 10 -- Maximum number of entries in a popup
  -- Configure how Neovim automatically formats and wraps text:
  --   j: Cleanly join commented lines (removes redundant comment characters on `J`)
  --   c: Auto-wrap comments using textwidth
  --   r: Auto-insert comment prefix when pressing <Enter> in Insert mode
  --   o: Auto-insert comment prefix when pressing `o` or `O` in Normal mode
  --   q: Allow formatting of comments with `gq`
  --   l: Prevents wrapping code lines in Insert mode that are already long
  --   n: Recognize numbered lists when formatting text
  --   t: Auto-wrap text using textwidth
  vim.opt.formatoptions = "jcroqlnt"

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  See `:help 'clipboard'`
  vim.schedule(function()
    vim.o.clipboard = "unnamedplus"

    -- WSL support since Windows is a special kid
    if vim.fn.has("wsl") == 1 then
      vim.o.clipboard = {
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
  end)

  -- Enable break indent (preserves indentation block of the original line)
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Set highlight on search
  vim.o.hlsearch = true

  -- Keep signcolumn on by default, otherwise it would shift the text each time
  vim.o.signcolumn = "yes"

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true -- Put new windows below current
  vim.o.splitbelow = true -- Put new windows right of current
  vim.o.winminwidth = 5 -- Minimum window width
  vim.o.splitkeep = "screen" -- Keep cursor to same exact same screen line when splitting

  -- Sets how neovim will display certain whitespace characters in the editor.
  vim.o.list = true -- Show invisible characters
  vim.opt.listchars = { leadmultispace = "│ ", tab = "⇥ ", trail = "␣", nbsp = "␣" }
  vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }

  -- Do not preview substitutions live as we type
  vim.o.inccommand = "nosplit"

  -- Show which line the cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen space to keep around the cursor
  vim.o.scrolloff = 5 -- Lines to keep above and below
  vim.o.sidescrolloff = 8 -- Columns of chars

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  vim.o.confirm = true

  -- Disable line wrap
  vim.o.wrap = false

  -- Enable auto write on switching to different buffer, useful for multi-buffer usage
  vim.o.autowrite = true

  -- Session information to store
  vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winpos", "winsize" }

  -- Tab/indent settings
  vim.o.expandtab = true -- Use spaces instead of tabs
  vim.o.tabstop = 4 -- Number of spaces tabs count for
  vim.o.shiftround = true -- Round indent
  vim.o.shiftwidth = 2 -- Size of an indent
end

-- ============================================================
-- Plugin Manager bootstrapping (lazy.nvim)
-- TODO: Replace with vim.pack
-- ============================================================
do
  -- Bootstrap lazy.nvim path
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Initialize lazy.nvim with specifications
  require("lazy").setup({
    spec = {
      { import = "plugins" },
      { import = "plugins.lang" },
    },
    defaults = {
      lazy = false,
      version = false,
    },
    rocks = {
      enabled = false,
    },
    change_detection = {
      enabled = true,
      notify = true,
    },
    checker = {
      enabled = true,
      notify = true,
    },
    performance = {
      reset_packpath = false, -- Preserve packpath so native vim.pack can be resolved
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
    ui = {
      border = "rounded",
    },
  })

  -- Keymap to open Lazy UI
  vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
end

-- ============================================================
-- Keymaps
-- ============================================================
do
  -- Safety
  vim.keymap.set("n", "Q", "<nop>")

  -- Jumps
  vim.keymap.set("n", "gj", [[<C-O>]], { desc = "Jump to previous" })
  vim.keymap.set("n", "gJ", [[<C-I>]], { desc = "Jump to next" })

  -- Better up/down
  vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  vim.keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz", { desc = "Move half page down" })
  vim.keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz", { desc = "Move half page up" })

  -- Better indenting
  vim.keymap.set("x", "<", "<gv")
  vim.keymap.set("x", ">", ">gv")

  -- Move to window using the <ctrl> hjkl keys
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

  -- Move Lines (Visual Mode)
  -- TODO: Fix so that we stay in visual mode
  vim.keymap.set("x", "J", ":m '>+1<CR>gv", { desc = "Move block down", silent = true })
  vim.keymap.set("x", "K", ":m '<-2<CR>gv", { desc = "Move block up", silent = true })

  -- Powerful <esc>
  vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>nohlsearch<CR><esc>")
  vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" }) -- For terminal mode

  -- Diagnostics
  vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

  -- Buffer
  vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

  -- Windows
  vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
  vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
end

-- ============================================================
-- Autocmds
-- ============================================================
do
  local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
  end

  -- Autorefresh the buffer by checking if we need to reload the file when it changed
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    command = "checktime",
  })

  -- Highlight when yanking (copying) text
  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("highlight_yank"),
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  -- Resize splits if window got resized
  vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  })

  -- Auto create dir when saving a file, in case some intermediate directory does not exist
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
      if event.match:match("^%w%w+://") then
        return
      end
      local file = vim.uv.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
  })

  -- Switch for controlling whether you want autoformatting.
  --  Use :AutoFormatToggle to toggle autoformatting on or off
  vim.api.nvim_create_user_command("AutoFormatToggle", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("Autoformat is toggled to " .. (vim.g.autoformat and "on" or "off") .. ".", vim.log.levels.INFO, {
      title = "Toggle autoformat on save",
    })
  end, {})

  -- Post-update/install build hooks for specific packages
  vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup("pack_hooks"),
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

-- ============================================================
-- Core UI
-- ============================================================
do
  vim.pack.add({
    "https://github.com/echasnovski/mini.icons",
    "https://github.com/catppuccin/nvim",
  })

  -- Configure mini.icons
  require("mini.icons").setup({})
  -- Mock nvim-web-devicons for older plugins that do not natively support mini.icons yet
  require("mini.icons").mock_nvim_web_devicons()

  -- Configure catppuccin
  require("catppuccin").setup({
    custom_highlights = function(colors)
      return {
        VertSplit = { fg = colors.surface2 },
        WinSeparator = { fg = colors.surface2 },
      }
    end,
  })

  -- Set colorscheme
  vim.cmd.colorscheme("catppuccin-frappe")
end

-- ============================================================
-- Formatting via conform.nvim setup and keymap
-- ============================================================
do
  vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
  })

  require("conform").setup({
    format_on_save = function(_)
      if not vim.g.autoformat then
        return
      end
      return { timeout_ms = 3000 }
    end,
    default_format_opts = { lsp_format = "fallback" },
    formatters_by_ft = {
      ["_"] = { "trim_whitespace", "trim_newlines" },
    },
  })

  -- Set formatexpr for gq range formatting
  vim.o.formatexpr = "v:lua.require('conform').formatexpr()"
end
