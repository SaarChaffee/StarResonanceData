local super = require("ui.component.loop_grid_view_item")
local VehicleMainItemTplItem = class("VehicleMainItemTplItem", super)
local bgPath = "ui/atlas/vehicle/vehicle_item_bg_"

function VehicleMainItemTplItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
end

function VehicleMainItemTplItem:OnRefresh(data)
  self.data_ = data
  if self.data_ then
    self.uiBinder.img_bg:SetImage(bgPath .. self.data_.Quality)
    self.uiBinder.img_icon:SetImage(self.data_.Icon)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, self.IsSelected)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
    local isEquip, type = self.vehicleVM_.IsEquip(self.data_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_equip, isEquip)
    local count = self.itemsVM_.GetItemTotalCount(self.data_.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, count == 0)
  end
end

function VehicleMainItemTplItem:OnSelected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parent.UIView:SetSelectId(self.data_.Id, false)
  end
  self:refreshSelectState(isSelected)
end

function VehicleMainItemTplItem:refreshSelectState(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_light, isSelect)
end

function VehicleMainItemTplItem:OnUnInit()
end

return VehicleMainItemTplItem
