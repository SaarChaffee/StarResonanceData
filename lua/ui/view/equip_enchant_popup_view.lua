local UI = Z.UI
local super = require("ui.ui_view_base")
local Equip_enchant_popupView = class("Equip_enchant_popupView", super)
local attrLoopItem = require("ui.component.equip.equip_enchant_popup_attr_loop_item")
local loop_list = require("ui.component.loop_list_view")
local CENTE_COUNT = 3

function Equip_enchant_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "equip_enchant_popup")
  self.enchantVm_ = Z.VMMgr.GetVM("equip_enchant")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Equip_enchant_popupView:initBinders()
  self.cancelBtn_ = self.uiBinder.btn_cancel
  self.confirmBtn_ = self.uiBinder.btn_confirm
  self.beforeLoopList_ = self.uiBinder.loop_item
  self.curNameLab_ = self.uiBinder.lab_cur_name
  self.selectedNameLab_ = self.uiBinder.lab_selected_name
  self.typeLab_ = self.uiBinder.lab_type
  self.desLab_ = self.uiBinder.lab_des
  self.sceneMask_ = self.uiBinder.scenemask
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
end

function Equip_enchant_popupView:initBtns()
  self:AddClick(self.cancelBtn_.btn, function()
    self.enchantVm_.CloseEnchantPopupView()
  end)
  self:AddAsyncClick(self.confirmBtn_.btn, function()
    self.enchantVm_.AsyncEquipEnchant(self.viewData.equipUuid, self.viewData.enchantItemConfigId, self.viewData.selectedTogType, self.cancelSource:CreateToken())
  end)
end

function Equip_enchant_popupView:initUI()
  self.attrListView_ = loop_list.new(self, self.beforeLoopList_, attrLoopItem, "equip_enchant_popup_item_tpl")
  if self.viewData and self.viewData.equipUuid and self.viewData.enchantItemConfigId then
    self.typeLab_.text = Lang("EnchantType", {
      val = Lang("EquipEnchantTypeTitleTips" .. self.viewData.selectedTogType)
    })
    local nowEnchantAttr = {}
    local equipEnchantInfo = Z.ContainerMgr.CharSerialize.equip.equipEnchant[self.viewData.equipUuid]
    if equipEnchantInfo then
      local row = self.enchantVm_.GetEnchantItemByTypeAndLevel(equipEnchantInfo.enchantItemTypeId, equipEnchantInfo.enchantLevel)
      if row then
        nowEnchantAttr = self.enchantVm_.GetAttrByEnchantItemRow(row)
        self.curNameLab_.text = self.itemsVm_.ApplyItemNameWithQualityTag(row.Id)
      end
    end
    local enchantItemRow = Z.TableMgr.GetRow("EquipEnchantItemTableMgr", self.viewData.enchantItemConfigId)
    if enchantItemRow then
      self.selectedNameLab_.text = self.itemsVm_.ApplyItemNameWithQualityTag(enchantItemRow.Id)
      local infoStr = ""
      if self.viewData.selectedTogType == E.EnchantType.Common then
        infoStr = enchantItemRow.OrdinaryAddEffectsDes
      elseif self.viewData.selectedTogType == E.EnchantType.Middle then
        infoStr = enchantItemRow.IntermediateAddEffectsDes
      else
        infoStr = enchantItemRow.AdvancedAddEffectsDes
      end
      self.desLab_.text = Lang("EnchantEffect", {val = infoStr})
      local data = self:getData(nowEnchantAttr, self.enchantVm_.GetAttrByEnchantItemRow(enchantItemRow))
      if #data > CENTE_COUNT then
        self.attrListView_:SetIsCenter(false)
      else
        self.attrListView_:SetIsCenter(true)
      end
      self.attrListView_:Init(data)
    end
  end
end

function Equip_enchant_popupView:getData(leftData, rightData)
  local data = {}
  if not leftData or not rightData then
    return data
  end
  local maxCount = math.max(#leftData, #rightData)
  for i = 1, maxCount do
    data[i] = {
      leftData = leftData[i],
      rightData = rightData[i]
    }
  end
  return data
end

function Equip_enchant_popupView:OnActive()
  self:initBinders()
  self:initBtns()
  self:initUI()
  Z.EventMgr:Add(Z.ConstValue.Equip.EquipEnchantResult, self.euipEnchantResult, self)
end

function Equip_enchant_popupView:euipEnchantResult(isSuccess)
  if isSuccess then
    self.enchantVm_.CloseEnchantPopupView()
  end
end

function Equip_enchant_popupView:OnDeActive()
  if self.attrListView_ then
    self.attrListView_:UnInit()
    self.attrListView_ = nil
  end
end

function Equip_enchant_popupView:OnRefresh()
end

return Equip_enchant_popupView
