-- Copyright (C) xing_lao @ MaMa, Inc.
local config = require "core.config"
local tracker = require "resty.fastdfs.tracker"
local storage = require "resty.fastdfs.storage"
local magick = require "magick"

local floor = math.floor

local recieve_timeout = config.connect_timeout
local tracker_host = config.tracker_host
local tracker_port = config.tracker_port

function resize(group_name, file_name, ext)
	group_name = 'group'..group_name
	file_name = file_name .. '.' .. ext
	local tk = tracker:new()
	tk:set_timeout(recieve_timeout)
	tk:connect({host = tracker_host, port = tracker_port})
	local res, err = tk:query_storage_fetch(group_name, file_name)	
	
	local st = storage:new()
	st:set_timeout(recieve_timeout)
	local ok, err = st:connect(res)
	local content, err = st:download_file_to_buff(group_name, file_name)
	
	local img = magick.load_image_from_blob(content)
	img:resize_and_crop(120,80)
	content = img:get_blob()
	local thumb, err = st:upload_slave_by_buff(group_name, file_name, '_c120', content, ext)
	if not thumb then
		ngx.say("generate error:" .. err)
		ngx.exit(200)
	end
	local thumb_url = '/' ..thumb.group_name .. '/' .. thumb.file_name
	return thumb_url
end

function scale(group_name, file_name, ext, width)
	group_name = 'group'..group_name
	file_name = file_name .. '.' .. ext
	local tk = tracker:new()
	tk:set_timeout(recieve_timeout)
	tk:connect({host = tracker_host, port = tracker_port})
	local res, err = tk:query_storage_fetch(group_name, file_name)	
	
	local st = storage:new()
	st:set_timeout(recieve_timeout)
	local ok, err = st:connect(res)
	local content, err = st:download_file_to_buff(group_name, file_name)
	
	local img = magick.load_image_from_blob(content)
	local src_w = img:get_width()
	local src_h = img:get_height()
	new_w = tonumber(width)
	new_h = floor(src_h*new_w/src_w)
	img:scale(new_w, new_h)
	content = img:get_blob()
	local thumb, err = st:upload_slave_by_buff(group_name, file_name, '_w'..new_w, content, ext)
	if not thumb then
		ngx.say("generate error:" .. err)
		ngx.exit(200)
	end
	local thumb_url = '/' ..thumb.group_name .. '/' .. thumb.file_name
	return thumb_url
end