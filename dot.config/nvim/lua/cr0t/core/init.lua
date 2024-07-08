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

-- These settings aimed to improve ESC waiting time (open/close plugins or
-- change modes faster, for example).
local function configure_timeouts()
    vim.o.timeout = true
    vim.o.timeoutlen = 200
    vim.o.ttimeoutlen = 0
    vim.o.updatetime = 200
end

local function how_to_quit()
    -- Close on quit
    vim.api.nvim_create_autocmd({ "QuitPre" }, {
        callback = function()
            vim.cmd("NvimTreeClose")
        end,
    })

    -- Map annoying Q/Wq/QA/etc. stuff that I often type too fast when quit
    vim.cmd("command! Q q")
    vim.cmd("command! Qall qall")
    vim.cmd("command! QA qall")
    vim.cmd("command! E e")
    vim.cmd("command! W w")
    vim.cmd("command! Wq wq")
end

-- Let make it roll!
local function init()
    disable_standard_plugins()
    initialize_leader_keys()
    configure_timeouts()
    how_to_quit()

    vim.o.termguicolors = true
    vim.opt.sessionoptions:append 'globals' -- need this for barbar+mini.sessions and buffers order restoration

    require("cr0t.core.lazy")
    require("cr0t.core.keys")

    vim.cmd("colorscheme nightfox")
end

init()
