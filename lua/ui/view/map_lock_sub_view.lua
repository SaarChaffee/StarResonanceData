local UI = Z.UI
local super = require("ui.ui_subview_base")
local Map_lock_subView = class("Map_lock_subView", super)

function Map_lock_subView:ctor(parent)
  self.uiBinder = nil
  self.parent_ = parent
  super.ctor(self, "map_lock_sub", "map/map_lock_sub", UI.ECacheLv.None)
end

function Map_lock_subView:OnActive()
  self:InitData()
  self:InitComponent()
end

function Map_lock_subView:OnDeActive()
  self:clearUnlockItem()
end

function Map_lock_subView:OnRefresh()
  self:refreshData()
  self:refreshPanelInfo()
end

function Map_lock_subView:InitData()
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Map_lock_subView:InitComponent()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddClick(self.uiBinder.btn_close, function()
    self.parent_:CloseRightSubView()
  end)
  self:AddClick(self.uiBinder.btn_operate, function()
    self:OnClickOperate()
  end)
  self:AddClick(self.uiBinder.btn_pathfinding, function()
    self:OnClickPathFinding()
  end)
end

function Map_lock_subView:refreshData()
  self.flagData_ = self.viewData.flagData
  self.targetSceneId_ = self.viewData.sceneId
  self.curSceneId_ = self.viewData.curSceneId
end

function Map_lock_subView:refreshPanelInfo()
  self:SetUIVisible(self.uiBinder.btn_operate, false)
  self:SetUIVisible(self.uiBinder.btn_pathfinding, false)
  self:SetUIVisible(self.uiBinder.node_area_name, false)
  local topOffset = 138
  if self.curSceneId_ ~= nil then
    local curSceneRow = Z.TableMgr.GetRow("SceneTableMgr", self.curSceneId_)
    if curSceneRow then
      self.uiBinder.lab_scene_name.text = curSceneRow.Name
      self:SetUIVisible(self.uiBinder.node_area_name, true)
      topOffset = 176
    end
  end
  self.uiBinder.node_desc:SetOffsetMax(0, -topOffset)
  self:refreshUnlockInfo()
  local curSceneTagId = self.flagData_ and self.flagData_.TypeId or self:getSceneTagIdBySceneId(self.targetSceneId_)
  if curSceneTagId == nil then
    return
  end
  local sceneTagRow = Z.TableMgr.GetRow("SceneTagTableMgr", curSceneTagId)
  if sceneTagRow == nil then
    return
  end
  self.uiBinder.lab_title.text = sceneTagRow.Name
  self.uiBinder.lab_content.text = sceneTagRow.Description
  if self.flagData_ ~= nil and 0 < sceneTagRow.TrackType then
    local trackRow = Z.TableMgr.GetRow("TargetTrackTableMgr", sceneTagRow.TrackType)
    if trackRow.MapTrack == 1 then
      local curSceneId = self.targetSceneId_
      if self.parent_.GetCurSceneId then
        curSceneId = self.parent_:GetCurSceneId()
      end
      local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(curSceneId, self.flagData_)
      self.uiBinder.lab_operate.text = isTracking and Lang("cancleTrace") or Lang("trace")
      self:SetUIVisible(self.uiBinder.btn_operate, true)
      local isShow = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.PathFinding, true)
      self:SetUIVisible(self.uiBinder.btn_pathfinding, isShow)
    end
  end
end

function Map_lock_subView:refreshUnlockInfo()
  local targetSceneRow = Z.TableMgr.GetRow("SceneTableMgr", self.targetSceneId_)
  if targetSceneRow == nil then
    return
  end
  local unlockDescList = Z.ConditionHelper.GetConditionDescList(targetSceneRow.MapEntryCondition)
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearUnlockItem()
    self:createUnlockItem(unlockDescList)
  end)()
end

function Map_lock_subView:createUnlockItem(descList)
  local unitPath = self.uiBinder.comp_ui_cache:GetString("lock_item")
  for index, info in ipairs(descList) do
    local unitParent = self.uiBinder.node_lock
    local unitName = string.zconcat("item_unlock_", index)
    local unitToken = self.cancelSource:CreateToken()
    self.unlockUnitTokenDict_[unitName] = unitToken
    local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
    self.unlockUnitDict_[unitName] = unitItem
    unitItem.lab_unlock_conditions.text = Z.RichTextHelper.ApplyColorTag(info.Desc, "#FFFFFF")
    unitItem.Ref:SetVisible(unitItem.img_on, info.IsUnlock)
    unitItem.Ref:SetVisible(unitItem.img_off, not info.IsUnlock)
  end
end

function Map_lock_subView:clearUnlockItem()
  if self.unlockUnitTokenDict_ then
    for unitName, unitToken in pairs(self.unlockUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.unlockUnitTokenDict_ = {}
  if self.unlockUnitDict_ then
    for unitName, unitItem in pairs(self.unlockUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.unlockUnitDict_ = {}
end

function Map_lock_subView:getSceneTagIdBySceneId(sceneId)
  local sceneTagTable = Z.TableMgr.GetTable("SceneTagTableMgr")
  local configDict = sceneTagTable.GetDatas()
  for id, config in pairs(configDict) do
    if config.Type == E.SceneTagType.SceneEnter and tonumber(config.Param) == sceneId then
      return id
    end
  end
end

function Map_lock_subView:OnClickOperate()
  if self.flagData_ == nil then
    return
  end
  local curSceneId = self.targetSceneId_
  if self.parent_.GetCurSceneId then
    curSceneId = self.parent_:GetCurSceneId()
  end
  local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(curSceneId, self.flagData_)
  if isTracking then
    self.mapVM_.ClearFlagDataTrackSource(curSceneId, self.flagData_)
  else
    self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, curSceneId, self.flagData_)
  end
  self.parent_:CloseRightSubView()
end

function Map_lock_subView:OnClickPathFinding()
  local curSceneId = self.targetSceneId_
  if self.parent_.GetCurSceneId then
    curSceneId = self.parent_:GetCurSceneId()
  end
  self.mapVM_.SetMapTraceByFlagData(E.GoalGuideSource.MapFlag, curSceneId, self.flagData_)
  local pathFindingVM = Z.VMMgr.GetVM("path_finding")
  pathFindingVM:StartPathFindingByFlagData(curSceneId, self.flagData_)
  self.parent_:CloseRightSubView()
end

return Map_lock_subView
