local super = require("ui.component.loop_grid_view_item")
local CameraFishItem = class("CameraFishItem", super)

function CameraFishItem:ctor()
  self.fishing_data_ = Z.DataMgr.Get("fishing_data")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
end

function CameraFishItem:OnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, false)
  Z.EventMgr:Add(Z.ConstValue.Fishing.UpdateActionCurFishId, self.refreshIsUsed, self)
end

function CameraFishItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.rimg_icon:SetImage(data.FishingIcon)
  self:refreshIsUsed()
end

function CameraFishItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, isSelected)
  if isSelected then
    self.fishing_data_:SetActionFishId(self.data_.FishId)
    self:replayAction()
  end
end

function CameraFishItem:refreshIsUsed()
  local fishingId = self.fishing_data_:GetActionFishId()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, fishingId == self.data_.FishId)
end

function CameraFishItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Fishing.UpdateActionCurFishId, self.refreshIsUsed, self)
end

function CameraFishItem:replayAction()
  local curType = self.expressionData_:GetLogicExpressionType()
  local playingId = self.expressionData_:GetCurPlayingId()
  if not (curType == E.ExpressionType.Action and playingId) or playingId == -1 then
    return
  end
  if self.expressionData_.OpenSourceType == E.ExpressionOpenSourceType.Expression then
    self.expressionVM_.PlayAction(playingId, true, true)
  elseif self.expressionData_.OpenSourceType == E.ExpressionOpenSourceType.Camera then
    self.expressionVM_.ExpressionSinglePlay()
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ExpressionPlaySlider, true)
  end
end

return CameraFishItem
