local super = require("ui.component.toggleitem")
local HelpsysFirstClassLoopItem = class("HelpsysFirstClassLoopItem", super)

function HelpsysFirstClassLoopItem:ctor()
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function HelpsysFirstClassLoopItem:OnInit()
end

function HelpsysFirstClassLoopItem:Refresh()
  self.isSelected = false
  local index = self.index
  self.data_ = self.view:GetGroupData(index)
  if self.data_ then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.HelpsysTabRed .. "group" .. self.data_.HelpGroup, self.view, self.uiBinder.Trans)
    if self.data_.Icon and self.data_.Icon ~= "" then
      self.uiBinder.img_on:SetImage(self.data_.Icon)
      self.uiBinder.img_off:SetImage(self.data_.Icon)
    end
  end
  self:refreshLines()
end

function HelpsysFirstClassLoopItem:OnSelected(isOn)
  self.isSelected = isOn
  if isOn then
    self.commonVM_.CommonPlayTogAnim(self.uiBinder.anim_tog, self.view.cancelSource:CreateToken())
  end
  self:refreshLines()
end

function HelpsysFirstClassLoopItem:refreshLines()
end

function HelpsysFirstClassLoopItem:UnInit()
  self.component.group = nil
  self.component.isOn = false
  if self.data_ then
    Z.RedPointMgr.RemoveNodeItem(E.RedType.HelpsysTabRed .. "group" .. self.data_.HelpGroup)
  end
end

return HelpsysFirstClassLoopItem
