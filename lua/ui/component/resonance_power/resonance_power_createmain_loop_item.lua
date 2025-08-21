local super = require("ui.component.loop_grid_view_item")
local ResonancePowerCreateMainLoopItem = class("ResonancePowerCreateMainLoopItem", super)
local item = require("common.item_binder")
local bagRed = require("rednode.bag_red")

function ResonancePowerCreateMainLoopItem:ctor()
end

function ResonancePowerCreateMainLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.uiView)
  self.resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
end

function ResonancePowerCreateMainLoopItem:OnRefresh(data)
  self.data = data
  self.configId = data
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = self.configId,
    isClickOpenTips = false
  })
  self:SelectState()
  local isHaveCoreMaterial = self.resonancePowerVM_.CheckHaveCoreMaterial(self.configId)
  self.itemClass_:SetLab(isHaveCoreMaterial and Lang("HaveResonanceCoreMaterial") or "")
  self.redDotId_ = bagRed.GetResonanceMakeItemRedId(self.configId)
  Z.RedPointMgr.LoadRedDotItem(self.redDotId_, self.parent.UIView, self.uiBinder.Trans)
end

function ResonancePowerCreateMainLoopItem:Selected(isSelected)
  if isSelected then
    self.itemClass_:SetSelected(isSelected)
    self.parentUIView:OnSelectResonancePowerItemCreate(self:GetCurData())
  end
  self:SelectState()
end

function ResonancePowerCreateMainLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function ResonancePowerCreateMainLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function ResonancePowerCreateMainLoopItem:OnUnInit()
  self:clearRedDot()
  self.itemClass_:UnInit()
  self.updateTimer_ = nil
  self.timerMgr_ = nil
end

function ResonancePowerCreateMainLoopItem:OnRecycle()
  self:clearRedDot()
end

function ResonancePowerCreateMainLoopItem:clearRedDot()
  if self.redDotId_ then
    Z.RedPointMgr.RemoveNodeItem(self.redDotId_)
    self.redDotId_ = nil
  end
end

return ResonancePowerCreateMainLoopItem
