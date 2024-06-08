local telescope = require('telescope')
local telescope_actions = require('telescope.actions')

-- Looking for a keymap configuration? Check it in the `keys.lua` nearby.

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

telescope.setup {
  defaults = {
    dynamic_preview_title = true,
    layout_strategy = 'flex',
    layout_config = { prompt_position = 'top' },
    sorting_strategy = 'ascending',
    mappings = {
      i = { ['<esc>'] = telescope_actions.close } -- press ESC once to close the modal
    },
    -- See :h telescope.defaults.file_ignore_patterns for more information and be very careful about what we put inside
    -- the file; prefer to use regex as precise as possible to avoid false positives (like with the _build below):
    -- (^ leaving this comment and example below just for future me, as a reminder becase the old config hid files
    -- saved in a .../trip_builder/... directory)
    file_ignore_patterns = {
      -- 'deps/',
      -- '_build/',
      '^assets/vendor/heroicons',
      '^node_modules/'
    },
    winblend = 5, -- pseudo-transparency for the modal (0..100)
    preview = {
      treesitter = false
    }
  },
}
