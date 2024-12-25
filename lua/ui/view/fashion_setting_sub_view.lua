local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_setting_subView = class("Fashion_setting_subView", super)
local region2Name = {
  [E.FashionRegion.Suit] = "suit",
  [E.FashionRegion.UpperClothes] = "upper_clothes",
  [E.FashionRegion.Pants] = "pants",
  [E.FashionRegion.Gloves] = "gloves",
  [E.FashionRegion.Shoes] = "shoes",
  [E.FashionRegion.Ring] = "ring",
  [E.FashionRegion.Tail] = "tail",
  [E.FashionRegion.Headwear] = "headwear",
  [E.FashionRegion.FaceMask] = "face_mask",
  [E.FashionRegion.MouthMask] = "mouth_mask",
  [E.FashionRegion.Earrings] = "earrings",
  [E.FashionRegion.Necklace] = "necklace"
}

function Fashion_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_setting_sub", "fashion/fashion_setting_sub", UI.ECacheLv.None)
  self.settingVM_ = Z.VMMgr.GetVM("fashion_setting")
end

function Fashion_setting_subView:OnActive()
  self.uiBinder.tog_body:RemoveAllListeners()
  self.uiBinder.tog_head:RemoveAllListeners()
  self.uiBinder.tog_body.isOn = true
  self.uiBinder.tog_head.isOn = false
  self.uiBinder.tog_body.group = self.uiBinder.togs_title
  self.uiBinder.tog_head.group = self.uiBinder.togs_title
  self.uiBinder.tog_body:AddListener(function(isOn)
    if isOn then
      self.uiBinder.scrollview_body.verticalNormalizedPosition = 1
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_body, isOn)
  end)
  self.uiBinder.tog_head:AddListener(function(isOn)
    if isOn then
      self.uiBinder.scrollview_head.verticalNormalizedPosition = 1
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_head, isOn)
  end)
  local regionDict = self.settingVM_.GetCurFashionSettingRegionDict()
  for region, nodeName in pairs(region2Name) do
    local widget = self.uiBinder["node_" .. nodeName]
    widget.switch_fashion.IsOn = regionDict[region] ~= 2
    widget.switch_fashion:AddListener(function(isOn)
      self.settingVM_.SetSingleFashionRegionIsHide(region, not isOn)
    end)
  end
  self.uiBinder.scrollview_body.verticalNormalizedPosition = 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_body, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_head, false)
  Z.EventMgr:Add(Z.ConstValue.FashionSettingChange, self.onFashionSettingChange, self)
end

function Fashion_setting_subView:OnDeActive()
  self.uiBinder.tog_body:RemoveAllListeners()
  self.uiBinder.tog_head:RemoveAllListeners()
end

function Fashion_setting_subView:onFashionSettingChange(regionDict)
  for region, nodeName in pairs(region2Name) do
    local widget = self.uiBinder["node_" .. nodeName]
    if widget then
      local isHide = regionDict[region] == 2
      widget.switch_fashion:SetIsOnWithoutNotify(not isHide)
    end
  end
end

return Fashion_setting_subView
