vim.pack.add({
  "https://github.com/mrjones2014/smart-splits.nvim",
})

-- Configure and setup smart-splits
require("smart-splits").setup({})

-- Window resizing mappings (Normal Mode)
vim.keymap.set("n", "<C-M-h>", "<cmd>SmartResizeLeft<cr>", { desc = "Resize window (left)", silent = true })
vim.keymap.set("n", "<C-M-j>", "<cmd>SmartResizeDown<cr>", { desc = "Resize window (down)", silent = true })
vim.keymap.set("n", "<C-M-k>", "<cmd>SmartResizeUp<cr>", { desc = "Resize window (up)", silent = true })
vim.keymap.set("n", "<C-M-l>", "<cmd>SmartResizeRight<cr>", { desc = "Resize window (right)", silent = true })
