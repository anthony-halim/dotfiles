return {
  -- LSP progress
  {
    "linrongbin16/lsp-progress.nvim",
    opts = {
      client_format = function(client_name, spinner, series_messages)
        if #series_messages == 0 then
          return nil
        end
        return {
          name = client_name,
          body = spinner .. " " .. table.concat(series_messages, ", "),
        }
      end,
      format = function(client_messages)
        --- @param name string
        --- @param msg string?
        --- @return string
        local function stringify(name, msg)
          return msg and string.format("%s %s", name, msg) or name
        end

        local sign = "" -- nf-fa-gear \uf013
        local lsp_clients = vim.lsp.get_clients()
        local messages_map = {}
        for _, climsg in ipairs(client_messages) do
          messages_map[climsg.name] = climsg.body
        end

        if #lsp_clients > 0 then
          table.sort(lsp_clients, function(a, b)
            return a.name < b.name
          end)
          local builder = {}
          for _, cli in ipairs(lsp_clients) do
            if type(cli) == "table" and type(cli.name) == "string" and string.len(cli.name) > 0 then
              if messages_map[cli.name] then
                table.insert(builder, stringify(cli.name, messages_map[cli.name]))
              else
                table.insert(builder, stringify(cli.name))
              end
            end
          end
          if #builder > 0 then
            return sign .. " " .. table.concat(builder, ", ")
          end
        end
        return ""
      end,
    },
  },

  -- Better vim.ui
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },

  -- Better vim.notify
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      stages = "fade_in_slide_out",
    },
    keys = {
      { "<leader>sn", "<cmd>Telescope notify<cr>", desc = "Search notification" },
    },
    init = function()
      vim.notify = require("notify")
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "linrongbin16/lsp-progress.nvim",
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { { "b:gitsigns_head", icon = "" } },
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = " ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          { "searchcount" },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
          {
            function()
              local ok, lsp_progress = pcall(require, "lsp-progress")
              if ok then
                return lsp_progress.progress()
              end
            end,
          },
        },
      },
      extensions = { "nvim-tree", "lazy" },
    },
    init = function()
      -- listen lsp-progress event and refresh lualine
      vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = "lualine_augroup",
        pattern = "LspProgressStatusUpdated",
        callback = require("lualine").refresh,
      })
    end,
  },

  -- Floating filename for each window
  {
    "b0o/incline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      window = {
        margin = {
          horizontal = 0,
          vertical = 0,
        },
        placement = {
          horizontal = "right",
          vertical = "bottom",
        },
      },
      render = function(props)
        local icons = require("config").options.icons

        -- Filename
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":p:.")
        local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
        local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf }) and "bold,italic" or "bold"

        -- Diagnostic
        local diagnostic_labels = {}
        for severity, icon in pairs(icons.diagnostics) do
          local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
          if n > 0 then
            table.insert(diagnostic_labels, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
          end
        end
        if #diagnostic_labels > 0 then
          table.insert(diagnostic_labels, { "| " })
        end

        -- Git changes
        local git_labels = {}
        local ok, gitsign_status = pcall(vim.api.nvim_buf_get_var, props.buf, "gitsigns_status_dict")
        if ok then
          for name, icon in pairs(icons.git) do
            if tonumber(gitsign_status[name]) and gitsign_status[name] > 0 then
              table.insert(git_labels, { icon .. " " .. gitsign_status[name] .. " ", group = "Diff" .. name })
            end
          end
          if #git_labels > 0 then
            table.insert(git_labels, { "| " })
          end
        end

        local buffer = {
          { diagnostic_labels },
          { git_labels },
          { ft_icon,          guifg = ft_color },
          { " " },
          { filename,         gui = modified },
        }
        return buffer
      end,
    },
    config = true,
  },

  -- Active indent guide and indent text objects. When you're browsing
  -- code, this highlights the current level of indentation, and animates
  -- the highlighting.
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          ---@diagnostic disable-next-line:inject-field
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- Splash screen
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    dependencies = {
      "echasnovski/mini.sessions",
    },
    opts = function()
      local utils = require("utils.utils")
      local starter = require("mini.starter")
      local sessions = require("mini.sessions")
      local options = {}

      options.header = [[
⣿⣿⣿⣿⣿⣿⡿⣟⠻⠯⠭⠉⠛⠋⠉⠉⠛⠻⢿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡽⠚⠉⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠈⠙⢿⣿⣿⣿
⣿⣿⠏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣷⣦⡀⠶⣿⣿⣿
⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡆⢻⣿⣿
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣤⣻⣿⣯⣤⣹⣿
⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⡇⠀⣿⢟⣿⡀⠟⢹⣿
⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣷⣤⣤⣼⣿⣿⡄⢹⣿
⣷⠀⠀⠀⠶⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⠛⠉⠈⢻
⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠋⠛⠛⠛⠀⠀⣤⣾
⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠛⠁⣰⣿⣿
⣿⣿⣿⣿⣿⣷⣦⣤⣤⣤⣤⣄⣀⣀⣀⣀⣀⣠⣤⣤⣤⣾⣿⣿⣿
]]

      options.evaluate_single = true

      options.items = {
        starter.sections.sessions(3, true),
        { name = "Find file",   action = "Telescope find_files", section = "Shortcuts" },
        { name = "Search grep", action = "Telescope live_grep",  section = "Shortcuts" },
        { name = "New file",    action = "enew",                 section = "Shortcuts" },
        { name = "Lazy",        action = "Lazy",                 section = "Shortcuts" },
        { name = "Quit",        action = "qall",                 section = "Shortcuts" },
      }

      -- Add additional shortcut to reload current directory
      -- session if present
      local session_name = utils.generate_session_name_cwd()
      if sessions.detected[utils.generate_session_name_cwd()] ~= nil then
        table.insert(options.items, 2, {
          name = "Restore session",
          action = function()
            sessions.read(session_name)
          end,
          section = "Shortcuts",
        })
      end

      options.footer = function()
        local hour = tonumber(vim.fn.strftime('%H'))
        -- [04:00, 12:00) - morning, [12:00, 20:00) - day, [20:00, 04:00) - evening
        local part_id = math.floor((hour + 4) / 8) + 1
        local day_part = ({ 'evening', 'morning', 'afternoon', 'evening' })[part_id]
        local username = vim.uv.os_get_passwd()['username'] or 'USERNAME'
        return ('Good %s, %s'):format(day_part, username)
      end

      options.silent = true

      return options
    end,
  },

  -- icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ui components
  { "MunifTanjim/nui.nvim",        lazy = true },
}
