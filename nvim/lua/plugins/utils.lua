return {
  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "echasnovski/mini.sessions",
    version = false,
    event = "VimEnter",
    opts = {
      autoread = false,
      autowrite = false, -- Disable default autocmd
    },
    init = function()
      local utils = require("utils.utils")
      local sessions = require("mini.sessions")
      local augroup = vim.api.nvim_create_augroup("MiniSessions", {})
      local autowrite = function()
        -- Only write session for meaningful buffers
        local bufs = vim.tbl_filter(function(b)
          -- Filter by buffer type
          if
            vim.bo[b].filetype == "gitcommit"
            or vim.bo[b].filetype == "gitrebase"
            or vim.bo[b].filetype == "ministarter"
            or vim.bo[b].filetype == "minifiles"
          then
            return false
          end

          -- Filter by buffer name
          local bufname = vim.api.nvim_buf_get_name(b)
          if bufname:match("/tmp/edit%.[%d%a]+/") then
            return false
          end

          return vim.api.nvim_buf_get_name(b) ~= ""
        end, vim.api.nvim_list_bufs())
        if #bufs == 0 then
          return
        end

        local session_name = utils.generate_session_name_cwd()
        sessions.write(session_name, { force = true })
      end

      vim.api.nvim_create_autocmd(
        "VimLeavePre",
        { group = augroup, callback = autowrite, desc = "Autowrite current session" }
      )
    end,
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- SchemaStore for JSONs and YAMLs
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
}
