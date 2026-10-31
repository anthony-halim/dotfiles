vim.pack.add({
  "https://github.com/nvim-mini/mini.sessions",
})

local MiniSessions = require("mini.sessions")
local utils = require("utils")

-- Configure and setup mini.sessions
MiniSessions.setup({
  autoread = false,
  autowrite = false, -- Disable default autocmd
})

--- Get session name tied to the Git project root (fallback to cwd)
---@return string session name
MiniSessions.get_current_session_name = function()
  local dir = utils.git_dir_cwd()
  local root = dir ~= "" and dir or vim.fn.getcwd()
  return vim.fn.fnamemodify(root, ":t")
end

-- Custom auto-saving session logic on VimLeavePre
do
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

    local session_name = MiniSessions.get_current_session_name()
    MiniSessions.write(session_name, { force = true })
  end

  vim.api.nvim_create_autocmd(
    "VimLeavePre",
    { group = augroup, callback = autowrite, desc = "Autowrite current session" }
  )
end
