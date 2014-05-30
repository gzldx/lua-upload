-- Copyright (C) 2013 doujiang24, MaMa Inc.

local pairs = pairs
local insert = table.insert
local type = type

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end


local _M = { _VERSION = '0.01' }


function _M.filter(tbl, func)
    local ret = {}
    for k, v in pairs(tbl) do
        if not func(v) then
            ret[k] = v
        end
    end
    return ret
end

function _M.in_tbl(value, tbl)
    for _k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return nil
end

local function copy(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        if "table" == type(v) then
            ret[k] = copy(v)
        else
            ret[k] = v
        end
    end
    return ret
end
_M.copy = copy

-- append: append tbl2 to tbl1 when is true; default nil
-- tbl1, tbl2 should not be mix hash table
function _M.merge(tbl1, tbl2, append)
    local ret = tbl1
    if not append then
        ret = copy(tbl1)
    end

    for k, v in pairs(tbl2) do
        if type(k) == "number" then
            insert(ret, v)
        else
            ret[k] = v
        end
    end
    return ret
end

function _M.slice(tbl, offset, length)
    local ret = {}
    local fend = length and ((offset + length) <= #tbl) and (offset + length - 1) or #tbl
    for i = offset, fend, 1 do
        insert(ret, tbl[i])
    end
    return ret
end

function _M.keys(tbl)
    local ret = {}

    for k, _v in pairs(tbl) do
        ret[#ret + 1] = k
    end

    return ret
end

function _M.values(tbl, key)
    local ret = {}

    for _k, v in pairs(tbl) do
        ret[#ret + 1] = key and v[key] or v
    end

    return ret
end

function _M.array_to_hash(t)
    local n = #t
    local h = new_tab(0, n / 2)
    for i = 1, n, 2 do
        h[t[i]] = t[i + 1]
    end
    return h
end

return _M
