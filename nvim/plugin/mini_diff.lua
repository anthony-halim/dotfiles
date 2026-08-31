vim.pack.add({
  "https://github.com/echasnovski/mini.diff",
})

-- Configure mini.diff
require("mini.diff").setup({
  view = {
    style = "sign",
    signs = { add = "▎", change = "▒", delete = "" },
  },
})

-- Apply hunks mapping (Normal & Visual Modes)
vim.keymap.set({ "n", "v" }, "<leader>gha", function()
  -- first 'gh': mapping for mini.diff.operator("apply")
  -- second 'gh': textobject for Git hunk
  vim.cmd("norm ghgh")
end, { desc = "Apply hunks", silent = true })

-- Reset hunks mapping (Normal & Visual Modes)
vim.keymap.set({ "n", "v" }, "<leader>ghr", function()
  -- first 'gH': mapping for mini.diff.operator("reset")
  -- second 'gh': textobject for Git hunk
  vim.cmd("norm gHgh")
end, { desc = "Reset hunks", silent = true })
