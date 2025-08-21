local super = require("ui.component.loop_list_view_item")
local ModEntryListTplItem = class("ModEntryListTplItem", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")
local item = require("common.item_binder")
local slotUIPath = "ui/atlas/mod_new/mod_num_"

function ModEntryListTplItem:ctor()
  self.uiBinder = nil
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.modVm_ = Z.VMMgr.GetVM("mod")
end

function ModEntryListTplItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.uiBinder.btn_select:AddListener(function()
    self.parent.UIView:SetSelectUuid(self.data_.uuid)
  end, true)
end

function ModEntryListTplItem:OnRefresh(data)
  self.data_ = data
  local itemInfo = self.itemVm_.GetItemInfobyItemId(data.uuid, data.configId)
  local itemData = {
    uiBinder = self.uiBinder.item,
    configId = data.configId,
    uuid = data.uuid,
    labType = E.ItemLabType.Str,
    lab = "",
    itemInfo = itemInfo,
    isSquareItem = true
  }
  self.itemClass_:Init(itemData)
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemData.configId)
  self.itemClass_:SetRedDot(data.isRed)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, data.isSelected)
  local isEquip, slotId = self.modVm_.IsModEquip(data.uuid)
  if isEquip then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_num, true)
    self.uiBinder.lab_slot.text = slotId
    if slotId == data.curSlot then
      self.uiBinder.Ref:SetVisible(self.uiBinder.effect, true)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.effect, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_num, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect, false)
  end
  local details = self.modVm_.GetModEffectIdAndSuccessTimesDetail(data.uuid)
  for i = 1, MOD_DEFINE.ModEffectMaxCount do
    local nodeOnUIBinder = self.uiBinder["node_img_on_" .. i]
    local nodeOffUIBinder = self.uiBinder["node_img_off_" .. i]
    local detail = details[i]
    if detail then
      nodeOnUIBinder.Ref.UIComp:SetVisible(true)
      modGlossaryItemTplItem.RefreshTpl(nodeOnUIBinder.mod_glossary_item_tpl, detail.id)
      nodeOnUIBinder.lab_num.text = "+" .. detail.level
      nodeOffUIBinder.Ref.UIComp:SetVisible(true)
      modGlossaryItemTplItem.RefreshTpl(nodeOffUIBinder.mod_glossary_item_tpl, detail.id)
      nodeOffUIBinder.lab_num.text = "+" .. detail.level
    else
      nodeOnUIBinder.Ref.UIComp:SetVisible(false)
      nodeOffUIBinder.Ref.UIComp:SetVisible(false)
    end
  end
end

function ModEntryListTplItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected, isSelected)
end

function ModEntryListTplItem:OnUnInit()
  self.itemClass_:UnInit()
end

return ModEntryListTplItem
