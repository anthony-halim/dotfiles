vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.files",
})

-- Configure and setup mini.files
require("mini.files").setup({
  mappings = {
    close = "q",
    go_in = "",
    go_in_plus = "<cr>",
    go_out = "<bs>",
    go_out_plus = "",
    reset = ".",
    reveal_cwd = "@",
    show_help = "g?",
    synchronize = "=",
    trim_left = "<",
    trim_right = ">",
  },
  content = {
    filter = function(entry)
      return entry.name ~= ".DS_Store" and entry.name ~= ".git" and entry.name ~= ".direnv"
    end,
  },
  windows = {
    -- Maximum number of windows to show side by side
    max_number = math.huge,
    -- Whether to show preview of file/directory under cursor
    preview = false,
    -- Width of focused window
    width_focus = math.min(math.floor(vim.o.columns * 0.4), 40),
    -- Width of non-focused window
    width_nofocus = math.min(math.floor(vim.o.columns * 0.2), 25),
    -- Width of preview window
    width_preview = math.min(math.floor(vim.o.columns * 0.3), 80),
  },
  options = {
    use_as_default_explorer = true,
  },
})

-- Start Mini.files with directory on BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("mini_files_start_directory", { clear = true }),
  desc = "Start Mini.files with directory",
  once = true,
  callback = function()
    if package.loaded["mini.files"] then
      return
    else
      local stats = vim.uv.fs_stat(vim.fn.argv(0))
      if stats and stats.type == "directory" then
        require("mini.files").open()
      end
    end
  end,
})

-- Mappings to toggle explorer tree
vim.keymap.set("n", "<leader>e", function()
  local minifiles = require("mini.files")
  if vim.bo.ft == "minifiles" then
    minifiles.close()
  else
    local file = vim.api.nvim_buf_get_name(0)
    local file_exists = vim.fn.filereadable(file) ~= 0
    minifiles.open(file_exists and file or nil)
  end
end, { desc = "Explorer Tree", silent = true })
