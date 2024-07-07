-- Debug printing with vim.inspect (_G is a special global variable in Lua)
_G.P = function(...)
    for _, v in ipairs({ ... }) do
        print(vim.inspect(v))
    end

    return ...
end

-- Disable some of the plugins that are shipped with Neovim
local function disable_standard_plugins()
    vim.g.loaded_gzip = 1
    vim.g.loaded_tar = 1
    vim.g.loaded_tarPlugin = 1
    vim.g.loaded_zip = 1
    vim.g.loaded_zipPlugin = 1

    vim.g.loaded_2html_plugin = 1
    vim.g.loaded_getscript = 1
    vim.g.loaded_getscriptPlugin = 1
    vim.g.loaded_vimball = 1
    vim.g.loaded_vimballPlugin = 1

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwFileHandlers = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_netrwSettings = 1

    vim.g.loaded_logiPat = 1
    vim.g.loaded_matchit = 1
    vim.g.loaded_matchparen = 1
    vim.g.loaded_rrhelper = 1
    vim.g.loaded_tutor = 1
end

-- Initialize leader key to `\`, and `,` to localleader
local function initialize_leader_keys()
    vim.g.mapleader = "\\"
    vim.g.maplocalleader = ","
end

-- Let make it roll!
local function init()
    disable_standard_plugins()
    initialize_leader_keys()

    require("cr0t.core.lazy")

    vim.cmd("colorscheme nightfox")
end

init()
