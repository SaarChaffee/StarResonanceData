local super = require("ui.model.data_base")
local RoleInfoData = class("RoleInfoData", super)

function RoleInfoData:ctor()
  super.ctor(self)
end

function RoleInfoData:Init()
  self.CacheX = 0
  self.CacheY = 0
  self.CacheZ = 0
end

function RoleInfoData:SetCache(x, y, z)
  self.CacheX = x
  self.CacheY = y
  self.CacheZ = z
end

function RoleInfoData:GetCache()
  return self.CacheX, self.CacheY, self.CacheZ
end

return RoleInfoData
