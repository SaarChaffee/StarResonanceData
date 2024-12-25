local super = require("ui.component.loop_grid_view_item")
local ResonancePowerCreateMainLoopItem = class("ResonancePowerCreateMainLoopItem", super)
local item = require("common.item_binder")
local bagRed = require("rednode.bag_red")

function ResonancePowerCreateMainLoopItem:ctor()
end

function ResonancePowerCreateMainLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.uiView)
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
  local nodeId = bagRed.GetResonanceMakeItemRedId(self.configId)
  Z.RedPointMgr.LoadRedDotItem(nodeId, self.parent.UIView, self.uiBinder.Trans)
end

function ResonancePowerCreateMainLoopItem:refreshNoItemUi()
  self:SetCanSelect(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_info, false)
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
  self.itemClass_:UnInit()
  self.updateTimer_ = nil
  self.timerMgr_ = nil
end

return ResonancePowerCreateMainLoopItem
