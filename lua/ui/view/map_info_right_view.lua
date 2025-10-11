local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_info_rightView = class("Map_info_rightView", super)
local loopListView = require("ui/component/loop_list_view")
local monsterRewardItem = require("ui/component/explore_monster/explore_monster_reward_item")

function Map_info_rightView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "map_info_right_sub", "map/map_info_right_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.pivotVM_ = Z.VMMgr.GetVM("pivot")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Map_info_rightView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self.closeByBtn_ = false
  self:AddClick(self.uiBinder.btn_close, function()
    self.closeByBtn_ = true
    self.parent_:CloseRightSubView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_single, function()
    if not self.flagData_.TpPointId then
      return
    end
    self.mapVM_.CheckTeleport(function()
      self.mapVM_.AsyncUserTp(self.sceneId_, self.flagData_.TpPointId)
      Z.UIMgr:GotoMainView()
    end)
  end)
  self:AddAsyncClick(self.uiBinder.btn_track, function()
    self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_notrack, function()
    self.mapVM_.ClearFlagDataTrackSource(self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_union, function()
    self.unionVM_:AsyncEnterUnionScene(self.cancelSource:CreateToken())
    Z.UIMgr:GotoMainView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_pathfinding, function()
    self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, self.parent_:GetCurSceneId(), self.flagData_)
    local pathFindingVM = Z.VMMgr.GetVM("path_finding")
    pathFindingVM:StartPathFindingByFlagData(self.parent_:GetCurSceneId(), self.flagData_)
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.uiBinder.tog_drop, function(isOn)
    if isOn then
      self:refreshLoopComp()
    end
  end)
  self:AddClick(self.uiBinder.tog_loot, function(isOn)
    if isOn then
      self:refreshLoopComp()
    end
  end)
  self.uiBinder.tog_drop.group = self.uiBinder.togs_tab
  self.uiBinder.tog_loot.group = self.uiBinder.togs_tab
  self:initLoopComp()
end

function Map_info_rightView:OnRefresh()
  self.flagData_ = self.viewData.flagData
  self.sceneId_ = self.parent_:GetCurSceneId()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_getaward, self.mapData_.IsShowRedInfo)
  self.mapData_.IsShowRedInfo = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_single, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_track, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_pathfinding, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_notrack, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reward, false)
  local tagRow = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(self.flagData_.TypeId)
  local descStr = tagRow.Description
  local nameStr = self.flagData_.Name
  local needCheckTrack = false
  if self.flagData_.FlagType == E.MapFlagType.Entity then
    if self.flagData_.SubType == E.SceneObjType.Transfer then
      local transferId = self.pivotVM_.GetTransferIdByUid(self.flagData_.Uid, self.sceneId_)
      if transferId then
        local transferTableRow = Z.TableMgr.GetTable("TransferTableMgr").GetRow(transferId)
        if transferTableRow then
          descStr = transferTableRow.TransferDec
        end
        if self.mapVM_.CheckTransferPointUnlock(transferId) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.btn_single, true)
        else
          self:ShowTrackBtn()
        end
      end
    elseif self.flagData_.SubType == E.SceneObjType.MonsterHunt then
      local monsterGlobalConfig = Z.TableMgr.GetLevelTableRow(E.LevelTableType.Monster, self.sceneId_, self.flagData_.Uid)
      if monsterGlobalConfig ~= nil then
        local monsterHuntListRow = Z.TableMgr.GetRow("MonsterHuntListTableMgr", monsterGlobalConfig.Id)
        if monsterHuntListRow ~= nil then
          descStr = monsterHuntListRow.Condition
        end
        local monsterRow = Z.TableMgr.GetRow("MonsterTableMgr", monsterGlobalConfig.Id)
        if monsterRow ~= nil then
          nameStr = monsterRow.Name
        end
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_reward, true)
        if self.uiBinder.tog_loot.isOn then
          self:refreshLoopComp()
        else
          self.uiBinder.tog_loot.isOn = true
        end
      end
      needCheckTrack = true
    elseif tagRow.Type == E.SceneTagType.SceneEnter then
      needCheckTrack = true
    elseif self:CheckUnionState() then
      needCheckTrack = false
    else
      needCheckTrack = true
    end
  elseif self.flagData_.FlagType == E.MapFlagType.NotEntity then
    needCheckTrack = true
  elseif self.flagData_.FlagType == E.MapFlagType.Position then
    needCheckTrack = true
  end
  if needCheckTrack and tagRow.TrackType > 0 then
    local trackRow = Z.TableMgr.GetTable("TargetTrackTableMgr").GetRow(tagRow.TrackType)
    if trackRow.MapTrack == 1 then
      self:ShowTrackBtn()
    end
  end
  local sceneTbl = Z.TableMgr.GetTable("SceneTableMgr")
  local sceneRow = sceneTbl.GetRow(self.sceneId_)
  if sceneRow then
    self.uiBinder.lab_place.text = sceneRow.Name
  end
  if nameStr ~= nil then
    self.uiBinder.lab_title.text = nameStr
  else
    local sceneTagTbl = Z.TableMgr.GetTable("SceneTagTableMgr")
    local seceneTagData = sceneTagTbl.GetRow(self.flagData_.TypeId)
    if seceneTagData then
      self.uiBinder.lab_title.text = seceneTagData.Name
    end
  end
  self.uiBinder.lab_content.text = descStr
end

function Map_info_rightView:OnDeActive()
  self:startAnimatedHide()
  self:unInitLoopComp()
  self.uiBinder.tog_drop:RemoveAllListeners()
  self.uiBinder.tog_loot:RemoveAllListeners()
end

function Map_info_rightView:ShowTrackBtn()
  local mapVM = Z.VMMgr.GetVM("map")
  local isTracking = mapVM.CheckIsTracingFlagByFlagData(self.parent_:GetCurSceneId(), self.viewData.flagData)
  if isTracking then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_notrack, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_track, true)
  end
  local isShow = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.PathFinding, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_pathfinding, isShow)
end

function Map_info_rightView:CheckUnionState()
  local isShowUnionBtn = false
  if self.flagData_.TypeId == E.SceneTagId.UnionEnter and self.unionVM_:CheckCanEnterUnionScene() then
    isShowUnionBtn = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_union, isShowUnionBtn)
  return isShowUnionBtn
end

function Map_info_rightView:startAnimatedShow()
  self.uiBinder.tween_container_comp:Restart(Z.DOTweenAnimType.Open)
end

function Map_info_rightView:startAnimatedHide()
  if self.closeByBtn_ then
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.uiBinder.tween_container_comp.CoroPlay)
      coro(self.uiBinder.tween_container_comp, Z.DOTweenAnimType.Close)
    end)()
  end
end

function Map_info_rightView:initLoopComp()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, monsterRewardItem, "com_item_square_8", true)
  self.loopListView_:Init({})
end

function Map_info_rightView:refreshLoopComp()
  local monsterGlobalConfig = Z.TableMgr.GetLevelTableRow(E.LevelTableType.Monster, self.sceneId_, self.flagData_.Uid)
  if monsterGlobalConfig == nil then
    return
  end
  local monsterHuntListRow = Z.TableMgr.GetRow("MonsterHuntListTableMgr", monsterGlobalConfig.Id)
  if monsterHuntListRow == nil then
    return
  end
  local awardPreviewVM = Z.VMMgr.GetVM("awardpreview")
  local dataList = {}
  local haveTreasureReward = monsterHuntListRow.TreasureBoxId and monsterHuntListRow.TreasureBoxId ~= 0
  self:SetUIVisible(self.uiBinder.lab_reward_tips, self.uiBinder.tog_drop.isOn)
  self:SetUIVisible(self.uiBinder.lab_reward_title, not haveTreasureReward)
  self:SetUIVisible(self.uiBinder.togs_tab, haveTreasureReward)
  if haveTreasureReward and self.uiBinder.tog_loot.isOn then
    local collectionConfig = Z.TableMgr.GetRow("CollectionTableMgr", monsterHuntListRow.TreasureBoxId)
    if collectionConfig ~= nil then
      dataList = awardPreviewVM.GetAllAwardPreListByIds(collectionConfig.AwardId)
    end
  elseif monsterHuntListRow.Award ~= 0 then
    dataList = awardPreviewVM.GetAllAwardPreListByIds(monsterHuntListRow.Award)
  end
  self.loopListView_:RefreshListView(dataList, true)
end

function Map_info_rightView:unInitLoopComp()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

return Map_info_rightView
