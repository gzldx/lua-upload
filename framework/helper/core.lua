-- Copyright (C) 2013 doujiang24, MaMa Inc.

local get_instance = get_instance

local say = ngx.say
local exit = ngx.exit
local HTTP_INTERNAL_SERVER_ERROR = ngx.HTTP_INTERNAL_SERVER_ERROR
local HTTP_OK = ngx.HTTP_OK
local HTTP_NOT_FOUND = ngx.HTTP_NOT_FOUND


local _M = { _VERSION = '0.01' }


function _M.show_error(err_msg, ...)
    local debug = get_instance().debug
    debug:log(debug.ERR, err_msg, ...)
    say(err_msg)
    exit(HTTP_OK)
end

function _M.show_404(msg, ...)
    if msg then
        _M.log_debug(msg, ...)
    end
    exit(HTTP_NOT_FOUND)
end

function _M.log_debug(...)
    return get_instance().debug:log_debug(...)
end

function _M.log_error(...)
    return get_instance().debug:log_error(...)
end

return _M
