local super = require("ui.component.loop_list_view_item")
local PersonalzoneEditBgItem = class("PersonalzoneEditBgItem", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")

function PersonalzoneEditBgItem:OnInit()
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function PersonalzoneEditBgItem:OnRefresh(data)
  self.data_ = data
  local frameId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  local defaultId = self.personalZoneData_:GetDefaultProfileImageConfigByType(PersonalZoneDefine.ProfileImageType.PersonalzoneBg)
  local isUnlock = self.itemsVm_.GetItemTotalCount(data.Id) > 0 or defaultId == data.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, not isUnlock)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, frameId == data.Id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.uiBinder.rimg_bg:SetImage(data.Image)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.personalzoneVm_.CheckSingleRedDot(self.data_.Id))
end

function PersonalzoneEditBgItem:OnUnInit()
end

function PersonalzoneEditBgItem:OnSelected(isSelected, isClick)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parent.UIView:ChangeBg(self.data_.Id)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  self.personalZoneData_:RemovePersonalzoneItem(self.data_.Id)
  self.personalzoneVm_.CheckRed()
end

return PersonalzoneEditBgItem
