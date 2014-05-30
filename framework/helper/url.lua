-- Copyright (C) 2013 doujiang24, MaMa Inc.

local ngx_header = ngx.header

local get_instance = get_instance
local exit = ngx.exit
local re_match = ngx.re.match
local ngx_redirect = ngx.redirect
local escape_uri = ngx.escape_uri
local pairs = pairs
local type = type
local insert = table.insert
local concat = table.concat
local encode_args = ngx.encode_args

local HTTP_MOVED_TEMPORARILY = ngx.HTTP_MOVED_TEMPORARILY


local _M = { _VERSION = '0.01' }


function _M.site_url(url)
    local host = get_instance().request.host
    return re_match(url, "^\\w+://", "i") and url or "http://" .. host .. "/" .. url
end

function _M.redirect(url, status)
    local request = get_instance().request
    local url, status = _M.site_url(url), status or HTTP_MOVED_TEMPORARILY
    return ngx_redirect(url, status)
end

_M.gen_args = encode_args

function _M.root_domain(domain)
    if type(domain) ~= "string" then
        return nil, "root_domain bad arg type, not string"
    end

    local m, err = re_match(domain, [[^(.*?)([^.]+.[^.]+)$]], "jo")
    if not m then
        if err then
            return nil, "failed to match the domain: " .. err
        end

        return nil, "bad domain"
    else
        return m[2], nil
    end
end

function _M.url_domain(url)
    if type(url) ~= "string" then
        return nil, "url_domain bad arg type, not string"
    end

    local m, err = re_match(url, [[^(http[s]*)://([^:/]+)(?::(\d+))?(.*)]], "jo")

    if m then
        return m[2]

    elseif err then
        return nil, "failed to match the uri: " .. err

    end

    return nil, "bad uri"
end

return _M
