local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_master_share_windowView = class("Hero_dungeon_master_share_windowView", super)
local hero_dungeon_master_scoreTpl = require("ui.component.hero_dungeon.hero_dungeon_master_score_tpl")

function Hero_dungeon_master_share_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_master_share_window")
  self.heroDungeonMasterScoreTpl = hero_dungeon_master_scoreTpl.new(self)
end

function Hero_dungeon_master_share_windowView:OnActive()
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("hero_dungeon_master_share_window")
  end)
  self.heroDungeonMasterScoreTpl:Init(self.uiBinder.hero_dungeon_master_share_tpl, self.viewData)
end

function Hero_dungeon_master_share_windowView:OnDeActive()
  self.heroDungeonMasterScoreTpl:UnInit()
end

function Hero_dungeon_master_share_windowView:OnRefresh()
end

return Hero_dungeon_master_share_windowView
