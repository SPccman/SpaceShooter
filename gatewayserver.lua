-- 网关服务器，管理客户端链接
local skynet = require "skynet"
local syslog = require "syslog"
local netpack = require "netpack"
local socketdriver = require "socketdriver"


local queue

-- lua 命令
local CMD = setmetatable({}, {__gc = function () netpack.clear(queue) end})

-- 链接管理 key:fd
local connection = {}

-- 当前连接数
local curclient = 0;
local maxclient


function CMD.open(config) 
    local addr = config.addr or "0.0.0.0"
    local port = assert(tonumber(config.port))

    -- 最大连接数
    maxclient = config.maxclient or 128

    syslog.debugf("listen on (%s) (%d)", addr, port)
    
    socket = socketdriver.listen(addr, port);
    -- start 后, 套接口才生效
    socketdriver.start(socket)
end


function login_handler(fd, account) 

end


----------------------------------socket MSG-------------------------------------
-- 设置 socket 处理
skynet.register_protocol {
    name = 'socket',
    -- 表示是 socket 来的
    id = skynet.PTYPE_SOCKET,
    -- 解包函数
    unpack = function(msg, sz) 
        return netpack.filter(queue, msg, sz)
    end,
    -- 解包后的消息投递到这个函数
    dispatch = function(_, _, queue, type, ...)
        queue = q;
        if type then
            -- 根据 type 调用具体的函数
            return MSG[type](...)
        end
    end
}


-- socket(dispatch设置) 命令
local MSG {}
-- open 表示有 socket 链接上来的， "open" 是 skynet 框架底层定的名字
function MSG.open(fd, addr)
    if curclient > maxclient then
        socketdriver.close(fd)
    end

    local c {
        fd = fd,
        addr = addr
    }

    connection[fd] = c
    curclient = curclient + 1

    -- 激活fd
    socketdriver.start(fd)
end

-- data 表示 socket 数据处理函数, "data" 也是 skynet 底层定的名字
MSG.data = dispatch_msg

-- 这个函数赋值给 MSG.data, 也就是 socket 通信消息的处理函数
function dispatch_msg(fd, msg, sz)
    -- 找到链接
    local c = connection[fd]
    local agent = c.agent
    if agent then
        -- 转发消息到 agent 处理

    else
        -- 没找到则新建 agent
        login_handler(fd, account)
    end
end
----------------------------------socket MSG-------------------------------------
