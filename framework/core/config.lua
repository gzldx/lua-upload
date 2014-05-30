local _M = {}

-- router
_M.max_level = 2
_M.default_ctr = "home"
_M.default_func = "index"

-- fastdfs
_M.tracker_host = "192.168.18.183"
_M.tracker_port = 22122

-- form upload
_M.chunk_size = 4098        -- 4k
_M.connect_timeout = 3000   -- 3s

return _M