local super = require("ui.component.loop_grid_view_item")
local ModRecommendTplItem = class("ModRecommendTplItem", super)
local MOD_DEFINE = require("ui.model.mod_define")
local modGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModRecommendTplItem:ctor()
  self.uiBinder = nil
  self.modData_ = Z.DataMgr.Get("mod_data")
end

function ModRecommendTplItem:OnInit()
  self.uiBinder.tog:RemoveAllListeners()
  self.uiBinder.tog:AddListener(function(isOn)
    if isOn then
      self.parent.UIView.SelectEffectId[self.data_.Id] = self.data_.Id
    else
      self.parent.UIView.SelectEffectId[self.data_.Id] = nil
    end
  end, true)
  self.uiBinder.btn_effect:RemoveAllListeners()
  self.uiBinder.btn_effect:AddListener(function()
    local viewData = {
      parent = self.parent.UIView.uiBinder.node_info,
      effectId = self.data_.Id
    }
    Z.UIMgr:OpenView("mod_item_popup", viewData)
  end, true)
end

function ModRecommendTplItem:OnRefresh(data)
  self.data_ = data
  local modEffectConfig = self.modData_:GetEffectTableConfig(self.data_.Id, 0)
  if modEffectConfig then
    self.uiBinder.lab_name_on.text = modEffectConfig.EffectName
    self.uiBinder.lab_name_off.text = modEffectConfig.EffectName
  end
  modGlossaryItemTplItem.RefreshTpl(self.uiBinder.node_glossary_item_tpl, self.data_.Id, 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_recommend, self.data_.recommend)
  self.uiBinder.tog:SetIsOnWithoutCallBack(self.data_.isOn)
end

function ModRecommendTplItem:OnUnInit()
end

return ModRecommendTplItem
