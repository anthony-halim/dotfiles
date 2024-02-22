return {
  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "olimorris/persisted.nvim",
    event = "BufReadPre",
    cmd = { "SessionLoadLast" },
    opts = {
      should_autosave = function()
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        if bufname:match("/tmp/edit%.[%d%a]+/") then
          return false
        end
        return true
      end,
    },
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}
