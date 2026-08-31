vim.pack.add({
  "https://github.com/echasnovski/mini.bufremove",
})

-- Configure and setup mini.bufremove
require("mini.bufremove").setup({})

-- Delete buffer mapping (Normal Mode)
vim.keymap.set("n", "<leader>bd", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Delete Buffer", silent = true })

-- Delete buffer (Force) mapping (Normal Mode)
vim.keymap.set("n", "<leader>bD", function()
  require("mini.bufremove").delete(0, true)
end, { desc = "Delete Buffer (Force)", silent = true })
