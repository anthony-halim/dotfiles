vim.pack.add({
  "https://github.com/sammaji/markdown-preview.nvim",
})

vim.fn["mkdp#util#install_sync"]()

-- Keymap to launch the preview (Normal Mode)
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview", silent = true })
