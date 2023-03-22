-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local api = require('nvim-tree.api')

local function opts(desc)
  return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
end

local function treeToggle()
  api.tree.toggle({focus = true })
end

local function treeFind()
  api.tree.toggle({focus = true, find_file = true})
end

vim.keymap.set('n', '<C-b>', treeToggle, opts('Toggle Tree'))
vim.keymap.set('n', '<C-f>', treeFind, opts('Find File'))

vim.api.nvim_create_autocmd({'QuitPre'}, {
  callback = function()
    vim.cmd("NvimTreeClose")
  end,
})

-- empty setup using defaults
require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  update_focused_file = {
	  enable = true,
  },
})

-- OR setup with some options
--require('nvim-tree').setup({
--  
--  renderer = {
--    group_empty = true,
--  },
--  filters = {
--    dotfiles = true,
--  },
--})

