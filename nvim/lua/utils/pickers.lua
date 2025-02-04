local M = {
  mini_pick = {}
}

function M.mini_pick.gitfiles_with_fallback(opts)
  local git_dir = require("utils.utils").git_dir_cwd()
  if git_dir ~= "" then
    local merged_opts = vim.tbl_deep_extend('force', { path = git_dir }, opts or {})
    require("mini.extra").pickers.git_files(merged_opts)
  else
    require("mini.pick").builtin.files()
  end
end

function M.mini_pick.git_greplive_with_fallback()
  local local_opts = {}
  local opts = {}
  local git_dir = require("utils.utils").git_dir_cwd()
  if git_dir ~= "" then
    local_opts = { tool = "git" }
    opts = { source = { cwd = git_dir } }
  end
  require("mini.pick").builtin.grep_live(local_opts, opts)
end

return M
