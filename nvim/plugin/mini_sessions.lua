vim.pack.add({
  "https://github.com/nvim-mini/mini.sessions",
})

-- Configure and setup mini.sessions
require("mini.sessions").setup({
  autoread = false,
  autowrite = false, -- Disable default autocmd
})

-- Custom auto-saving session logic on VimLeavePre
do
  local utils = require("utils.utils")
  local sessions = require("mini.sessions")
  local augroup = vim.api.nvim_create_augroup("MiniSessions", {})

  local autowrite = function()
    -- Only write session for meaningful buffers
    local bufs = vim.tbl_filter(function(b)
      -- Filter by buffer type
      local ft = vim.bo[b].filetype
      if
        ft == "gitcommit"
        or ft == "gitrebase"
        or ft == "ministarter"
        or ft == "minifiles"
      then
        return false
      end

      -- Filter by buffer name
      local bufname = vim.api.nvim_buf_get_name(b)
      if bufname:match("/tmp/edit%.[%d%a]+/") then
        return false
      end

      return bufname ~= ""
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
end
