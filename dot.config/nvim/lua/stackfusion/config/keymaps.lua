local wk = require("which-key")

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
})
