vim.pack.add({
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/b0o/incline.nvim",
})

-- Configure incline
require("incline").setup({
  window = {
    margin = {
      horizontal = 0,
      vertical = 0,
    },
    placement = {
      horizontal = "right",
      vertical = "bottom",
    },
  },
  render = function(props)
    local icons_config = require("config").options.icons
    local icons = require("mini.icons")

    -- Filename and modification status
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":p:.")
    local ft_icon, ft_hl, _ = icons.get("file", filename)
    local modified = vim.bo[props.buf].modified and "bold,italic" or "bold"

    -- Diagnostic labels
    local diagnostic_labels = {}
    local counts = vim.diagnostic.count(props.buf)
    for severity, icon in pairs(icons_config.diagnostics) do
      local sev_enum = vim.diagnostic.severity[string.upper(severity)]
      local n = counts[sev_enum] or 0
      if n > 0 then
        table.insert(diagnostic_labels, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
      end
    end
    if #diagnostic_labels > 0 then
      table.insert(diagnostic_labels, { "| " })
    end

    return {
      { diagnostic_labels },
      { ft_icon, group = ft_hl },
      { " " },
      { filename, gui = modified },
    }
  end,
})
