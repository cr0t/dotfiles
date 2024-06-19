-- LSP-related mappings are in nvim-lspconfig.lua

local telescope = require('telescope.builtin')

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= true

  vim.keymap.set(mode, lhs, rhs, opts)
end

-- traverse through available buffers
map('n', '<leader>[', '<cmd>bprevious!<cr>')
map('n', '<leader>]', '<cmd>bnext!<cr>')
map('n', '<leader>w', '<cmd>bp | sp | bn | bd<cr>', { desc = 'Close buffer' })

-- files, copy currently opened file data into clipboard
map('n', '<leader>n', '<cmd>enew<cr>', { desc = 'Create new file' })
map('n', '<leader>cf', '<cmd>let @+ = expand("%")<cr>', { desc = 'Copy relative path' })
map('n', '<leader>cF', '<cmd>let @+ = expand("%:p")<cr>', { desc = 'Copy absolute path' })
map('n', '<leader>ct', '<cmd>let @+ = expand("%:t")<cr>', { desc = 'Copy file name' })
map('n', '<leader>ch', '<cmd>let @+ = expand("%:p:h")<cr>', { desc = 'Copy directory name' })

-- windows
map('n', '<C-w>-', '<cmd>split<cr>', { desc = 'Split horizontally' })
map('n', '<C-w>\\', '<cmd>vsplit<cr>', { desc = 'Split vertically' })
map('n', '<C-w>m', '<cmd>MaximizerToggle<cr>', { desc = 'Maximize current window' })
map('n', '<leader>q', '<C-w>c', { desc = 'Delete window' })

-- switch between windows via `CTRL+hjkl` (see tmux.conf settings!)
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- miscellaneous
map('n', 'k', 'gk') -- useful move in a long wrapped line
map('n', 'j', 'gj') -- useful move in a long wrapped line
map('n', '<leader>i', '<cmd>set list!<cr>', { desc = 'Show/hide invisible chars' })
map('n', '<leader>l', '<cmd>nohlsearch<cr>', { desc = 'Hide search highlights' })
map('n', 'gp', '`[v`]', { desc = 'Reselect pasted text' }) -- (https://vimtricks.com/p/reselect-pasted-text/)
map('n', '<leader>s', '<cmd>setlocal spell! spelllang=en_us<cr>', { desc = 'Toggle spellchecking' })

-- disable annoying SHIFT+arrow keys screen height selection (and jumps); I need this because
-- I am often moving too fast up or down when selecting lines of text
map('v', '<S-Down>', 'j')
map('v', '<S-Up>', 'k')
map('v', 'J', 'j')
map('v', 'K', 'k')

-- Telescope
map('n', '<leader>p', telescope.find_files, { desc = 'Find files' })
map('n', '<leader>f', telescope.live_grep, { desc = 'Live grep' })
map('n', '<leader>h', telescope.help_tags, { desc = 'Search through help' })
map('n', '<leader>b', telescope.buffers, { desc = 'Quick switch between buffers' })
