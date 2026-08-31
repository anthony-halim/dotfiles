vim.pack.add({
  "https://github.com/voldikss/vim-floaterm",
})

-- Force Neovim to source the plugin's core Vimscript commands
--
-- NOTE: Because lazy.nvim is active in this hybrid setup, it disables Neovim's standard plugin loading
-- (vim.go.loadplugins = false). This prevents the Vimscript command definition files (plugin/*.vim) 
-- from being sourced automatically upon packadd. Calling 'runtime!' forces Neovim to immediately scan 
-- the runtimepath and source floaterm.vim, cleanly registering the ':FloatermNew' command on boot.
--
-- TODO: Remove workaround after lazy.nvim is removed.
vim.cmd("runtime! plugin/floaterm.vim")

-- Lazygit shortcut mapping (Normal Mode)
vim.keymap.set("n", "<leader>gg", "<cmd>FloatermNew --height=0.95 --width=0.95 --wintype=float --disposable --autoclose=always --title=Lazygit --titleposition=center lazygit<cr>", { desc = "LazyGit", silent = true })
