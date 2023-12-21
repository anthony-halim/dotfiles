local function vault_options(base_dir)
  return {
    home = base_dir .. "/" .. "permanent",
    take_over_my_home = true,
    command_pallete_theme = "dropdown",
    show_tags_theme = "dropdown",
    templates = base_dir .. "/" .. "templates",
    template_new_note = base_dir .. "/" .. "templates/new_note.md",
    auto_set_filetype = true,
    auto_set_syntax = true,
    journal_auto_open = true,
  }
end

local personal_vault_opt = vault_options(vim.fn.expand(os.getenv("NOTES_PERSONAL_VAULT") or "~/notes/personal"))
local work_vault_opt = vault_options(vim.fn.expand(os.getenv("NOTES_WORK_VAULT") or "~/notes/work"))
local default_vault = os.getenv("NOTES_DEFAULT_VAULT") or "personal"

return {
  {
    "renerocksai/telekasten.nvim",
    cmd = "Telekasten",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      vaults = {
        personal = personal_vault_opt,
        work = work_vault_opt,
      },
      default_vault = default_vault,
      plug_into_calendar = false,
    },
    keys = {
      -- Search
      { "<leader>zsf", "<cmd>Telekasten find_notes<cr>",   desc = "Find notes" },
      { "<leader>zsg", "<cmd>Telekasten search_notes<cr>", desc = "Search notes (grep)" },
      { "<leader>zst", "<cmd>Telekasten show_tags<cr>",    desc = "Search tags" },
      {
        "<leader>zsw",
        "<cmd>Telekasten find_weekly_notes<cr>",
        desc = "Find weeky notes by title (calendar week)",
      },
      {
        "<leader>zsr",
        "<cmd>Telekasten find_friends<cr>",
        desc = "Find all notes linking to the link under the cursor",
      },

      -- Journal/Note
      { "<leader>znn", "<cmd>Telekasten new_note<cr>",           desc = "New note" },
      { "<leader>znr", "<cmd>Telekasten rename_note<cr>",        desc = "Rename note" },
      { "<leader>znt", "<cmd>Telekasten new_templated_note<cr>", desc = "New templated note" },

      -- Vault
      { "<leader>zv",  "<cmd>Telekasten switch_vault<cr>",       desc = "Switch vault" },

      -- Editing
      { "<leader>zt",  "<cmd>Telekasten toggle_todo<cr>",        desc = "Toggle todo status" },
      { "<leader>zg",  "<cmd>Telekasten follow_link<cr>",        desc = "Follow link" },
      { "<leader>zb",  "<cmd>Telekasten show_backlinks<cr>",     desc = "Show backlinks" },
      { "<leader>zi",  "<cmd>Telekasten insert_link<cr>",        desc = "Insert link" },
    },
    config = function(_, opts)
      require("telekasten").setup(opts)

      -- Setup highlighting
      vim.api.nvim_set_hl(0, "tkLink", { link = "Search" })
      vim.api.nvim_set_hl(0, "tkBrackets", { link = "Search" })
      vim.api.nvim_set_hl(0, "tkAliasedLink", { link = "Todo" })
      vim.api.nvim_set_hl(0, "tkHighlight", { link = "Special" })
      vim.api.nvim_set_hl(0, "tkTag", { link = "IncSearch" })
    end,
  },
}
