return {
  -- {
  --   "EdenEast/nightfox.nvim",
  --   lazy = true,
  --   opts = {
  --     groups = {
  --       all = {
  --         VertSplit = { fg = "bg3" },
  --       },
  --     },
  --   },
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
      custom_highlights = function(colors)
        return {
          VertSplit = { fg = colors.surface2 },
        }
      end,
    },
  },
}
