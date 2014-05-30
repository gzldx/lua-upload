-- Copyright (C) 2013 doujiang24, MaMa Inc.

local null = ngx.null
local type = type
local ipairs = ipairs
local re_match = ngx.re.match
local maxn = table.maxn


local _M = { _VERSION = '0.01' }


function _M.empty(...)
    local tbl = { ... }
    for i = 1, maxn(tbl) do
        if tbl[i] ~= "" and tbl[i] ~= nil and tbl[i] ~= null and tbl[i] ~= false then
            return false
        end
    end
    return true
end

function _M.is_numeric(...)
    local tbl = { ... }
    for i = 1, maxn(tbl) do
        if type(tbl[i]) ~= "number" and
            (type(tbl[i]) ~= "string" or re_match(tbl[i], "^-?\\d+.?\\d*$") == nil ) then
            return false
        end
    end
    return #tbl > 0 and true or false
end

function _M.is_string(...)
    local tbl = {...}
    for i = 1, maxn(tbl) do
        if type(tbl[i]) ~= "string" then
            return false
        end
    end
    return #tbl > 0 and true or false
end

return _M
