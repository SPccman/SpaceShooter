-- 用户登陆
-- 更新分数
-- 拉取榜单

local skynet = require "skynet"
local socketdriver = require "skynet.socketdriver"
local netpack = require "skynet.netpack"

--链接管理
local connection = {}

-- 通信消息
local MSG = {}

local queue

-- open close data 等都与netpack中对应了 代码在 lua-netpack.c +480

-- 客户端链接
function MSG.open(fd, msg)
    print("MSG.open")
    -- 这里将fd投递到框架，否则框架不会处理到这个fd
    socketdriver.start(fd)
end

function MSG.close(fd)
    print("MSG.close")
end

-- 处理请求
function MSG.MsgParser(msg)
    print("MSG.MsgParser")
end

-- 注册消息

-- 注册socket类消息(只处理客户端上来的请求)
skynet.register_protocol {
    name = "socket",
    id = skynet.PTYPE_SOCKET, -- PTYPE_SOCKET=6
    unpack =  function(msg, sz)    -- 解包函数
        return netpack.filter(queue, msg, sz) 
    end,
    dispatch = function(_, _, q, type, ...)   --分发函数
        if type then
            MSG[type](...)
        end 
    end 
}

skynet.start(
    function()
        InitServer()
    end 
)

-- 初始化服务器
function InitServer()
    local address="0.0.0.0"
    local port = 8383
    print(string.format("Listen on (%s) port (%d)", address, port))
    socket = socketdriver.listen(address, port)
    socketdriver.start(socket)
end

local function AddUserScore(uid, score)
end

local function GetRank()
end
