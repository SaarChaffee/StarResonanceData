local super = require("ui.component.loop_grid_view_item")
local CameraSettingActionItem = class("CameraSettingActionItem", super)

function CameraSettingActionItem:ctor()
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
end

function CameraSettingActionItem:OnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_emoji_bg, true)
  self.parent.UIView:AddClick(self.uiBinder.btn_select, function()
    self:onBtnClicked()
  end)
  self.parent.UIView:EventAddAsyncListener(self.uiBinder.btn_select.OnLongPressEvent, function()
    self:onSelectedLongPress()
  end, nil, nil)
end

function CameraSettingActionItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_emoji:SetImage(data.tableData.Icon)
  self:setLockState()
  self:SetCanSelect(self.data_.activeType == E.ExpressionState.Active)
  if data.tableData.Type == E.ExpressionType.Action then
    local cornerMark = data.tableData.CornerMark
    for i = 1, 3 do
      self.uiBinder.Ref:SetVisible(self.uiBinder["img_emoji_corner_" .. i], i == cornerMark)
    end
  else
    for i = 1, 3 do
      self.uiBinder.Ref:SetVisible(self.uiBinder["img_emoji_corner_" .. i], false)
    end
  end
end

function CameraSettingActionItem:OnSelected(isSelected, isClick)
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    self.parent:ClearAllSelect()
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local canPlayAction = self.expressionVM_.CanPlayActionCheck(stateId)
  if not canPlayAction then
    self.parent:ClearAllSelect()
    Z.TipsVM.ShowTips(1000028)
    return
  end
end

function CameraSettingActionItem:OnUnInit()
end

function CameraSettingActionItem:onSelectedLongPress()
  local viewData = self.parent.UIView.viewData
  if not (self.data_ and viewData) or viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera or self.data_.activeType ~= E.ExpressionState.Active then
    return
  end
  local tipsState = E.ExpressionCommonTipsState.Add
  local isAdd = true
  if self.expressionVM_.CheckIsHadCommonData(self.data_.tableData.Type, self.data_.tableData.Id) then
    isAdd = false
    tipsState = E.ExpressionCommonTipsState.Remove
  end
  self.expressionData_:SetCommonTipsInfo(tipsState, self.data_.tableData.Type, self.data_.tableData.Id, isAdd)
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.ShowExpressionTipList, self.uiBinder.Trans)
end

function CameraSettingActionItem:onBtnClicked()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local canPlayAction = self.expressionVM_.CanPlayActionCheck(stateId)
  if not canPlayAction then
    Z.TipsVM.ShowTips(1000028)
    return
  end
  if self.data_.activeType == E.ExpressionState.Active then
    self.parent:SetSelected(self.Index)
    self:play(self.data_.tableData)
    self.expressionVM_.OpenTipsActionNamePopup(self.uiBinder.Trans, self.data_.tableData.Name)
  else
    self.expressionVM_.InitExpressionItemData(self.data_, self.uiBinder.Trans, self.data_.tableData.Id)
  end
end

function CameraSettingActionItem:play(emoteCfg)
  local cfgId = emoteCfg.Id
  self.expressionData_:SetCurPlayingId(cfgId)
  local model = {}
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    model.ZModel = self.cameraData_:GetUnionModel()
  end
  self.expressionData_:SetLogicExpressionType(emoteCfg.Type)
  if emoteCfg.Type == E.ExpressionType.Action then
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
    local viewData = self.parent.UIView.viewData
    if viewData and viewData.OpenSourceType == E.ExpressionOpenSourceType.Camera then
      self.expressionVM_.ExpressionSinglePlay(model)
    else
      self.expressionVM_.PlayAction(cfgId, true, true)
    end
    if Z.IsPCUI then
      Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, cfgId)
    else
      Z.EventMgr:Dispatch(Z.ConstValue.Camera.ExpressionPlaySlider, true)
    end
  elseif emoteCfg.Type == E.ExpressionType.Emote then
    self.expressionVM_.ExpressionSinglePlay(model)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickEmotion, cfgId)
  end
end

function CameraSettingActionItem:setLockState()
  local isActive = self.data_.activeType == E.ExpressionState.Active
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not isActive)
  self.uiBinder.img_emoji.color.a = isActive and 1 or 0.2
end

return CameraSettingActionItem
