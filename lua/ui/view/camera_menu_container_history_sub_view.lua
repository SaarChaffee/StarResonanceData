local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_history_subView = class("Camera_menu_container_history_subView", super)
local itemViewType = {History = 1, Common = 2}

function Camera_menu_container_history_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_history_sub", "photograph/camera_menu_container_history_sub", UI.ECacheLv.None)
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.selectedItemWidget_ = nil
  self.pressEffectItem = nil
  self.camerasys_data = Z.DataMgr.Get("camerasys_data")
  self.actionData = Z.DataMgr.Get("action_data")
  self.historyItem_ = {}
  self.commonItem_ = {}
  self.lastPosition_ = nil
end

function Camera_menu_container_history_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initZWidget()
  self:bindWatcher()
  self:bindEvent()
  self:bindLuaAttrWatchers()
end

function Camera_menu_container_history_subView:OnDeActive()
  self.expressionData_:ClearCurPlayData()
  self:cancelSelect(false)
  self.lastPosition_ = nil
  if self.onOftenUseTypeListChange then
    Z.ContainerMgr.CharSerialize.showPieceData.Watcher:UnregWatcher(self.onOftenUseTypeListChange)
    self.onOftenUseTypeListChange = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Expression.ExpressionHistoryDataUpdate, self.initHistoryLayout, self)
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
end

function Camera_menu_container_history_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Expression.ExpressionHistoryDataUpdate, self.initHistoryLayout, self)
end

function Camera_menu_container_history_subView:bindWatcher()
  function self.onOftenUseTypeListChange(container, dirty)
    self:initCommonLayout()
  end
  
  local oftenUseTypeList = Z.ContainerMgr.CharSerialize.showPieceData
  oftenUseTypeList.Watcher:RegWatcher(self.onOftenUseTypeListChange)
end

function Camera_menu_container_history_subView:OnRefresh()
  self:initCommonLayout()
  self:initHistoryLayout()
end

function Camera_menu_container_history_subView:initZWidget()
  self.historyLayout_ = self.uiBinder.layout_active_history
  self.commonLayout_ = self.uiBinder.layout_active_common
  self.historyNode_ = self.uiBinder.node_active_history
  self.commonNode_ = self.uiBinder.node_active_common
  self.emptyCommonNode_ = self.uiBinder.node_empty_common
  self.emptyHistoryNode_ = self.uiBinder.node_empty_history
end

function Camera_menu_container_history_subView:removeUnit(layoutType)
  local itemList
  if layoutType == itemViewType.History then
    itemList = self.historyItem_
  else
    itemList = self.commonItem_
  end
  if itemList then
    for _, v in pairs(itemList) do
      self:RemoveUiUnit(v)
    end
    itemList = {}
  end
end

function Camera_menu_container_history_subView:initCommonLayout()
  local commonData = self.expressionData_:GetExpressionCommonData(E.ExpressionType.Action)
  self:removeUnit(itemViewType.Common)
  if not commonData then
    self.uiBinder.Ref:SetVisible(self.emptyCommonNode_, true)
    return
  end
  self.uiBinder.Ref:SetVisible(self.emptyCommonNode_, false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:createItem(commonData, self.commonLayout_, self.commonNode_, "common", itemViewType.Common, self.commonItem_)
  end)()
end

function Camera_menu_container_history_subView:initHistoryLayout()
  local historyData = self.expressionData_:GetExpressionHistoryData()
  self:removeUnit(itemViewType.History)
  if not historyData then
    self.uiBinder.Ref:SetVisible(self.emptyHistoryNode_, true)
    return
  end
  self.uiBinder.Ref:SetVisible(self.emptyHistoryNode_, false)
  Z.CoroUtil.create_coro_xpcall(function()
    self:createItem(historyData, self.historyLayout_, self.historyNode_, "history", itemViewType.History, self.historyItem_)
  end)()
end

function Camera_menu_container_history_subView:createItem(listData, layoutNode, transNode, nameSuffix, itemType, itemList)
  if listData and next(listData) then
    local itemPath = self.uiBinder.prefabCache:GetString("settingActionItemPath")
    for k, v in pairs(listData) do
      local name = string.format("%s%s", nameSuffix, k)
      table.insert(itemList, name)
      local item = self:AsyncLoadUiUnit(itemPath, name, transNode)
      self:setItemData(item, v, itemType)
    end
  end
  layoutNode:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_history_subView:setItemData(item, showPieceData, itemType)
  if not item or not showPieceData then
    return
  end
  item.Ref:SetVisible(item.img_lock, false)
  for i = 1, 3 do
    item.Ref:SetVisible(item["img_emoji_corner_" .. i], false)
  end
  item.Ref:SetVisible(item.img_select, false)
  local data, iconKey
  local pieceId = type(showPieceData) == "number" and showPieceData or showPieceData.Id
  if type(showPieceData) == "number" or showPieceData.Type == E.ExpressionType.Action then
    data = self.expressionVm_.GetActionDataByActionId(pieceId)
    iconKey = data.Id
  else
    iconKey = pieceId
    data = self.expressionData_:GetEmoteDataByActionName(iconKey)
  end
  if not iconKey then
    return
  end
  local emoteCfg = self.expressionData_:GetEmoteDataByActionName(iconKey)
  if not emoteCfg then
    return
  end
  self:setItemPress(item, emoteCfg, showPieceData, itemType)
  local itemBgPath = self.uiBinder.prefabCache:GetString("itemBgPath")
  item.img_emoji:SetImage(emoteCfg.Icon)
  local originalColor = Color.New(item.img_emoji.color.r, item.img_emoji.color.g, item.img_emoji.color.b, 1)
  item.img_emoji:SetColor(originalColor)
  local cornerMark = emoteCfg.CornerMark
  for i = 1, 3 do
    item.Ref:SetVisible(item["img_emoji_corner_" .. i], i == cornerMark)
  end
  item.Ref:SetVisible(item.img_btn_emoji_bg, true)
  item.img_btn_emoji_bg:SetImage(string.format("%s%s", itemBgPath, "_off"))
end

function Camera_menu_container_history_subView:setItemPress(item, data, actionId, itemType)
  self:AddClick(item.btn_select, function()
    if Z.EntityMgr.PlayerEnt == nil then
      logError("PlayerEnt is nil")
      return
    end
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    local canPlayAction = self.expressionVm_.CanPlayActionCheck(stateId)
    if not canPlayAction then
      item.Ref:SetVisible(item.img_select, false)
      Z.TipsVM.ShowTips(1000028)
      return
    end
    local isVisible = item.Ref:GetUIComp(item.img_select).IsVisible
    if not isVisible then
      if self.selectedItemWidget_ then
        self.selectedItemWidget_.Ref:SetVisible(self.selectedItemWidget_.img_select, false)
      end
      self.selectedItemWidget_ = item
      self:onPlayAction(actionId, item, itemType)
      self.expressionVm_.OpenTipsActionNamePopup(item.Trans, data.Name)
    else
      item.Ref:SetVisible(item.img_select, false)
    end
  end)
  item.btn_select.OnLongPressEvent:RemoveAllListeners()
  if itemType == itemViewType.Common then
    self:EventAddAsyncListener(item.btn_select.OnLongPressEvent, function()
      self.expressionData_:SetCommonTipsInfo(E.ExpressionCommonTipsState.Remove, E.ExpressionType.Action, actionId, false)
      Z.EventMgr:Dispatch(Z.ConstValue.Expression.ShowExpressionTipList, item.Trans)
    end, nil, nil)
  end
end

function Camera_menu_container_history_subView:onPlayAction(showPieceData, item, itemType)
  self.expressionClickTag_ = true
  local isUpdateHistoryData = itemType == itemViewType.Common
  local showPieceId = type(showPieceData) == "number" and showPieceData or showPieceData.Id
  if type(showPieceData) == "number" or showPieceData.Type == E.ExpressionType.Action then
    self.expressionVm_.PlayAction(showPieceId, true, isUpdateHistoryData)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, showPieceId)
  else
    local emoteId = self.expressionVm_.FacialIdConversion(showPieceId)
    if not showPieceId then
      return
    end
    self.expressionVm_.PlayEmote(showPieceId, emoteId, true, isUpdateHistoryData)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickEmotion, showPieceId)
  end
end

function Camera_menu_container_history_subView:bindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerPosWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnAttrVirtualPosChanged(function()
      self:updatePosEvent()
    end)
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      self:onPlayerStateChange()
    end)
  end
end

function Camera_menu_container_history_subView:updatePosEvent()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local currentPosition = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
  if not self.lastPosition_ then
    self.lastPosition_ = currentPosition
    return
  end
  if self.lastPosition_ ~= currentPosition then
    if self.selectedItemWidget_ then
      self.selectedItemWidget_.Ref:SetVisible(self.selectedItemWidget_.img_select, false)
      self.selectedItemWidget_ = nil
    end
    self.expressionClickTag_ = false
    self:btnReset()
  end
end

function Camera_menu_container_history_subView:onPlayerStateChange()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if stateId ~= Z.PbEnum("EActorState", "ActorStateDefault") and stateId ~= Z.PbEnum("EActorState", "ActorStateAction") then
    if not self.expressionClickTag_ and self.selectedItemWidget_ then
      self.selectedItemWidget_.Ref:SetVisible(self.selectedItemWidget_.img_select, false)
      self.selectedItemWidget_ = nil
    end
    self.expressionClickTag_ = false
  end
end

function Camera_menu_container_history_subView:btnReset()
  local curExpressionTableRow = self.expressionData_:GetCurPlayingEmotTableRow()
  if not curExpressionTableRow then
    return
  end
  if curExpressionTableRow.Type == E.ExpressionType.Action then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ActionReset)
  end
  self.expressionData_:SetCurPlayingId(-1)
  self:cancelSelect(false)
end

function Camera_menu_container_history_subView:cancelSelect(isShow)
  if not isShow and self.selectedItemWidget_ then
    self.selectedItemWidget_.Ref:SetVisible(self.selectedItemWidget_.img_select, false)
    self.selectedItemWidget_ = nil
  end
end

return Camera_menu_container_history_subView
