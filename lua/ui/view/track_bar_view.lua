local UI = Z.UI
local super = require("ui.ui_subview_base")
local questTrackView = require("ui.view.quest_track_view")
local dungeonTrackView = require("ui.view.dungeon_track_view")
local Track_barView = class("Track_barView", super)

function Track_barView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "track_bar_sub", "main/track/track_bar_sub", UI.ECacheLv.None, true)
  self.questTrackView_ = questTrackView.new(self)
  self.dungeonTrackView_ = dungeonTrackView.new(self)
  self.eventTrackComp_ = require("ui.component.dungeon_track.track_event_comp").new()
  
  function self.onDungeonEventChange_(container, dirtyKeys)
    self.eventTrackComp_:RefreshUnits(container, dirtyKeys)
  end
end

function Track_barView:OnActive()
  self:startAnimatedShow()
  self.questTrackView_:Active(nil, self.uiBinder.trans_quest_track)
  self.dungeonTrackView_:Active(nil, self.uiBinder.trans_dungeon_track)
  if Z.IsPCUI then
    local width, height = self.uiBinder.trans_pc_high:GetSize(nil, nil)
    self.uiBinder.scrollview.transform:SetHeight(height)
  end
  self:BindEvents()
  local compData = {}
  compData.dungeonEvent = Z.ContainerMgr.DungeonSyncData.dungeonEvent
  self.eventTrackComp_:Init(self, self.uiBinder.trans_event_track, compData)
  Z.ContainerMgr.DungeonSyncData.dungeonEvent.Watcher:RegWatcher(self.onDungeonEventChange_)
end

function Track_barView:OnRefresh()
end

function Track_barView:OnDeActive()
  self.questTrackView_:DeActive()
  self.dungeonTrackView_:DeActive()
  self.uiBinder.scrollview:ClearAll()
  Z.ContainerMgr.DungeonSyncData.dungeonEvent.Watcher:UnregWatcher(self.onDungeonEventChange_)
  self.eventTrackComp_:UnInit()
end

function Track_barView:BindEvents()
end

function Track_barView:startAnimatedShow()
  self.uiBinder.comp_tween_provider:Restart(Z.DOTweenAnimType.Open)
end

function Track_barView:ReplayOpenAnim()
  self.uiBinder.comp_tween_provider:Rewind(Z.DOTweenAnimType.Open)
  self.uiBinder.comp_tween_provider:Restart(Z.DOTweenAnimType.Open)
end

function Track_barView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_tween_provider.CoroPlay)
  coro(self.uiBinder.comp_tween_provider, Z.DOTweenAnimType.Close)
end

return Track_barView
