local lsocket = require("lsocket")
local M = {}
M.kTimeout = 0.01
----------------------------------------------------------------------------------
local function splitline(data)
  if #data > 0 then
    local _, pos = string.find(data, '\n')
    if pos then
      local ret = nil
      if data[pos-1] =='\r' then
        ret = string.sub(data, 1, pos-1)
      else
        ret = string.sub(data, 1, pos)
      end
      return ret, string.sub(data, pos+1, -1)
    end
  end
  return nil
end

function M.connect(host, port, timeout)
  if host == "localhost" then
    host = "127.0.0.1"
  end
  local conn, err = lsocket.connect(host, port)
  lsocket.select(nil, {conn}, timeout)
  local ok, err1 = conn:status()
  if not ok then
    print("error: "..err)
    return nil, err
  end
  -- 构造sock对象。
  local sock = {conn=conn, buf=""}
  -- function recv
  function sock:recv(sz)
    local buf_size = #self.buf
    if buf_size >= sz then
      local ret = string.sub(self.buf, 1, sz) 
      self.buf = string.sub(self.buf, sz+1, -1)
      return ret;
    end
    local bufs = {}
    table.insert(bufs, self.buf)
    self.buf = ""
    while true do
      local buf, err = self.conn:recv()
      if buf then
        if buf_size + #buf >= sz then
          local ss = string.sub(buf, 1, sz - buf_size)
          table.insert(bufs, ss)
          self.buf = string.sub(buf, sz - buf_size + 1, -1)
          break
        else
          buf_size = buf_size + #buf
          table.insert(bufs, buf)
        end
      else
        if false == buf then
          -- 需要重试。
          local ret = lsocket.select({self.conn}, self.timeout)
          if not ret then
            -- 超时跟出错都认为是timeout
            self.buf = table.concat(bufs)
            return nil, "timeout"
          end
        else
          -- 出错。
          print("conn:close")
          return nil, err
        end
      end -- if !buf  
    end -- while
    --
    local ret = table.concat(bufs)
    return ret
  end
  -- function readline
  function sock:readline()
    local line, data = splitline(self.buf)
    if line then
      self.buf = data
      return line
    end
    --
    local bufs = {}
    table.insert(bufs, self.buf)
    self.buf = ""
    --
    while true do
      local buf, err = self.conn:recv()
      if buf then
        local line, data = splitline(buf)
        if line then
          table.insert(bufs, line)
          self.buf = data
          break
        else
          table.insert(bufs, buf)
        end
      else
        if false == buf then
          -- 需要重试。
          local ret = lsocket.select({self.conn}, self.timeout)
          if not ret then
            -- 超时跟出错都认为是timeout
            self.buf = table.concat(bufs)
            return nil, "timeout"
          end
        else
          -- 出错。
          print("conn:close")
          return nil, err
        end
      end -- if !buf
    end -- while
    --
    local ret = table.concat(bufs)
    return ret
  end
  -- function receive
  function sock:receive(sz)
    if sz then
      return self:recv(sz)
    end
    return self:readline()
  end
  -- function send
  function sock:send(data)
    return self.conn:send(data)
  end
  -- function settimeout
  function sock:settimeout(timeout)
    if type(timeout) == "number" then
      self.timeout = timeout
    else
      self.timeout = M.kTimeout
    end
  end
  -- 
  return sock, err
end

function M.tcp()
  local sock = {timeout=nil,yx=true}
  function sock:connect(host, port)
    return M.connect(host, port, self.timeout)
  end
  function sock:settimeout(timeout)
    self.timeout = timeout
  end
  return sock
end
----------------------------------------------------------------------------------
return M