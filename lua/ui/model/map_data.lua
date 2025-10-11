local super = require("ui.model.data_base")
local MapData = class("MapData", super)
E.MapFlagEffectType = {Trace = 1, WorldQuest = 2}
local COLLECTION_POS_OFFSET = 10000000000

function MapData:ctor()
  super.ctor(self)
  self.MapEffectPathDict = {
    [E.MapFlagEffectType.Trace] = "ui/prefabs/map/map_effect_trace_tpl",
    [E.MapFlagEffectType.WorldQuest] = "ui/prefabs/map/map_effect_worldquest_tpl"
  }
  self:ResetMapData()
end

function MapData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function MapData:UnInit()
  self.CancelSource:Recycle()
end

function MapData:Clear()
  self:ResetMapData()
end

function MapData:ResetMapData()
  self:ResetMapAreaData()
  self.AutoSelectTrackSrc = nil
  self.AutoSelectFlagId = nil
  self.IsShowRedInfo = false
  self.TracingFlagData = nil
  self.showProportion_ = nil
  self.focus_ = nil
  self.targetCollectionId_ = nil
  self.dynamicTraceParams_ = nil
  self.collectionPosInfoDict_ = nil
end

function MapData:ResetMapAreaData()
  self.CurAreaId = 0
  self.IsHadShownAreaName = false
end

function MapData:SetMapFlagVisibleSettingByTypeId(id, isShow)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "BKL_MAP_FLAG_VISIBLE" .. tostring(id), isShow)
end

function MapData:GetMapFlagVisibleSettingByTypeId(id)
  return Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "BKL_MAP_FLAG_VISIBLE" .. tostring(id), true)
end

function MapData:SetShowProportion(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_PROP_TAG", value)
  self.showProportion_ = value
end

function MapData:GetShowProportion()
  local data
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "BKL_PROP_TAG") then
    data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_PROP_TAG")
  else
    data = E.ShowProportionType.Middle
  end
  self:SetShowProportion(data)
  return data
end

function MapData:SetViewFocus(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_FOCUS_TAG", value)
  self.focus_ = value
end

function MapData:GetViewFocus()
  local data
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "BKL_FOCUS_TAG") then
    data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_FOCUS_TAG")
  else
    data = E.ViewFocusType.focusDir
    self:SetViewFocus(data)
  end
  return data
end

function MapData:SetTargetCollectionId(id)
  self.targetCollectionId_ = id
  Z.EventMgr:Dispatch(Z.ConstValue.MapCollectionChange)
end

function MapData:GetTargetCollectionId()
  return self.targetCollectionId_
end

function MapData:SaveDynamicTraceParam(sceneId, sourceType, posType, uid, param, position)
  self:RemoveGoalDynamicTrace()
  self.dynamicTraceParams_ = {
    SceneId = sceneId,
    SourceType = sourceType,
    PosType = posType,
    Uid = uid,
    Param = param,
    Position = position
  }
  Z.EventMgr:Dispatch(Z.ConstValue.MapDynamicFlagChange)
end

function MapData:ClearDynamicTraceParam()
  self:RemoveGoalDynamicTrace()
  self.dynamicTraceParams_ = nil
  Z.EventMgr:Dispatch(Z.ConstValue.MapDynamicFlagChange)
end

function MapData:RemoveGoalDynamicTrace()
  if self.dynamicTraceParams_ ~= nil then
    local sceneId = self.dynamicTraceParams_.SceneId
    local sourceType = self.dynamicTraceParams_.SourceType
    local posType = self.dynamicTraceParams_.PosType
    local uid = self.dynamicTraceParams_.Uid
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    local guideData = Z.DataMgr.Get("goal_guide_data")
    local goalInfoList = guideData:GetGuideGoalsBySource(sourceType)
    if goalInfoList ~= nil then
      for i, info in ipairs(goalInfoList) do
        if info.SceneId == sceneId and info.Uid == uid and info.PosType == posType then
          guideVM.SetGuideGoals(sourceType, nil)
          break
        end
      end
    end
  end
end

function MapData:GetDynamicTraceParam(sourceType, posType, uid)
  if self.dynamicTraceParams_ ~= nil and self.dynamicTraceParams_.SourceType == sourceType and self.dynamicTraceParams_.PosType == posType and self.dynamicTraceParams_.Uid == uid then
    return self.dynamicTraceParams_.Param
  end
  return nil
end

function MapData:GetCollectionPosInfo(collectionId, sceneId)
  if self.collectionPosInfoDict_ == nil then
    self.collectionPosInfoDict_ = {}
    local collectionRowData = Z.TableMgr.GetTable("CollectionEnrichmentTableMgr").GetDatas()
    for id, row in pairs(collectionRowData) do
      local sceneId = math.floor(id / COLLECTION_POS_OFFSET)
      if self.collectionPosInfoDict_[row.CollectionId] == nil then
        self.collectionPosInfoDict_[row.CollectionId] = {}
      end
      if self.collectionPosInfoDict_[row.CollectionId][sceneId] == nil then
        self.collectionPosInfoDict_[row.CollectionId][sceneId] = {}
      end
      local info = {
        Id = row.Id,
        Count = row.Count,
        CenterPos = row.CenterPosition
      }
      table.insert(self.collectionPosInfoDict_[row.CollectionId][sceneId], info)
    end
  end
  if self.collectionPosInfoDict_[collectionId] ~= nil and self.collectionPosInfoDict_[collectionId][sceneId] ~= nil then
    return self.collectionPosInfoDict_[collectionId][sceneId]
  end
end

function MapData:GetSceneUnlockedTransporter(sceneID)
  if not self.transferDatas then
    self:GetAllTransporter()
  end
  local itemList = {}
  local mapVM = Z.VMMgr.GetVM("map")
  local pivotVm = Z.VMMgr.GetVM("pivot")
  for k, v in pairs(self.transferDatas) do
    if v.MapId == sceneID then
      if v.TransferType == 1 then
        if mapVM.CheckTransferPointUnlock(v.Id) then
          local item = {}
          item.Id = v.Id
          table.insert(itemList, item)
        end
      elseif v.TransferType == 2 and pivotVm.CheckPivotUnlock(v.Id) then
        local item = {}
        item.Id = v.Id
        table.insert(itemList, item)
      end
    end
  end
  table.sort(itemList, function(a, b)
    if a.TransferType == b.TransferType then
      return a.Id < b.Id
    else
      return a.TransferType < b.TransferType
    end
  end)
  return itemList
end

function MapData:GetAllTransporter()
  self.transferDatas = Z.TableMgr.GetTable("TransferTableMgr").GetDatas()
end

function MapData:OnLanguageChange()
  self:GetAllTransporter()
end

return MapData
