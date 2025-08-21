local super = require("ui.component.loop_list_view_item")
local ModListEntryDetailTplItem = class("ModListEntryDetailTplItem", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModListEntryDetailTplItem:ctor()
  self.uiBinder = nil
  self.modVm_ = Z.VMMgr.GetVM("mod")
  self.modData_ = Z.DataMgr.Get("mod_data")
end

function ModListEntryDetailTplItem:OnInit()
  self.uiBinder.btn_effect:AddListener(function()
    local viewData = {
      parent = self.parent.UIView.uiBinder.mod_info.Trans,
      effectId = self.data_.id,
      config = self.effectConfig_
    }
    Z.UIMgr:OpenView("mod_item_popup", viewData)
  end, true)
end

function ModListEntryDetailTplItem:OnRefresh(data)
  self.data_ = data
  local level = 0
  local nextSuccessTimes = 0
  if data.nextValue then
    level, nextSuccessTimes = self.modVm_.GetEffectLevelAndNextLevelSuccessTimes(data.id, data.nextValue)
  else
    level, nextSuccessTimes = self.modVm_.GetEffectLevelAndNextLevelSuccessTimes(data.id, data.curValue)
  end
  modGlossaryItemTplItem.RefreshTpl(self.uiBinder.node_glossary_item_tpl, data.id)
  if level == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_on_1, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_on_2, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_off_1, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_off_2, true)
    self.effectConfig_ = self.modData_:GetEffectTableConfig(data.id, 1)
    self.uiBinder.lab_name.text = self.effectConfig_.EffectName .. " " .. Lang("Grade", {val = level})
    local text = self.modVm_.ParseModEffectDesc(data.id, 1)
    self.uiBinder.lab_upgrade_on_2.text = text
    self.uiBinder.lab_upgrade_off_2.text = text
    if Z.IsPCUI then
      local size = self.uiBinder.lab_upgrade_on_2:GetPreferredValues(text, 400, 26)
      local height = math.max(95, 54 + size.y)
      self.uiBinder.Trans:SetHeight(height)
    else
      local size = self.uiBinder.lab_upgrade_on_2:GetPreferredValues(text, 540, 26)
      local height = math.max(112, 70 + size.y)
      self.uiBinder.Trans:SetHeight(height)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_on_1, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_on_2, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_off_1, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade_off_2, false)
    self.effectConfig_ = self.modData_:GetEffectTableConfig(data.id, level)
    self.uiBinder.lab_name.text = self.effectConfig_.EffectName .. " " .. Lang("Grade", {val = level})
    local text = self.modVm_.ParseModEffectDesc(data.id, level)
    self.uiBinder.lab_upgrade_on_1.text = text
    self.uiBinder.lab_upgrade_off_1.text = text
    if Z.IsPCUI then
      local size = self.uiBinder.lab_upgrade_on_1:GetPreferredValues(text, 400, 26)
      local height = math.max(95, 54 + size.y)
      self.uiBinder.Trans:SetHeight(height)
    else
      local size = self.uiBinder.lab_upgrade_on_1:GetPreferredValues(text, 540, 26)
      local height = math.max(112, 70 + size.y)
      self.uiBinder.Trans:SetHeight(height)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, data.isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not data.isSelect)
  local value = data.curValue
  if data.nextValue then
    value = data.nextValue
  end
  if value >= MOD_DEFINE.MaxEffectIntensifyCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_maximum, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_maximum, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_upgrade, true)
    self.uiBinder.lab_upgrade.text = string.format("%s +%s/+%s", Lang("NextLevel"), value, nextSuccessTimes)
  end
  if data.nextValue then
    if data.curValue < data.nextValue then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_up, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_down, false)
    elseif data.curValue == data.nextValue then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_up, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_down, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_up, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_down, true)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_up, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_down, false)
  end
  self.parent:OnItemSizeChanged(self.Index)
end

function ModListEntryDetailTplItem:OnUnInit()
end

return ModListEntryDetailTplItem
