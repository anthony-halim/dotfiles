return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Better notification
      notifier = { enabled = true },
      -- Better vim.ui.input
      input = { enabled = true },
      styles = {
        -- Input at cursor position
        input = { relative = "cursor", row = -3, col = 0 },
      },
    },
    init = function()
      -- LSP Progress via notification
      vim.api.nvim_create_autocmd("LspProgress", {
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
          local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.notify(vim.lsp.status(), "info", {
            id = "lsp_progress",
            title = "LSP Progress",
            opts = function(notif)
              notif.icon = ev.data.params.value.kind == "end" and " "
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
          })
        end,
      })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
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
        lualine_b = { { "branch", icon = "" } },
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = " ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          { "searchcount" },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
      extensions = { "nvim-tree", "lazy" },
    },
  },

  -- Floating filename for each window
  {
    "b0o/incline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "echasnovski/mini.icons",
      "echasnovski/mini.diff",
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
        local icons_config = require("config").options.icons
        local icons = require("mini.icons")

        -- Filename
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":p:.")
        local ft_icon, ft_hl, _ = icons.get("file", filename)
        local modified = vim.api.nvim_get_option_value("modified", { buf = props.buf }) and "bold,italic" or "bold"

        -- Diagnostic
        local diagnostic_labels = {}
        for severity, icon in pairs(icons_config.diagnostics) do
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
        local ok, minidiff_summary = pcall(vim.api.nvim_buf_get_var, props.buf, "minidiff_summary")
        if ok then
          if minidiff_summary.add ~= nil and minidiff_summary.add > 0 then
            table.insert(git_labels, { icons_config.git.add .. minidiff_summary.add .. " ", group = "MiniDiffSignAdd" })
          end
          if minidiff_summary.change ~= nil and minidiff_summary.change > 0 then
            table.insert(
              git_labels,
              { icons_config.git.change .. minidiff_summary.change .. " ", group = "MiniDiffSignChange" }
            )
          end
          if minidiff_summary.delete ~= nil and minidiff_summary.delete > 0 then
            table.insert(
              git_labels,
              { icons_config.git.delete .. minidiff_summary.delete .. " ", group = "MiniDiffSignDelete" }
            )
          end
          if #git_labels > 0 then
            table.insert(git_labels, { "| " })
          end
        end

        local buffer = {
          { diagnostic_labels },
          { ft_icon, group = ft_hl },
          { " " },
          { filename, gui = modified },
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
      "echasnovski/mini.pick",
      "echasnovski/mini.extra",
    },
    opts = function()
      local utils = require("utils.utils")
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
        {
          name = "Find file",
          action = function()
            local git_dir = require("utils.utils").git_dir_cwd()
            if git_dir ~= "" then
              require("mini.extra").pickers.git_files()
            else
              require("mini.pick").builtin.files()
            end
          end,
          section = "Shortcuts",
        },
        {
          name = "Search grep",
          action = function()
            local local_opts = {}
            if require("utils.utils").git_dir_cwd() ~= "" then
              local_opts = { tool = "git" }
            end
            require("mini.pick").builtin.grep_live(local_opts)
          end,
          section = "Shortcuts",
        },
        { name = "New file", action = "enew", section = "Shortcuts" },
        { name = "Lazy", action = "Lazy", section = "Shortcuts" },
        { name = "Quit", action = "qall", section = "Shortcuts" },
      }

      -- Add additional shortcut to reload current directory
      -- session if present
      local session_name = utils.generate_session_name_cwd()
      if sessions.detected[utils.generate_session_name_cwd()] ~= nil then
        table.insert(options.items, 0, {
          name = "Restore session",
          action = function()
            sessions.read(session_name)
          end,
          section = "Shortcuts",
        })
      end

      options.footer = function()
        local hour = tonumber(vim.fn.strftime("%H"))
        -- [04:00, 12:00) - morning, [12:00, 20:00) - day, [20:00, 04:00) - evening
        local part_id = math.floor((hour + 4) / 8) + 1
        local day_part = ({ "evening", "morning", "afternoon", "evening" })[part_id]
        local username = vim.uv.os_get_passwd()["username"] or "USERNAME"
        return ("Good %s, %s"):format(day_part, username)
      end

      options.silent = true

      return options
    end,
  },

  -- icons
  { "echasnovski/mini.icons", opts = {}, lazy = true },
}
