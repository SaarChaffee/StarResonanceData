local UI = Z.UI
local super = require("ui.ui_view_base")
local AcquiretipView = class("AcquiretipView", super)

function AcquiretipView:ctor()
  self.uiBinder = nil
  super.ctor(self, "acquiretip")
end

function AcquiretipView:OnActive()
  self.perItemHeight_ = Z.IsPCUI and 40 or 50
  self.moveHeight_ = 0
  self.totalCount_ = 3
  self.uiBinder.trans_rect:SetHeight(self.totalCount_ * self.perItemHeight_)
  self.data_ = Z.DataMgr.Get("tips_data")
  self.isUpdate_ = false
  self.activeItems_ = {}
  self.unActiveItems_ = {}
  self:startUpdate()
  self:BindEvents()
end

function AcquiretipView:OnRefresh()
  self:startUpdate()
end

function AcquiretipView:startUpdate()
  if self.updateTimer_ then
    return
  end
  self.updateTimer_ = self.timerMgr:StartFrameTimer(function()
    self:update()
  end, 1, -1)
end

function AcquiretipView:update()
  self.moveHeight_ = 0
  for _, value in ipairs(self.activeItems_) do
    if not value.IsActive then
      self.moveHeight_ = self.moveHeight_ + self.perItemHeight_
      table.insert(self.unActiveItems_, value)
    end
  end
  for _, value in ipairs(self.activeItems_) do
    value:Update(Time.deltaTime, self.moveHeight_)
  end
  for _, v in pairs(self.unActiveItems_) do
    table.zremoveOneByValue(self.activeItems_, v)
  end
  if self:checkCanAddItem() then
    self:addItem()
  end
  if #self.activeItems_ == 0 and #self.data_.AcquireTipsInfos == 0 then
    self.timerMgr:StopTimer(self.updateTimer_)
    self.updateTimer_ = nil
    Z.UIMgr:CloseView("acquiretip")
  end
end

function AcquiretipView:checkCanAddItem()
  if #self.data_.AcquireTipsInfos > 0 and #self.activeItems_ < self.totalCount_ then
    for _, value in ipairs(self.activeItems_) do
      if 0 >= value.Height then
        return false
      end
    end
    return true
  end
  return false
end

function AcquiretipView:addItem()
  local data = Z.DataMgr.Get("tips_data")
  local itemInfo = data:PopAcquireItemInfo()
  local item
  local unActiveItemsCount = #self.unActiveItems_
  if 0 < unActiveItemsCount then
    item = self.unActiveItems_[unActiveItemsCount]
    table.remove(self.unActiveItems_, unActiveItemsCount)
  else
    local AcquiretipItemView = require("ui.view.acquiretipitem_view")
    item = AcquiretipItemView.new()
  end
  item:Active(self, itemInfo, (self.totalCount_ - #self.activeItems_ - 1) * self.perItemHeight_, self.uiBinder.trans_rect)
  table.insert(self.activeItems_, item)
end

function AcquiretipView:OnDeActive()
  for _, value in ipairs(self.activeItems_) do
    value:UnInit()
  end
  for _, value in ipairs(self.unActiveItems_) do
    value:UnInit()
  end
  self.activeItems_ = nil
  self.unActiveItems_ = nil
  self.data_ = nil
  self.updateTimer_ = nil
end

function AcquiretipView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.ShowAcquireItemInfo, self.startUpdate, self)
end

return AcquiretipView
