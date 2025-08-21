local super = require("ui.component.loop_grid_view_item")
local ExpressionActionItem = class("ExpressionActionItem", super)

function ExpressionActionItem:ctor()
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.multActionVm_ = Z.VMMgr.GetVM("multaction")
end

function ExpressionActionItem:OnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.btn_bg.interactable = true
  self.isHighlighted_ = false
  self.parent.UIView:EventAddAsyncListener(self.uiBinder.btn_bg.OnLongPressEvent, function()
    self:setBtnLongPressFunc()
  end, nil, nil)
  self.parent.UIView:AddClick(self.uiBinder.btn_bg, function()
    self:onBtnClicked()
  end)
  self:OnNodeStateChange(function(state)
    self:onNodeStateChange(state)
  end)
end

function ExpressionActionItem:OnRefresh(data)
  self.data_ = data
  self:setLockState()
  self:SetCanSelect(self.data_.activeType == E.ExpressionState.Active)
  if data.tableData.Type == E.ExpressionType.Action then
    if data.UnlockItem and data.UnlockItem ~= 0 then
      Z.RedPointMgr.LoadRedDotItem(E.RedType.ExpressionMain .. E.ItemType.ActionExpression .. data.tableData.EmoteType .. data.UnlockItem, self.parent.UIView, self.uiBinder.Trans)
    end
    Z.GuideMgr:SetSteerIdByComp(self.uiBinder.camera_setting_action_item, E.DynamicSteerType.ExpressionId, data.tableData.Id)
    local cornerMark = data.tableData.CornerMark
    for i = 1, 3 do
      self.uiBinder.Ref:SetVisible(self.uiBinder["img_emoji_corner_" .. i], i == cornerMark)
    end
  else
    for i = 1, 3 do
      self.uiBinder.Ref:SetVisible(self.uiBinder["img_emoji_corner_" .. i], false)
    end
  end
  self.uiBinder.img_emoji:SetImage(data.tableData.Icon)
end

function ExpressionActionItem:OnUnInit()
  self.isHighlighted_ = false
end

function ExpressionActionItem:play(emoteCfg)
  local cfgId = emoteCfg.Id
  self.expressionData_:SetLogicExpressionType(emoteCfg.Type)
  self.expressionData_:SetCurPlayingId(cfgId)
  if emoteCfg.Type == E.ExpressionType.Action then
    self.expressionVM_.PlayAction(cfgId, true, true)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, cfgId)
  elseif emoteCfg.Type == E.ExpressionType.Emote then
    local emoteId = self.expressionVM_.FacialIdConversion(cfgId)
    if not emoteId then
      return
    end
    self.expressionVM_.PlayEmote(cfgId, emoteId, true, true)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickEmotion, cfgId)
  else
    self.multActionVm_.PlayMultAction(emoteCfg.Emote[2], self.parent.UIView.cancelSource)
  end
end

function ExpressionActionItem:setLockState()
  local isActive = self.data_.activeType == E.ExpressionState.Active
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock, not isActive)
  self.uiBinder.img_emoji.color.a = isActive and 1 or 0.2
  local deadVm = Z.VMMgr.GetVM("dead")
  local isDead = deadVm.CheckPlayerIsDead()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not isActive and not isDead)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, not isActive or isDead)
  self.uiBinder.btn_bg.interactable = not isDead
end

function ExpressionActionItem:setBtnLongPressFunc()
  if self.data_.activeType ~= E.ExpressionState.Active then
    return
  end
  local tipsState = E.ExpressionCommonTipsState.Add
  local isAdd = true
  local actionId = self.data_.tableData.Id
  local type = self.data_.tableData.Type
  if self.expressionVM_.CheckIsHadCommonData(type, actionId) then
    isAdd = false
    tipsState = E.ExpressionCommonTipsState.Remove
  end
  self.expressionData_:SetCommonTipsInfo(tipsState, type, actionId, isAdd)
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.ShowExpressionTipList, self.uiBinder.Trans)
end

function ExpressionActionItem:onBtnClicked()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local canPlayAction = self.expressionVM_.CanPlayActionCheck(stateId)
  local canUse = Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.ActorStateAction)
  if not canPlayAction or not canUse then
    Z.TipsVM.ShowTips(1000028)
    return
  end
  if self.data_.activeType == E.ExpressionState.Active then
    self:play(self.data_.tableData)
  else
    self.expressionVM_.InitExpressionItemData(self.data_, self.uiBinder.Trans, self.data_.tableData.Id)
    return
  end
end

function ExpressionActionItem:onNodeStateChange(state)
  if not Z.IsPCUI then
    return
  end
  if state == E.NodeState.Highlighted and not self.isHighlighted_ then
    self.expressionVM_.OpenTipsActionNamePopup(self.uiBinder.Trans, self.data_.tableData.Name)
    self.isHighlighted_ = true
  elseif self.isHighlighted_ then
    self.expressionVM_.CloseTipsActionNamePopup()
    self.isHighlighted_ = false
  end
end

return ExpressionActionItem
