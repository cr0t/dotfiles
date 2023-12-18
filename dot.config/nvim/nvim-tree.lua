-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local api = require('nvim-tree.api')

local function opts(desc)
  return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
end

-- show/hide the tree panel
local function treeToggle()
  api.tree.toggle({focus = true})
end

-- my preference is to always open (or leave it opened) when run "find file"
local function treeFindFile()
  api.tree.open({focus = true, find_file = true})
end

-- my minimum basic functionality (migrated from NERDtree)
vim.keymap.set('n', '<C-b>', treeToggle, opts('Toggle Tree'))
vim.keymap.set('n', '<C-f>', treeFindFile, opts('Find File'))

-- close on quit
vim.api.nvim_create_autocmd({'QuitPre'}, {
  callback = function()
    vim.cmd("NvimTreeClose")
  end,
})

require('nvim-tree').setup({
  view = {
    width = 48
  }
})
