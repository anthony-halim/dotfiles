vim.pack.add({
  "https://github.com/nvim-mini/mini.extra",
  "https://github.com/nvim-mini/mini.hipatterns",
})

-- Configure and setup mini.hipatterns
local hi_words = require("mini.extra").gen_highlighter.words
local hi_patterns = require("mini.hipatterns")

hi_patterns.setup({
  highlighters = {
    fixme = hi_words(
      { "FIXME", "FIX" },
      "MiniHipatternsFixme",
      { sign_text = "", sign_hl_group = "DiagnosticSignError" }
    ),
    hack = hi_words(
      { "HACK" },
      "MiniHipatternsHack",
      { sign_text = "", sign_hl_group = "DiagnosticSignWarn" }
    ),
    warning = hi_words(
      { "WARNING" },
      "MiniHipatternsHack",
      { sign_text = "", sign_hl_group = "DiagnosticSignWarn" }
    ),
    todo = hi_words(
      { "TODO" },
      "MiniHipatternsTodo",
      { sign_text = "", sign_hl_group = "DiagnosticSignInfo" }
    ),
    note = hi_words(
      { "NOTE" },
      "MiniHipatternsNote",
      { sign_text = " ", sign_hl_group = "DiagnosticSignHint" }
    ),
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hi_patterns.gen_highlighter.hex_color({ priority = 2000 }),
  },
})
