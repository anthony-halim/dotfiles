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
  local root = vim.fs.root(0, ".git")
  local rel = (root and path ~= "") and vim.fs.relpath(root, path) or "%f"
  return rel .. "%m%r"
end

-- ============================================================
-- Floating Terminal
-- ============================================================

M._term_state = { win = -1, buf = -1 }

--- Toggle a centered native floating terminal window.
---@param cmd string|nil the command to run (e.g. "lazygit"), or nil for the default shell.
function M.toggle_terminal(cmd)
  if vim.api.nvim_win_is_valid(M._term_state.win) then
    vim.api.nvim_win_close(M._term_state.win, true)
    return
  end

  if not vim.api.nvim_buf_is_valid(M._term_state.buf) then
    M._term_state.buf = vim.api.nvim_create_buf(false, true)
  end

  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.95)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  M._term_state.win = vim.api.nvim_open_win(M._term_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = string.format(" %s ", cmd and string.upper(string.sub(cmd, 1, 1)) .. string.sub(cmd, 2) or "Terminal"),
    title_pos = "center",
  })

  if vim.bo[M._term_state.buf].buftype ~= "terminal" then
    vim.fn.jobstart(cmd or vim.o.shell, {
      term = true,
      on_exit = function(_, exit_code, _)
        if exit_code == 0 then
          if vim.api.nvim_win_is_valid(M._term_state.win) then
            vim.api.nvim_win_close(M._term_state.win, true)
          end
          if vim.api.nvim_buf_is_valid(M._term_state.buf) then
            vim.api.nvim_buf_delete(M._term_state.buf, { force = true })
          end
        end
      end,
    })

    vim.bo[M._term_state.buf].buflisted = false
  end

  vim.cmd("startinsert")
end

-- ============================================================
-- LSP Progress Notifications
-- ============================================================

M._client_notifs = {}
M._spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

function M._get_notif_data(client_id, token)
  if not M._client_notifs[client_id] then
    M._client_notifs[client_id] = {}
  end

  if not M._client_notifs[client_id][token] then
    M._client_notifs[client_id][token] = {}
  end

  return M._client_notifs[client_id][token]
end

function M._update_spinner(client_id, token)
  local notif_data = M._get_notif_data(client_id, token)

  if notif_data.spinner then
    local new_spinner = (notif_data.spinner + 1) % #M._spinner_frames
    notif_data.spinner = new_spinner

    notif_data.notification = vim.notify(nil, nil, {
      hide_from_history = true,
      icon = M._spinner_frames[new_spinner],
      replace = notif_data.notification,
    })

    vim.defer_fn(function()
      M._update_spinner(client_id, token)
    end, 100)
  end
end

function M._format_title(title, client_name)
  return client_name .. (#title > 0 and ": " .. title or "")
end

function M._format_message(message, percentage)
  return (percentage and percentage .. "%\t" or "") .. (message or "")
end

--- LSP progress handler for LspProgress autocommand.
---@param ev table The autocommand event payload.
function M.lsp_progress(ev)
  if not ev or not ev.data or not ev.data.params then
    return
  end
  local client_id = ev.data.client_id
  local params = ev.data.params
  local val = params.value
  if not val or not val.kind then
    return
  end

  local token = params.token
  local notif_data = M._get_notif_data(client_id, token)

  if val.kind == "begin" then
    local message = M._format_message(val.message, val.percentage)
    local client = vim.lsp.get_client_by_id(client_id)
    local client_name = client and client.name or "LSP"

    notif_data.notification = vim.notify(message, vim.log.levels.INFO, {
      title = M._format_title(val.title, client_name),
      icon = M._spinner_frames[1],
      timeout = false,
      hide_from_history = false,
    })
    notif_data.spinner = 1

    M._update_spinner(client_id, token)
  elseif val.kind == "report" and notif_data and notif_data.notification then
    notif_data.notification = vim.notify(M._format_message(val.message, val.percentage), vim.log.levels.INFO, {
      replace = notif_data.notification,
      hide_from_history = false,
    })
  elseif val.kind == "end" and notif_data and notif_data.notification then
    notif_data.notification = vim.notify(val.message and M._format_message(val.message) or "Complete", vim.log.levels.INFO, {
      icon = "",
      replace = notif_data.notification,
      timeout = 3000,
    })
    notif_data.spinner = nil
  end
end

return M
