return {
  -- Autocompletion
  {
    "saghen/blink.cmp",
    dependencies = {
      "echasnovski/mini.icons",
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    lazy = false, -- lazy loading handled internally
    -- use a release tag to download pre-built binaries
    version = "v0.*",
    opts = {
      keymap = {
        preset = "enter",
      },
      snippets = {
        expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction) require("luasnip").jump(direction) end,
      },
      sources = {
        -- Disable cmdline completions
        cmdline = {},
        default = { "lsp", "path", "luasnip", "buffer" },
        providers = {
          snippets = {
            should_show_items = function(ctx)
              return ctx.trigger.initial_kind ~= "trigger_character"
            end,
          }
        }
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
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- Optionally, you may also use the highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              }
            }
          },
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
