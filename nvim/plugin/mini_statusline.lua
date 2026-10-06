vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.diff",
  "https://github.com/nvim-mini/mini-git",
  "https://github.com/nvim-mini/mini.statusline",
})

local utils = require("utils.utils")

-- Configure and setup mini.statusline
require("mini.statusline").setup({
  use_icons = true,
  content = {
    active = function()
      local MiniStatusline = require("mini.statusline")

      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local filename = utils.git_relative_path()
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local location = "%l:%c│%L" -- '<cursor line>:<cursor column>|<total lines>'
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { string.upper(mode) } },
        { hl = "MiniStatuslineDevinfo", strings = { git, lsp } },
        "%<", -- Mark general truncate point
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=", -- End left alignment
        { hl = "MiniStatuslineFilename", strings = { diagnostics, diff } },
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      })
    end,
    inactive = function()
      local MiniStatusline = require("mini.statusline")
      local filename = utils.git_relative_path()
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      return MiniStatusline.combine_groups({
        "%=", -- End left alignment
        { hl = "MiniStatuslineFilename", strings = { diagnostics, diff } },
        { hl = "MiniStatuslineFileinfo", strings = { filename } },
      })
    end,
  },
})
