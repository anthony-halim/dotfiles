vim.pack.add({
  "https://github.com/nvim-mini/mini-git",
})

-- Configure and setup mini-git
require("mini.git").setup({
  job = {
    timeout = 5000, -- in ms
  },
})

-- Show at cursor mapping (Normal Mode)
vim.keymap.set("n", "<leader>gc", function()
  require("mini.git").show_at_cursor({ split = "horizontal" })
end, { desc = "Show at cursor", silent = true })

-- Open git blame mapping (Normal Mode)
vim.keymap.set("n", "<leader>gb", "<Cmd>vertical Git blame -- %<CR>", { desc = "Git blame", silent = true })

-- Align view and bind scrolling/cursor movement for git blame
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniGitCommandSplit",
  callback = function(ev)
    if ev.data.git_subcommand ~= "blame" then
      return
    end
    local win_src = ev.data.win_source
    local win_blame = ev.data.win_stdout

    vim.wo[win_blame].wrap = false
    vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
    vim.api.nvim_win_set_cursor(win_blame, { vim.fn.line(".", win_src), 0 })
    vim.wo[win_blame].scrollbind, vim.wo[win_src].scrollbind = true, true
    vim.wo[win_blame].cursorbind, vim.wo[win_src].cursorbind = true, true
  end,
})
