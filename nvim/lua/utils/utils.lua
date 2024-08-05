local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
M._git_repo_cache = {}

--- Generate session name for current working directory.
---@return string session name
function M.generate_session_name_cwd()
  local cwd = vim.fn.getcwd()

  -- Update git_repo cache
  if M._git_repo_cache[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
      local git_repo_path = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
      M._git_repo_cache[cwd] = git_repo_path
    end
  end

  -- Override to git_repo if present
  local session_name = cwd
  if M._git_repo_cache[cwd] ~= "" then
    session_name = M._git_repo_cache[cwd]
  end

  -- Trim trailing whitespaces
  local session_name_short = vim.fn.fnamemodify(session_name, ":t")
  session_name_short = string.gsub(session_name_short, '^%s*(.-)%s*$', '%1')
  return session_name_short
end

return M
