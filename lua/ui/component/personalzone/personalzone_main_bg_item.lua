local super = require("ui.component.loop_grid_view_item")
local PersonalzoneMainBgItem = class("PersonalzoneMainBgItem", super)
local DEFINE = require("ui.model.personalzone_define")

function PersonalzoneMainBgItem:ctor()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
end

function PersonalzoneMainBgItem:OnInit()
  self.uiBinder.btn_bg:AddListener(function()
    self.parent.UIView:SetSelect(self.data_.config.Id)
  end)
end

function PersonalzoneMainBgItem:OnRefresh(data)
  self.data_ = data
  if data and data.config then
    self.uiBinder.rimg_bg:SetImage(data.config.Image)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, data.isSelect)
  if data.config.Unlock == DEFINE.ProfileImageUnlockType.DefaultUnlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  elseif data.config.Unlock == DEFINE.ProfileImageUnlockType.GetUnlock then
    local itemsCount = self.itemsVM_.GetItemTotalCount(data.config.Id)
    if itemsCount and 0 < itemsCount then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, data.config.Id == self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.PersonalzoneBg))
end

function PersonalzoneMainBgItem:OnUnInit()
end

function PersonalzoneMainBgItem:OnBeforePlayAnim()
end

return PersonalzoneMainBgItem
