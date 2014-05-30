local app = require "core.app"
local app = app:init()
local router = require "core.router"
local rt = router:new()
return rt:run()