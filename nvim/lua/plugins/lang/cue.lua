return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "cue",
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        -- NOTE: cuelsp is archived, but we are using it for simplicity
        -- since it is supported
        "cuelsp",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- NOTE: dagger is deprecated, but it is supported by
        -- nvim-lspconfig so we use it just for simplicity
        dagger = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cue = { "cueimports", "cuepls" },
      },
    },
  },
}
