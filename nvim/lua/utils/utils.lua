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

return M
