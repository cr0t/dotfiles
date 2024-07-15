-- Diagnostics
-- -----------
--
-- Show diagnostics warnings automatically in a floating window, we used this guide initially, but had to rework it:
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#show-line-diagnostics-automatically-in-hover-window

vim.diagnostic.config({ virtual_text = false })
vim.cmd([[ autocmd ColorScheme * highlight NormalFloat guibg=none ]])
vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Shows diagnostics floating window in normal mode when cursor holds on a line with an issue",
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "single",
      source = "if_many",
    }

    vim.diagnostic.open_float(nil, opts)
  end
})
