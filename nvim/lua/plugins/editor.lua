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
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "echasnovski/mini.icons",
    },
    opts = {
      pickers = {
        git_files = { theme = "ivy" },
        find_files = { theme = "ivy" },
        live_grep = { theme = "ivy" },
        buffers = { theme = "ivy" },
      },
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          i = {
            ["<C-Down>"] = function(...)
              return require("telescope.actions").cycle_history_next(...)
            end,
            ["<C-Up>"] = function(...)
              return require("telescope.actions").cycle_history_prev(...)
            end,
            ["<C-f>"] = function(...)
              return require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-b>"] = function(...)
              return require("telescope.actions").preview_scrolling_up(...)
            end,
          },
          n = {
            ["q"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
        file_ignore_patterns = {
          "^.git/",
          "node_modules/",
        },
      },
      extensions = {
        fzf = {},
      },
    },
    keys = {
      {
        "<leader>fb",
        "<cmd>Telescope buffers<cr>",
        desc = "Files in buffers",
      },
      {
        "<leader>ff",
        function()
          local opts = {} -- define here if you want to define something
          local git_dir = require("utils.utils").git_dir_cwd()
          if git_dir ~= "" then
            require("telescope.builtin").git_files(opts)
          else
            require("telescope.builtin").find_files(opts)
          end
        end,
        desc = "Find files",
      },
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({ no_ignore = true, hidden = true })
        end,
        desc = "Find files (including hidden)",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").find_files({ no_ignore = true, hidden = true, search_dirs = { "%:p:h" } })
        end,
        desc = "Find files (in directory)",
      },
      {
        "<leader>sb",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({})
        end,
        desc = "Search fuzzy current buffer",
      },
      {
        "<leader>ss",
        function()
          local opts = {}
          local git_dir = require("utils.utils").git_dir_cwd()
          if git_dir ~= "" then
            opts = { cwd = git_dir }
          end
          require("telescope.builtin").live_grep(opts)
        end,
        desc = "Search grep",
      },
      {
        "<leader>sd",
        function()
          require("telescope.builtin").live_grep({ cwd = require("telescope.utils").buffer_dir() })
        end,
        desc = "Search by grep (in buffer directory)",
      },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Search diagnostics" },
      { "<leader>sr", "<cmd>Telescope resume<cr>",      desc = "Resume search" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>",   desc = "Search help" },
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
    init = function()
      local function create_custom_global_hl(group_name, source_name)
        local existing_hl = vim.api.nvim_get_hl(0, { name = source_name })
        vim.api.nvim_set_hl(
          0,
          group_name,
          { italic = true, bold = true, underdotted = true, bg = existing_hl.bg, fg = existing_hl.fg }
        )
      end
      create_custom_global_hl("CustomHipatternsFixme", "DiagnosticError")
      create_custom_global_hl("CustomHipatternsHack", "DiagnosticWarn")
      create_custom_global_hl("CustomHipatternsWarn", "DiagnosticWarn")
      create_custom_global_hl("CustomHipatternsTodo", "DiagnosticInfo")
      create_custom_global_hl("CustomHipatternsNote", "DiagnosticHint")
    end,
    opts = function()
      local hipatterns = require("mini.hipatterns")
      return {
        -- To see all highlight groups that are currently active,
        -- :so $VIMRUNTIME/syntax/hitest.vim
        highlighters = {
          fixme = {
            pattern = "%f[%w]()" .. vim.pesc("FIXME") .. "()%f[%W]",
            group = "CustomHipatternsFixme",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignError" },
          },
          hack = {
            pattern = "%f[%w]()" .. vim.pesc("HACK") .. "()%f[%W]",
            group = "CustomHipatternsHack",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignWarn" },
          },
          warning = {
            pattern = "%f[%w]()" .. vim.pesc("WARNING") .. "()%f[%W]",
            group = "CustomHipatternsWarn",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignWarn" },
          },
          todo = {
            pattern = "%f[%w]()" .. vim.pesc("TODO") .. "()%f[%W]",
            group = "CustomHipatternsTodo",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignInfo" },
          },
          note = {
            pattern = "%f[%w]()" .. vim.pesc("NOTE") .. "()%f[%W]",
            group = "CustomHipatternsNote",
            extmark_opts = { sign_text = " ", sign_hl_group = "DiagnosticSignHint" },
          },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color({ priority = 2000 }),
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
