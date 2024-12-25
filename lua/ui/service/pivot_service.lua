local super = require("ui.service.service_base")
local PivotService = class("PivotService", super)

function PivotService:OnInit()
  self.isIgnoreInput_ = false
  self.pivotVM_ = Z.VMMgr.GetVM("pivot")
end

function PivotService:OnUnInit()
end

function PivotService:InitRed()
  local mapFuncShowSceneDict = self.pivotVM_.GetPivotMapFuncShowSceneDict()
  local pivotTableMgr = Z.TableMgr.GetTable("PivotTableMgr")
  for id, config in pairs(pivotTableMgr.GetDatas()) do
    local cfg = config
    if mapFuncShowSceneDict[cfg.MapID] then
      local nodeId = self.pivotVM_.GetPivotRedId(cfg.MapID, id)
      Z.RedPointMgr.AddChildNodeData(E.RedType.PivotProgress, E.RedType.PivotProgress, nodeId)
    end
  end
  local pivotAwardTableMgr = Z.TableMgr.GetTable("PivotAwardTableMgr")
  for sceneId, value in pairs(pivotAwardTableMgr.GetDatas()) do
    if mapFuncShowSceneDict[sceneId] then
      local cfg = value
      for index, awardId in ipairs(cfg.AwardId) do
        local nodeId = self.pivotVM_.GetProgressRedId(sceneId, awardId)
        Z.RedPointMgr.AddChildNodeData(E.RedType.PivotProgress, E.RedType.PivotProgress, nodeId)
      end
    end
  end
end

function PivotService:UnInitRed()
  local mapFuncShowSceneDict = self.pivotVM_.GetPivotMapFuncShowSceneDict()
  local pivotTableMgr = Z.TableMgr.GetTable("PivotTableMgr")
  for id, config in pairs(pivotTableMgr.GetDatas()) do
    local cfg = config
    if mapFuncShowSceneDict[cfg.MapID] then
      local nodeId = self.pivotVM_.GetPivotRedId(cfg.MapID, id)
      Z.RedPointMgr.RemoveChildNodeData(E.RedType.PivotProgress, nodeId)
    end
  end
  local pivotAwardTableMgr = Z.TableMgr.GetTable("PivotAwardTableMgr")
  for sceneId, value in pairs(pivotAwardTableMgr.GetDatas()) do
    if mapFuncShowSceneDict[sceneId] then
      local cfg = value
      for index, awardId in ipairs(cfg.AwardId) do
        local nodeId = self.pivotVM_.GetProgressRedId(sceneId, awardId)
        Z.RedPointMgr.RemoveChildNodeData(E.RedType.PivotProgress, nodeId)
      end
    end
  end
end

function PivotService:CheckRed()
  self.pivotVM_.CheckPivotRedDot()
  self.pivotVM_.CheckPointRedDot()
end

function PivotService:OnInteractionBack(isSuccess, uuid, templateId)
  if not isSuccess then
    return
  end
  local interactiveTableRow = Z.TableMgr.GetTable("InteractiveTableMgr").GetRow(templateId)
  if interactiveTableRow == nil then
    return
  end
  if interactiveTableRow.TipsGroup == E.EInteractiveGroup.Pivot then
    self:PivotInteractBack(uuid)
  elseif interactiveTableRow.TipsGroup == E.EInteractiveGroup.PivotProgress then
    self:PivotProgressInteractBacck(uuid)
  end
end

function PivotService:PivotInteractBack(uuid)
  local isSuccess, pivotId = Z.EntityHelper.TryGetConfigIdByUuid(uuid, nil)
  if not isSuccess or pivotId == 0 then
    return
  end
  local pivotData = Z.DataMgr.Get("pivot_data")
  local pivotVM = Z.VMMgr.GetVM("pivot")
  if pivotVM.CheckPivotUnlock(pivotId) then
    local pivotTableMgr = Z.TableMgr.GetTable("PivotTableMgr")
    local pivotTableRow = pivotTableMgr.GetRow(pivotId)
    if pivotTableRow == nil then
      return
    end
    if not self.isIgnoreInput_ then
      Z.IgnoreMgr:SetInputIgnore(4294967295, true, Panda.ZGame.EIgnoreMaskSource.EUIPivot)
      Z.ZInputMapModeMgr:ChangeInputMode(Panda.ZInput.EInputMode.Default)
      self.isIgnoreInput_ = true
      Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.PivotUnlock, function()
        Z.ZInputMapModeMgr:ChangeInputMode(Z.ZInputMapModeMgr.GamePlayDefaultMode)
        Z.IgnoreMgr:SetInputIgnore(4294967295, false, Panda.ZGame.EIgnoreMaskSource.EUIPivot)
        self.isIgnoreInput_ = false
        pivotData:SetUnlockPivotId(pivotId)
        local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
        gotoFuncVM.GoToFunc(E.FunctionID.Map, pivotTableRow.MapID)
      end, 1.5, 1)
    end
  end
end

function PivotService:PivotProgressInteractBacck(uuid)
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity == nil then
    return
  end
  local configId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  local settingOffTableRow = Z.TableMgr.GetTable("SettingOffTableMgr").GetRow(configId)
  if settingOffTableRow == nil then
    return
  end
  local pivotTableRow = Z.TableMgr.GetTable("PivotTableMgr").GetRow(settingOffTableRow.PivotId)
  if pivotTableRow == nil then
    return
  end
  local pivotCount = #self.pivotVM_.GetPivotAllPort(pivotTableRow.Id)
  local unlockPivotCount = self.pivotVM_.GetPivotPortUnlockCount(pivotTableRow.Id)
  Z.TipsVM.ShowTipsLang(16004001, {
    name = pivotTableRow.Name,
    progress = string.zconcat(unlockPivotCount, "/", pivotCount)
  })
end

function PivotService:getRefreshPivotDict(unlockPivotIdDict)
  local idDict = {}
  for id, _ in pairs(unlockPivotIdDict) do
    idDict[id] = true
  end
  local transferTableDatas = Z.TableMgr.GetTable("TransferTableMgr").GetDatas()
  for id, row in pairs(transferTableDatas) do
    if row.PivotId > 0 and unlockPivotIdDict[row.PivotId] then
      idDict[row.Id] = true
    end
  end
  return idDict
end

function PivotService:OnLogin()
  function self.onContainerDataChange_(container, dirtyKeys)
    if dirtyKeys and dirtyKeys.pivots then
      self.pivotVM_.CheckPivotRedDot()
      
      local refreshIdDict = self:getRefreshPivotDict(dirtyKeys.pivots)
      Z.EventMgr:Dispatch(Z.ConstValue.Pivot.OnPivotUnlock, refreshIdDict)
    end
    if dirtyKeys and dirtyKeys.mapPivots then
      self.pivotVM_.CheckPointRedDot()
    end
  end
  
  Z.ContainerMgr.CharSerialize.pivot.Watcher:RegWatcher(self.onContainerDataChange_)
  Z.EventMgr:Add(Z.ConstValue.Interaction.OnInteractionBack, self.OnInteractionBack, self)
  self:InitRed()
end

function PivotService:OnLogout()
  self:UnInitRed()
  if self.isIgnoreInput_ then
    Z.IgnoreMgr:SetInputIgnore(4294967295, false, Panda.ZGame.EIgnoreMaskSource.EUIPivot)
    self.isIgnoreInput_ = false
  end
  Z.EventMgr:Remove(Z.ConstValue.Interaction.OnInteractionBack, self.OnInteractionBack, self)
  Z.ContainerMgr.CharSerialize.pivot.Watcher:UnregWatcher(self.onContainerDataChange_)
  self.onContainerDataChange_ = nil
end

function PivotService:OnSyncAllContainerData()
  self:CheckRed()
end

return PivotService
