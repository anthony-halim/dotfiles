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
  session_name_short = string.gsub(session_name_short, '^%s*(.-)%s*$', '%1')
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

function M.lsp_progress(_, result, ctx)
  local client_id = ctx.client_id

  local val = result.value
  if not val.kind then
    return
  end

  local notif_data = M._get_notif_data(client_id, result.token)

  if val.kind == "begin" then
    local message = M._format_message(val.message, val.percentage)

    notif_data.notification = vim.notify(message, "info", {
      title = M._format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
      icon = M._spinner_frames[1],
      timeout = false,
      hide_from_history = false,
    })
    notif_data.spinner = 1

    M._update_spinner(client_id, result.token)
  elseif val.kind == "report" and notif_data then
    notif_data.notification = vim.notify(M._format_message(val.message, val.percentage), "info", {
      replace = notif_data.notification,
      hide_from_history = false,
    })
  elseif val.kind == "end" and notif_data then
    notif_data.notification =
        vim.notify(val.message and M._format_message(val.message) or "Complete", "info", {
          icon = "",
          replace = notif_data.notification,
          timeout = 3000,
        })
    notif_data.spinner = nil
  end
end

return M
