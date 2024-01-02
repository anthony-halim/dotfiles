local M = {}

M.options = {
  colorscheme = "catppuccin",
  autofmt = true,

  -- icons used by other plugins
  icons = {
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    },
    git = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    kinds = {
      Array = " ",
      Boolean = " ",
      Class = " ",
      Color = " ",
      Constant = " ",
      Constructor = " ",
      Copilot = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = " ",
      Interface = " ",
      Key = " ",
      Keyword = " ",
      Method = " ",
      Module = " ",
      Namespace = " ",
      Null = " ",
      Number = " ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = " ",
      String = " ",
      Struct = " ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = " ",
    },
  },
}

M.has_setup = false

function M.setup()
  if not M.has_setup then
    M.has_setup = true

    require("config.options")
    require("config.keymaps")
    require("config.lazy")
    require("config.autocmds")

    -- Optional requires based on local configurations
    pcall(require, "local_config.options")
    pcall(require, "local_config.keymaps")
    pcall(require, "local_config.autocmds")

    vim.cmd.colorscheme(M.options.colorscheme)
  end
end

return M
