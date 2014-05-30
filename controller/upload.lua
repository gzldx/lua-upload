-- Copyright (C) xing_lao
function background()
	local request = get_instance().request
	url = request:post()
	ngx.redirect(url)
end