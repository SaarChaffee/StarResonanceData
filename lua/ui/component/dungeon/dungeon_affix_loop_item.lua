local super = require("ui.component.loop_list_view_item")
local DungeonAffixLoopItem = class("DungeonAffixLoopItem", super)

function DungeonAffixLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self.vm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  self.affixCfgs_ = Z.TableMgr.GetTable("AffixTableMgr")
end

function DungeonAffixLoopItem:OnRefresh(data)
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
end

function DungeonAffixLoopItem:OnUnInit()
  Z.TipsVM.CloseItemTipsView()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

return DungeonAffixLoopItem
