-- Copyright (C) 2013 doujiang24, MaMa Inc.

local utf8 = require "helper.utf8"
local bit = require "bit"
local numhepler = require "helper.number"

local band = bit.band
local rshift = bit.rshift
local bor = bit.bor
local tonumber = tonumber
local chr = string.char
local insert = table.insert
local concat = table.concat
local h2dec = numhepler.h2dec
local regmatch = ngx.re.gmatch
local regsub = ngx.re.gsub


local _M = { _VERSION = '0.01' }


-- unicode num to utf8 (char is a num or num string)
function _M.u2utf8(char)
    local ret = {}
    local num = tonumber(char)
    if num < 0x80 then
        insert(ret, chr(num))
    elseif num < 0x800 then
        insert(ret, chr(bor(0xC0, rshift(num, 6))))
        insert(ret, chr(bor(0x80, band(num, 0x3F))))
    elseif num < 0x10000 then
        insert(ret, chr(bor(0xE0, rshift(num, 12))))
        insert(ret, chr(bor(0x80, band(rshift(num, 6), 0x3F))))
        insert(ret, chr(bor(0x80, band(num, 0x3F))))
    elseif num < 0x200000 then
        insert(ret, chr(bor(0xF0, rshift(num, 18))))
        insert(ret, chr(bor(0x80, band(rshift(num, 12), 0x3F))))
        insert(ret, chr(bor(0x80, band(rshift(num, 6), 0x3F))))
        insert(ret, chr(bor(0x80, band(num, 0x3F))))
    end
    return concat(ret)
end

function _M.str_u2utf8(str)
    local ret = str
    for m in regmatch(str, '&#([xX]?)([0-9a-fA-F]{2,7})(;?)', "u") do
        local s, x, dec = m[0], m[1], m[2]
        dec = (x ~= "") and h2dec(dec) or dec
        ret = regsub(ret, s, _M.u2utf8(dec))
    end
    return ret
end

return _M
