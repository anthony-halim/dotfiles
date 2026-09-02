vim.pack.add({
  "https://github.com/folke/which-key.nvim",
})

-- Configure and setup which-key
require("which-key").setup({
  spec = {
    { "<leader>b",  desc = "+buffer" },
    { "<leader>c",  desc = "+code" },
    { "<leader>d",  desc = "+diagnostic" },
    { "<leader>f",  desc = "+file" },
    { "<leader>g",  desc = "+git" },
    { "<leader>gh", desc = "+hunks" },
    { "<leader>s",  desc = "+search" },
    { "<leader>u",  desc = "+ui" },
  },
})
