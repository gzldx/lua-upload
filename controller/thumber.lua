-- Copyright (C) xing_lao
local thumber = get_instance().loader:library('thumber')
local var = ngx.var
local sub = string.sub
function generate()
	local size = sub(var.arg_w, 2)
	local mode = sub(var.arg_w, 1, 1)
	if mode == "c" then
		url = thumber.resize(var.arg_gn, var.arg_fn, var.arg_ext)
	elseif mode == "w" then
		url = thumber.scale(var.arg_gn, var.arg_fn, var.arg_ext, size)
	end
	return ngx.redirect(url)
end