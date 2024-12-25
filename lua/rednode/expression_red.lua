local ExpressionRed = {}
ExpressionRed.itemType = {}
local expressionVm, actionData

function ExpressionRed.AddNewRed(itemType, itemId, emoteTableType)
  if ExpressionRed.itemType[itemType] == nil then
    ExpressionRed.itemType[itemType] = {}
  end
  if table.zcontains(ExpressionRed.itemType[itemType], itemId) then
    return
  end
  Z.RedPointMgr.AddChildNodeData(E.RedType.ExpressionMain, E.RedType.ExpressionItem, E.RedType.ExpressionMain .. itemType .. emoteTableType)
  table.insert(ExpressionRed.itemType[itemType], itemId)
  Z.RedPointMgr.AddChildNodeData(E.RedType.ExpressionMain .. itemType .. emoteTableType, E.RedType.ExpressionAction, E.RedType.ExpressionMain .. itemType .. emoteTableType .. itemId)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ExpressionMain .. itemType .. emoteTableType, #ExpressionRed.itemType[itemType])
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ExpressionMain .. itemType .. emoteTableType .. itemId, 1)
  ExpressionRed.refreshExpressionRed()
end

function ExpressionRed.refreshExpressionRed()
  local count = 0
  for _, value in pairs(ExpressionRed.itemType) do
    count = count + #value
  end
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ExpressionMain, count)
end

function ExpressionRed.RemoveRed(itemId, emoteTableType)
  for key, value in pairs(ExpressionRed.itemType) do
    if table.zcontains(value, itemId) then
      table.zremoveOneByValue(value, itemId)
      Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ExpressionMain .. key .. emoteTableType, #value)
      Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ExpressionMain .. key .. emoteTableType .. itemId, 0)
      ExpressionRed.refreshExpressionRed()
    end
  end
end

function ExpressionRed.addExpressionRed()
  if not actionData then
    return
  end
  for itemId, actionId in pairs(actionData.UnLocakItemMap) do
    local emoteTableData = expressionVm.CheckIsUnlockByItemIdAndActionId(itemId, actionId)
    if emoteTableData then
      ExpressionRed.AddNewRed(E.ItemType.ActionExpression, itemId, emoteTableData.EmoteType)
    end
  end
end

function ExpressionRed.changeItem(item)
  if not item then
    return
  end
  if not actionData then
    return
  end
  local actionId = actionData.UnLocakItemMap[item.configId]
  if not actionId then
    return
  end
  local emoteTableData = expressionVm.CheckIsUnlockByItemIdAndActionId(item.configId, actionId)
  if emoteTableData then
    ExpressionRed.AddNewRed(E.ItemType.ActionExpression, item.configId, emoteTableData.EmoteType)
  end
end

function ExpressionRed.addItemEvent()
  if not actionData then
    return
  end
  for configId, actionId in pairs(actionData.UnLocakItemMap) do
    Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, configId, ExpressionRed.changeItem)
  end
end

function ExpressionRed.removeItemEvent()
  if not actionData then
    return
  end
  for configId, actionId in pairs(actionData.UnLocakItemMap) do
    Z.ItemEventMgr.Remove(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, configId, ExpressionRed.changeItem)
  end
end

function ExpressionRed.Init()
  actionData = Z.DataMgr.Get("action_data")
  expressionVm = Z.VMMgr.GetVM("expression")
  ExpressionRed.addItemEvent()
  Z.EventMgr:Add(Z.ConstValue.SyncAllContainerData, ExpressionRed.addExpressionRed)
end

function ExpressionRed.UnInit()
  ExpressionRed.removeItemEvent()
  Z.EventMgr:Remove(Z.ConstValue.SyncAllContainerData, ExpressionRed.addExpressionRed)
end

return ExpressionRed
