local super = require("ui.component.loop_list_view_item")
local EquipEnchantPopupAttrLooItem = class("EquipEnchantPopupAttrLooItem", super)

function EquipEnchantPopupAttrLooItem:ctor()
end

function EquipEnchantPopupAttrLooItem:OnInit()
end

function EquipEnchantPopupAttrLooItem:OnRefresh(data)
  self.data_ = data
  if self.data_.leftData then
    local isBuffAttr = self.data_.leftData.attrType == E.RemodelInfoType.Buff
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, isBuffAttr)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nature, not isBuffAttr)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_number, not isBuffAttr)
    if isBuffAttr then
      self.uiBinder.lab_content.text = self.data_.leftData.buffInfo
    else
      self.uiBinder.lab_nature.text = self.data_.leftData.attrName
      self.uiBinder.lab_number.text = "+" .. self.data_.leftData.attrValue
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nature, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_number, false)
  end
  if self.data_.rightData then
    local isBuffAttr = self.data_.rightData.attrType == E.RemodelInfoType.Buff
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content_later, isBuffAttr)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nature_later, not isBuffAttr)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_number_later, not isBuffAttr)
    if isBuffAttr then
      self.uiBinder.lab_content_later.text = self.data_.rightData.buffInfo
    else
      self.uiBinder.lab_nature_later.text = self.data_.rightData.attrName
      self.uiBinder.lab_number_later.text = "+" .. Z.RichTextHelper.ApplyStyleTag(self.data_.rightData.attrValue, E.TextStyleTag.TipsGreen)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content_later, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_nature_later, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_number_later, false)
  end
end

function EquipEnchantPopupAttrLooItem:OnSelected(isSelected)
end

function EquipEnchantPopupAttrLooItem:OnUnInit()
end

function EquipEnchantPopupAttrLooItem:OnBeforePlayAnim()
end

return EquipEnchantPopupAttrLooItem
