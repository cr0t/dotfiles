local wk = require("which-key")
local trail = require("mini.trailspace")
local tree_api = require("nvim-tree.api")

-- Trim trailing whitespace and extra empty lines at the EOF
local function trimWhitespace()
    trail.trim()
    trail.trim_last_lines()
end

-- show/hide the tree panel
local function treeToggle()
    tree_api.tree.toggle({ focus = true })
end

-- my preference is to always open (or leave it opened) when run "find file"
local function treeFindFile()
    tree_api.tree.open({ focus = true, find_file = true })
end

wk.register({
    -- ["K"] = {"<cmd>lua vim.lsp.buf.hover()<cr>", "Hover information"},
    -- ["gd"] = {"<cmd>lua vim.lsp.buf.definition()<cr>", "Go to declaration" },
    -- ["gr"] = {"<cmd>Telescope lsp_references<cr>", "Go to references"},

    -- Buffers, windows
    ["<A-,>"] = { "<cmd>bprevious!<cr>", "Previous buffer" },
    ["<A-.>"] = { "<cmd>bnext!<cr>", "Next buffer" },
    ["<C-w>"] = {
        ["-"] = { "<cmd>split<cr>", "Split horizontally" },
        ["\\"] = { "<cmd>vsplit<cr>", "Split vertically" },
        m = { "<cmd>MaximizerToggle<cr>", "Maximize current window" },
    }
})

wk.register({
    -- Buffers, windows
    ["["] = { "<cmd>bprevious!<cr>", "Previous buffer" },
    ["]"] = { "<cmd>bnext!<cr>", "Next buffer" },
    q = { "<C-w>c", "Delete window" },
    w = { "<cmd>bp | sp | bn | bd<cr>", "Close buffer" },

    -- Fuzzy-finder
    f = { "<cmd>Telescope live_grep<cr>", "Live grep" },
    p = { "<cmd>Telescope find_files<cr>", "Find files" },

    -- Files, currently opened file data into clipboard
    n = { "<cmd>enew<cr>", "Create new file" },
    C = {
        name = "Copy file's",
        F = { "<cmd>let @+ = expand('%:p')<cr>", "Absolute path" },
        f = { "<cmd>let @+ = expand('%')<cr>", "Relative path" },
        h = { "<cmd>let @+ = expand('%:p:h')<cr>", "Directory name" },
        t = { "<cmd>let @+ = expand('%:t')<cr>", "File name" }
    },

    -- Misc.
    i = { trimWhitespace, "Trim whitespace" },

    -- Telescope
    T = {
        name = "Telescope",
        b = { "<cmd>Telescope buffers<cr>", "Buffers" },
        f = { "<cmd>Telescope live_grep<cr>", "Live grep" },
        j = { "<cmd>Telescope jumplist<cr>", "Jumplist" },
        o = { "<cmd>Telescope oldfiles<CR>", "Recent files" },
        p = { "<cmd>Telescope find_files<CR>", "Find files" },
        q = { "<cmd>Telescope quickfix<cr>", "Quickfix list" },
        r = { "<cmd>Telescope resume<cr>", "Previous Telescope window" },
        s = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace symbols" },
        t = { "<cmd>Telescope<cr>", "Open Telescope" },
        g = {
            name = "Git",
            b = { "<cmd>Telescope git_branches<cr>", "Git branches" },
            o = { "<cmd>Telescope git_files<cr>", "Git files" },
        }
    }
}, { prefix = "<leader>" })

-- disable SHIFT+arrow keys screen movement (jumps) in visual mode: need this
-- because I often move too fast up or down when selecting lines
wk.register({
    ["<S-Down>"] = { "j", "" },
    ["<S-Up>"] = { "k", "" },
    ["J"] = { "j", "" },
    ["K"] = { "k", "" }
}, { mode = "v" })
