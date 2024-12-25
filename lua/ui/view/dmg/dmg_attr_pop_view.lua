local UI = Z.UI
local super = require("ui.ui_subview_base")
local Dmg_attr_popView = class("Dmg_attr_popView", super)
local attrEnum = {
  attAttrId = Z.PbAttrEnum("AttrAttackAdd"),
  attrDefendId = Z.PbAttrEnum("AttrDefenseAdd"),
  attrHp = Z.PbAttrEnum("AttrMaxHpAdd")
}
local monsterAttrTab = {
  [attrEnum.attAttrId] = 0,
  [attrEnum.attrDefendId] = 0,
  [attrEnum.attrHp] = 0
}
local dmgData = Z.DataMgr.Get("damage_data")

function Dmg_attr_popView:ctor(parent)
  self.panel = nil
  super.ctor(self, "dmg_attr_pop", "dmg/dmg_attr_pop", UI.ECacheLv.None)
end

function Dmg_attr_popView:OnActive()
  self:AddClick(self.panel.input_num1.TMPInput, function(num)
    monsterAttrTab[attrEnum.attAttrId] = tonumber(num)
  end)
  self:AddClick(self.panel.input_num2.TMPInput, function(num)
    monsterAttrTab[attrEnum.attrHp] = tonumber(num)
  end)
  self:AddClick(self.panel.input_num3.TMPInput, function(num)
    monsterAttrTab[attrEnum.attrDefendId] = tonumber(num)
  end)
  self:AddClick(self.panel.btn_cancel.btn.Btn, function()
    for key, value in pairs(monsterAttrTab) do
      monsterAttrTab[key] = 0
    end
    dmgData.ControlMonsterAttrTab = {}
  end)
  self:AddClick(self.panel.btn_confirm.btn.Btn, function()
    for key, value in pairs(monsterAttrTab) do
      if value ~= 0 then
        dmgData.ControlMonsterAttrTab[key] = value
      end
    end
    self:DeActive()
  end)
  self:AddClick(self.panel.btn_reset.btn.Btn, function()
    self.panel.input_num1.TMPInput.text = 0
    self.panel.input_num2.TMPInput.text = 0
    self.panel.input_num3.TMPInput.text = 0
  end)
  self:AddClick(self.panel.btn_popup_close.Btn, function()
    self:DeActive()
  end)
end

function Dmg_attr_popView:OnDeActive()
end

function Dmg_attr_popView:OnRefresh()
end

return Dmg_attr_popView
