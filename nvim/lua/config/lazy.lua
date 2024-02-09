-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "plugins.lang" },
    { import = "plugins.extra.notes", enabled = os.getenv("NVIM_EXTRA_NOTES") or true },
    { import = "plugins.extra.bible", enabled = os.getenv("NVIM_EXTRA_BIBLE") or false },
    -- Overrides from local settings
    -- NOTE: The better way is to only load on existence of local_plugins dir & local_plugins/*.lua
    -- But Lua minimalism makes dir and file exist check too painful.
    -- So we add an empty local_plugins/init.lua to ensure there is something to load.
    { import = "local_plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  change_detection = {
    enabled = true,
    notify = true,
  },
  checker = {
    enabled = true,
    notify = true,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
  },
})
