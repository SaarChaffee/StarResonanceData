local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local ExpressionTabClassItem = class("ExpressionTabClassItem", super)
local iconPath_ = "ui/atlas/emote/"

function ExpressionTabClassItem:ctor()
end

function ExpressionTabClassItem:OnInit()
  self.unit.tog.Tog:AddListener(function()
    if self.unit.tog.Tog.isOn then
      local vm_ = Z.VMMgr.GetVM("expression")
      vm_.SetTabSelected(self.component.Index + 1)
      self.item_.img_select:SetVisible(true)
      self.item_.img_unselect:SetVisible(false)
    else
      self.item_.img_select:SetVisible(false)
      self.item_.img_unselect:SetVisible(true)
    end
  end)
end

function ExpressionTabClassItem:Refresh()
  local index_ = self.component.Index + 1
  local data_ = self.parent:GetDataByIndex(index_)
  self.item_ = nil
  self.icon_ = string.format("%s%s", iconPath_, data_.icon)
  if #self.parent.Data == index_ then
    self.unit.tab_normal:SetVisible(false)
    self.unit.tab_end:SetVisible(true)
    self.item_ = self.unit.tab_end
  else
    self.unit.tab_normal:SetVisible(true)
    self.unit.tab_end:SetVisible(false)
    self.item_ = self.unit.tab_normal
  end
  self.item_.off.Img:SetImage(self.icon_ .. "_off")
  self.item_.on.Img:SetImage(self.icon_ .. "_on")
  self.unit.tog.Tog.group = self.parent.uiView.tab_btn_bg.tabViewPort.TogGroup
  if index_ == 1 then
    self.unit.tog.Tog.isOn = true
  else
    self.unit.tog.Tog.isOn = false
  end
end

function ExpressionTabClassItem:Selected(isSelected)
end

function ExpressionTabClassItem:OnUnInit()
  self.item_ = nil
end

function ExpressionTabClassItem:OnReset()
end

return ExpressionTabClassItem
