return {
  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  -- Autocompletion
  {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    -- use a release tag to download pre-built binaries
    version = "v0.*",
    opts = {
      keymap = {
        preset = "enter",
      },
      completion = {
        documentation = {
          auto_show = true,
        },
        menu = {
          draw = {
            columns = {
              { "kind_icon", "kind",              gap = 1 },
              { "label",     "label_description", gap = 1 },
            },
          }
        },
      },
    },
  },

  -- auto pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },
}
