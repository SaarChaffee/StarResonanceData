local super = require("ui.component.loop_list_view_item")
local DungeonOpenAffixLoopItem = class("DungeonOpenAffixLoopItem", super)

function DungeonOpenAffixLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.affixCfgs_ = Z.TableMgr.GetTable("AffixTableMgr")
end

function DungeonOpenAffixLoopItem:OnRefresh(data)
  local affixId = data.affixId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_clock, self.vm_.IsRegularAffix({}, affixId))
  self.parentView_:AddClick(self.uiBinder.btn_affix, function()
    Z.CommonTipsVM.OpenAffixTips({affixId}, self.parentView_.uiBinder.node_affix)
  end)
  local cfg = self.affixCfgs_.GetRow(affixId)
  if cfg then
    self.uiBinder.img_affix:SetImage(cfg.Icon)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_kay, data.isKey == true)
  self.uiBinder.lab_name.text = cfg.Name
  self.uiBinder.lab_content.text = cfg.Description
  local size = self.uiBinder.lab_content:GetPreferredValues(1194, 78)
  self.uiBinder.lab_content_trans:SetHeight(size.y)
  self.uiBinder.Trans:SetHeight(size.y + 90)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function DungeonOpenAffixLoopItem:OnUnInit()
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

return DungeonOpenAffixLoopItem
