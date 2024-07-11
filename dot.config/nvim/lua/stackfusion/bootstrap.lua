-- Debug printing with vim.inspect (_G is a special global variable in Lua)
_G.P = function(...)
    for _, v in ipairs({ ... }) do
        print(vim.inspect(v))
    end

    return ...
end

-- Disable some of the plugins that are shipped with Neovim and we don't use
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

local function bootstrap()
    -- Vim's Heritage
    -- A few standard keymappings, leader key set up, and other basic settings that are shared between Vim and Neovim.
    -- Check ~/.vimrc and ~/.config/vim.d/* for details.
    vim.cmd("source ~/.vimrc")

    disable_standard_plugins()

    require("stackfusion.lazy")

    vim.cmd("colorscheme nightfox")
end

bootstrap()
