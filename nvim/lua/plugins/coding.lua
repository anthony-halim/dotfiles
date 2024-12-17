return {
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
              { "kind_icon", "kind", gap = 1 },
              { "label", "label_description", gap = 1 },
            },
          },
        },
        trigger = {
          show_on_insert_trigger_character = false,
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
