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
  table.sort(self.HandleDataList, function(a, b)
    return self:SortOption(a, b)
  end)
end

function InteractionData:DeleteData(index)
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
