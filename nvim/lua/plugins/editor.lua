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
          if not MiniFiles.close() then
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
        max_number = 3,
        -- Whether to show preview of file/directory under cursor
        preview = true,
        -- Width of focused window
        width_focus = 30,
        -- Width of non-focused window
        width_nofocus = 15,
        -- Width of preview window
        width_preview = 25,
      },
      options = {
        use_as_default_explorer = false,
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
          ".git",
        },
      },
      extensions = {
        fzf = {},
      },
    },

    keys = {
      {
        "<leader>sb",
        "<cmd>Telescope current_buffer_fuzzy_find<cr>",
        desc = "[S]earch fuzzy current buffer",
      },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "[F]iles in [B]uffers" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>",   desc = "[F]iles included in [G]it" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "[S]earch [F]iles" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>",   desc = "[S]earch [H]elp" },
      { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "[S]earch current [W]ord" },
      { "<leader>sg", "<cmd>Telescope live_grep<cr>",   desc = "[S]earch by [G]rep" },
      { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "[S]earch [D]iagnostics" },
      { "<leader>sr", "<cmd>Telescope resume<cr>",      desc = "[S]earch [R]esume" },
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
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
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
        ["<leader>s"] = { name = "+search" },
        ["<leader>sn"] = { name = "+Noice" },
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

  -- Flash enhances the built-in search functionality by showing labels
  -- at the end of each match, letting you quickly jump to a specific
  -- location.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Jump (Flash)" },
    },
  },

  -- Finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
    },
  },

  -- buffer remove
  {
    "echasnovski/mini.bufremove",
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
      { "<C-M-h>", "<cmd>SmartResizeLeft<cr>",  { desc = "Resize window (left)" } },
      { "<C-M-j>", "<cmd>SmartResizeDown<cr>",  { desc = "Resize window (down)" } },
      { "<C-M-k>", "<cmd>SmartResizeUp<cr>",    { desc = "Resize window (up)" } },
      { "<C-M-l>", "<cmd>SmartResizeRight<cr>", { desc = "Resize window (right)" } },
    },
  },
}