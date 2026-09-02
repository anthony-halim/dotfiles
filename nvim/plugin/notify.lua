vim.pack.add({
  "https://github.com/rcarriga/nvim-notify",
})

-- Configure and set up nvim-notify
require("notify").setup({
  timeout = 3000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
  stages = "fade_in_slide_out",
})

-- Override standard vim.notify with nvim-notify
vim.notify = require("notify")

-- Integrate LSP progress notifications natively
vim.api.nvim_create_autocmd("LspProgress", {
  group = vim.api.nvim_create_augroup("LspProgressNotify", { clear = true }),
  callback = function(ev)
    require("utils.utils").lsp_progress(ev)
  end,
})
