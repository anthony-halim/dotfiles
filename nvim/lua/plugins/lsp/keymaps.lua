local M = {}

---@class KeyMapOpts
---@field modes? string[]
---@field key string
---@field func string|function
---@field desc string

---@type KeyMapOpts[]
M.keys = {
  {
    key = "<leader>cr",
    func = vim.lsp.buf.rename,
    desc = "Code rename",
  },
  {
    key = "<leader>ca",
    func = function()
      vim.lsp.buf.code_action({ context = { only = { "quickfix", "refactor", "source" } } })
    end,
    desc = "Code action",
  },
  {
    key = "<leader>ck",
    func = vim.lsp.buf.signature_help,
    desc = "Code signature",
  },
  {
    key = "gd",
    func = require("telescope.builtin").lsp_definitions,
    desc = "Goto definition",
  },
  {
    key = "gD",
    func = vim.lsp.buf.declaration,
    desc = "Goto declaration",
  },
  {
    key = "gr",
    func = require("telescope.builtin").lsp_references,
    desc = "Goto references",
  },
  {
    key = "gI",
    func = require("telescope.builtin").lsp_implementations,
    desc = "Goto implementation",
  },
  {
    key = "<leader>cd",
    func = require("telescope.builtin").lsp_type_definitions,
    desc = "Type definition",
  },
  {
    key = "<leader>csd",
    func = require("telescope.builtin").lsp_document_symbols,
    desc = "Document symbols",
  },
  {
    key = "<leader>csw",
    func = require("telescope.builtin").lsp_dynamic_workspace_symbols,
    desc = "Workspace symbols",
  },
}

---@param keyOpt KeyMapOpts
function M.keymap(bufnr, keyOpt)
  local desc
  local modes = keyOpt.modes or { "n" }

  if keyOpt.desc then
    desc = "LSP: " .. keyOpt.desc
  end

  for _, mode in ipairs(modes) do
    vim.keymap.set(mode, keyOpt.key, keyOpt.func, { buffer = bufnr, desc = desc })
  end
end

return M
