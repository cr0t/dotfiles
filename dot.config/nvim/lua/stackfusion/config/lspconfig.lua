require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "ansiblels", "bashls", "cssls", "elixirls", "elmls", "html", "lua_ls", "solargraph", "svelte", "tsserver",
        "yamlls"
    },
})

require("mason-lspconfig").setup_handlers({
    -- The first entry (without a key) will be the default handler and will be called for each installed server that
    -- doesn't have a dedicated handler.
    function(server_name)
        require("lspconfig")[server_name].setup {
            capabilities = require("cmp_nvim_lsp").default_capabilities()
        }
    end,
    -- Next, you can provide a dedicated handler for specific servers. For example, a handler override for the `lua_ls`:
    ["lua_ls"] = function()
        require("lspconfig").lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" }
                    }
                }
            }
        })
    end,
})
