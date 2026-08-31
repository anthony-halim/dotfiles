vim.pack.add({
  "https://github.com/echasnovski/mini-git",
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
