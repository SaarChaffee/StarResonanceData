local super = require("ui.model.data_base")
local TeamTipData = class("TeamTipData", super)

function TeamTipData:ctor()
  super.ctor(self)
  self.CacheTipsList = {}
end

function TeamTipData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function TeamTipData:Clear()
  self.CacheTipsList = {}
end

function TeamTipData:UnInit()
  self.CancelSource:Recycle()
end

function TeamTipData:SetCacheData(info)
  for _, value in ipairs(self.CacheTipsList) do
    if value.content == info.content and value.tipsType == info.tipsType then
      return
    end
  end
  table.insert(self.CacheTipsList, info)
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTipsByData)
end

function TeamTipData:GetCacheData()
  local info
  if #self.CacheTipsList > 0 then
    info = self.CacheTipsList[1]
    table.remove(self.CacheTipsList, 1)
  end
  return info
end

function TeamTipData:GetCacheDatas()
  return self.CacheTipsList
end

return TeamTipData
