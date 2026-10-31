local M = {}

-- ============================================================
-- Git Utilities
-- ============================================================

--- Returns git root path associated with current buffer/cwd, or empty string if not in git.
---@return string git_dir
function M.git_dir_cwd()
  return vim.fs.root(0, ".git") or vim.fs.root(vim.fn.getcwd(), ".git") or ""
end

--- Returns the buffer's file path relative to the Git repository root (falls back to '%f').
---@return string
function M.git_relative_path()
  local path = vim.api.nvim_buf_get_name(0)
  local root = M.git_dir_cwd()
  local rel = (root ~= "" and path ~= "") and vim.fs.relpath(root, path) or "%f"
  return rel .. "%m%r"
end

-- ============================================================
-- Floating Terminal
-- ============================================================

local term_state = { win = -1, buf = -1 }

--- Toggle a centered native floating terminal window.
---@param cmd string|nil the command to run (e.g. "lazygit"), or nil for the default shell.
function M.toggle_terminal(cmd)
  if vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_close(term_state.win, true)
    return
  end

  if not vim.api.nvim_buf_is_valid(term_state.buf) then
    term_state.buf = vim.api.nvim_create_buf(false, true)
  end

  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.95)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local title = cmd and cmd:gsub("^%l", string.upper) or "Terminal"

  term_state.win = vim.api.nvim_open_win(term_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = string.format(" %s ", title),
    title_pos = "center",
  })

  if vim.bo[term_state.buf].buftype ~= "terminal" then
    vim.fn.jobstart(cmd or vim.o.shell, {
      term = true,
      on_exit = function(_, exit_code, _)
        if exit_code == 0 then
          if vim.api.nvim_win_is_valid(term_state.win) then
            vim.api.nvim_win_close(term_state.win, true)
          end
          if vim.api.nvim_buf_is_valid(term_state.buf) then
            vim.api.nvim_buf_delete(term_state.buf, { force = true })
          end
        end
      end,
    })

    vim.bo[term_state.buf].buflisted = false
  end

  vim.cmd("startinsert")
end

-- ============================================================
-- LSP Progress Notifications
-- ============================================================

local notifs = {}
local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(key)
  local data = notifs[key]
  if data and data.spinner then
    data.spinner = (data.spinner % #spinner_frames) + 1
    data.notif = vim.notify(nil, nil, {
      hide_from_history = true,
      icon = spinner_frames[data.spinner],
      replace = data.notif,
    })
    vim.defer_fn(function()
      update_spinner(key)
    end, 100)
  end
end

--- LSP progress handler for LspProgress autocommand.
---@param ev table The autocommand event payload.
function M.lsp_progress(ev)
  local params = ev and ev.data and ev.data.params
  local val = params and params.value
  if not val or not val.kind then
    return
  end

  local key = ev.data.client_id .. ":" .. tostring(params.token)
  local data = notifs[key] or {}
  notifs[key] = data

  local msg = (val.percentage and val.percentage .. "%\t" or "") .. (val.message or "")

  if val.kind == "begin" then
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local title = (client and client.name or "LSP") .. (val.title and ": " .. val.title or "")
    data.notif = vim.notify(msg, vim.log.levels.INFO, {
      title = title,
      icon = spinner_frames[1],
      timeout = false,
    })
    data.spinner = 1
    update_spinner(key)
  elseif val.kind == "report" and data.notif then
    data.notif = vim.notify(msg, vim.log.levels.INFO, {
      replace = data.notif,
    })
  elseif val.kind == "end" and data.notif then
    data.spinner = nil
    data.notif = vim.notify(val.message or "Complete", vim.log.levels.INFO, {
      icon = "",
      replace = data.notif,
      timeout = 2500,
    })
    vim.defer_fn(function()
      notifs[key] = nil
    end, 3000)
  end
end

return M
