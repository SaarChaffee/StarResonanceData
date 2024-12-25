local worldProxy_ = require("zproxy.world_proxy")
local expressionRed = require("rednode.expression_red")
local setItemSelected = function(data)
  local expressionData_ = Z.DataMgr.Get("expression_data")
  expressionData_:SetItemsSelectedData(data)
end
local setTabSelected = function(index)
  local expressionData_ = Z.DataMgr.Get("expression_data")
  if index == expressionData_.TabSelected then
    return
  end
  expressionData_.TabSelected = index
end
local refItemGroup = function()
  local expressionData_ = Z.DataMgr.Get("expression_data")
  expressionData_.IsRefTab = true
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.CloseTip)
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.Ref)
end
local getActionDataByActionId = function(id)
  if not id then
    return nil
  end
  local actionTableMgr = Z.TableMgr.GetTable("ActionTableMgr")
  local row = actionTableMgr.GetRow(id)
  return row
end
local openExpressionView = function(data)
  Z.UIMgr:OpenView("expression", data)
end
local closeExpressionView = function()
  if Z.UIMgr:IsActive("expression") then
    Z.UIMgr:CloseView("expression")
  end
end
local playAction = function(actionId, isSyncServer, isUpdateHistoryData)
  if not actionId then
    return
  end
  local expressionData_ = Z.DataMgr.Get("expression_data")
  isSyncServer = isSyncServer or false
  if isUpdateHistoryData then
    expressionData_:UpdateExpressionHistoryData(E.ExpressionType.Action, actionId)
  end
  Z.ZAnimActionPlayMgr:PlayAction(actionId, isSyncServer)
end
local playEmote = function(configId, emoteId, isSyncServer, isUpdateHistoryData)
  if not emoteId then
    return
  end
  isSyncServer = isSyncServer or false
  local expressionData_ = Z.DataMgr.Get("expression_data")
  if isUpdateHistoryData then
    expressionData_:UpdateExpressionHistoryData(E.ExpressionType.Emote, configId)
  end
  Z.ZAnimActionPlayMgr:PlayEmote(emoteId, isSyncServer)
end
local checkExpressionHistoryAndCommonData = function()
  local expressionData_ = Z.DataMgr.Get("expression_data")
  local count = 0
  if not expressionData_:GetExpressionCommonData(E.ExpressionType.Action) or not next(expressionData_:GetExpressionCommonData(E.ExpressionType.Action)) then
    count = count + 1
  end
  if not expressionData_:GetExpressionHistoryData() or not next(expressionData_:GetExpressionHistoryData()) then
    count = count + 1
  end
  return count < 2
end
local setOftenUseShowPieceList = function(pieceType, pieceId, isAdd)
  local cancelSource = Z.CancelSource.Rent()
  local ret = worldProxy_.SetOftenUseShowPieceList(pieceType, pieceId, isAdd, cancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
  cancelSource:Recycle()
end
local unlockShowPiece = function(pieceType, pieceId)
  if not pieceType or not pieceId then
    return
  end
  local cancelSource = Z.CancelSource.Rent()
  local ret = worldProxy_.UnlockShowPiece(pieceType, pieceId, cancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  cancelSource:Recycle()
  local expressionData_ = Z.DataMgr.Get("expression_data")
  local actionData = getActionDataByActionId(pieceId)
  if actionData and ret == 0 then
    local emoteData = expressionData_:GetEmoteDataByActionName(actionData.Id)
    if emoteData then
      expressionRed.RemoveRed(actionData.UnlockItem, emoteData.EmoteType)
    end
  end
  if expressionData_.tipsViewId then
    Z.TipsVM.CloseItemTipsView(expressionData_.tipsViewId)
    expressionData_.tipsViewId = nil
  end
  return ret
end
local getItemInfo = function(itemConfigId)
  if not itemConfigId then
    return
  end
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemsTableMgr.GetRow(itemConfigId)
  if itemTableData == nil then
    return nil
  end
  return itemTableData
end
local openExpressionItemTips = function(posTrans, showPieceId, pieceType)
  local actionData = getActionDataByActionId(showPieceId)
  if not actionData then
    return
  end
  local itemData = getItemInfo(actionData.UnlockItem)
  if not itemData then
    return
  end
  local itemVm = Z.VMMgr.GetVM("items")
  local enough = itemVm.GetItemTotalCount(actionData.UnlockItem) >= 1
  local viewData = {
    rect = posTrans,
    title = Lang("EmoteUnlockTitle"),
    content = Lang("EmoteUnlockDescription"),
    itemDataArray = {
      {
        ItemId = actionData.UnlockItem,
        ItemNum = 1
      }
    },
    btnContent = Lang("UnLock"),
    func = function()
      if not enough then
        return
      end
      Z.CoroUtil.create_coro_xpcall(function()
        unlockShowPiece(pieceType, showPieceId)
      end)()
    end,
    enabled = enough,
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_title_content_items_btn", viewData)
end
local closeTitleContentItemsBtn = function()
  Z.UIMgr:CloseView("tips_title_content_items_btn")
end
local initExpressionItemData = function(data, item, actionId)
  if not data or not item then
    return
  end
  local pieceType
  if data.tableData.Type == E.ExpressionType.Action then
    pieceType = data.tableData.Type
  else
    return
  end
  openExpressionItemTips(item.Trans, actionId, pieceType)
end
local checkCommonDataContainer = function(showPieceType, showPieceId)
  if not showPieceType or not showPieceId then
    return
  end
  local oftenUseTypeList = Z.ContainerMgr.CharSerialize.showPieceData.OftenUseTypeList
  if not oftenUseTypeList or not next(oftenUseTypeList) then
    return
  end
  if not oftenUseTypeList[showPieceType] or not oftenUseTypeList[showPieceType].pieceIds then
    return
  end
  return true
end
local checkIsUnlockByItemIdAndActionId = function(itemId, actionId)
  if itemId == nil then
    return nil
  end
  if actionId == nil then
    return nil
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  local count = itemsVm.GetItemTotalCount(itemId)
  if count == nil or count < 1 then
    return nil
  end
  local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
  local expressionData_ = Z.DataMgr.Get("expression_data")
  if not expressionData_:CheckActionIsUnlock(actionId) then
    return emoteTableMgr.GetRow(actionId)
  end
  return nil
end
local checkIsUnlockByItemId = function(itemId)
  if itemId == nil then
    return
  end
  local actionData = Z.DataMgr.Get("action_data")
  local actioId = actionData.UnLocakItemMap[itemId]
  if actioId == nil then
    return nil
  end
  return checkIsUnlockByItemIdAndActionId(itemId, actioId)
end
local addExpressionRed = function()
  local actionData = Z.DataMgr.Get("action_data")
  for itemId, actionId in pairs(actionData.UnLocakItemMap) do
    local emoteTableData = checkIsUnlockByItemIdAndActionId(itemId, actionId)
    if emoteTableData then
      expressionRed.AddNewRed(E.ItemType.ActionExpression, itemId, emoteTableData.EmoteType)
    end
  end
end
local checkIsHadCommonData = function(showPieceType, showPieceId)
  if not showPieceType or not showPieceId then
    return
  end
  if not checkCommonDataContainer(showPieceType, showPieceId) then
    return
  end
  local oftenUseTypeList = Z.ContainerMgr.CharSerialize.showPieceData.OftenUseTypeList
  for k, v in pairs(oftenUseTypeList[showPieceType].pieceIds) do
    if v == showPieceId then
      return true
    end
  end
  return false
end
local checkCommonDataLimit = function(showPieceType, showPieceId)
  if not showPieceType or not showPieceId then
    return
  end
  local commonDataMax = 1
  if not string.zisEmpty(Z.Global.FacialMaxCommonNum) then
    commonDataMax = tonumber(Z.Global.FacialMaxCommonNum)
  end
  if not checkCommonDataContainer(showPieceType, showPieceId) then
    return
  end
  local oftenUseTypeList = Z.ContainerMgr.CharSerialize.showPieceData.OftenUseTypeList
  if commonDataMax <= #oftenUseTypeList[showPieceType].pieceIds then
    return true
  end
  return false
end
local facialIdConversion = function(facialId)
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  if not facialId or not gender then
    return
  end
  local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
  local emoteCfg = emoteTableMgr.GetRow(facialId)
  local tempFacialId
  if emoteCfg then
    if gender == Z.PbEnum("EGender", "GenderMale") then
      tempFacialId = emoteCfg.FaceDataId[1]
    else
      tempFacialId = emoteCfg.FaceDataId[2]
    end
  end
  return tempFacialId
end
local getActionPerState = function(actionId, value)
  local expressionData = Z.DataMgr.Get("expression_data")
  local id = expressionData:GetCurPlayingId()
  local zActionAnimInfo = Z.ZAnimActionPlayMgr:GetActionAnimInfoByActionId(id)
  if zActionAnimInfo == nil then
    return 0
  end
  local gender = Z.ContainerMgr.CharSerialize.charBase.gender
  local totalTime = zActionAnimInfo:GetTotalTime(gender)
  return value * totalTime
end
local freezeFrameCtrl = function(modelData, id, timePer)
  if id == nil or id < 0 then
    return
  end
  local actionTime = timePer
  if 0 < timePer then
    actionTime = getActionPerState(id, timePer)
  end
  if modelData and modelData.ZModel then
    Z.ZAnimActionPlayMgr:SetActionPersistTime(modelData.ZModel, actionTime)
    return
  end
  Z.ZAnimActionPlayMgr:SetActionPersistTime(actionTime)
end
local assemblyActionData = function(emotcgf)
  local actionTempData = {}
  local actionId = emotcgf.Id
  if not actionId then
    return
  end
  local actionTableData = getActionDataByActionId(actionId)
  if not actionTableData then
    return
  end
  local expressionData = Z.DataMgr.Get("expression_data")
  if actionTableData.UnlockItem == 0 or expressionData:CheckActionIsUnlock(actionId) then
    actionTempData.activeType = E.ExpressionState.Active
  else
    actionTempData.activeType = E.ExpressionState.UnActive
  end
  actionTempData.UnlockItem = actionTableData.UnlockItem
  actionTempData.tableData = emotcgf
  return actionTempData
end
local setEmoteData = function(v, displayType)
  if v.EmoteType == displayType and v.IsShow ~= "0" then
    if v.Type == E.ExpressionType.Action then
      return assemblyActionData(v)
    else
      local emoteInfo = {}
      emoteInfo.activeType = E.ExpressionState.Active
      emoteInfo.tableData = v
      return emoteInfo
    end
  end
end
local getExpressionShowDataByType = function(displayType, isShowUnLock)
  if not displayType then
    return
  end
  local tableRowDatas = Z.TableMgr.GetTable("EmoteTableMgr").GetDatas()
  local ret = {}
  local index = 1
  for _, v in pairs(tableRowDatas) do
    local data = setEmoteData(v, displayType, isShowUnLock)
    local isCanInsert = true
    if data ~= nil and data.activeType == E.ExpressionState.UnActive and not isShowUnLock then
      isCanInsert = false
    end
    if isCanInsert then
      table.insert(ret, data)
      index = index + 1
    end
  end
  if 1 < index then
    table.sort(ret, function(left, right)
      if left.activeType ~= right.activeType then
        return left.activeType > right.activeType
      end
      if left.tableData.Id ~= right.tableData.Id then
        return left.tableData.Id < right.tableData.Id
      end
    end)
  end
  return ret
end
local displayTypeToLogicType = function(index)
  local result = E.ExpressionType.Action
  if index == E.DisplayExpressionType.CommonAction or index == E.DisplayExpressionType.LoopAction then
    result = E.ExpressionType.Action
  else
    result = E.ExpressionType.Emote
  end
  return result
end
local expressionSinglePlay = function(modelData)
  local expressionData = Z.DataMgr.Get("expression_data")
  local id = expressionData:GetCurPlayingId()
  if id ~= -1 then
    if expressionData:GetLogicExpressionType() == E.ExpressionType.Emote then
      id = facialIdConversion(id)
      if not id then
        return
      end
      if modelData and modelData.ZModel then
        Z.ZAnimActionPlayMgr:PlayEmote(modelData.ZModel, id, false)
        return
      end
      Z.ZAnimActionPlayMgr:PlayEmote(id, false)
    else
      if modelData and modelData.ZModel then
        Z.ZAnimActionPlayMgr:PlayAction(modelData.ZModel, id, false)
        return
      end
      Z.ZAnimActionPlayMgr:PlayAction(id, false)
    end
  end
end
local ret = {
  SetItemSelected = setItemSelected,
  SetTabSelected = setTabSelected,
  RefItemGroup = refItemGroup,
  OpenExpressionView = openExpressionView,
  CloseExpressionView = closeExpressionView,
  PlayAction = playAction,
  PlayEmote = playEmote,
  GetActionDataByActionId = getActionDataByActionId,
  CheckExpressionHistoryAndCommonData = checkExpressionHistoryAndCommonData,
  SetOftenUseShowPieceList = setOftenUseShowPieceList,
  UnlockShowPiece = unlockShowPiece,
  InitExpressionItemData = initExpressionItemData,
  CloseTitleContentItemsBtn = closeTitleContentItemsBtn,
  CheckIsHadCommonData = checkIsHadCommonData,
  CheckCommonDataLimit = checkCommonDataLimit,
  AddExpressionRed = addExpressionRed,
  FacialIdConversion = facialIdConversion,
  GetActionPerState = getActionPerState,
  FreezeFrameCtrl = freezeFrameCtrl,
  GetExpressionShowDataByType = getExpressionShowDataByType,
  DisplayTypeToLogicType = displayTypeToLogicType,
  CheckIsUnlockByItemId = checkIsUnlockByItemId,
  ExpressionSinglePlay = expressionSinglePlay,
  CheckIsUnlockByItemIdAndActionId = checkIsUnlockByItemIdAndActionId
}
return ret
