local skynet = require "skynet" 
local socket = require "socket"


--lua命令
local CMD  = {}

-- 连接管理
local connection = {}

function read(fd, size)
    return socket.read(fd, size) or error()
end


function read_msg(fd) 
    -- 读2个字节。是阻塞的吗?
    local s = read(fd, 2)
    -- 包长
    local size = s:byte(1) * 256 + s:byte(2)
    local msg = read(fd, size)

    return msg, size
end

-- 登陆验证
function auth(fd, addr)
    connection[fd] = addr

    -- 将 fd 注册到本service, 消息才能投递到本服务
    socket.start(fd)
    
    -- 缓冲区大小？
    socket.limit(8192)

    --读取 socket, 这里返回的 msg 已经去除包头了
    local msg, size = read_msg(fd)

    -- 反序列化
    local rev = protobuf.decode("ns.Base", message)

    -- 是否为登陆消息
    if rev.msgname == "login" then
        -- 新建 agent
        
    else
        close(fd)
    end

end

-- 初始化
-- conf loginserver的配置
function CMD.open(conf) 

    -- 监听端口
    local host = conf.host or "0.0.0.0"
    local port = assert(tonumber(conf.port))
    local sock = socket.listen(host, port)

    -- 收到新的连接后,调用的指定函数
    socket.start(sock, function(fd, addr)
        -- 验证
        auth(fd, addr)
    end) 
end

