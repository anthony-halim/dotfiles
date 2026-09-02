vim.pack.add({
  "https://github.com/iamcco/markdown-preview.nvim",
})

vim.fn["mkdp#util#install"]()

-- Keymap to launch the preview (Normal Mode)
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview", silent = true })
