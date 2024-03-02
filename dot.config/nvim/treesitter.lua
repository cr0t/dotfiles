-- Quick help on available commands:
--
-- :TSBufEnable {module} " enable module on current buffer
-- :TSBufDisable {module} " disable module on current buffer
-- :TSEnable {module} [{ft}] " enable module on every buffer. If filetype is specified, enable only for this filetype.
-- :TSDisable {module} [{ft}] " disable module on every buffer. If filetype is specified, disable only for this filetype.
-- :TSModuleInfo [{module}] " list information about modules state for each filetype

-- Use nvim-treesitter only if gcc is available (not a production server, for example)
if vim.fn.executable("gcc") == 1 then
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "bash", "elixir", "erlang", "fish", "javascript", "lua", "markdown",
      "markdown_inline", "ruby", "typescript", "vim",
    },
    auto_install = false, -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    highlight = {
      additional_vim_regex_highlighting = true,
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))

        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
    }
  }
end
