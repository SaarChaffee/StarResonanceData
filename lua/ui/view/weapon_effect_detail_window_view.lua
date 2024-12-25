local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_effect_detail_windowView = class("Weapon_effect_detail_windowView", super)
local item = "ui/prefabs/weaponhero/auto_layout_desc_item"

function Weapon_effect_detail_windowView:ctor()
  self.panel = nil
  super.ctor(self, "weapon_effect_detail_window")
end

function Weapon_effect_detail_windowView:OnActive()
  self.vm_ = Z.VMMgr.GetVM("profession_sign")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.professionId_ = self.viewData.professionId
  self.professionEffectActive_ = self.vm_.CheckProfessionEffectActive(self.professionId_)
  self.effectId_ = self.vm_.GetProfessionActiveEffectId(self.professionId_)
  self:AddClick(self.panel.cont_btn_return.btn.Btn, function()
    self.vm_.CloseProfessionDesc()
  end)
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshProfessionDesc()
    self:refreshProfessionEffectDesc()
    self:refreshEffectDec()
    self:refreshSignDec()
  end)()
end

function Weapon_effect_detail_windowView:refreshProfessionDesc()
  local professionConfig = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(self.professionId_)
  if professionConfig == nil then
    return
  end
  self.panel.profession_desc_tpl.lab_title.TMPLab.text = professionConfig.Name
  local unit = self:AsyncLoadUiUnit(item, "profession_desc", self.panel.layout_att_1.Trans)
  unit.lab_attr.TMPLab.text = Z.TableMgr.DecodeLineBreak(professionConfig.Description)
end

function Weapon_effect_detail_windowView:refreshProfessionEffectDesc()
  local unit = self:AsyncLoadUiUnit(item, "profession_effect_desc", self.panel.layout_att_4.Trans)
  if self.professionEffectActive_ then
    local effectConfig = Z.TableMgr.GetTable("ProfessionEffectTableMgr").GetRow(self.effectId_)
    if effectConfig == nil then
      return
    end
    self.panel.profession_effect_desc_tpl.lab_title.TMPLab.text = effectConfig.Name
    unit.lab_attr.TMPLab.text = Z.TableMgr.DecodeLineBreak(effectConfig.Description)
  else
    self.panel.profession_effect_desc_tpl.lab_title.TMPLab.text = Lang("ProfessionEffectDesc")
    unit.lab_attr.TMPLab.text = Lang("signActiveProfessionEffect")
  end
end

function Weapon_effect_detail_windowView:refreshEffectDec()
  local attrParseVM = Z.VMMgr.GetVM("equip_attr_parse")
  local externAttr = self.vm_.GetProfessionEffectAttr(self.professionId_, false, false)
  if externAttr == nil or #externAttr == 0 then
    local unit = self:AsyncLoadUiUnit(item, "effect_desc", self.panel.layout_att_2.Trans)
    unit.lab_attr.TMPLab.text = Lang("professionEffectActiveEntry")
  else
    local tips = attrParseVM.GetEquipExternAttrTips(externAttr, nil, E.AttrInfoType.All)
    for index, value in ipairs(tips) do
      local unit = self:AsyncLoadUiUnit(item, "effect_desc_" .. index, self.panel.layout_att_2.Trans)
      unit.lab_attr.TMPLab.text = value.tip
    end
  end
end

function Weapon_effect_detail_windowView:refreshSignDec()
  local effectInfo = self.vm_.GetProfessionActiveEffect(self.professionId_)
  self.equipEffectId_ = self.vm_.GetProfessionActiveEffectId(self.professionId_)
  local total = 0
  if self.equipEffectId_ ~= 0 then
    for index = 1, 3 do
      local uuid = 0
      if effectInfo then
        uuid = effectInfo.signCards[index]
      end
      local signConfigId = self.itemsVm_.GetItemConfigId(uuid, E.BackPackItemPackageType.Mod)
      if uuid ~= 0 then
        total = total + 1
        local descTabel_ = self.vm_.GetSignEffectDesc(uuid, signConfigId)
        local desc = ""
        for index, value in ipairs(descTabel_) do
          desc = desc .. value
        end
        local unit = self:AsyncLoadUiUnit(item, "sign_desc_" .. index, self.panel.layout_att_3.Trans)
        unit.lab_attr.TMPLab.text = Z.TableMgr.DecodeLineBreak(desc)
      end
    end
  end
  if total == 0 then
    local unit = self:AsyncLoadUiUnit(item, "sign_desc", self.panel.layout_att_3.Trans)
    unit.lab_attr.TMPLab.text = Lang("not_equip_sign")
  end
end

function Weapon_effect_detail_windowView:OnDeActive()
end

function Weapon_effect_detail_windowView:OnRefresh()
end

return Weapon_effect_detail_windowView
