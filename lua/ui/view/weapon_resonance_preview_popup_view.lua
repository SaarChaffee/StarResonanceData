local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_resonance_preview_popupView = class("Weapon_resonance_preview_popupView", super)

function Weapon_resonance_preview_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_resonance_preview_popup")
  self.skillAoyiTableMgr_ = Z.TableMgr.GetTable("SkillAoyiTableMgr")
  self.skillTableMgr_ = Z.TableMgr.GetTable("SkillTableMgr")
end

function Weapon_resonance_preview_popupView:OnActive()
  self:initData()
  self:initComponent()
  self:refreshInfo()
end

function Weapon_resonance_preview_popupView:OnDeActive()
end

function Weapon_resonance_preview_popupView:OnRefresh()
end

function Weapon_resonance_preview_popupView:initData()
  self.curSkillId_ = self.viewData.skillId
  self.curResonanceConfig_ = self.skillAoyiTableMgr_.GetRow(self.curSkillId_)
  self.curSkillConfig_ = self.skillTableMgr_.GetRow(self.curSkillId_)
end

function Weapon_resonance_preview_popupView:initComponent()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
end

function Weapon_resonance_preview_popupView:refreshInfo()
  self.uiBinder.lab_name.text = self.curSkillConfig_.Name
  self.uiBinder.lab_desc.text = self.curResonanceConfig_.Dialogue
  self.uiBinder.rimg_monster:SetImage(self.curResonanceConfig_.ArtPreview)
end

return Weapon_resonance_preview_popupView
