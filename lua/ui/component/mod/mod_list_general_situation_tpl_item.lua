local super = require("ui.component.loop_list_view_item")
local ModListGeneralSituationTplItem = class("ModListGeneralSituationTplItem", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModListGeneralSituationTplItem:ctor()
  self.uiBinder = nil
  self.modVm_ = Z.VMMgr.GetVM("mod")
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.commonVm_ = Z.VMMgr.GetVM("common")
end

function ModListGeneralSituationTplItem:OnInit()
  self.uiBinder.btn_tips:AddListener(function()
    local text = Lang("ModMaximumOpenLevelTips")
    Z.CommonTipsVM.ShowTipsContent(self.parent.UIView.uiBinder.mod_info.Trans, text)
  end, true)
  self.uiBinder.btn_effect:AddListener(function()
    local viewData = {
      parent = self.parent.UIView.uiBinder.mod_info.Trans,
      effectId = self.data_.id,
      config = self.effectConfig_
    }
    Z.UIMgr:OpenView("mod_item_popup", viewData)
  end, true)
end

function ModListGeneralSituationTplItem:OnRefresh(data)
  self.data_ = data
  local level = 0
  local nextSuccessTimes = 0
  if data.nextValue then
    level, nextSuccessTimes = self.modVm_.GetEffectLevelAndNextLevelSuccessTimes(data.id, data.nextValue)
  else
    level, nextSuccessTimes = self.modVm_.GetEffectLevelAndNextLevelSuccessTimes(data.id, data.curValue)
  end
  modGlossaryItemTplItem.RefreshTpl(self.uiBinder.node_glossary_item_tpl, data.id)
  self.effectConfig_ = self.modData_:GetEffectTableConfig(data.id, level)
  self.uiBinder.node_on.Ref.UIComp:SetVisible(data.isSelect)
  self.uiBinder.node_off.Ref.UIComp:SetVisible(not data.isSelect)
  self.uiBinder.node_on.lab_name.text = self.effectConfig_.EffectName .. " " .. Lang("Grade", {val = level})
  self.uiBinder.node_off.lab_name.text = self.effectConfig_.EffectName .. " " .. Lang("Grade", {val = level})
  local value = data.curValue
  if data.nextValue then
    value = data.nextValue
  end
  if value >= MOD_DEFINE.MaxEffectIntensifyCount then
    self.uiBinder.node_on.Ref:SetVisible(self.uiBinder.node_on.lab_maximum, true)
    self.uiBinder.node_on.Ref:SetVisible(self.uiBinder.node_on.lab_upgrade, false)
    self.uiBinder.node_off.Ref:SetVisible(self.uiBinder.node_off.lab_maximum, true)
    self.uiBinder.node_off.Ref:SetVisible(self.uiBinder.node_off.lab_upgrade, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_tips, true)
  else
    self.uiBinder.node_on.Ref:SetVisible(self.uiBinder.node_on.lab_maximum, false)
    self.uiBinder.node_on.Ref:SetVisible(self.uiBinder.node_on.lab_upgrade, true)
    self.uiBinder.node_off.Ref:SetVisible(self.uiBinder.node_off.lab_maximum, false)
    self.uiBinder.node_off.Ref:SetVisible(self.uiBinder.node_off.lab_upgrade, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_tips, false)
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
    self.uiBinder.node_on.lab_upgrade.text = string.format("%s +%s/+%s", Lang("NextLevel"), data.nextValue, nextSuccessTimes)
    self.uiBinder.node_off.lab_upgrade.text = string.format("%s +%s/+%s", Lang("NextLevel"), data.nextValue, nextSuccessTimes)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_up, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_arrow_down, false)
    self.uiBinder.node_on.lab_upgrade.text = string.format("%s +%s/+%s", Lang("NextLevel"), data.curValue, nextSuccessTimes)
    self.uiBinder.node_off.lab_upgrade.text = string.format("%s +%s/+%s", Lang("NextLevel"), data.curValue, nextSuccessTimes)
  end
  if self.parent.UIView.IsShowModEffectUIEffect and self.parent.UIView.ShowModEffectUIEffectId == data.id then
    self.commonVm_.CommonPlayAnim(self.uiBinder.anim, "anim_", self.parent.UIView.cancelSource:CreateToken(), function()
    end)
  else
    self.uiBinder.anim:Stop()
  end
end

function ModListGeneralSituationTplItem:OnUnInit()
end

return ModListGeneralSituationTplItem
