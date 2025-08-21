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
  self.uiBinder = nil
  super.ctor(self, "task_pace_tpl", "main/track/task_pace_tpl", UI.ECacheLv.None, true)
  self.parentView_ = parent
  self.dungeonTrackVm_ = Z.VMMgr.GetVM("dungeon_track")
  self.trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  self.stepId_ = 1
  self.targetItemDic_ = {}
  self.targetItemTrialRoadDic_ = {}
  self.targetShowDic_ = {}
end

function Dungeon_trackView:OnActive()
  self.bShowAnim = false
  self:BindEvents()
end

function Dungeon_trackView:showPanel()
  local isDungeonStage = Z.StageMgr.IsDungeonStage()
  self.isShow_ = false
  if isDungeonStage and self:CheckDungeonTargetsAvailable() then
    self.isShow_ = true
  end
  self:showTrackView()
end

function Dungeon_trackView:CheckDungeonTargetsAvailable()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local targetDataDic = Z.ContainerMgr.DungeonSyncData.target.targetData
  return dungeonsTable and #dungeonsTable.DungeonTarget > 0 and 0 < table.zcount(targetDataDic)
end

function Dungeon_trackView:OnDeActive()
  self:ClearAllUnitFlag()
  self:UnInitAllUnit()
end

function Dungeon_trackView:showTrackView()
  if not self.isShow_ then
    self:clearAndHide()
    return
  end
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  self.stepId_ = dungeonData:GetDungeonTargetData("step")
  if self.stepId_ == -1 then
    self:clearAndHide()
    return
  end
  self:SetUIVisible(self.uiBinder.rebuilder_layout, dungeonData.TrackViewShow)
  self:showTargetDataView()
end

function Dungeon_trackView:clearAndHide()
  self:SetUIVisible(self.uiBinder.rebuilder_layout, false)
  self:ClearAllUnits()
end

function Dungeon_trackView:showTargetDataView()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    self:loadTrackUnit(self.trialroadVM_.IsTrialRoad())
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
  self:SetUIVisible(self.uiBinder.rebuilder_layout, dungeonData.TrackViewShow)
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
  if not self.units or table.zcount(self.units) == 0 then
    return
  end
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

function Dungeon_trackView:UnInitAllUnit()
  for targetId, _ in pairs(self.targetShowDic_) do
    local unitName = self:GetUnitName(targetId)
    self:RemoveUiUnit(unitName)
  end
  self.targetShowDic_ = {}
  for _, item in pairs(self.targetItemDic_) do
    item:UnInit()
  end
  self.targetItemDic_ = {}
  for _, item in pairs(self.targetItemTrialRoadDic_) do
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
    self:loadTrackUnit(self.trialroadVM_.IsTrialRoad())
  end)()
end

function Dungeon_trackView:loadTrackUnit(isTrialRoad)
  local targetDataDic = Z.ContainerMgr.DungeonSyncData.target.targetData
  if table.zcount(targetDataDic) == 0 then
    return
  end
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTable then
    return
  end
  local stepId = isTrialRoad == true and 1 or self.stepId_
  local targetArray = dungeonsTable.DungeonTarget[stepId]
  for _, targetId in ipairs(targetArray) do
    self:processTarget(targetId, targetDataDic, isTrialRoad)
  end
  self.uiBinder.rebuilder_layout:ForceRebuildLayoutImmediate()
  if 0 < #targetArray and not self.bShowAnim then
    self.bShowAnim = true
    self:playTweenAnimation()
  end
  self:UnInitNoUsedUnit()
end

function Dungeon_trackView:processTarget(targetId, targetDataDic, isTrialRoad)
  local targetData = targetDataDic[targetId]
  local targetCfg = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
  if not targetCfg then
    return
  end
  if not targetData then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    logError("dungeonId = {0}, targetId = {1}, isTrialRoad = {2}", dungeonId, targetId, isTrialRoad)
    logError(table.ztostring(targetDataDic))
    return
  end
  local unitName = self:GetUnitName(targetId)
  local mainUnit = self.units[unitName]
  local targetItem = isTrialRoad and self.targetItemTrialRoadDic_[targetId] or self.targetItemDic_[targetId]
  if not mainUnit then
    self:loadNewUnit(targetId, unitName, targetData, targetItem, isTrialRoad)
  else
    self.targetShowDic_[targetId] = true
    if targetItem then
      targetItem:SetData(targetData)
    end
  end
end

function Dungeon_trackView:loadNewUnit(targetId, unitName, targetData, targetItem, isTrialRoad)
  if targetItem then
    targetItem:UnInit()
  end
  local path = Z.IsPCUI and UnitPath.MainPC or UnitPath.Main
  local targetItemDict = isTrialRoad and self.targetItemTrialRoadDic_ or self.targetItemDic_
  if isTrialRoad then
    path = Z.IsPCUI and UnitPath.TrialRoadPC or UnitPath.TrialRoad
  end
  local mainUnit = self:AsyncLoadUiUnit(path, unitName, self.uiBinder.rebuilder_layout.transform)
  if not mainUnit then
    return
  end
  targetItem = isTrialRoad and trackTargetTrialroadItem.new() or trackTargetItem.new()
  targetItem:Init(mainUnit, self)
  targetItemDict[targetId] = targetItem
  self.targetShowDic_[targetId] = true
  targetItem:SetData(targetData)
end

function Dungeon_trackView:playTweenAnimation()
  self.parentView_:ReplayOpenAnim()
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
  self:SetUIVisible(self.uiBinder.rebuilder_layout, self.isShow_)
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
    self:SetUIVisible(self.uiBinder.rebuilder_layout, false)
    self:ClearAllUnits()
    return
  end
  self:SetUIVisible(self.uiBinder.rebuilder_layout, dungeonData.TrackViewShow)
  self:UpdateTargetItemByContain()
end

function Dungeon_trackView:OnRefresh()
  self:showPanel()
end

return Dungeon_trackView
