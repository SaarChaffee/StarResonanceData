local super = require("ui.model.data_base")
local PlayerData = class("PlayerData", super)

function PlayerData:ctor()
  super.ctor(self)
end

function PlayerData:Init()
  self:Clear()
end

function PlayerData:Uninit()
  self:Clear()
end

function PlayerData:Clear()
  self.SDKType = nil
  self.SDKToken = nil
  self.Token = nil
  self.AccountInfo = nil
  self.AccountName = nil
  self.CurrentCharId = nil
  self.CharDataList = nil
  self.CharDataIndex = nil
  self.DeleteCharIdsLeftTime = nil
  self.GetDeleteCharTimestamp = nil
  self.LastUnstuckTime = nil
end

function PlayerData:DeleteChar(charId)
  if self.CharDataList == nil then
    return
  end
  for i, v in ipairs(self.CharDataList) do
    if v.charId == charId then
      table.remove(self.CharDataList, i)
      break
    end
  end
  if self.DeleteCharIdsLeftTime[charId] then
    self.DeleteCharIdsLeftTime[charId] = nil
  end
  if self.GetDeleteCharTimestamp[charId] then
    self.GetDeleteCharTimestamp[charId] = nil
  end
end

function PlayerData:SortCharDataList(targetCharId)
  if self.CharDataList == nil then
    return
  end
  if #self.CharDataList == 1 then
    self.CharDataIndex = 1
    return
  end
  table.sort(self.CharDataList, function(a, b)
    local aDeleteLeftTime = self.DeleteCharIdsLeftTime[a.charId] or 0
    local bDeleteLeftTime = self.DeleteCharIdsLeftTime[b.charId] or 0
    if aDeleteLeftTime == bDeleteLeftTime then
      if a.basicData.onlineTime == b.basicData.onlineTime then
        return a.basicData.createTime < b.basicData.createTime
      else
        return a.basicData.onlineTime > b.basicData.onlineTime
      end
    else
      return aDeleteLeftTime < bDeleteLeftTime
    end
  end)
  if targetCharId then
    for i, v in ipairs(self.CharDataList) do
      if v.charId == targetCharId then
        self.CharDataIndex = i
        break
      end
    end
  else
    self.CharDataIndex = 1
  end
end

return PlayerData
