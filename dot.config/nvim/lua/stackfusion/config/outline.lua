local wk = require("which-key")

require("aerial").setup({
    on_attach = function()
        wk.add({
            { "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
            { "{", "<cmd>AerialPrev<cr>", desc = "Prev symbol" },
        })
    end,
})

wk.add({
    { "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" }
})
