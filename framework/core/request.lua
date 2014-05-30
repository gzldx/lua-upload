-- Copyright (C) xing_lao
local config = require "core.config"
local upload = require "resty.upload"
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"
local _M = { _VERSION = '0.01'}

local match = string.match
local ngx_var = ngx.var
local get_headers = ngx.req.get_headers
local chunk_size = config.chunk_size
local recieve_timeout = config.connect_timeout
local tracker_host = config.tracker_host
local tracker_port = config.tracker_port

local mt = { __index = _M }

local function getextension(filename)
	return filename:match(".+%.(%w+)$")
end

local function _multipart_formdata(self)
	local form, err = upload:new(chunk_size)
	if not form then
		ngx.log(ngx.ERR, "failed to new upload ", err)
		ngx.exit(500)
	end
	form:set_timeout(recieve_timeout)
	
	local filename,content
	while true do
		local typ, res, err = form:read()
		if not typ then
			ngx.say("failed to read: ", err)
			return
		end
		
		if typ == "header" then
			if res[1] == "Content-Disposition" then
				key = match(res[2], "name=\"(.-)\"")
				filename = match(res[2], "filename=\"(.-)\"")

			elseif res[1] == "Content-Type" then
				filetype = res[2]
			end
			
			if filename and filetype then
				if not self.extname then
					self.extname = getextension(filename)
				end
				value = "userdata"
			end
	
		elseif typ == "body" then
			if value == "userdata" then
				if content == nil then
					content = res
				else
					content = content .. res
				end
			end
			
		--elseif typ == "part_end" then

		elseif typ == "eof" then
			--self.send_fastdfs(content, self.extname)
			break
		end
	end
	return content
end

local function send_fastdfs(blob, ext)
	local tk = tracker:new()
	tk:set_timeout(recieve_timeout)
	tk:connect({host = tracker_host, port = tracker_port})
	local res, err = tk:query_storage_store()
	if not res then
		ngx.say("query storage error:" .. err)
		ngx.exit(200)
	end
	
	local st = storage:new()
	st:set_timeout(recieve_timeout)
	local ok, err = st:connect(res)
	if not ok then
		ngx.say("connect storage error:" .. err)
		ngx.exit(200)
	end
	local result, err = st:upload_appender_by_buff(blob, ext)
	if not result then
		ngx.say("upload error:" .. err)
		ngx.exit(200)
	end
	--local ip = { group1 = 107, group2 = 108}
	--local redirect_url = 'http://192.168.18.' .. ip[result.group_name] .. '/' .. result.group_name .. '/' .. result.file_name
	local redirect_url = '/' .. result.group_name .. '/' .. result.file_name
	return redirect_url
end

local function headers(self, key)
    if not self.header_vars then
        self.header_vars = get_headers()
    end

    if key then
        return self.header_vars[key]
    else
        return self.header_vars
    end
end
_M.headers = headers

local function _check_post(self)
	if ngx_var.request_method == "POST" then
		local header = headers(self, 'Content-Type')
		--ngx.say(header)
		if header == "application/octet-stream" then
            content = _save_raw_file(self)
		else
			-- multipart/form-data
			content = _multipart_formdata(self)
			res = send_fastdfs(content, self.extname)
		end
	end
	return res
end

function _M.new(self)
	local res = {
		header_vars = nil
	}
	return setmetatable(res, mt)
end

local function post(self)
	local res = _check_post(self)
	return res
end
_M.post = post

return _M
