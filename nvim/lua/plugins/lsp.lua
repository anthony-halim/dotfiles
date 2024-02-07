local LspKeyMaps = require("plugins.lsp.keymaps")

-- Create an autocmd that executes on LspAttach event
---@param on_attach fun(client, buffer)
local function augroup_on_lsp_attach(on_attach)
  -- Whenever an LSP attaches to a buffer, we will run this function.
  -- See `:help LspAttach` for more information about this autocmd event.
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

-- Configs and setups when a LSP attaches to a buffer.
local function lsp_on_attach_bufnr(_, bufnr)
  -- Setup keymaps
  local keysOpt = LspKeyMaps.keys
  for _, keyOpt in ipairs(keysOpt) do
    LspKeyMaps.keymap(bufnr, keyOpt)
  end

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })

  -- Setup floating window for LSP diagnostics on cursor hold
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "none",
        source = "always",
        prefix = " ",
        scope = "cursor",
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neodev.nvim", opts = {} },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- LSP progress
      "j-hui/fidget.nvim",

      -- LSP search functionalities
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        update_in_insert = false,
        virtual_text = false, -- We use floating window
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = require("config").options.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = require("config").options.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = require("config").options.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = require("config").options.icons.diagnostics.Info,
          },
        },
      },

      -- list of servers
      servers = {
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
    },

    config = function(_, opts)
      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Ensure the servers above are installed
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(opts.servers),
      })

      -- Setup handlers
      mason_lspconfig.setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = lsp_on_attach_bufnr,
            settings = opts.servers[server_name],
            filetypes = (opts.servers[server_name] or {}).filetypes,
          })
        end,
      })

      -- Setup diagnostics
      for name, icon in pairs(require("config").options.icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "codespell",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      -- Formatters are run sequentially
      formatters_by_ft = {
        lua = { "stylua" },
        -- Use the "*" filetype to run formatters on all filetypes.
        ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      format_on_save = function(bufnr)
        -- Check global toggle
        if not vim.g.autoformat then
          return
        end

        -- Disable autoformat for files in a certain path
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("/node_modules/") then
          return
        end

        return { timeout_ms = 3000, lsp_fallback = true }
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
