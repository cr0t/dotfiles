local path = require("cr0t.helpers.path")

local lazyroot = path.join(path.dataroot, "lazy")
local lazypath = path.join(lazyroot, "lazy.nvim")

if not path.exists(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath
    })
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("cr0t.plugins", {
    root = lazyroot,
    performance = {
        rtp = {
            disabled_plugins = {
                "getscriptPlugin",
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "vimballPlugin",
                "zipPlugin",
            },
        },
    },
})
