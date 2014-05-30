-- Copyright (C) 2013 doujiang24, MaMa Inc.

local insert = table.insert
local gsub = string.gsub
local gmatch = string.gmatch
local concat = table.concat
local select = select
local next = next


local _M = { _VERSION = '0.01' }


local utf8char = '[%z\1-\127\194-\244][\128-\191]*'

function _M.len(s)
	return select(2, gsub(s, '[^\128-\193]', ''))
end

function _M.sub(s, start, fend)
    fend = fend or -1
    fend = fend > 0 and fend or _M.len(s) + fend
    start = start > 0 and start or _M.len(s) + start + 1
    if start > fend then
        return ""
    end

    local ret = {}
    local i = 1

    for w in gmatch(s, utf8char) do
        if i >= start then
            insert(ret, w)
        end
        if i >= fend then
            break
        end
        i = i + 1
    end
    return next(ret) and concat(ret, "") or ""
end

function _M.iter(str)
    return gmatch(str, utf8char)
end

return _M
