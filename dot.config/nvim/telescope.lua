local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

vim.keymap.set('n', '<leader>p', builtin.find_files, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
vim.keymap.set('n', '<leader>b', builtin.buffers, {})

-- The following Telescope settings configures it to layout similar to this:
--
-- ┌────────────────────────────────────────────────┐
-- │   ┌───────────────────┐┌──────Filepath─────┐   │
-- │   │> Prompt           ││                   │   │
-- │   └───────────────────┘│                   │   │
-- │   ┌───────────────────┐│                   │   │
-- │   │  Results          ││      Preview      │   │
-- │   │  Results          ││                   │   │
-- │   │  ...              ││                   │   │
-- │   │                   ││                   │   │
-- │   └───────────────────┘└───────────────────┘   │
-- └────────────────────────────────────────────────┘
require('telescope').setup {
  defaults = {
    dynamic_preview_title = true,
    layout_strategy = 'flex',
    layout_config = { prompt_position = "top" },
    sorting_strategy = "ascending",
    mappings = {
      i = { ["<esc>"] = actions.close } -- press ESC once to close the modal
    },
    file_ignore_patterns = {
      "deps",
      "_build",
      "heroicons",
      "node_modules"
    },
    winblend = 5, -- pseudo-transparency for the modal (0..100)
  },
}
