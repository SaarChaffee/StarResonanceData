local super = require("ui.model.data_base")
local InteractionData = class("InteractionData", super)

function InteractionData:ctor()
  super.ctor(self)
  self.HandleDataList = {}
end

function InteractionData:SortOption(left, right)
  if left:HasNpcQuestTalk() ~= right:HasNpcQuestTalk() then
    return left:HasNpcQuestTalk()
  elseif left:GetSortId() ~= right:GetSortId() then
    return left:GetSortId() > right:GetSortId()
  elseif left:GetAddTime() ~= right:GetAddTime() then
    return left:GetAddTime() < right:GetAddTime()
  end
end

function InteractionData:AddData(handleData)
  self.HandleDataList[#self.HandleDataList + 1] = handleData
end

function InteractionData:SortData()
  table.sort(self.HandleDataList, function(a, b)
    return self:SortOption(a, b)
  end)
end

function InteractionData:HasData(uuid, interactionCfgId)
  for i = 1, #self.HandleDataList do
    if self.HandleDataList[i]:GetNew() and self.HandleDataList[i]:GetUuid() == uuid and self.HandleDataList[i]:GetInteractionCfgId() == interactionCfgId then
      return true
    end
  end
  return false
end

function InteractionData:DeleteData(index)
  local handleData = self.HandleDataList[index]
  if handleData then
    handleData:UnInit()
  end
  table.remove(self.HandleDataList, index)
end

function InteractionData:Clear()
  self.HandleDataList = {}
  Z.EventMgr:Dispatch(Z.ConstValue.DeActiveOption)
end

function InteractionData:GetData()
  return self.HandleDataList
end

return InteractionData
