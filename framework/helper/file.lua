-- Copyright (C) 2013 doujiang24, MaMa Inc.

local corehelper = require "helper.core"

local log_error = corehelper.log_error
local find = string.find
local sub = string.sub
local insert = table.insert

local get_instance = get_instance
local io_open = io.open
local type = type
local concat = table.concat
local rename = os.rename
local remove = os.remove
local time = ngx.time
local ipairs = ipairs
local sub = string.sub


local _M = { _VERSION = '0.01' }

local magics = {
    { "\137PNG", 'png' },
    { "GIF87a", 'gif' },
    { "GIF89a", 'gif' },
    { "\255\216\255\224\0\16\74\70\73\70\0", 'jpg' },
    { "\255\216\255\225\19\133\69\120\105\102\0", 'jpg' },  -- JPEG Exif
}

function _M.detect(str)
    for _i, v in ipairs(magics) do
        if v[1] == sub(str, 1, #v[1]) then
            return v[2]
        end
    end
    return "tmp"
end

function _M.move(source, dest)
    local ok, err = rename(source, dest)
    if not ok then
        log_error('move file err:', err, source, dest)
    end
    return ok
end

function _M.exists(f)
    local fh, err = io_open(f)
    if fh then
        fh:close()
        return true
    end
    return nil
end

function _M.remove(f)
    local ok, err = remove(f)
    if not ok then
        log_error("remove file: ", f, "; error: ", err)
    end
    return ok
end

function _M.log_file(file, ...)
    local fp, err = io_open(file, "a")
    if not fp then
        local debug = get_instance().debug
        debug:log(debug.ERR, "failed to open file ", file)
        return
    end

    local args = { ... }
    for i = 1, #args do
        if args[i] == nil then
            args[i] = ""
        elseif type(args[i]) == "table" then
            args[i] = "table value"
        end
    end
    local str = concat(args, "\t")
    local ok, err = fp:write(str, "\n")
    if not ok then
        local debug = get_instance().debug
        debug:log(debug.ERR, "failed to write log file:", file, "str:", str)
        return
    end

    fp:close()
    return true
end

function _M.read_all(filename)
    local file, err = io_open(filename, "r")
    local data = file and file:read("*a") or nil
    if file then
        file:close()
    end
    return data
end

return _M
