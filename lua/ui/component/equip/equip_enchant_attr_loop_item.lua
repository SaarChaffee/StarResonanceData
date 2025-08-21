local super = require("ui.component.loop_list_view_item")
local EquipEnchantAttrLooItem = class("EquipEnchantAttrLooItem", super)
local item = require("common.item_binder")

function EquipEnchantAttrLooItem:ctor()
end

function EquipEnchantAttrLooItem:OnInit()
end

function EquipEnchantAttrLooItem:OnRefresh(data)
  self.data_ = data
  local isBuffAttr = data.attrType == E.RemodelInfoType.Buff
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_content, isBuffAttr)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lab_01, not isBuffAttr)
  if isBuffAttr then
    self.uiBinder.lab_content.text = data.buffInfo
  else
    self.uiBinder.lab_nature.text = data.attrName
    self.uiBinder.lab_number.text = "+" .. data.attrValue
  end
end

function EquipEnchantAttrLooItem:OnSelected(isSelected)
end

function EquipEnchantAttrLooItem:OnUnInit()
end

function EquipEnchantAttrLooItem:OnBeforePlayAnim()
end

return EquipEnchantAttrLooItem
