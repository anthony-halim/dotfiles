---@class KeyMapOpts
---@field modes? string[]
---@field key string
---@field func string|function
---@field desc string

-- lsp_keymaps are the set of keymaps to be set on LSP attach.
---@type KeyMapOpts[]
local lsp_keymaps = {
  {
    key = "<leader>cr",
    func = vim.lsp.buf.rename,
    desc = "Code rename",
  },
  {
    key = "<leader>ca",
    func = function()
      vim.lsp.buf.code_action({
        context = {
          only = { "quickfix", "refactor", "source" },
          diagnostics = {},
        },
      })
    end,
    desc = "Code action",
  },
  {
    key = "<leader>ck",
    func = vim.lsp.buf.signature_help,
    desc = "Code signature",
  },
  {
    key = "K",
    func = vim.lsp.buf.hover,
    desc = "Hover documentation",
  },
  {
    key = "gd",
    func = function() require("mini.extra").pickers.lsp({ scope = "definition" }) end,
    desc = "Goto definition",
  },
  {
    key = "gD",
    func = function() require("mini.extra").pickers.lsp({ scope = "declaration" }) end,
    desc = "Goto declaration",
  },
  {
    key = "gr",
    func = function() require("mini.extra").pickers.lsp({ scope = "references" }) end,
    desc = "Goto references",
  },
  {
    key = "gI",
    func = function() require("mini.extra").pickers.lsp({ scope = "implementation" }) end,
    desc = "Goto implementation",
  },
  {
    key = "<leader>cd",
    func = function() require("mini.extra").pickers.lsp({ scope = "type_definition" }) end,
    desc = "Type definition",
  },
  {
    key = "<leader>csd",
    func = function() require("mini.extra").pickers.lsp({ scope = "document_symbol" }) end,
    desc = "Document symbols",
  },
  {
    key = "<leader>csw",
    func = function() require("mini.extra").pickers.lsp({ scope = "workspace_symbol" }) end,
    desc = "Workspace symbols",
  },
}

-- lsp_set_keymap sets LSP keymaps.
---@param key_opt KeyMapOpts
local function lsp_set_keymap(bufnr, key_opt)
  local desc
  local modes = key_opt.modes or { "n" }

  if key_opt.desc then
    desc = "LSP: " .. key_opt.desc
  end

  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, key_opt.key, key_opt.func, { buffer = bufnr, desc = desc })
  end
end

-- Configs and setups when a LSP attaches to a buffer.
local function lsp_on_attach_bufnr(_, bufnr)
  -- Setup keymaps
  for _, key_opt in ipairs(lsp_keymaps) do
    lsp_set_keymap(bufnr, key_opt)
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
    "folke/lazydev.nvim",
    ft = "lua",                                -- only load on lua files
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    },
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- LSP search functionalities
      "echasnovski/mini.extra",
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
        -- ["*"] = { "codespell" },
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

        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
