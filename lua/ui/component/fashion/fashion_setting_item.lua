local super = require("ui.component.loop_list_view_item")
local FashionSettingItem = class("FashionSettingItem", super)

function FashionSettingItem:OnInit()
  self.settingVM_ = Z.VMMgr.GetVM("fashion_setting")
end

function FashionSettingItem:OnUnInit()
  self.settingVM_ = nil
end

function FashionSettingItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_title.text = Lang(data.name)
  self:refreshSettingState()
end

function FashionSettingItem:OnPointerClick(go, eventData)
  local regionDict = self.settingVM_.GetCurFashionSettingRegionDict()
  local isHide = regionDict[self.data_.type] == 2
  self.settingVM_.SetSingleFashionRegionIsHide(self.data_.type, not isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isHide)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, not isHide)
end

function FashionSettingItem:refreshSettingState()
  local regionDict = self.settingVM_.GetCurFashionSettingRegionDict()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, regionDict[self.data_.type] ~= 2)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, regionDict[self.data_.type] == 2)
end

return FashionSettingItem
