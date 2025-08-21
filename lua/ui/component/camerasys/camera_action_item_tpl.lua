local super = require("ui.component.loop_grid_view_item")
local CameraActionItem = class("CameraActionItem", super)

function CameraActionItem:ctor()
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.multActionData_ = Z.DataMgr.Get("multaction_data")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function CameraActionItem:OnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lock, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  self.parent.UIView:AddClick(self.uiBinder.btn_bg, function()
    self:onBtnClicked()
  end)
  self.isHighlighted_ = false
  self:OnNodeStateChange(function(state)
    self:onNodeStateChange(state)
  end)
end

function CameraActionItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_emoji:SetImage(data.tableData.Icon)
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

function CameraActionItem:OnSelected(isSelected, isClick)
  if not self.cameraVM_.CheckIsFashionState() then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    local canPlayAction = self.expressionVM_.CanPlayActionCheck(stateId)
    if not canPlayAction then
      self.parent:ClearAllSelect()
      Z.TipsVM.ShowTips(1000028)
      return
    end
  end
  self:play(self.data_.tableData)
end

function CameraActionItem:OnUnInit()
  self.isHighlighted_ = false
end

function CameraActionItem:play(emoteCfg)
  local cfgId = emoteCfg.Id
  self.expressionData_:SetCurPlayingId(cfgId)
  local model = {}
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    model.ZModel = self.cameraData_:GetUnionModel()
  end
  self.expressionData_:SetLogicExpressionType(emoteCfg.Type)
  if emoteCfg.Type == E.ExpressionType.Action then
    self.expressionVM_.ExpressionSinglePlay(model)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickAction, cfgId)
  elseif emoteCfg.Type == E.ExpressionType.Emote then
    self.expressionVM_.ExpressionSinglePlay(model)
    Z.EventMgr:Dispatch(Z.ConstValue.Expression.ClickEmotion, cfgId)
  end
end

function CameraActionItem:onBtnClicked()
  if not self.cameraVM_.CheckIsFashionState() then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    local canPlayAction = self.expressionVM_.CanPlayActionCheck(stateId)
    if not canPlayAction then
      Z.TipsVM.ShowTips(1000028)
      return
    end
  end
  self.parent:SetSelected(self.Index)
  self:play(self.data_.tableData)
end

function CameraActionItem:onNodeStateChange(state)
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

return CameraActionItem
