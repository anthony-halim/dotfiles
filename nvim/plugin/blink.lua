vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("luasnip").setup({})
require("blink.cmp").setup({
  keymap = { preset = "enter" },
  snippets = { preset = "luasnip" },
  sources = { default = { "lsp", "path", "snippets" } },
  -- Adjusts spacing to ensure Nerd Font icons align perfectly
  appearance = { nerd_font_variant = "mono" },
  -- Disable command line autocompletion
  cmdline = { enabled = false },
  -- Use the fast and lightweight built-in Lua fuzzy matcher
  fuzzy = { implementation = "lua" },
  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    -- Avoid showing completion on start of insert mode on a trigger character
    trigger = { show_on_insert_on_trigger_character = false },

    menu = {
      draw = {
        columns = {
          { "kind_icon", "kind", gap = 1 },
          { "label", "label_description", gap = 1 },
        },
        components = {
          kind_icon = {
            ellipsis = false,
            text = function(ctx)
              local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
              return kind_icon
            end,
            highlight = function(ctx)
              local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              return hl
            end,
          },
        },
      },
    },
  },
})
