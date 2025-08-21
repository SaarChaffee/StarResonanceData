local super = require("ui.model.data_base")
local ServerData = class("ServerData", super)

function ServerData:ctor()
  super.ctor(self)
  self.LastGetTime = 0
  self.ServerList = {}
  self.LoginNameToIp = {}
  self.LoginOptions = {}
  self.NowSelectData = {}
  self.ServerMap = {}
  self.NowSelectServerId = 0
end

function ServerData:SetServerData(serverList)
  self.ServerList = serverList
  self.LoginOptions = {}
  self.LoginNameToIp = {}
  self.ServerMap = {}
  for key, value in pairs(serverList) do
    self.ServerMap[value.id] = value
    self.LoginNameToIp[value.description] = value.serverUrl .. ":" .. math.floor(value.host)
    table.insert(self.LoginOptions, value.description)
  end
  local loginVM = Z.VMMgr.GetVM("login")
  self.LoginNameToIp[Lang("CustomServer")] = ""
  table.insert(self.LoginOptions, Lang("CustomServer"))
end

function ServerData:SetNowSelectData(data)
  self.NowSelectData = data
  if self.NowSelectData.zoneId ~= nil then
    self.NowSelectData.zoneId = math.floor(self.NowSelectData.zoneId)
  end
end

function ServerData:GetServerId(addr)
  for key, value in pairs(self.ServerMap) do
    if addr == value.serverUrl .. ":" .. math.floor(value.host) then
      return key
    end
  end
  return 0
end

function ServerData:SetNowSelectServerId(id)
  self.NowSelectServerId = id
end

function ServerData:GetSelectServerInfo()
  return self.ServerList[self.NowSelectServerId]
end

function ServerData:GetChatUrl()
  return self.NowSelectData.chatUrl
end

function ServerData:GetCurrentZoneId()
  return self.NowSelectData.zoneId or 9999
end

function ServerData:GetDescriptionByAddr(addr)
  for description, serverAddr in pairs(self.LoginNameToIp) do
    if serverAddr == addr then
      return description
    end
  end
  return ""
end

return ServerData
