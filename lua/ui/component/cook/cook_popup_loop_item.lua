local super = require("ui.component.loopscrollrectitem")
local CookPopupItem = class("CookPopupItem", super)
local itemClass = require("common.item")
local cookVM = Z.VMMgr.GetVM("cook")
local path = "cook_item_empty"
local qualityPath = "ui/atlas/item/prop/fashion_img_quality_empty"

function CookPopupItem:ctor()
end

function CookPopupItem:OnInit()
end

function CookPopupItem:Refresh()
  self.itemClass_ = itemClass.new(self.parent.uiView)
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.isUnlock = cookVM.IsUnlockCookBook(self.data_.Id)
  local configId = self.isUnlock and self.data_.Id or 0
  local itemPreviewData = {
    unit = self.unit,
    configId = configId,
    isSquareItem = true,
    isClickOpenTips = false
  }
  itemPreviewData.lab = ""
  itemPreviewData.labType = E.ItemLabType.Str
  self.itemClass_:Init(itemPreviewData)
  if not self.isUnlock then
    self.unit.cont_info:SetVisible(true)
    self.unit.cont_info.rimg_icon.RImg:SetImage(path)
    self.unit.cont_info.rimg_icon:SetVisible(true)
    self.itemClass_:setQuality(qualityPath)
  end
end

function CookPopupItem:OnBeforePlayAnim()
end

function CookPopupItem:Selected(isSelected)
  if isSelected then
    if not self.isUnlock then
      Z.TipsVM.ShowTips(1002003)
      return
    end
    self.parent.uiView:SetSelect(self)
    if self.lastSelect then
      self.lastSelect:setSelect(false)
    end
    self:setSelect(true)
    self.lastSelect = self
  end
end

function CookPopupItem:setSelect(isSelected)
  self.unit.cont_info.anim_select:SetVisible(isSelected)
  self.unit.cont_info.img_select:SetVisible(isSelected)
end

function CookPopupItem:OnPointerClick(go, eventData)
end

function CookPopupItem:SetShowClose(show)
  self.unit.cont_info.btn_close:SetVisible(show)
end

function CookPopupItem:SetLabText(str)
  self.unit.cont_info.lab_level.TMPLab.text = str
end

function CookPopupItem:UpdateData()
  self:setSelect(false)
end

function CookPopupItem:OnUnInit()
  self.itemClass_:UnInit()
  self.lastSelect = nil
end

return CookPopupItem
