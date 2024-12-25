local super = require("ui.component.loop_list_view_item")
local MapStickItem = class("MapStickItem", super)

function MapStickItem:ctor()
  self.mapClockVm_ = Z.VMMgr.GetVM("map_clock")
end

function MapStickItem:OnInit()
  self.size_ = {}
  self.size_.x, self.size_.y = self.uiBinder.Trans:GetSize(self.size_.x, self.size_.y)
end

function MapStickItem:OnRefresh(data)
  self.stickerId_ = data.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_select, false)
  self.uiBinder.img_icon:SetImage(data.congfig.Icon)
  local finishTasks = self.mapClockVm_.CheckStickAllTaskFinish(data.mapId, self.stickerId_)
  local unlock = self.mapClockVm_.CheckStickUnlock(data.mapId, self.stickerId_)
  if not finishTasks then
    self.uiBinder.img_icon:SetGray()
    self.uiBinder.img_mask:SetGray()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  else
    self.uiBinder.img_icon:ClearGray()
    self.uiBinder.img_mask:ClearGray()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, not unlock)
  end
end

function MapStickItem:OnUnInit()
  self.uiBinder.Trans:SetSizeDelta(self.size_.x, self.size_.y)
end

function MapStickItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_select, self.IsSelected)
  if self.IsSelected then
    self.uiBinder.Trans:SetSizeDelta(self.size_.x * 1.1, self.size_.y * 1.1)
  else
    self.uiBinder.Trans:SetSizeDelta(self.size_.x, self.size_.y)
  end
  self.parent.UIView:onStickerSelected(self.stickerId_)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return MapStickItem
