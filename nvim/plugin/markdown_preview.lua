vim.pack.add({
  "https://github.com/iamcco/markdown-preview.nvim",
})

-- Force Neovim to source the plugin's core Vimscript commands
--
-- NOTE: Because lazy.nvim is active in this hybrid setup, it disables Neovim's standard plugin loading
-- (vim.go.loadplugins = false). This prevents the Vimscript command definition files (plugin/*.vim) 
-- from being sourced automatically upon packadd. Calling 'runtime!' forces Neovim to immediately scan 
-- the runtimepath and source floaterm.vim, cleanly registering the ':FloatermNew' command on boot.
--
-- TODO: Remove workaround after lazy.nvim is removed.
vim.cmd("runtime! plugin/mkdp.vim")

vim.fn["mkdp#util#install"]()

-- Keymap to launch the preview (Normal Mode)
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown preview", silent = true })
