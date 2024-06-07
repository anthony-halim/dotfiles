return {
  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          --- @diagnostic disable-next-line:undefined-global
          if not MiniFiles.close() then
            --- @diagnostic disable-next-line:undefined-global
            MiniFiles.open(vim.api.nvim_buf_get_name(0))
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
        -- Filter .git
        filter = function(fs_entry)
          return not vim.startswith(fs_entry.name, ".git")
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
    },
    opts = {
      pickers = {
        find_files = {
          hidden = true,
        },
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
          "%.git",
        },
      },
      extensions = {
        fzf = {},
      },
    },
    keys = {
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Files in buffers" },
      {
        "<leader>ff",
        function()
          -- Check for git repo to use as cwd, then fallback to current directory
          local function is_git_repo()
            vim.fn.system("git rev-parse --is-inside-work-tree")
            return vim.v.shell_error == 0
          end
          local function get_git_root()
            local dot_git_path = vim.fn.finddir(".git", ".;")
            return vim.fn.fnamemodify(dot_git_path, ":h")
          end
          local opts = {}
          if is_git_repo() then
            opts = {
              cwd = get_git_root(),
            }
          end
          require("telescope.builtin").find_files(opts)
        end,
        desc = "Find files",
      },
      {
        "<leader>fd",
        "<cmd>Telescope find_files search_dirs={'%:p:h'}<cr>",
        desc = "Files in directory",
      },
      {
        "<leader>sb",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "Search fuzzy current buffer",
      },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Search help" },
      { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Search current word" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search grep" },
      {
        "<leader>sG",
        "<cmd>Telescope live_grep search_dirs={'%:p:h'}<cr>",
        desc = "Search by grep in file directory",
      },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Search diagnostics" },
      { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume search" },
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
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>B"] = { name = "+Bible" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>d"] = { name = "+diagnostic" },
        ["<leader>f"] = { name = "+file" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>gb"] = { name = "+blame" },
        ["<leader>gd"] = { name = "+diff" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>z"] = { name = "+zettelkasten" },
        ["<leader>zs"] = { name = "+search" },
        ["<leader>zn"] = { name = "+notes" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },

  -- Custom highlighting
  {
    "echasnovski/mini.hipatterns",
    event = { "BufReadPost" },
    opts = function()
      local hipatterns = require("mini.hipatterns")
      return {
        -- To see all highlight groups that are currently active,
        -- :so $VIMRUNTIME/syntax/hitest.vim
        highlighters = {
          fixme = {
            pattern = "%f[%w]()FIXME()%f[%W]",
            group = "DiagnosticVirtualTextError",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignError" },
          },
          hack = {
            pattern = "%f[%w]()HACK()%f[%W]",
            group = "DiagnosticVirtualTextWarn",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignWarn" },
          },
          warn = {
            pattern = "%f[%w]()WARNING()%f[%W]",
            group = "DiagnosticVirtualTextWarn",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignWarn" },
          },
          todo = {
            pattern = "%f[%w]()TODO()%f[%W]",
            group = "DiagnosticVirtualTextInfo",
            extmark_opts = { sign_text = "", sign_hl_group = "DiagnosticSignInfo" },
          },
          note = {
            pattern = "%f[%w]()NOTE()%f[%W]",
            group = "DiagnosticVirtualTextHint",
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
      { "<C-M-h>", "<cmd>SmartResizeLeft<cr>", desc = "Resize window (left)" },
      { "<C-M-j>", "<cmd>SmartResizeDown<cr>", desc = "Resize window (down)" },
      { "<C-M-k>", "<cmd>SmartResizeUp<cr>", desc = "Resize window (up)" },
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
