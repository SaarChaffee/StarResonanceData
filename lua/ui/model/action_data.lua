local super = require("ui.model.data_base")
local ActionData = class("ActionData", super)

function ActionData:ctor()
  super.ctor(self)
end

function ActionData:Init()
  local actionTableMgr = Z.TableMgr.GetTable("ActionTableMgr")
  local datas = actionTableMgr.GetDatas()
  self.UnLocakItemMap = {}
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  for key, value in pairs(datas) do
    if value.UnlockItem ~= nil and value.UnlockItem ~= 0 then
      local itemId = value.UnlockItem
      local item = itemTableMgr.GetRow(itemId)
      if item ~= nil then
        self.UnLocakItemMap[value.UnlockItem] = key
      else
        logError("ActionData:Init() item is nil, itemId = " .. itemId)
      end
    end
  end
end

function ActionData:GetActionDataByUnlockItemId(unlockItemId)
  local actionId = self.UnLocakItemMap[unlockItemId]
  if actionId then
    local actionTableMgr = Z.TableMgr.GetTable("ActionTableMgr")
    return actionTableMgr.GetRow(actionId, false)
  end
end

function ActionData:GetDurationLoopTime(Id, expressionType)
  if expressionType == E.ExpressionType.Emote then
    return 5
  end
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  local actionAnimInfo = Z.ZAnimActionPlayMgr:GetActionAnimInfoByActionId(Id)
  if actionAnimInfo then
    local time = actionAnimInfo:GetDefaultClipLength(gender)
    if 0 < time then
      return time
    end
    return actionAnimInfo:GetLoopAnimTime(gender)
  else
    return 0
  end
end

function ActionData:GetDurationSumTime(Id, expressionType)
  if expressionType == E.ExpressionType.Emote then
    return 5
  end
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  local actionAnimInfo = Z.ZAnimActionPlayMgr:GetActionAnimInfoByActionId(Id)
  if actionAnimInfo then
    return actionAnimInfo:GetTotalTime(gender)
  else
    return 0
  end
end

return ActionData
