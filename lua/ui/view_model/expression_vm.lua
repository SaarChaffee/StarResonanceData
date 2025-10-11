local worldProxy_ = require("zproxy.world_proxy")
local expressionRed = require("rednode.expression_red")
local INPUT_EXPRESSION_SOLT_MAP = {
  [Z.InputActionIds.ExpressionUse1] = 1,
  [Z.InputActionIds.ExpressionUse2] = 2,
  [Z.InputActionIds.ExpressionUse3] = 3,
  [Z.InputActionIds.ExpressionUse4] = 4,
  [Z.InputActionIds.ExpressionUse5] = 5,
  [Z.InputActionIds.ExpressionUse6] = 6,
  [Z.InputActionIds.ExpressionUse7] = 7,
  [Z.InputActionIds.ExpressionUse8] = 8
}
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
local canPlayActionCheck = function(stateId)
  if stateId ~= Z.PbEnum("EActorState", "ActorStateDefault") and stateId ~= Z.PbEnum("EActorState", "ActorStateAction") and stateId ~= Z.PbEnum("EActorState", "ActorStateInteraction") and stateId ~= Z.PbEnum("EActorState", "ActorStateSelfPhoto") and stateId ~= Z.PbEnum("EActorState", "ActorStateRide") and stateId ~= Z.PbEnum("EActorState", "ActorStateRideControl") then
    return false
  end
  return true
end
local playAction = function(actionId, isSyncServer, isUpdateHistoryData)
  if not actionId then
    return
  end
  local expressionData_ = Z.DataMgr.Get("expression_data")
  isSyncServer = isSyncServer or false
  local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
  local tableRow = emoteTableMgr.GetRow(actionId)
  if not tableRow then
    return
  end
  if isUpdateHistoryData then
    expressionData_:UpdateExpressionHistoryData(E.ExpressionType.Action, actionId)
  end
  local fishingData = Z.DataMgr.Get("fishing_data")
  local fishSize = 0
  local accessoryId = 0
  if tableRow.Accessory[1] == E.ActionAccessory.Fish then
    fishSize = fishingData:GetCurActionSize()
    accessoryId = fishingData:GetActionFishId()
  elseif tableRow.Accessory[1] == E.ActionAccessory.Pendant then
    accessoryId = tableRow.Accessory[2]
  end
  Z.ZAnimActionPlayMgr:PlayAction(actionId, isSyncServer, 0, -1, false, 0, false, false, accessoryId, fishSize)
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
  local errCode = worldProxy_.SetOftenUseShowPieceList(pieceType, pieceId, isAdd, cancelSource:CreateToken())
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
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
local openExpressionItemTips = function(posTrans, showPieceId, pieceType, emoteData)
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
    title = emoteData.tableData.Name,
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
        Z.TipsVM.ShowTipsLang(100002)
        return
      end
      Z.CoroUtil.create_coro_xpcall(function()
        unlockShowPiece(pieceType, showPieceId)
      end)()
    end,
    enabled = true,
    isRightFirst = false,
    isCenter = false
  }
  Z.UIMgr:OpenView("tips_title_content_items_btn", viewData)
end
local closeTitleContentItemsBtn = function()
  Z.UIMgr:CloseView("tips_title_content_items_btn")
end
local initExpressionItemData = function(data, itemTrans, actionId)
  if not data or not itemTrans then
    return
  end
  local pieceType
  if data.tableData.Type == E.ExpressionType.Action then
    pieceType = data.tableData.Type
  else
    return
  end
  openExpressionItemTips(itemTrans, actionId, pieceType, data)
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
  local cameraData = Z.DataMgr.Get("camerasys_data")
  local gender = cameraData:GetGender()
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
  local zActionAnimInfo = Z.ZAnimActionPlayMgr:GetActionAnimInfoByActionId(actionId)
  if zActionAnimInfo == nil then
    return 0
  end
  local cameraData = Z.DataMgr.Get("camerasys_data")
  local gender = cameraData:GetGender()
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
local setEmoteData = function(v, displayType, allAction)
  local typeMatch = v.EmoteType == displayType
  if allAction then
    typeMatch = v.EmoteType == E.DisplayExpressionType.LoopAction or v.EmoteType == E.DisplayExpressionType.CommonAction or v.EmoteType == E.DisplayExpressionType.MultAction or v.EmoteType == E.DisplayExpressionType.FishingAction
  end
  if typeMatch and v.IsShow ~= "0" then
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
local getExpressionShowDataByType = function(displayType, isShowUnLock, allAction)
  if not displayType then
    return
  end
  local tableRowDatas = Z.TableMgr.GetTable("EmoteTableMgr").GetDatas()
  local ret = {}
  local index = 1
  for _, v in pairs(tableRowDatas) do
    local data = setEmoteData(v, displayType, allAction)
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
  if index == E.DisplayExpressionType.CommonAction or index == E.DisplayExpressionType.LoopAction or index == E.DisplayExpressionType.FishingAction then
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
    local emoteTableMgr = Z.TableMgr.GetTable("EmoteTableMgr")
    local tableRow = emoteTableMgr.GetRow(id)
    if not tableRow then
      return
    end
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
      local fishingData = Z.DataMgr.Get("fishing_data")
      local accessoryId = 0
      local fishSize = 0
      if tableRow.Accessory[1] == E.ActionAccessory.Fish then
        fishSize = fishingData:GetCurActionSize()
        accessoryId = fishingData:GetActionFishId()
      elseif tableRow.Accessory[1] == E.ActionAccessory.Pendant then
        accessoryId = tableRow.Accessory[2]
      end
      if modelData and modelData.ZModel then
        Z.ZAnimActionPlayMgr:PlayAction(modelData.ZModel, id, false, 0, -1, true, 0, false, true, accessoryId, fishSize)
        return
      end
      Z.ZAnimActionPlayMgr:PlayAction(id, false, 0, -1, false, 0, false, true, accessoryId, fishSize)
    end
  end
end
local openExpressionFastWindow = function()
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.CheckFuncCanUse(E.FunctionID.Performace, false) then
    return
  end
  if not funcVM.CheckFuncCanUse(E.FunctionID.ChatExpressionFast, true) then
    return
  end
  if not Z.UIMgr:CheckMainUIActionLimit(Z.InputActionIds.ExpressionFast) then
    return
  end
  if Z.IsPCUI then
    Z.UIMgr:OpenView("expression_fast_window_pc")
  else
    Z.UIMgr:OpenView("expression_fast_window")
  end
end
local closeExpressionFastWindow = function()
  if Z.IsPCUI then
    Z.UIMgr:CloseView("expression_fast_window_pc")
  else
    Z.UIMgr:CloseView("expression_fast_window")
  end
end
local openExpressionWheelSettingView = function()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ChatExpressionFast)
  if not isOn then
    return
  end
  if Z.IsPCUI then
    Z.UIMgr:OpenView("expression_wheel_setting_window_pc")
  else
    Z.UIMgr:OpenView("expression_wheel_setting_window")
  end
end
local closeExpressionWheelSettingView = function()
  if Z.IsPCUI then
    Z.UIMgr:CloseView("expression_wheel_setting_window_pc")
  else
    Z.UIMgr:CloseView("expression_wheel_setting_window")
  end
end
local quickUseExpressionEmoji = function(slotData)
  local wheelData = Z.DataMgr.Get("wheel_data")
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  chatMainVm.AsyncSendMessage(E.ChatChannelType.EChannelScene, nil, "", E.ChitChatMsgType.EChatMsgPictureEmoji, slotData.Id, wheelData.CancelSource:CreateToken())
end
local quickUseExpressionAction = function(slotData)
  local wheelData = Z.DataMgr.Get("wheel_data")
  if slotData.tableData.Type == 1 then
    playAction(slotData.tableData.Id, true, true)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, slotData.tableData.Id)
  elseif slotData.tableData.Type == 3 then
    local multActionVm = Z.VMMgr.GetVM("multaction")
    multActionVm.PlayMultAction(slotData.tableData.Emote[2], wheelData.CancelSource)
  end
end
local quickUseExpressionMessage = function(slotData)
  local wheelData = Z.DataMgr.Get("wheel_data")
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  chatMainVm.AsyncSendMessage(E.ChatChannelType.EChannelScene, nil, "", E.ChitChatMsgType.EChatMsgPictureEmoji, slotData.Id, wheelData.CancelSource:CreateToken())
end
local quickUseExpressionTransporter = function(slotData)
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneRow_ = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local mapVM = Z.VMMgr.GetVM("map")
  if sceneRow_.SceneSubType ~= E.SceneSubType.Dungeon and sceneRow_.SceneSubType ~= E.SceneSubType.Mirror then
    mapVM.CheckTeleport(function()
      mapVM.AsyncUserTp(slotData.MapId, slotData.Id)
    end)
  else
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescLeaveDungeon"), function()
      mapVM.CheckTeleport(function()
        mapVM.AsyncUserTp(slotData.MapId, slotData.Id)
      end)
    end)
  end
end
local quickUseExpression = function(index)
  local wheelData = Z.DataMgr.Get("wheel_data")
  local curWheelPage = wheelData:GetWheelPage()
  local list = wheelData:GetWheelList(curWheelPage)
  local data = list[index]
  if not data or data.type == 0 then
    return
  end
  local expressionData = Z.DataMgr.Get("expression_data")
  local lastTime = expressionData:GetQuickUseTime()
  local isCD = lastTime ~= 0 and (Z.TimeTools.Now() - lastTime) / 1000 < Z.Global.UseWheelExpressionCD
  if isCD then
    Z.TipsVM.ShowTipsLang(1000108)
    return
  end
  expressionData:SetQuickUseTime(Z.TimeTools.Now())
  if data.type == E.ExpressionSettingType.Emoji then
    local slotData = wheelData:GetDataByTypeAndId(data.type, data.id)
    quickUseExpressionEmoji(slotData)
  elseif data.type == E.ExpressionSettingType.AllAction then
    local slotData = wheelData:GetDataByTypeAndId(data.type, data.id)
    quickUseExpressionAction(slotData)
  elseif data.type == E.ExpressionSettingType.QuickMessage then
    local slotData = wheelData:GetDataByTypeAndId(data.type, data.id)
    quickUseExpressionMessage(slotData)
  elseif data.type == E.ExpressionSettingType.Transporter then
    local slotData = wheelData:GetDataByTypeAndId(data.type, data.id)
    quickUseExpressionTransporter(slotData)
  elseif data.type == E.ExpressionSettingType.UseItem then
    local itemsVm = Z.VMMgr.GetVM("items")
    itemsVm.AsyncUseItemByConfigId(data.id, wheelData.CancelSource:CreateToken(), 1)
  end
end
local quickUseExpressionByInput = function(inputActionId)
  local param = INPUT_EXPRESSION_SOLT_MAP[inputActionId]
  if param then
    quickUseExpression(param)
  end
end
local setExpressionTargetFinish = function()
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.TargetShortcutKeySetting)
end
local closeTipsActionNamePopup = function()
  Z.UIMgr:CloseView("tips_action_name_popup")
end
local openTipsActionNamePopup = function(posTrans, name)
  if string.zisEmpty(name) then
    return
  end
  local viewData = {
    rect = posTrans,
    title = name,
    enabled = true,
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_action_name_popup", viewData)
end
local ret = {
  SetItemSelected = setItemSelected,
  SetTabSelected = setTabSelected,
  RefItemGroup = refItemGroup,
  OpenExpressionView = openExpressionView,
  CloseExpressionView = closeExpressionView,
  CanPlayActionCheck = canPlayActionCheck,
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
  CheckIsUnlockByItemIdAndActionId = checkIsUnlockByItemIdAndActionId,
  OpenExpressionFastWindow = openExpressionFastWindow,
  CloseExpressionFastWindow = closeExpressionFastWindow,
  OpenExpressionWheelSettingView = openExpressionWheelSettingView,
  CloseExpressionWheelSettingView = closeExpressionWheelSettingView,
  QuickUseExpression = quickUseExpression,
  QuickUseExpressionByInput = quickUseExpressionByInput,
  SetExpressionTargetFinish = setExpressionTargetFinish,
  OpenTipsActionNamePopup = openTipsActionNamePopup,
  CloseTipsActionNamePopup = closeTipsActionNamePopup
}
return ret
