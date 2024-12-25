local super = require("ui.model.data_base")
local MapData = class("MapData", super)
E.MapFlagEffectType = {Trace = 1, WorldQuset = 2}

function MapData:ctor()
  super.ctor(self)
  self.CurAreaId = 0
  self.IsHadShownAreaName = false
  self.IsShownNameAfterChangeScene = false
  self.AutoSelectTrackSrc = nil
  self.AutoSelectFlagId = nil
  self.IsShowRedInfo = false
  self.TracingFlagData = nil
  self.CurIdx = 0
  self.showProportion_ = nil
  self.focus_ = nil
  self.collectionList_ = {}
  self.dynamicTraceParams_ = {}
  self.MapEffectPathDict = {
    [E.MapFlagEffectType.Trace] = "ui/prefabs/map/map_effect_trace_tpl",
    [E.MapFlagEffectType.WorldQuset] = "ui/prefabs/map/map_effect_worldquest_tpl"
  }
end

function MapData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function MapData:UnInit()
  self.CancelSource:Recycle()
end

function MapData:SetMapFlagVisibleSettingByTypeId(id, isShow)
  Z.LocalUserDataMgr.SetBool("BKL_MAP_FLAG_VISIBLE" .. tostring(id), isShow)
end

function MapData:GetMapFlagVisibleSettingByTypeId(id)
  return Z.LocalUserDataMgr.GetBool("BKL_MAP_FLAG_VISIBLE" .. tostring(id), true)
end

function MapData:SetShowProportion(value)
  Z.LocalUserDataMgr.SetInt("BKL_PROP_TAG", value)
  self.showProportion_ = value
end

function MapData:GetShowProportion()
  local data
  if Z.LocalUserDataMgr.Contains("BKL_PROP_TAG") then
    data = Z.LocalUserDataMgr.GetInt("BKL_PROP_TAG")
  else
    data = E.ShowProportionType.Middle
  end
  self:SetShowProportion(data)
  return data
end

function MapData:SetViewFocus(value)
  Z.LocalUserDataMgr.SetInt("BKL_FOCUS_TAG", value)
  self.focus_ = value
end

function MapData:GetViewFocus()
  local data
  if Z.LocalUserDataMgr.Contains("BKL_FOCUS_TAG") then
    data = Z.LocalUserDataMgr.GetInt("BKL_FOCUS_TAG")
  else
    data = E.ViewFocusType.focusDir
    self:SetViewFocus(data)
  end
  return data
end

function MapData:SetCollectionData(sceneId, flagData)
  if self.collectionList_[sceneId] == nil then
    self.collectionList_[sceneId] = {}
  end
  table.insert(self.collectionList_[sceneId], flagData)
end

function MapData:RemoveCollectionData(sceneId, id)
  if self.collectionList_[sceneId] then
    for i = #self.collectionList_[sceneId], 1, -1 do
      if self.collectionList_[sceneId][i].Id == id then
        table.remove(self.collectionList_[sceneId], i)
      end
    end
  end
end

function MapData:GetCollectionDataBySceneId(sceneId)
  return self.collectionList_[sceneId] or {}
end

function MapData:SaveDynamicTraceParam(sourceType, posType, uid, param)
  if self.dynamicTraceParams_[sourceType] == nil then
    self.dynamicTraceParams_[sourceType] = {}
  end
  if self.dynamicTraceParams_[sourceType][posType] == nil then
    self.dynamicTraceParams_[sourceType][posType] = {}
  end
  self.dynamicTraceParams_[sourceType][posType][uid] = param
end

function MapData:GetDynamicTraceParam(sourceType, posType, uid)
  if self.dynamicTraceParams_[sourceType] and self.dynamicTraceParams_[sourceType][posType] then
    return self.dynamicTraceParams_[sourceType][posType][uid]
  end
end

return MapData
