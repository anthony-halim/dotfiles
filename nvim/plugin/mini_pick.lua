vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.extra",
  "https://github.com/nvim-mini/mini.pick",
})

-- Configure and setup mini.pick
require("mini.pick").setup({
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
vim.ui.select = require("mini.pick").ui_select

-- Define all fuzzy finder keymaps (Normal Mode)
vim.keymap.set("n", "<leader>fb", function()
  require("mini.pick").builtin.buffers()
end, { desc = "Find buffers", silent = true })

vim.keymap.set("n", "<leader>ff", function()
  require("utils.pickers").mini_pick.gitfiles_with_fallback()
end, { desc = "Find files", silent = true })

vim.keymap.set("n", "<leader>fF", function()
  require("utils.pickers").mini_pick.gitfiles_with_fallback({ scope = "ignored" })
end, { desc = "Find hidden files", silent = true })

vim.keymap.set("n", "<leader>fd", function()
  local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
  require("mini.pick").builtin.files({}, opts)
end, { desc = "Find files in buffer directory", silent = true })

vim.keymap.set("n", "<leader>sb", function()
  require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { desc = "Search fuzzy current buffer", silent = true })

vim.keymap.set("n", "<leader>ss", function()
  require("utils.pickers").mini_pick.git_greplive_with_fallback()
end, { desc = "Search grep", silent = true })

vim.keymap.set("n", "<leader>sd", function()
  local opts = { source = { cwd = vim.fn.expand("%:p:h") } }
  local local_opts = {}
  if require("utils.utils").git_dir_cwd() ~= "" then
    local_opts = { tool = "git" }
  end
  require("mini.pick").builtin.grep_live(local_opts, opts)
end, { desc = "Search grep in buffer directory", silent = true })

vim.keymap.set("n", "<leader>sx", function()
  require("mini.extra").pickers.diagnostic()
end, { desc = "Search diagnostics", silent = true })

vim.keymap.set("n", "<leader>sh", function()
  require("mini.pick").builtin.help()
end, { desc = "Search help", silent = true })

vim.keymap.set("n", "<leader>sr", function()
  require("mini.pick").builtin.resume()
end, { desc = "Resume search", silent = true })
