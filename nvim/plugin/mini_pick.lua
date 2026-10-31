vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.extra",
  "https://github.com/nvim-mini/mini.pick",
})

local MiniPick = require("mini.pick")
local utils = require("utils")

-- Configure and setup mini.pick
MiniPick.setup({
  delay = {
    busy = 10,
  },
  options = {
    use_cache = true,
  },
  window = {
    config = {
      border = "rounded",
    },
    prompt_prefix = " ",
  },
})

-- Override vim.ui.select natively with mini.pick's UI selector
vim.ui.select = MiniPick.ui_select

-- ============================================================
-- Custom Pickers
-- ============================================================

-- Git files picker with fallback to all files if not inside a git repo
MiniPick.registry.git_files = function(opts)
  local git_dir = utils.git_dir_cwd()
  if git_dir ~= "" then
    local merged_opts = vim.tbl_deep_extend("force", { path = git_dir }, opts or {})
    require("mini.extra").pickers.git_files(merged_opts)
  else
    MiniPick.builtin.files()
  end
end

-- Live grep picker restricted to git root if inside a git repo
MiniPick.registry.git_greplive = function(opts)
  local local_opts = {}
  local source_opts = {}
  local git_dir = utils.git_dir_cwd()
  if git_dir ~= "" then
    local_opts = { tool = "git" }
    source_opts = { source = { cwd = git_dir } }
  end
  MiniPick.builtin.grep_live(local_opts, vim.tbl_deep_extend("force", source_opts, opts or {}))
end

-- Define all fuzzy finder keymaps (Normal Mode)
vim.keymap.set("n", "<leader>fb", function()
  MiniPick.builtin.buffers()
end, { desc = "Find buffers", silent = true })

vim.keymap.set("n", "<leader>ff", function()
  MiniPick.registry.git_files()
end, { desc = "Find files", silent = true })

vim.keymap.set("n", "<leader>fF", function()
  MiniPick.registry.git_files({ scope = "ignored" })
end, { desc = "Find hidden files", silent = true })

vim.keymap.set("n", "<leader>fd", function()
  local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
  MiniPick.builtin.files({}, opts)
end, { desc = "Find files in buffer directory", silent = true })

vim.keymap.set("n", "<leader>sb", function()
  require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "Search fuzzy current buffer", silent = true })

vim.keymap.set("n", "<leader>ss", function()
  MiniPick.registry.git_greplive()
end, { desc = "Search grep", silent = true })

vim.keymap.set("n", "<leader>sd", function()
  local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
  local local_opts = {}
  if utils.git_dir_cwd() ~= "" then
    local_opts = { tool = "git" }
  end
  MiniPick.builtin.grep_live(local_opts, opts)
end, { desc = "Search grep in buffer directory", silent = true })

vim.keymap.set("n", "<leader>sx", function()
  require("mini.extra").pickers.diagnostic()
end, { desc = "Search diagnostics", silent = true })

vim.keymap.set("n", "<leader>sh", function()
  MiniPick.builtin.help()
end, { desc = "Search help", silent = true })

vim.keymap.set("n", "<leader>sr", function()
  MiniPick.builtin.resume()
end, { desc = "Resume search", silent = true })
