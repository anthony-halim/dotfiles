vim.pack.add({
  "https://github.com/echasnovski/mini.icons",
  "https://github.com/nvim-lualine/lualine.nvim",
})

-- Configure and setup lualine
require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    disabled_filetypes = { statusline = { "dashboard", "alpha" } },
    component_separators = "|",
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { { "branch", icon = "" } },
    lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", path = 1, symbols = { modified = " ", readonly = "", unnamed = "" } },
    },
    lualine_x = {
      { "searchcount" },
      { "encoding" },
      { "filetype" },
    },
  },
  extensions = { "nvim-tree", "lazy" },
})
