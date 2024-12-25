local UnitPath = {
  Main = "ui/prefabs/main/track/task_pace_main_tpl",
  MainPC = "ui/prefabs/main/track/task_pace_main_tpl_pc",
  TrialRoad = "ui/prefabs/main/track/task_goal_item_tpl",
  TrialRoadPC = "ui/prefabs/main/track/task_goal_item_tpl_pc"
}
local trackTargetItem = require("ui.component.dungeon_track.track_target_item")
local trackTargetTrialroadItem = require("ui.component.dungeon_track.track_target_trialroad_item")
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Dungeon_trackView = class("Dungeon_trackView", super)

function Dungeon_trackView:ctor(parent)
  self.panel = nil
  local assetPath = Z.IsPCUI and "main/track/task_pace_tpl_pc" or "main/track/task_pace_tpl"
  super.ctor(self, "task_pace_tpl", assetPath, UI.ECacheLv.None)
  self.dungeonTrackVm_ = Z.VMMgr.GetVM("dungeon_track")
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.stepId_ = 1
  self.targetItemDic_ = {}
  self.targetItemTrialRoadDic_ = {}
  self.targetShowDic_ = {}
  self.finishQuestId = {}
end

function Dungeon_trackView:OnActive()
  self.layout_ = self.panel.layout_task
  self.parentPanel = self.viewData
  self.bShowAnim = false
  self:BindEvents()
end

function Dungeon_trackView:showPanel()
  self.isShow_ = false
  if Z.StageMgr.GetCurrentStageType() == Z.EStageType.Dungeon or Z.StageMgr.GetCurrentStageType() == Z.EStageType.MirrorDungeon then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    local targetDataDic = Z.ContainerMgr.DungeonSyncData.target.targetData
    if dungeonsTable and #dungeonsTable.DungeonTarget > 0 and 0 < table.zcount(targetDataDic) then
      self.isShow_ = true
    end
  end
  self:showTrackView()
end

function Dungeon_trackView:OnDeActive()
  self:ClearAllUnitFlag()
  self:UnInitAllUnit()
end

function Dungeon_trackView:showTrackView()
  if not self.isShow_ then
    self.panel.layout_task:SetVisible(false)
    self:ClearAllUnits()
    return
  end
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  self.stepId_ = dungeonData:GetDungeonTargetData("step")
  if self.stepId_ == -1 then
    self.panel.layout_task:SetVisible(false)
    self:ClearAllUnits()
    return
  end
  self.panel.layout_task:SetVisible(dungeonData.TrackViewShow)
  self:showTargetDataView()
end

function Dungeon_trackView:showTargetDataView()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.trialroadVM_.IsTrialRoad() then
      self:loadTrackTrialRoadBinder()
    else
      self:loadTrackUnit()
    end
  end)()
end

function Dungeon_trackView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Dungeon.UpdateTrackView, self.updateTrackViewBySever, self)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.TargetResetData, self.resetTrackView, self)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.TrackAnimPlay, self.animPlayFlagChange, self)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.UpdateTargetViewVisible, self.SetViewVisible, self)
end

function Dungeon_trackView:animPlayFlagChange()
  self.bShowAnim = false
end

function Dungeon_trackView:SetViewVisible()
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  self.layout_:SetVisible(dungeonData.TrackViewShow)
end

function Dungeon_trackView:ClearAllUnitFlag()
  if self.cancelTokens ~= nil then
    for key, value in pairs(self.cancelTokens) do
      if self.cancelTokens[key] then
        Z.CancelSource.ReleaseToken(self.cancelTokens[key])
        self.cancelTokens[key] = nil
      end
    end
  end
  if self.units ~= nil then
    for targetId, _ in pairs(self.targetShowDic_) do
      self.targetShowDic_[targetId] = false
    end
  end
end

function Dungeon_trackView:UnInitNoUsedUnit()
  if self.units ~= nil then
    for targetId, _ in pairs(self.targetShowDic_) do
      if self.targetShowDic_[targetId] == false then
        local unitName = self:GetUnitName(targetId)
        self:RemoveUiUnit(unitName)
        if self.targetItemDic_[targetId] then
          self.targetItemDic_[targetId]:UnInit()
          self.targetItemDic_[targetId] = nil
        end
        if self.targetItemTrialRoadDic_[targetId] then
          self.targetItemTrialRoadDic_[targetId]:UnInit()
          self.targetItemTrialRoadDic_[targetId] = nil
        end
        self.targetShowDic_[targetId] = nil
      end
    end
  end
end

function Dungeon_trackView:UnInitAllUnit()
  for targetId, _ in pairs(self.targetShowDic_) do
    local unitName = self:GetUnitName(targetId)
    self:RemoveUiUnit(unitName)
  end
  self.targetShowDic_ = {}
  for targetId, item in pairs(self.targetItemDic_) do
    item:UnInit()
  end
  self.targetItemDic_ = {}
  for targetId, item in pairs(self.targetItemTrialRoadDic_) do
    item:UnInit()
  end
  self.targetItemTrialRoadDic_ = {}
end

function Dungeon_trackView:GetUnitName(targetId)
  return string.format("main%d", targetId)
end

function Dungeon_trackView:UpdateTargetItemByContain()
  self:ClearAllUnitFlag()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.trialroadVM_.IsTrialRoad() then
      self:loadTrackTrialRoadBinder()
    else
      self:loadTrackUnit()
    end
  end)()
end

function Dungeon_trackView:loadTrackTrialRoadBinder()
  local targetDataDic = Z.ContainerMgr.DungeonSyncData.target.targetData
  if table.zcount(targetDataDic) == 0 then
    return
  end
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local targetArray
  if dungeonsTable == nil then
    return
  end
  targetArray = dungeonsTable.DungeonTarget[1]
  for i = 1, #targetArray do
    local targetId = targetArray[i]
    local targetData = targetDataDic[targetId]
    local targetCfg = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
    if targetCfg == nil then
      return
    end
    local unitName = self:GetUnitName(targetId)
    local mainUnit = self.units[unitName]
    local targetItem = self.targetItemTrialRoadDic_[targetId]
    if mainUnit == nil then
      local path = Z.IsPCUI and UnitPath.TrialRoadPC or UnitPath.TrialRoad
      mainUnit = self:AsyncLoadUiUnit(path, unitName, self.panel.layout_task.Trans)
      if mainUnit == nil then
        return
      end
      targetItem = trackTargetTrialroadItem.new()
      targetItem:Init(mainUnit, self)
      self.targetItemTrialRoadDic_[targetId] = targetItem
    end
    self.targetShowDic_[targetId] = true
    targetItem:SetData(targetData)
  end
  self.layout_.ZLayout:ForceRebuildLayoutImmediate()
  if 0 < #targetArray and not self.bShowAnim then
    self.bShowAnim = true
    self.parentPanel.node_parent.TweenContainer:Rewind(Panda.ZUi.DOTweenAnimType.Open)
    self.parentPanel.node_parent.TweenContainer:Restart(Panda.ZUi.DOTweenAnimType.Open)
  end
  self:UnInitNoUsedUnit()
end

function Dungeon_trackView:loadTrackUnit()
  local targetDataDic = Z.ContainerMgr.DungeonSyncData.target.targetData
  if table.zcount(targetDataDic) == 0 then
    return
  end
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local targetArray
  if dungeonsTable == nil then
    return
  end
  targetArray = dungeonsTable.DungeonTarget[self.stepId_]
  for i = 1, #targetArray do
    local targetId = targetArray[i]
    local targetData = targetDataDic[targetId]
    local targetCfg = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
    if targetCfg == nil then
      return
    end
    local unitName = self:GetUnitName(targetId)
    local mainUnit = self.units[unitName]
    local targetItem = self.targetItemDic_[targetId]
    if mainUnit == nil then
      if targetItem then
        targetItem:UnInit()
      end
      local path = Z.IsPCUI and UnitPath.MainPC or UnitPath.Main
      mainUnit = self:AsyncLoadUiUnit(path, unitName, self.panel.layout_task.Trans)
      if mainUnit == nil then
        return
      end
      targetItem = trackTargetItem.new()
      targetItem:Init(mainUnit, self)
      self.targetItemDic_[targetId] = targetItem
    end
    self.targetShowDic_[targetId] = true
    targetItem:SetData(targetData, nil)
  end
  self.layout_.ZLayout:ForceRebuildLayoutImmediate()
  if 0 < #targetArray and not self.bShowAnim then
    self.bShowAnim = true
    self.parentPanel.node_parent.TweenContainer:Rewind(Panda.ZUi.DOTweenAnimType.Open)
    self.parentPanel.node_parent.TweenContainer:Restart(Panda.ZUi.DOTweenAnimType.Open)
  end
  self:UnInitNoUsedUnit()
end

function Dungeon_trackView:resetTrackView()
  self.isShow_ = false
  if Z.StageMgr.GetCurrentStageType() == Z.EStageType.Dungeon or Z.StageMgr.GetCurrentStageType() == Z.EStageType.MirrorDungeon then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if dungeonsTable and #dungeonsTable.DungeonTarget > 0 then
      self.isShow_ = true
    end
  end
  self.panel.layout_task:SetVisible(self.isShow_)
  if not self.isShow_ then
    self:ClearAllUnits()
    return
  end
  self.bShowAnim = false
  self:updateTrackViewBySever()
end

function Dungeon_trackView:updateTrackViewBySever()
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  self.stepId_ = dungeonData:GetDungeonTargetData("step")
  if self.stepId_ == -1 and not self.trialroadVM_.IsTrialRoad() then
    self.panel.layout_task:SetVisible(false)
    self:ClearAllUnits()
    return
  end
  self.panel.layout_task:SetVisible(dungeonData.TrackViewShow)
  self:UpdateTargetItemByContain()
end

function Dungeon_trackView:BindLuaAttrWatchers()
end

function Dungeon_trackView:OnRefresh()
  self:showPanel()
end

return Dungeon_trackView
