local r_G = _G
local mt = getmetatable(r_G)
if mt then
    r_G = rawget(mt, "__index")
end

r_G.get_instance = function ()
    return ngx.ctx.app
end