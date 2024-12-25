local super = require("ui.component.loop_list_view_item")
local ModFantasyListTplItem = class("ModFantasyListTplItem", super)
local ModGlossaryItemTplItem = require("ui.component.mod.mod_glossary_item_tpl_item")

function ModFantasyListTplItem:OnInit()
  self.modData_ = Z.DataMgr.Get("mod_data")
  self.modVM_ = Z.VMMgr.GetVM("mod")
end

function ModFantasyListTplItem:OnRefresh(data)
  self.data_ = data
  self.config_ = self.modData_:GetEffectTableConfig(self.data_.id, self.data_.lv)
  if self.config_ then
    self.uiBinder.lab_name.text = self.config_.EffectName
    self.uiBinder.lab_lv.text = Lang("Lv") .. self.data_.lv .. "/" .. self.data_.maxLv
    ModGlossaryItemTplItem.RefreshTpl(self.uiBinder.node_item, self.data_.id, self.data_.lv)
  end
  local desc = self.modVM_.ParseModEffectDesc(self.data_.id, self.data_.lv)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_info_off, desc)
  Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.uiBinder.lab_info_on, desc)
  if self.data_.curLv then
    if self.data_.curLv == -1 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_ineffect, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
      self.uiBinder.canvas_root.alpha = 1
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_off, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_on, false)
    else
      local isCurLv = self.data_.curLv == self.data_.lv
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_ineffect, isCurLv)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isCurLv)
      if self.data_.lv <= self.data_.curLv then
        self.uiBinder.canvas_root.alpha = 1
        if self.data_.lv == self.data_.curLv then
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_off, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_on, true)
        else
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_off, true)
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_on, false)
        end
      else
        self.uiBinder.canvas_root.alpha = 0.2
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_off, true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_on, false)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_ineffect, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
    self.uiBinder.canvas_root.alpha = 0.2
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_off, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_info_on, false)
  end
end

function ModFantasyListTplItem:OnUnInit()
  Z.CommonTipsVM.CloseRichText()
end

return ModFantasyListTplItem
