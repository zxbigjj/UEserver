local LFS = require("lfs")

local path_sep = "/"

local io_utils = DECLARE_MODULE("sys_utils.io_utils")

function io_utils.readfile(file_path)
    local file_handle = io.open(file_path, "rb")
    if not file_handle then
        return
    end
    local file_content = file_handle:read("*a")
    file_handle:close()
    return file_content
end

function io_utils.requirefile(file_path)
    local file_content = io_utils.readfile(file_path)
    if file_content then
        local chunk, err = load(file_content)
        if chunk then
            return chunk()
        else
            error("load file error:" .. file_path .. "," .. err)
        end
    end
end

function io_utils.getfilesindir(file_dir, file_ext, is_deep, ret)
    ret = ret or {}
    for file in LFS.dir(file_dir) do
        if file ~= "." and file ~= ".." and string.find(file, ".+%" .. file_ext) then
            local f_path = file_dir .. path_sep .. file
            local attr = LFS.attributes(f_path)
            if attr.mode == "file" then
                ret[f_path] = file
            elseif attr.mode == "directory" and is_deep then
                io_utils.getfilesindir(f_path, file_ext, is_deep, ret)
            end
        end
    end
    return ret
end

return io_utils