-- Copyright (C) xing_lao
local ngx_var = ngx.var
local request = require "core.request"
local loader = require "core.loader"

local _M = { _VERSION = '0.01'}
local mt = { __index = _M}

function _M.init(self, root, appname)
	local APPNAME = appname or ngx_var.APPNAME
	--local APPPATH = (root or ngx_var.ROOT) .. APPNAME .. "/"
	local APPPATH = (root or ngx_var.ROOT)
	local app = setmetatable({
		APPNAME = APPNAME,
		APPPATH = APPPATH
	}, mt)
	ngx.ctx.app = app
	return app
end

local function _auto_load(table, key)
	local val = nil
	if key == "request" then
		val = request:new()
		
	elseif key == "loader" then
		val = loader:new()
	end
	local app = get_instance()
	app[key] = val
	return val
end

local class_mt = {
	__index = _auto_load
}

setmetatable(_M, class_mt)

return _M