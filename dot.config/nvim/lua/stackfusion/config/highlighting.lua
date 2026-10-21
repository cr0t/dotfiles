local ts = require("nvim-treesitter")

ts.setup({})

ts.install({
  "bash", "c", "css", "diff", "dockerfile", "elixir", "elm", "erlang", "fish", "git_config", "gitcommit", "gitignore",
  "heex", "html", "javascript", "jsdoc", "json", "lua", "luadoc", "luap", "markdown", "markdown_inline", "mermaid",
  "python", "query", "regex", "ruby", "scss", "sql", "ssh_config", "svelte", "terraform", "toml", "tsx", "typescript",
  "vim", "vimdoc", "xml", "yaml",
})

-- Start highlighting per filetype
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local buf = args.buf

    if vim.api.nvim_buf_line_count(buf) > 50000 then
      return
    end

    -- pcall: errors if no parser exists for this filetype
    if pcall(vim.treesitter.start, buf) then
      -- optional: treesitter-based indentation
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
