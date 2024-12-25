local UI = Z.UI
local super = require("ui.ui_view_base")
local Mod_intensify_popupView = class("Mod_intensify_popupView", super)
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function Mod_intensify_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_intensify_popup")
  self.viewData = nil
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.gotoEffectId_ = nil
end

function Mod_intensify_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.AudioMgr:Play("ui_questtimelimited_success")
  self:onStartAnimShow()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("mod_intensify_popup")
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:GotoMainView()
    self.modVM_.EnterModView(nil, self.gotoEffectId_)
  end)
  self.gotoEffectId_ = self.viewData.effectId
  ModGlossaryItemTplItem.RefreshTpl(self.uiBinder.mod_glossary_item_tpl, self.viewData.effectId, self.viewData.lv)
  local config = self.modData_:GetEffectTableConfig(self.viewData.effectId, self.viewData.lv)
  local name = ""
  if config then
    name = config.EffectName
  end
  self.uiBinder.lab_lv.text = string.format("%s %s", name, Lang("LvFormatSymbol", {
    val = self.viewData.lv
  }))
  self.uiBinder.lab_content.text = self.modVM_.ParseModEffectDesc(self.viewData.effectId, self.viewData.lv)
end

function Mod_intensify_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_item_eff)
end

function Mod_intensify_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_item_eff)
  self.uiBinder.anim:PlayOnce("anim_mod_intensify_popup_open")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Mod_intensify_popupView:OnRefresh()
end

return Mod_intensify_popupView
