local super = require("ui.component.loopscrollrectitem")
local logoItemTemp = require("ui.component.union.union_logo_item")
local UnionLogoListItem = class("UnionLogoListItem", super)

function UnionLogoListItem:SetLogo(logoData, selectedFunc)
  self.selectedFunc = selectedFunc
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_element, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_logo, true)
  self.logoItem:SetLogo(logoData)
end

function UnionLogoListItem:SetLargeImg(cfgId, selectedFunc)
  self.selectedFunc = selectedFunc
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_element, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_logo, false)
  local config = Z.TableMgr.GetTable("UnionIconTableMgr").GetRow(cfgId)
  if config == nil then
    return
  end
  self.uiBinder.img_icon:SetImage(config.ShowIconRoute)
end

function UnionLogoListItem:HideAll()
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_element, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.trans_logo, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function UnionLogoListItem:OnInit()
  self.logoItem = logoItemTemp.new()
  self.logoItem:Init(self.uiBinder.binder_logo.Go)
end

function UnionLogoListItem:Refresh()
  self.uiView_ = self.parent.uiView
  if self.uiView_.viewConfigKey == "union_create_window" then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_light_bg, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dark_bg, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_light_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_dark_bg, true)
  end
  local index = self.component.Index + 1
  if index > self.parent:GetCount() then
    self.component.CanSelected = false
    self:HideAll()
    return
  end
  self.itemData_ = self.parent:GetDataByIndex(index)
  self:Selected(false)
  if self.itemData_ == nil then
    self:HideAll()
  elseif self.itemData_.showMode == E.UnionLogoItemShowType.Logo then
    self:SetLogo(self.itemData_.data, self.itemData_.selectedFunc)
  elseif self.itemData_.showMode == E.UnionLogoItemShowType.Element then
    self:SetLargeImg(self.itemData_.data, self.itemData_.selectedFunc)
  else
    self:HideAll()
  end
end

function UnionLogoListItem:Selected(isSelected)
  self.isSelected_ = isSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.isSelected_)
  if self.isSelected_ == true and self.selectedFunc ~= nil then
    self.selectedFunc(self.itemData_)
  end
end

function UnionLogoListItem:OnUnInit()
  self.isSelected_ = false
  self.selectedFunc = nil
end

function UnionLogoListItem:OnReset()
  self.isSelected_ = false
  self.selectedFunc = nil
end

return UnionLogoListItem
