local super = require("ui.component.loop_list_view_item")
local ModPreviewListTplItem = class("ModPreviewListTplItem", super)
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModPreviewListTplItem:OnInit()
  self.modData_ = Z.DataMgr.Get("mod_data")
end

function ModPreviewListTplItem:OnRefresh(data)
  self.data_ = data
  self.config_ = self.modData_:GetEffectTableConfig(self.data_.id, 0)
  if self.config_ then
    self.uiBinder.lab_off_name.text = self.config_.EffectName
    self.uiBinder.lab_on_name.text = self.config_.EffectName
  end
  ModGlossaryItemTplItem.RefreshTpl(self.uiBinder.node_glossary_item_tpl, self.data_.id)
  self.uiBinder.lab_off_lv.text = self.data_.lv .. "/" .. self.data_.maxLv
  self.uiBinder.lab_on_lv.text = self.data_.lv .. "/" .. self.data_.maxLv
  if self.data_.lv == self.data_.maxLv then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_max, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_max, false)
  end
  if self.data_.isSelect then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  end
end

function ModPreviewListTplItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectEffect(self.data_.id)
  end
end

function ModPreviewListTplItem:OnUnInit()
end

return ModPreviewListTplItem
