local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
M._git_repo_cache = {}

--- Generate session name for current working directory.
---@return string session name
function M.generate_session_name_cwd()
  local cwd = vim.fn.getcwd()

  -- Override to git_repo if present
  local session_name = cwd
  local git_dir = M.git_dir_cwd()
  if git_dir ~= "" then
    session_name = git_dir
  end

  -- Trim trailing whitespaces
  local session_name_short = vim.fn.fnamemodify(session_name, ":t")
  session_name_short = string.gsub(session_name_short, "^%s*(.-)%s*$", "%1")
  return session_name_short
end

--- Returns git_dir associated with the cwd, if any.
--- If cwd does not belong in git repo, returns empty string.
---@return string git_dir
function M.git_dir_cwd()
  local cwd = vim.fn.getcwd()

  -- If not present from cache, populate it
  if M._git_repo_cache[cwd] == nil then
    local git_dir = ""

    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
      git_dir = vim.fn.system(string.format("git -C %s rev-parse --show-toplevel", vim.fn.expand("%:p:h")))
      git_dir = string.gsub(git_dir, "\n", "") -- remove newline character from git_dir
    end

    M._git_repo_cache[cwd] = git_dir
  end

  return M._git_repo_cache[cwd]
end

-- nvim-notify integration

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

-- Internal state of centered float term
M._term_state = { win = -1, buf = -1 }

--- Toggle a centered native floating terminal window.
---@param cmd string|nil the command to run (e.g. "lazygit"), or nil for the default shell.
function M.toggle_terminal(cmd)
  -- If the window is already open and valid, close it
  if vim.api.nvim_win_is_valid(M._term_state.win) then
    vim.api.nvim_win_close(M._term_state.win, true)
    return
  end

  -- Reuse the existing terminal buffer if valid, otherwise create a new one
  if not vim.api.nvim_buf_is_valid(M._term_state.buf) then
    M._term_state.buf = vim.api.nvim_create_buf(false, true)
  end

  -- Calculate optimized dimensions (centered, 95% width & height)
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.95)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Open the floating window
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

  -- If it's a fresh buffer, open the terminal job
  if vim.bo[M._term_state.buf].buftype ~= "terminal" then
    vim.fn.jobstart(cmd or vim.o.shell, {
      term = true,
      on_exit = function(_, exit_code, _)
        if exit_code == 0 then
          -- Process exited successfully: close floating window and delete buffer automatically
          if vim.api.nvim_win_is_valid(M._term_state.win) then
            vim.api.nvim_win_close(M._term_state.win, true)
          end
          if vim.api.nvim_buf_is_valid(M._term_state.buf) then
            vim.api.nvim_buf_delete(M._term_state.buf, { force = true })
          end
        end
      end,
    })

    -- Ensure buffer is marked cleanly and ignored by buffer removers or session saving
    vim.bo[M._term_state.buf].buflisted = false
  end

  -- Automatically enter insert mode
  vim.cmd("startinsert")
end

return M
