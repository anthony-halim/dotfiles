return {
  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    dependencies = {
      "echasnovski/mini.icons",
    },
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          local minifiles = require("mini.files")
          if vim.bo.ft == "minifiles" then
            minifiles.close()
          else
            local file = vim.api.nvim_buf_get_name(0)
            local file_exists = vim.fn.filereadable(file) ~= 0
            minifiles.open(file_exists and file or nil)
          end
        end,
        desc = "Explorer Tree",
      },
    },
    opts = {
      mappings = {
        close = "q",
        go_in = "",
        go_in_plus = "<cr>",
        go_out = "<bs>",
        go_out_plus = "",
        reset = ".",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },
      content = {
        filter = function(entry)
          return entry.name ~= ".DS_Store" and entry.name ~= ".git" and entry.name ~= ".direnv"
        end,
      },
      windows = {
        -- Maximum number of windows to show side by side
        max_number = math.huge,
        -- Whether to show preview of file/directory under cursor
        preview = false,
        -- Width of focused window
        width_focus = math.min(math.floor(vim.o.columns * 0.4), 40),
        -- Width of non-focused window
        width_nofocus = math.min(math.floor(vim.o.columns * 0.2), 25),
        -- Width of preview window
        width_preview = math.min(math.floor(vim.o.columns * 0.3), 80),
      },
      options = {
        use_as_default_explorer = true,
      },
    },
    init = function()
      -- For other plugins that only supports nvim-web-devicons
      require("mini.icons").mock_nvim_web_devicons()

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("mini_files_start_directory", { clear = true }),
        desc = "Start Mini.files with directory",
        once = true,
        callback = function()
          if package.loaded["mini.files"] then
            return
          else
            local stats = vim.uv.fs_stat(vim.fn.argv(0))
            if stats and stats.type == "directory" then
              require("mini.files").open()
            end
          end
        end,
      })
    end,
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    "echasnovski/mini.pick",
    dependencies = {
      "echasnovski/mini.icons",
      "echasnovski/mini.extra",
    },
    opts = {
      delay = {
        busy = 10,
      },
      options = {
        use_cache = true,
      },
      window = {
        config = {
          border = "rounded",
        },
        prompt_prefix = " "
      }
    },
    keys = {
      {
        "<leader>fb",
        function()
          require("mini.pick").builtin.buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>ff",
        function()
          local git_dir = require("utils.utils").git_dir_cwd()
          if git_dir ~= "" then
            require("mini.extra").pickers.git_files()
          else
            require("mini.pick").builtin.files()
          end
        end,
        desc = "Find files",
      },
      {
        "<leader>fF",
        function()
          local git_dir = require("utils.utils").git_dir_cwd()
          if git_dir ~= "" then
            require("mini.extra").pickers.git_files({ scope = "ignored" })
          else
            require("mini.pick").builtin.files()
          end
        end,
        desc = "Find hidden files",
      },
      {
        "<leader>fd",
        function()
          local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
          require("mini.pick").builtin.files({}, opts)
        end,
        desc = "Find files in buffer directory",
      },
      {
        "<leader>sb",
        function()
          require("mini.extra").pickers.buf_lines({ scope = "current" })
        end,
        desc = "Search fuzzy current buffer",
      },
      {
        "<leader>ss",
        function()
          local local_opts = {}
          if require("utils.utils").git_dir_cwd() ~= "" then
            local_opts = { tool = "git" }
          end
          require("mini.pick").builtin.grep_live(local_opts)
        end,
        desc = "Search grep",
      },
      {
        "<leader>sd",
        function()
          local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
          local local_opts = {}
          if require("utils.utils").git_dir_cwd() ~= "" then
            local_opts = { tool = "git" }
          end
          require("mini.pick").builtin.grep_live(local_opts, opts)
        end,
        desc = "Search grep in buffer directory",
      },
      {
        "<leader>sx",
        function()
          require("mini.extra").pickers.diagnostic()
        end,
        desc = "Search diagnostics"
      },
      {
        "<leader>sh",
        function()
          require("mini.pick").builtin.help()
        end,
        desc = "Search help"
      },
      {
        "<leader>sr",
        function()
          require("mini.pick").builtin.resume()
        end,
        desc = "Resume search",
      },
    },
  },

  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      current_line_blame_opts = {
        delay = 200,
        ignore_whitespace = true,
        virt_text_priority = 100,
      },
      preview_config = {
        border = "rounded",
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gbb", function() gs.blame_line({ full = false }) end, "Blame line")
        map("n", "<leader>gbB", function() gs.blame_line({ full = true }) end, "Blame line (full)")
        map("n", "<leader>gbt", gs.toggle_current_line_blame, "Toggle blame line")
        map("n", "<leader>gdd", gs.diffthis, "Diff this")
        map("n", "<leader>gdD", function() gs.diffthis("~") end, "Diff this ~")
      end,
    },
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b",  desc = "+buffer" },
        { "<leader>c",  desc = "+code" },
        { "<leader>d",  desc = "+diagnostic" },
        { "<leader>f",  desc = "+file" },
        { "<leader>g",  desc = "+git" },
        { "<leader>gh", desc = "+hunks" },
        { "<leader>gb", desc = "+blame" },
        { "<leader>gd", desc = "+diff" },
        { "<leader>s",  desc = "+search" },
        { "<leader>u",  desc = "+ui" },
      },
    },
  },

  -- Custom highlighting
  {
    "echasnovski/mini.hipatterns",
    event = { "BufReadPost" },
    dependencies = {
      "echasnovski/mini.extra",
    },
    opts = function()
      local hi_words = require("mini.extra").gen_highlighter.words
      local hi_patterns = require("mini.hipatterns")
      return {
        -- To see all highlight groups that are currently active,
        -- :so $VIMRUNTIME/syntax/hitest.vim
        highlighters = {
          fixme = hi_words(
            { "FIXME", "FIX" },
            "MiniHipatternsFixme",
            { sign_text = "", sign_hl_group = "DiagnosticSignError" }
          ),
          hack = hi_words(
            { "HACK" },
            "MiniHipatternsHack",
            { sign_text = "", sign_hl_group = "DiagnosticSignWarn" }
          ),
          warning = hi_words(
            { "WARNING" },
            "MiniHipatternsHack",
            { sign_text = "", sign_hl_group = "DiagnosticSignWarn" }
          ),
          todo = hi_words(
            { "TODO" },
            "MiniHipatternsTodo",
            { sign_text = "", sign_hl_group = "DiagnosticSignInfo" }
          ),
          note = hi_words(
            { "NOTE" },
            "MiniHipatternsNote",
            { sign_text = " ", sign_hl_group = "DiagnosticSignHint" }
          ),
          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hi_patterns.gen_highlighter.hex_color({ priority = 2000 }),
        },
      }
    end,
  },

  -- buffer remove
  {
    "echasnovski/mini.bufremove",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end,  desc = "Delete Buffer (Force)" },
    },
  },

  -- Better window resize
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      { "<C-M-h>", "<cmd>SmartResizeLeft<cr>",  desc = "Resize window (left)" },
      { "<C-M-j>", "<cmd>SmartResizeDown<cr>",  desc = "Resize window (down)" },
      { "<C-M-k>", "<cmd>SmartResizeUp<cr>",    desc = "Resize window (up)" },
      { "<C-M-l>", "<cmd>SmartResizeRight<cr>", desc = "Resize window (right)" },
    },
  },

  -- Floating window functionalities
  {
    "voldikss/vim-floaterm",
    cmd = { "FloatermNew", "FloatermPrev", "FloatermNext", "FloatermFirst", "FloatermLast", "FloatermUpdate" },
    keys = {
      {
        "<leader>gg",
        "<cmd>FloatermNew --height=0.95 --width=0.95 --wintype=float --disposable --autoclose=2 --title=Lazygit --titleposition=center lazygit<cr>",
        desc = "LazyGit",
      },
    },
  },
}
