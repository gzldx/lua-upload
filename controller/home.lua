-- Copyright (C) xing_lao
function index()
    ngx.say(get_instance().loader:view('index'))
end