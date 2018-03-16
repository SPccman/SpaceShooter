local skynet = require "skynet"
local login_config = require "config.loginserver"

skynet.start(function() 
    -- 创建 loginserver 服务,返回服务ID
    local loginserver = skynet.newservice("loginserver")
    -- 向 loginserver 发送 open(初始化) 命令
    skynet.call(loginserver, "lua", "open", login_config)
end)
