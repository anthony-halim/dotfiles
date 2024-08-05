-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local _git_repo_cache = {}

return {
  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "echasnovski/mini.sessions",
    version = false,
    event = "VimEnter",
    opts = {
      autoread = false,
      autowrite = false, -- Disable default autocmd
    },
    init = function()
      local augroup = vim.api.nvim_create_augroup('MiniSessions', {})
      local sessions = require("mini.sessions")
      local autowrite = function()
        local cwd = vim.fn.getcwd()

        -- Skip writing for certain paths
        if cwd:match("/tmp/") then
          return
        end

        -- Update git repo cache
        if _git_repo_cache[cwd] == nil then
          vim.fn.system("git rev-parse --is-inside-work-tree")
          if vim.v.shell_error == 0 then
            local git_repo_path = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
            _git_repo_cache[cwd] = git_repo_path
          end
        end

        -- Override to git-repo name if possible
        local session_name = cwd
        if _git_repo_cache[cwd] ~= "" then
          session_name = _git_repo_cache[cwd]
        end
        local session_name_short = vim.fn.fnamemodify(session_name, ":t")
        session_name_short = string.gsub(session_name_short, '^%s*(.-)%s*$', '%1')

        sessions.write(session_name_short, { force = true })
      end

      vim.api.nvim_create_autocmd(
        'VimLeavePre',
        { group = augroup, callback = autowrite, desc = 'Autowrite current session' }
      )
    end
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}
