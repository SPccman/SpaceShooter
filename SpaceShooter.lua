-- 用户登陆
-- 更新分数
-- 拉取榜单

local skynet = require "skynet"
local socketdriver = require "skynet.socketdriver"
local netpack = require "skynet.netpack"
local protobuf = require "protobuf"

-- proto
local function load_protofile(pbfile)
    protobuf.register_file(pbfile)
    print(string.format("注册proto文件: %s", pbfile))
end

--链接管理
local connection = {}

-- 通信消息
local MSG = {}

local queue

-- open close data 等都与netpack中对应了 代码在 lua-netpack.c +480

-- 客户端链接
function MSG.open(fd, msg)
    print("MSG.open")
    socketdriver.start(fd)
end

function MSG.close(fd)
    print("MSG.close")
end


-- 处理请求
function MsgParser(fd, msg, sz)
    print(string.format("MSG.MsgParser fd(%d) msg(%s) sz(%d)", fd, msg, sz))
    local message = netpack.tostring(msg, sz)
    local data = protobuf.decode("ns.AddScore", message)
    print(string.format("recv msg uid(%d) score(%d)", data.userid, data.score))
end

MSG.data = MsgParser

-- 注册消息

-- 注册socket类消息(只处理客户端上来的请求)
skynet.register_protocol {
    name = "socket",
    id = skynet.PTYPE_SOCKET, -- PTYPE_SOCKET=6
    unpack =  function(msg, sz)    -- 解包函数
        return netpack.filter(queue, msg, sz) 
    end,
    dispatch = function(_, _, q, type, ...)   --分发函数
        print(type)
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
    load_protofile("./SpaceShooter.pb")
end

local function AddUserScore(uid, score)
end

local function GetRank()
end
