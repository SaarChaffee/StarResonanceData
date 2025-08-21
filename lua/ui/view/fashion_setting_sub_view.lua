local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_setting_subView = class("Fashion_setting_subView", super)
local bodySettingList = {
  [1] = {
    type = E.FashionRegion.Suit,
    name = "Suit"
  },
  [2] = {
    type = E.FashionRegion.UpperClothes,
    name = "Jacket"
  },
  [3] = {
    type = E.FashionRegion.Pants,
    name = "Bottoms"
  },
  [4] = {
    type = E.FashionRegion.Gloves,
    name = "Handguard"
  },
  [5] = {
    type = E.FashionRegion.Shoes,
    name = "Shoe"
  },
  [6] = {
    type = E.FashionRegion.Ring,
    name = "Ring"
  },
  [7] = {
    type = E.FashionRegion.Back,
    name = "Back"
  }
}
local headSettingList = {
  [1] = {
    type = E.FashionRegion.Headwear,
    name = "Headgear"
  },
  [2] = {
    type = E.FashionRegion.FaceMask,
    name = "SurfaceDecoration"
  },
  [3] = {
    type = E.FashionRegion.MouthMask,
    name = "MouthDecoration"
  },
  [4] = {
    type = E.FashionRegion.Earrings,
    name = "Earring1"
  },
  [5] = {
    type = E.FashionRegion.Necklace,
    name = "Necklace"
  }
}
local loop_list_view = require("ui.component.loop_list_view")
local fashion_setting_item = require("ui.component.fashion.fashion_setting_item")

function Fashion_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_setting_sub", "fashion/fashion_setting_sub", UI.ECacheLv.None)
end

function Fashion_setting_subView:OnActive()
  self.loopList_ = loop_list_view.new(self, self.uiBinder.node_list, fashion_setting_item, "fashion_setting_tpl")
  self.loopList_:Init({})
  self.uiBinder.tog_body:RemoveAllListeners()
  self.uiBinder.tog_head:RemoveAllListeners()
  self.uiBinder.tog_body.isOn = true
  self.uiBinder.tog_head.isOn = false
  self.uiBinder.tog_body.group = self.uiBinder.togs_title
  self.uiBinder.tog_head.group = self.uiBinder.togs_title
  self.uiBinder.tog_body:AddListener(function(isOn)
    if isOn then
      self:setSelectList(bodySettingList)
    end
  end)
  self.uiBinder.tog_head:AddListener(function(isOn)
    if isOn then
      self:setSelectList(headSettingList)
    end
  end)
  self:setSelectList(bodySettingList)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionSettingChange, self.refreshList, self)
end

function Fashion_setting_subView:OnDeActive()
  self.uiBinder.tog_body:RemoveAllListeners()
  self.uiBinder.tog_head:RemoveAllListeners()
  self.loopList_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Fashion.FashionSettingChange, self.refreshList, self)
end

function Fashion_setting_subView:setSelectList(list)
  self.curList_ = list
  self.loopList_:RefreshListView(self.curList_, false)
end

function Fashion_setting_subView:refreshList()
  self.loopList_:RefreshListView(self.curList_, false)
end

return Fashion_setting_subView
