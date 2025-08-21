local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_actionView = class("Camera_menu_container_actionView", super)
local camerasys_data = Z.DataMgr.Get("camerasys_data")

function Camera_menu_container_actionView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_action_sub", "photograph/camera_menu_container_action_sub", UI.ECacheLv.None)
  self.selectedTog_ = nil
  self.pressEffectItem = nil
  self.expressionClickTag_ = false
  self.parent_ = parent
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.multActionVm_ = Z.VMMgr.GetVM("multaction")
  self.viewData = nil
  self.itemData_ = {}
end

function Camera_menu_container_actionView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:initUi()
end

function Camera_menu_container_actionView:initUi()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reset, self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera)
  self:AddClick(self.uiBinder.btn_reset, function()
    self:btnReset()
  end)
end

function Camera_menu_container_actionView:btnReset(isNotResetEmote)
  self.expressionData_:SetCurPlayingId(-1)
  local logicExpressionType = self.expressionData_:GetLogicExpressionType()
  if logicExpressionType == E.ExpressionType.Action then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ActionReset, self.viewData)
  elseif not isNotResetEmote then
    if self.viewData.ZModel then
      Z.ZAnimActionPlayMgr:ResetEmote(self.viewData.ZModel)
    else
      Z.ZAnimActionPlayMgr:ResetEmote()
    end
  end
  self:cancelSelect(false)
end

function Camera_menu_container_actionView:initEmoteData()
  local displayExpressionType = self.expressionData_:GetDisplayExpressionType()
  local isShowUnlockItem = self.viewData.OpenSourceType == E.ExpressionOpenSourceType.Expression
  local itemList = self.expressionVm_.GetExpressionShowDataByType(displayExpressionType, isShowUnlockItem)
  self.uiBinder.layout_center.AllowSwitchOff = true
  local togData = self.expressionData_:GetTabTableData()
  if not togData or not next(togData) then
    return
  end
  self.uiBinder.lab_name.text = togData[displayExpressionType + 1].name
  return itemList
end

function Camera_menu_container_actionView:UpdateListItem()
  local itemList
  itemList = self:initEmoteData()
  if not itemList then
    return
  end
  self:removeUnit()
  Z.CoroUtil.create_coro_xpcall(function()
    self:createItem(itemList)
  end)()
end

function Camera_menu_container_actionView:removeUnit()
  self:ClearAllUnits()
end

function Camera_menu_container_actionView:cancelSelect(isShow)
  if not isShow and self.selectedTog_ then
    self.selectedTog_ = nil
  end
end

function Camera_menu_container_actionView:createItem(activeDates)
  if activeDates and next(activeDates) then
    local itemPath = self.uiBinder.prefabCache:GetString("settingActionItemPath")
    for k, v in pairs(activeDates) do
      self:loadShowPieceUnit(k, v, itemPath)
    end
  end
  self.uiBinder.layout_active:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_actionView:loadShowPieceUnit(index, emoteData, itemPath)
  if self.viewData == E.ExpressionOpenSourceType.Camera and emoteData.activeType ~= E.ExpressionState.Active then
    return
  end
  local name = string.format("active%s", index)
  local item = self:AsyncLoadUiUnit(itemPath, name, self.uiBinder.node_active)
  self:setItemData(item, emoteData, name)
end

function Camera_menu_container_actionView:setItemData(item, data, name)
  item.Ref:SetVisible(item.img_lock, false)
  item.Ref:SetVisible(item.img_btn_emoji_bg, true)
  item.Ref:SetVisible(item.img_select, false)
  local actionId = data.tableData.Id
  if data.tableData.Type == E.ExpressionType.Action then
    if data.UnlockItem and data.UnlockItem ~= 0 then
      Z.RedPointMgr.LoadRedDotItem(E.RedType.ExpressionMain .. E.ItemType.ActionExpression .. data.tableData.EmoteType .. data.UnlockItem, self, item.Trans)
    end
    Z.GuideMgr:SetSteerIdByComp(item.camera_setting_action_item, E.DynamicSteerType.ExpressionId, actionId)
  end
  self:setTogPress(item, data, actionId)
  local itemBgPath = self.uiBinder.prefabCache:GetString("itemBgPath")
  local isActive = "_off"
  if data.activeType ~= E.ExpressionState.Active then
    isActive = "_off"
    item.Ref:SetVisible(item.img_lock, true)
    item.Ref:SetVisible(item.img_btn_emoji_bg, false)
    self:changeItemAlpha(item, 0.2)
  else
    self:changeItemAlpha(item, 1)
  end
  item.img_emoji:SetImage(data.tableData.Icon)
  if data.tableData.Type == E.ExpressionType.Action then
    local cornerMark = data.tableData.CornerMark
    for i = 1, 3 do
      item.Ref:SetVisible(item["img_emoji_corner_" .. i], i == cornerMark)
    end
  else
    for i = 1, 3 do
      item.Ref:SetVisible(item["img_emoji_corner_" .. i], false)
    end
  end
  item.img_btn_emoji_bg:SetImage(string.format("%s%s", itemBgPath, isActive))
end

function Camera_menu_container_actionView:changeItemAlpha(item, alphaValue)
  if not item or not alphaValue then
    return
  end
  item.img_emoji:SetColor(Color.New(item.img_emoji.color.r, item.img_emoji.color.g, item.img_emoji.color.b, alphaValue))
end

function Camera_menu_container_actionView:setTogPress(item, data, actionId)
  self:AddClick(item.btn_select, function()
    if Z.EntityMgr.PlayerEnt then
      local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
      local canPlayAction = self.expressionVm_.CanPlayActionCheck(stateId)
      local canUse = Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.ActorStateAction)
      if not canPlayAction or not canUse then
        Z.TipsVM.ShowTips(1000028)
        return
      end
    end
    self.selectedTog_ = item
    if data.activeType == E.ExpressionState.Active then
      self:play(data.tableData)
      self.expressionVm_.OpenTipsActionNamePopup(item.Trans, data.tableData.Name)
    else
      self.expressionVm_.InitExpressionItemData(data, item.Trans, actionId)
    end
  end)
  item.btn_select.OnLongPressEvent:RemoveAllListeners()
  if data.activeType == E.ExpressionState.Active and data.tableData.Type == E.ExpressionType.Action then
    self:EventAddAsyncListener(item.btn_select.OnLongPressEvent, function()
      local tipsState = E.ExpressionCommonTipsState.Add
      local isAdd = true
      if self.expressionVm_.CheckIsHadCommonData(data.tableData.Type, actionId) then
        isAdd = false
        tipsState = E.ExpressionCommonTipsState.Remove
      end
      self.expressionData_:SetCommonTipsInfo(tipsState, data.tableData.Type, actionId, isAdd)
      Z.EventMgr:Dispatch(Z.ConstValue.Expression.ShowExpressionTipList, item.Trans)
    end, nil, nil)
  end
end

function Camera_menu_container_actionView:play(emoteCfg)
  local expressionData = Z.DataMgr.Get("expression_data")
  local sourceType = self.viewData.OpenSourceType
  local cfgId = emoteCfg.Id
  expressionData:SetCurPlayingId(cfgId)
  if sourceType == E.ExpressionOpenSourceType.Camera then
    if emoteCfg.Type == E.ExpressionType.Action then
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
    end
    local isShowSlider = false
    if emoteCfg.Type ~= E.ExpressionType.Emote then
      isShowSlider = true
    end
    self.expressionVm_.ExpressionSinglePlay(self.viewData)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ExpressionPlaySlider, isShowSlider)
    self.parent_.uiBinder.Ref:SetVisible(self.parent_.uiBinder.node_action_slider_container, isShowSlider)
  elseif sourceType == E.ExpressionOpenSourceType.Expression then
    if emoteCfg.Type == E.ExpressionType.Action then
      self.expressionClickTag_ = true
      self.expressionVm_.PlayAction(cfgId, true, true)
      Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, cfgId)
    elseif emoteCfg.Type == E.ExpressionType.Emote then
      local emoteId = self.expressionVm_.FacialIdConversion(cfgId)
      if not emoteId then
        return
      end
      self.expressionVm_.PlayEmote(cfgId, emoteId, true, true)
      Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickEmotion, cfgId)
    else
      self.multActionVm_.PlayMultAction(emoteCfg.Emote[2], self.cancelSource)
    end
  end
end

function Camera_menu_container_actionView:OnDeActive()
  self.selectedTog_ = nil
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:UnregWatcher(self.unlockTypeListChange)
  self.unlockTypeListChange = nil
  self.playerPosWatcher = nil
  self:btnReset(true)
  self.expressionVm_.CloseTitleContentItemsBtn()
end

function Camera_menu_container_actionView:RestSelectedTog()
  self.selectedTog_ = nil
end

function Camera_menu_container_actionView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.SetActionSliderHide, self.setActionSliderVisible, self)
end

function Camera_menu_container_actionView:setActionSliderVisible(isShow)
  if not self.parent_ or self.viewData ~= E.ExpressionOpenSourceType.Camera then
    return
  end
  if not self.selectedTog_ or self.expressionData_:GetLogicExpressionType() ~= E.ExpressionType.Action or not self.uiBinder.Ref.UIComp.IsVisible then
    return
  end
  self.parent_.uiBinder.Ref:SetVisible(self.parent_.uiBinder.node_action_slider_container, isShow)
end

function Camera_menu_container_actionView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerPosWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnAttrVirtualPosChanged(function()
      self:updatePosEvent()
    end)
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      self:onPlayerStateChange()
    end)
  end
  
  function self.unlockTypeListChange(container, dirty)
    if dirty.unlockTypeList and self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
      self:UpdateListItem()
    end
  end
  
  Z.ContainerMgr.CharSerialize.showPieceData.Watcher:RegWatcher(self.unlockTypeListChange)
end

function Camera_menu_container_actionView:updatePosEvent()
  if self.selectedTog_ then
    self.selectedTog_ = nil
  end
  self.expressionClickTag_ = false
  if self.selectedTog_ then
    self:btnReset(true)
  end
end

function Camera_menu_container_actionView:onPlayerStateChange()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if stateId ~= Z.PbEnum("EActorState", "ActorStateDefault") and stateId ~= Z.PbEnum("EActorState", "ActorStateAction") then
    if not self.expressionClickTag_ and self.selectedTog_ then
      self.selectedTog_ = nil
    end
    self.expressionClickTag_ = false
  end
end

function Camera_menu_container_actionView:OnRefresh()
  self.togs_ = {}
  self:UpdateListItem()
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action and not camerasys_data.IsDecorateAddViewSliderShow and self.expressionData_:GetCurPlayingEmotTableRow() ~= nil then
    self.parent_.uiBinder.Ref:SetVisible(self.parent_.uiBinder.node_action_slider_container, true)
  end
end

return Camera_menu_container_actionView
