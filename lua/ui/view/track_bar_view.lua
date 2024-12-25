local UI = Z.UI
local super = require("ui.ui_subview_base")
local questTrackView = require("ui.view.quest_track_view")
local dungeonTrackView = require("ui.view.dungeon_track_view")
local Track_barView = class("Track_barView", super)

function Track_barView:ctor(parent)
  self.panel = nil
  local assetPath = Z.IsPCUI and "main/track/track_bar_sub_pc" or "main/track/track_bar_sub"
  super.ctor(self, "track_bar_sub", assetPath, UI.ECacheLv.None)
  self.questTrackView_ = questTrackView.new()
  self.dungeonTrackView_ = dungeonTrackView.new()
  self.eventTrackComp_ = require("ui.component.dungeon_track.track_event_comp").new()
  
  function self.onDungeonEventChange_(container, dirtyKeys)
    self.eventTrackComp_:RefreshUnits(container, dirtyKeys)
  end
end

function Track_barView:OnActive()
  self:startAnimatedShow()
  self.questTrackView_:Active(nil, self.panel.quest_track.Trans)
  self.dungeonTrackView_:Active(self.panel, self.panel.dungeon_track.Trans)
  if Z.IsPCUI then
    local pcSize = self.panel.node_pc_high.Ref:GetSize()
    self.panel.scrollview.Ref:SetHeight(pcSize.y)
  end
  self:BindEvents()
  local compData = {}
  compData.dungeonEvent = Z.ContainerMgr.DungeonSyncData.dungeonEvent
  self.eventTrackComp_:Init(self, self.panel.event_track.Trans, compData)
  Z.ContainerMgr.DungeonSyncData.dungeonEvent.Watcher:RegWatcher(self.onDungeonEventChange_)
end

function Track_barView:OnRefresh()
end

function Track_barView:OnDeActive()
  self.questTrackView_:DeActive()
  self.dungeonTrackView_:DeActive()
  self.panel.scrollview.Scroll:ClearAll()
  Z.ContainerMgr.DungeonSyncData.dungeonEvent.Watcher:UnregWatcher(self.onDungeonEventChange_)
  self.eventTrackComp_:UnInit()
end

function Track_barView:BindEvents()
end

function Track_barView:startAnimatedShow()
  self.panel.node_parent.TweenContainer:Restart(Z.DOTweenAnimType.Open)
end

function Track_barView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.panel.node_parent.TweenContainer.CoroPlay)
  coro(self.panel.node_parent.TweenContainer, Z.DOTweenAnimType.Close)
end

return Track_barView
