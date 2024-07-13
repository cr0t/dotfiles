local wk = require("which-key")
local miniMap = require("mini.map")
local miniTrail = require("mini.trailspace")

local function trim()
    miniTrail.trim()
    miniTrail.trim_last_lines()
end

wk.add({
    -- Foremost, provide descriptions to Vim's shortcuts (we set in vimrc.keymap)
    { "<leader>]", desc = "Next buffer" },
    { "<leader>[", desc = "Prev buffer" },
    { "<leader>q", desc = "Close buffer" },
    { "<leader>w", desc = "Close window" },
    { "<leader>l", desc = "Toggle invisibles" },
    { "<leader>n", desc = "Hide search highlight" },

    -- Now it's time to add some extra - Neovim-related only
    { "<leader>L", "<cmd>Lazy<cr>",               desc = "Lazy.nvim" },
    { "<leader>M", "<cmd>Mason<cr>",              desc = "Mason.nvim" },
    { "<leader>m", miniMap.toggle,                desc = "Toggle mini-map" },
    { "<leader>t", trim,                          desc = "Trim whitespace" },
})
