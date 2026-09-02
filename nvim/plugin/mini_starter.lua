vim.pack.add({
  "https://github.com/nvim-mini/mini.sessions",
  "https://github.com/nvim-mini/mini.pick",
  "https://github.com/nvim-mini/mini.extra",
  "https://github.com/nvim-mini/mini.starter",
})

-- Configure and setup mini.starter
local utils = require("utils.utils")
local sessions = require("mini.sessions")
local options = {}

options.header = [[
⣿⣿⣿⣿⣿⣿⡿⣟⠻⠯⠭⠉⠛⠋⠉⠉⠛⠻⢿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡽⠚⠉⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠈⠙⢿⣿⣿⣿
⣿⣿⠏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣷⣦⡀⠶⣿⣿⣿
⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡆⢻⣿⣿
⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣤⣻⣿⣯⣤⣹⣿
⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⡇⠀⣿⢟⣿⡀⠟⢹⣿
⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣷⣤⣤⣼⣿⣿⡄⢹⣿
⣷⠀⠀⠀⠶⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⠛⠉⠈⢻
⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠋⠛⠛⠛⠀⠀⣤⣾
⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠛⠁⣰⣿⣿
⣿⣿⣿⣿⣿⣷⣦⣤⣤⣤⣤⣄⣀⣀⣀⣀⣀⣠⣤⣤⣤⣾⣿⣿⣿
]]

options.evaluate_single = true

options.items = {
  {
    name = "Find file",
    action = function()
      require("utils.pickers").mini_pick.gitfiles_with_fallback()
    end,
    section = "Shortcuts",
  },
  {
    name = "Search grep",
    action = function()
      local local_opts = {}
      if require("utils.utils").git_dir_cwd() ~= "" then
        local_opts = { tool = "git" }
      end
      require("mini.pick").builtin.grep_live(local_opts)
    end,
    section = "Shortcuts",
  },
  { name = "New file", action = "enew", section = "Shortcuts" },
  { name = "Quit",     action = "qall", section = "Shortcuts" },
}

-- Add additional shortcut to reload current directory
-- session if present
local session_name = utils.generate_session_name_cwd()
if sessions.detected[utils.generate_session_name_cwd()] ~= nil then
  table.insert(options.items, 0, {
    name = "Restore session",
    action = function()
      sessions.read(session_name)
    end,
    section = "Shortcuts",
  })
end

options.footer = function()
  local hour = tonumber(vim.fn.strftime("%H"))
  -- [04:00, 12:00) - morning, [12:00, 20:00) - day, [20:00, 04:00) - evening
  local part_id = math.floor((hour + 4) / 8) + 1
  local day_part = ({ "evening", "morning", "afternoon", "evening" })[part_id]
  local username = vim.uv.os_get_passwd()["username"] or "USERNAME"
  return ("Good %s, %s"):format(day_part, username)
end

options.silent = true

-- Setup mini.starter
require("mini.starter").setup(options)
