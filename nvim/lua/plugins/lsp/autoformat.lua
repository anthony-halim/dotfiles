local M = {}

-- Create an augroup that is used for managing our formatting autocmds.
--      We need one augroup per client to make sure that multiple clients
--      can attach to the same buffer without interfering with each other.
M._augroups = {}
function M._get_augroup(client)
  if not M._augroups[client.id] then
    local group_name = "lsp-format-" .. client.name
    local id = vim.api.nvim_create_augroup(group_name, { clear = true })
    M._augroups[client.id] = id
  end

  return M._augroups[client.id]
end

function M.lsp_autoformat(client, buffer)
  -- Only attach to clients that support document formatting
  if not client.server_capabilities.documentFormattingProvider then
    return
  end

  -- Tsserver usually works poorly. Sorry you work with bad languages
  -- You can remove this line if you know what you're doing :)
  if client.name == "tsserver" then
    return
  end

  -- Create an autocmd that will run *before* we save the buffer.
  --  Run the formatting command for the LSP that has just attached.
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = M._get_augroup(client),
    buffer = buffer,
    callback = function()
      if not require("config").options.autofmt then
        return
      end

      -- Removes trailing space and new lines
      -- Credit to echasnovski/mini.trailspace
      --
      -- Trim trailing whitespace
      local curpos = vim.api.nvim_win_get_cursor(0)
      vim.cmd([[keeppatterns %s/\s\+$//e]])
      vim.api.nvim_win_set_cursor(0, curpos)

      -- Trim last blank lines
      local n_lines = vim.api.nvim_buf_line_count(0)
      local last_nonblank = vim.fn.prevnonblank(n_lines)
      if last_nonblank < n_lines then
        vim.api.nvim_buf_set_lines(0, last_nonblank, n_lines, true, {})
      end

      -- LSP formatting
      vim.lsp.buf.format({
        async = false,
        filter = function(c)
          return c.id == client.id
        end,
      })
    end,
  })
end

return M
