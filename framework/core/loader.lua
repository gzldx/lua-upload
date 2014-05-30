-- Copyright (C) 2013 doujiang24, MaMa Inc.
local corehelper = require "helper.core"
local filehelper = require "helper.file"
local ltp = require "library.ltp.template"

local setmetatable = setmetatable
local pcall = pcall
local assert = assert
local loadfile = loadfile
local type = type
local setfenv = setfenv
local concat = table.concat
local show_error = corehelper.show_error
local get_instance = get_instance
local fexists = filehelper.exists
local fread_all = filehelper.read_all
local ltp_load_template = ltp.load_template
local ltp_execute_template = ltp.execute_template

local _G = _G


local _M = { _VERSION = '0.01' }


local mt = { __index = _M }


local cache_module = {}


function _M.new(self)
    local app = get_instance()
    local res = {
        appname = app.APPNAME,
        apppath = app.APPPATH
    }
    return setmetatable(res, mt)
end

local function _get_cache(self, module)
    local appname = self.appname
    return cache_module[appname] and cache_module[appname][module]
end

local function _set_cache(self, name, val)
    local appname = self.appname
    if not cache_module[appname] then
        cache_module[appname] = {}
    end
    cache_module[appname][name] = val
end

local function _load_module(self, dir, name)
    local file = dir .. "/" .. name
    local cache = _get_cache(self, file)
    if cache == nil then
        local module = false
        local filename = self.apppath .. file .. ".lua"
        if fexists(filename) then
            module = setmetatable({}, { __index = _G })
            assert(pcall(setfenv(assert(loadfile(filename)), module)))
        end
        _set_cache(self, file, module)
        return module
    end
    return cache
end

function _M.core(self, filename)
    return _load_module(self, "core", filename)
end

function _M.controller(self, filename)
    return _load_module(self, "controller", filename)
end

function _M.model(self, mod, ...)
    local m = _load_module(self, "model", mod)
    return m and type(m.new) == "function" and m:new(...) or m
end

function _M.config(self, conf)
    return _load_module(self, "config", conf)
end

function _M.library(self, lib)
    return _load_module(self, "library", lib)
end

local function _ltp_function(self, tpl)
    local cache = _get_cache(self, tpl)
    if cache == nil then
        local tplfun = false
        local filename = self.apppath .. tpl
        if fexists(filename) then
            local fdata = fread_all(filename)
            tplfun = ltp_load_template(fdata, '<?lua','?>')
        else
            show_error("failed to load tpl:", filename)
        end
        _set_cache(self, tpl, tplfun)
        return tplfun
    end
    return cache
end

function _M.view(self, tpl, data)
    local template, data = "views/" .. tpl .. ".tpl", data or {}
    local tplfun = _ltp_function(self, template)
    local output = {}
    setmetatable(data, { __index = _G })
    ltp_execute_template(tplfun, data, output)
    return output
end

return _M
