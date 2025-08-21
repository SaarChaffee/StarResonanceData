local UI = Z.UI
local super = require("ui.ui_view_base")
local Hero_dungeon_begin_ready_tplView = class("Hero_dungeon_begin_ready_tplView", super)

function Hero_dungeon_begin_ready_tplView:ctor()
  self.uiBinder = nil
  super.ctor(self, "hero_dungeon_begin_ready_tpl")
  self.heroDungeonVm_ = Z.VMMgr.GetVM("hero_dungeon_main")
end

function Hero_dungeon_begin_ready_tplView:OnActive()
  self.isSetUIViewInputIgnore_ = true
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.uidepth:AddChildDepth(self.uiBinder.node_effect)
  self.uiBinder.anim:PlayOnce("anim_hero_dungeon_begin_ready_tpl_open")
  self.uiBinder.lab_title.text = Lang("Ready!")
  local time = 0
  self.timerMgr:StartTimer(function()
    time = time + 1
    if time == Z.Global.DungeonReadyToGoTime then
      if self.isSetUIViewInputIgnore_ then
        self.isSetUIViewInputIgnore_ = false
        Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
      end
      self.uiBinder.lab_title.text = Lang("Start!")
    end
  end, 1, Z.Global.DungeonStartCountDownTime, nil, function()
    self.heroDungeonVm_.CloseBeginReadyView()
  end)
end

function Hero_dungeon_begin_ready_tplView:OnDeActive()
  if self.isSetUIViewInputIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  end
  self.uiBinder.uidepth:RemoveChildDepth(self.uiBinder.node_effect)
end

function Hero_dungeon_begin_ready_tplView:OnRefresh()
end

return Hero_dungeon_begin_ready_tplView
