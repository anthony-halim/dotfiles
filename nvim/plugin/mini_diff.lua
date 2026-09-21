vim.pack.add({
  "https://github.com/nvim-mini/mini.diff",
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

-- Change how the Git diff string is formatted
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniDiffUpdated",
  callback = function(data)
    local summary = vim.b[data.buf].minidiff_summary
    local git_icons = require("config").options.icons.git
    local sumary_string = {}
    if summary.add > 0 then
      table.insert(sumary_string, git_icons.add .. summary.add)
    end
    if summary.change > 0 then
      table.insert(sumary_string, git_icons.change .. summary.change)
    end
    if summary.delete > 0 then
      table.insert(sumary_string, git_icons.delete .. summary.delete)
    end
    vim.b[data.buf].minidiff_summary_string = table.concat(sumary_string, " ")
  end,
})
