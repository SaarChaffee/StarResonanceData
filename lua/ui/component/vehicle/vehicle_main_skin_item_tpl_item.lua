local super = require("ui.component.loop_list_view_item")
local VehicleMainSkinItemTplItem = class("VehicleMainSkinItemTplItem", super)
local QualityColor = {
  [E.ItemQuality.Green] = Color.New(0.6313725490196078, 0.9490196078431372, 0.8745098039215686, 1),
  [E.ItemQuality.Blue] = Color.New(0.6078431372549019, 0.7843137254901961, 1.0, 1),
  [E.ItemQuality.Purple] = Color.New(0.8980392156862745, 0.7019607843137254, 1.0, 1),
  [E.ItemQuality.Yellow] = Color.New(0.9882352941176471, 0.8823529411764706, 0.2901960784313726, 1),
  [E.ItemQuality.Red] = Color.New(1.0, 0.6392156862745098, 0.5686274509803921, 1)
}

function VehicleMainSkinItemTplItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
end

function VehicleMainSkinItemTplItem:OnRefresh(data)
  self.data_ = data
  if self.data_ == nil then
    return
  end
  self.uiBinder.img_quality:SetColor(QualityColor[self.data_.Quality])
  self.uiBinder.rimg_quality:SetImage(self.data_.SkinBottomPicture)
  self.uiBinder.rimg_icon:SetImage(self.data_.Icon)
  self.uiBinder.lab_name.text = self.data_.Name
  self.uiBinder.lab_num.text = self.data_.Score
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  local count = self.itemsVM_.GetItemTotalCount(self.data_.Id)
  if count == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, true)
    self.uiBinder.node_content.alpha = 0.6
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
    self.uiBinder.node_content.alpha = 1
  end
  local baseVehicleId = self.data_.Id
  if self.data_.ParentId and self.data_.ParentId ~= 0 then
    baseVehicleId = self.data_.ParentId
  end
  local equipSkinId = self.vehicleVM_.GetEquipSkinId(baseVehicleId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lay_use, equipSkinId == self.data_.Id and 0 < count)
  if self.data_.ParentId and self.data_.ParentId ~= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, Z.RedPointMgr.GetRedState(self.vehicleVM_.GetRedNodeId(self.data_.Id)))
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  end
end

function VehicleMainSkinItemTplItem:OnSelected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parent.UIView:SetSelectSkinId(self.data_.Id, false)
  end
  self:refreshSelectState(isSelected)
end

function VehicleMainSkinItemTplItem:refreshSelectState(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelect)
end

function VehicleMainSkinItemTplItem:OnUnInit()
end

return VehicleMainSkinItemTplItem
