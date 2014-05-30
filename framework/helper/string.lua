-- Copyright (C) 2013 doujiang24, MaMa Inc.

local utf8 = require "helper.utf8"

local find = string.find
local sub = string.sub
local insert = table.insert
local concat = table.concat
local type = type
local regsub = ngx.re.gsub
local random = math.random

local ok, uuid = pcall(require, "resty.uuid")
if not ok then
    uuid = {}
    uuid.generate = function () return os.time() .. random(1000, 9999) end
end


local _M = { _VERSION = '0.01' }


-- @param pattern The split pattern (I.e. "%s+" to split text by one or more
-- whitespace characters).
function _M.split(s, pattern, ret)
    if not pattern then pattern = "%s+" end
    if not ret then ret = {} end
    local pos = 1
    local fstart, fend = find(s, pattern, pos)
    while fstart do
        insert(ret, sub(s, pos, fstart - 1))
        pos = fend + 1
        fstart, fend = find(s, pattern, pos)
    end
    if pos <= #s then
        insert(ret, sub(s, pos))
    end
    return ret
end

-- @param pattern The pattern to strip from the left-most and right-most of the
function _M.strip(s, pattern)
    local p = pattern or "%s*"
    local sub_start, sub_end

    -- Find start point
    local _, f_end = find(s, "^"..p)
    if f_end then sub_start = f_end + 1 end

    -- Find end point
    local f_start = find(s, p.."$")
    if f_start then sub_end = f_start - 1 end

    return sub(s, sub_start or 1, sub_end or #s)
end

-- to do: not sure allowable_tags work perfect
function _M.strip_tags(s, allowable_tags)
    local pattern = "</?[^>]+>"
    if allowable_tags and type(allowable_tags) == "table" then
        pattern = "</?+(?!" .. concat(allowable_tags, "|") .. ")([^>]*?)/?>"
    end
    return regsub(s, pattern, "", "iux")
end

-- Translate certain characters
-- from can be the table { from = to, from1 = to1 }
-- s is the utf8 string
function _M.strtr(s, from, to)
    local ret = {}
    if type(from) ~= "table" then
        from = { [from] = to }
    end
    for c in utf8.iter(s) do
        if from[c] then
            insert(ret, from[c])
        else
            insert(ret, c)
        end
    end
    return concat(ret)
end

function _M.uniqid()
    local id = uuid.generate()
    local pref = regsub(id, "-[^-]+$", "")
    local short = regsub(pref, "-", "")
    return short
end

return _M
