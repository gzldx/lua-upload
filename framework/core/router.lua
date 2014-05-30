-- Copyright (C) xing_lao
local ngx_var = ngx.var
local strhelper = require "helper.string"
local config = require "core.config"
local get_instance = get_instance

local strip = strhelper.strip
local split = strhelper.split
local _M = { _VERSION = '0.01'}

local max_level = config.max_level
local default_func = config.default_func

local mt = { __index = _M }

local function get_segments(self)
	if not self.segments then
		local str = self.uri
		local from, to, err = ngx.re.find(str, "\\?", "jo")
		if from then
			str = string.sub(str, 1, from - 1)
		end
		
		self.segments = split(strip(str, "/"), "/")
	end
	return self.segments
end
_M.get_segments = get_segments

function _M.new(self)
	local app = get_instance()
	
	return setmetatable({
		loader = app.loader,
		apppath = app.APPPATH,
		uri = ngx_var.uri,
		segments = nil
	}, mt)
end

local function _route(self)
	default_ctr = "home"
	local loader, segments = self.loader, get_segments(self)
	local seg_len = #segments
	if seg_len == 0 then
		segments[1] = default_ctr
		seg_len = 1
	end
	
	local max = (seg_len > max_level) and max_level or seg_len
	local uri = nil
	
	for i = 1, max do
        uri = (uri and uri .. "/" or '') .. segments[i]

        local ctr = loader:controller(uri)
        if not ctr and not segments[i+1] then
            ctr = loader:controller(uri .. "/" .. default_ctr)
        end

        if ctr then
            local func = segments[i+1]
            if func and type(ctr[func]) == "function" then
                return ctr[func], select(i+2, unpack(segments))

            elseif type(ctr[remap_func]) == "function" then
                return ctr[remap_func], select(i+1, unpack(segments))

            elseif not func and type(ctr[default_func]) == "function" then
                return ctr[default_func]
            end
        end
    end
end

local function _run(func, ...)
    if func then
        return func(...)
    end
    return ngx.exit(NOT_FOUND)
end

function _M.run(self)
    return _run(_route(self))
end

return _M