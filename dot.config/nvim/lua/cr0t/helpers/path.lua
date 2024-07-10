-- Path-related helpers and constants
local M = {}

-- `/` or `\`? That's the question!
M.separator = package.config:sub(1, 1)

-- Join a list of paths together
M.join = function(...)
    return table.concat({ ... }, M.separator)
end

-- Define default values for important path locations
M.home = os.getenv("HOME")
M.configroot = M.join(M.home, ".config", "nvim")
M.cacheroot = M.join(M.home, ".cache", "nvim")
M.dataroot = M.join(M.home, ".local", "share", "nvim")

-- Create a directory
M.create_dir = function(dir)
    local state = vim.loop.fs_stat(dir)

    if not state then
        vim.loop.fs_mkdir(dir, 511, function()
            assert("Failed to make path:" .. dir)
        end)
    end
end

-- Returns if the path exists on disk
M.exists = function(p)
    local state = vim.loop.fs_stat(p)

    return not (state == nil)
end

-- Remove file from the file system
M.remove_file = function(path)
    os.execute("rm " .. path)
end

-- Create a directory if it doesn't exist yet
M.ensure = function(path)
    if not M.exists(path) then
        M.create_dir(path)
    end
end

-- Read file's content
M.read_file = function(path, mode)
    mode = mode or "*a"
    local file = io.open(path, "r")

    if file then
        local content = file:read(mode)

        file:close()

        return content
    end
end

-- Writes given content to a file
M.write_file = function(path, content, mode)
    mode = mode or "w"

    local file = io.open(path, mode)

    if file then
        file:write(content)
        file:close()
    end
end

return M
