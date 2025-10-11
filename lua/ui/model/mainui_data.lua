local super = require("ui.model.data_base")
local MainUIData = class("MainUIData", super)

function MainUIData:ctor()
  super.ctor(self)
  self.mainUIHideStyleMark = {
    {},
    {},
    {},
    {}
  }
  self:ResetData()
  self.IsShowLeftBtn = true
  self.mainIconStorageCondition = {}
  self.mainUiBtnItemList = {}
  self.leftTrackCurSelectedIndex_ = E.MainViewLeftTrackUIMark.Task
end

function MainUIData:Init()
  self:ResetData()
  self:initBtnData()
end

function MainUIData:OnReconnect()
end

function MainUIData:OnLanguageChange()
  self.cacheKeyInfoMap_ = nil
end

function MainUIData:Clear()
  self:ResetData()
  self.IsShowLeftBtn = true
  self.mainIconStorageCondition = {}
end

function MainUIData:UnInit()
  self.mainUiBtnItemList = {}
end

function MainUIData:SetLeftTrackCurSelectedIndex(index)
  self.leftTrackCurSelectedIndex_ = index
end

function MainUIData:GetLeftTrackCurSelectedIndex()
  return self.leftTrackCurSelectedIndex_
end

function MainUIData:initBtnData()
  local mainIconTableMgr = Z.TableMgr.GetTable("MainIconTableMgr")
  if mainIconTableMgr == nil then
    return
  end
  local mainIconTableRowList = mainIconTableMgr.GetDatas()
  for k, v in pairs(mainIconTableRowList) do
    if Z.IsPCUI or v.Id ~= E.FunctionID.MainChat then
      table.insert(self.mainUiBtnItemList, v)
    end
  end
end

function MainUIData:ResetData()
  self.isShowLeftTop_ = true
  self.isShowBottomNode_ = true
  self.isShowMainChat_ = true
  self.mainUIHideStyleMark = {
    {},
    {},
    {},
    {}
  }
  self.MainUIPCShowFriendMessage = false
  self.MainUIPCShowMail = false
end

function MainUIData:SetMainUiAreaHideStyle(hideStyle, viewConfigKey, isHide)
  if not hideStyle or string.zisEmpty(viewConfigKey) then
    return
  end
  local areaPositionTable = self:initMainArea(hideStyle)
  self:AddMainUiAreaHideStyleMark(areaPositionTable, viewConfigKey, isHide)
end

function MainUIData:initMainArea(hideStyle)
  if not hideStyle then
    return nil
  end
  local areaPositionTable = {}
  if hideStyle == E.MainViewHideStyle.Left then
    table.insert(areaPositionTable, E.MainUIArea.UpperLeft)
    table.insert(areaPositionTable, E.MainUIArea.LowLeft)
  elseif hideStyle == E.MainViewHideStyle.Right then
    table.insert(areaPositionTable, E.MainUIArea.UpperRight)
    table.insert(areaPositionTable, E.MainUIArea.LowRight)
  elseif hideStyle == E.MainViewHideStyle.Bottom then
    table.insert(areaPositionTable, E.MainUIArea.LowLeft)
    table.insert(areaPositionTable, E.MainUIArea.LowRight)
  elseif hideStyle == E.MainViewHideStyle.Top then
    table.insert(areaPositionTable, E.MainUIArea.UpperLeft)
    table.insert(areaPositionTable, E.MainUIArea.UpperRight)
  elseif hideStyle == E.MainViewHideStyle.UpperLeft then
    table.insert(areaPositionTable, E.MainUIArea.UpperLeft)
  elseif hideStyle == E.MainViewHideStyle.UpperRight then
    table.insert(areaPositionTable, E.MainUIArea.UpperRight)
  elseif hideStyle == E.MainViewHideStyle.LowLeft then
    table.insert(areaPositionTable, E.MainUIArea.LowLeft)
  elseif hideStyle == E.MainViewHideStyle.LowRight then
    table.insert(areaPositionTable, E.MainUIArea.LowRight)
  end
  return areaPositionTable
end

function MainUIData:AddMainUiAreaHideStyleMark(mainMarkAreaPosition, viewConfigKey, isAdd)
  if table.zcount(mainMarkAreaPosition) == 0 or string.zisEmpty(viewConfigKey) then
    return
  end
  for k, v in pairs(mainMarkAreaPosition) do
    local markCount = self.mainUIHideStyleMark[v][viewConfigKey] or 0
    if isAdd then
      self.mainUIHideStyleMark[v][viewConfigKey] = markCount + 1
    else
      self.mainUIHideStyleMark[v][viewConfigKey] = math.max(0, markCount - 1)
      if self.mainUIHideStyleMark[v][viewConfigKey] == 0 then
        self.mainUIHideStyleMark[v][viewConfigKey] = nil
      end
    end
  end
end

function MainUIData:GetMainUiAreaHideStyle()
  return self.mainUIHideStyleMark
end

function MainUIData:SetIsShowMainChat(isShow)
  self.isShowMainChat_ = isShow
end

function MainUIData:GetIsShowMainChat()
  return self.isShowMainChat_
end

function MainUIData:RefreshMainIconStorageCondition()
  self.IsShowLeftBtn = true
  local mainuiId = self:getCurMainUiId()
  if mainuiId == nil then
    return
  end
  local mainUiCfg = Z.TableMgr.GetTable("MainUiTableMgr").GetRow(mainuiId, true)
  if mainUiCfg == nil then
    return
  end
  if mainUiCfg.MainIconStorageCondition == E.MainUIShowLeftType.DefaultHideButRec then
    if self.mainIconStorageCondition[mainuiId] ~= nil then
      self.IsShowLeftBtn = self.mainIconStorageCondition[mainuiId]
    else
      self.IsShowLeftBtn = false
    end
  elseif mainUiCfg.MainIconStorageCondition == E.MainUIShowLeftType.DefaultShowButRec then
    if self.mainIconStorageCondition[mainuiId] ~= nil then
      self.IsShowLeftBtn = self.mainIconStorageCondition[mainuiId]
    else
      self.IsShowLeftBtn = true
    end
  elseif mainUiCfg.MainIconStorageCondition == E.MainUIShowLeftType.DefaultHide then
    self.IsShowLeftBtn = false
  elseif mainUiCfg.MainIconStorageCondition == E.MainUIShowLeftType.DefaultShow then
    self.IsShowLeftBtn = true
  end
end

function MainUIData:RecordCurSceneMainIconStorageCondition(isShow)
  local mainuiId = self:getCurMainUiId()
  if mainuiId == nil then
    return
  end
  self.mainIconStorageCondition[mainuiId] = isShow
end

function MainUIData:getCurMainUiId()
  local mainuiId
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  if 0 < visualLayerId then
    local visualLayerCfg = Z.TableMgr.GetTable("VisualLayerMgr").GetRow(visualLayerId)
    if visualLayerCfg == nil then
      return
    end
    mainuiId = visualLayerCfg.MainUi
  else
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    local sceneMgr = Z.TableMgr.GetTable("SceneTableMgr")
    if sceneMgr == nil then
      return
    end
    local sceneCfg = sceneMgr.GetRow(sceneId)
    if sceneCfg == nil then
      return
    end
    mainuiId = sceneCfg.MainUi
  end
  if mainuiId == nil then
    return
  end
  return mainuiId
end

function MainUIData:GetKeyIdAndDescByFuncId(funcId)
  if self.cacheKeyInfoMap_ == nil then
    self.cacheKeyInfoMap_ = {}
    local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
    for keyId, row in pairs(keyTbl.GetDatas()) do
      if row.KeyboardDes == 2 then
        self.cacheKeyInfoMap_[row.FunctionId] = {
          keyId,
          row.SetDes
        }
      end
    end
  end
  local info = self.cacheKeyInfoMap_[funcId]
  if info then
    if funcId == E.FunctionID.PathFinding then
      if Z.ZPathFindingMgr.CurStage == Panda.ZGame.EPathFindingStage.EMove then
        return info[1], Lang("PathFindingMoving")
      else
        return info[1], info[2]
      end
    else
      return info[1], info[2]
    end
  end
end

return MainUIData
