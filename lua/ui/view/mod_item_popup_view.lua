local UI = Z.UI
local super = require("ui.ui_view_base")
local Mod_item_popupView = class("Mod_item_popupView", super)
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function Mod_item_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mod_item_popup")
  self.modVM_ = Z.VMMgr.GetVM("mod")
  self.modData_ = Z.DataMgr.Get("mod_data")
end

function Mod_item_popupView:OnActive()
  self.uiBinder.Trans.parent = self.viewData.parent
  self.uiBinder.adapt_pos:UpdatePosition(self.viewData.parent, true, false, true)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("mod_item_popup")
  end)
  self.uiBinder.rect_content:SetAnchorPosition(0, 0)
  local config
  if self.viewData and self.viewData.config then
    config = self.viewData.config
  else
    config = self.modData_:GetEffectTableConfig(self.viewData.effectId, 0)
  end
  if config then
    ModGlossaryItemTplItem.RefreshTpl(self.uiBinder.mod_glossary_item_tpl, self.viewData.effectId, config.Level)
    self.uiBinder.lab_name.text = config.EffectName
    self.uiBinder.lab_lv.text = Lang("LvFormatSymbol", {
      val = config.Level
    })
    local allEffectConfigs = self.modData_:GetEffectTableConfigList(self.viewData.effectId)
    local val = {}
    local tempIndex = 0
    for index, effectConfig in ipairs(allEffectConfigs) do
      local level = index - 1
      if 0 < level then
        tempIndex = tempIndex + 1
        val[tempIndex] = self.modVM_.ParseModEffectDesc(self.viewData.effectId, level)
        tempIndex = tempIndex + 1
        val[tempIndex] = effectConfig.EnhancementNum
      end
    end
    self.uiBinder.lab_info_content_2.text = Z.Placeholder.Placeholder(config.EffectOverview, {val = val})
  end
end

function Mod_item_popupView:OnDeActive()
end

function Mod_item_popupView:OnRefresh()
end

return Mod_item_popupView
