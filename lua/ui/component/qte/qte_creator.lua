local Mgr = {}
Mgr.IdCount = 0
Mgr.QTEDic = {}
Mgr.QTEFunctionDic = {}

function Mgr.OnEnterScene()
  Z.EventMgr:Add(Z.ConstValue.CloseQteByFunctionId, Mgr.OnCloseQteByFunctionId, Mgr)
end

function Mgr.OnLeaveScene()
  Z.EventMgr:RemoveObjAll(Mgr)
end

function Mgr.GetUuid()
  Mgr.IdCount = Mgr.IdCount + 1
  return Mgr.IdCount
end

function Mgr.Create(qteId, view, panel)
  local qteRow = Z.TableMgr.GetTable("QteTableMgr").GetRow(qteId)
  if qteRow == nil then
    logError("can not find config in QteTable")
    return
  end
  if qteRow.impactType == 0 then
  elseif qteRow.impactType == 1 then
    Mgr.CloseQteByFunctionIds(qteRow.impactFunctionId)
  elseif qteRow.impactType == 2 and Mgr.CheckExistQte(qteRow.impactFunctionId) then
    return
  end
  local qteTab = {}
  local qteUI
  local CLASS_PATH = "ui.component.qte."
  logGreen(qteId)
  if qteId == 1 then
    qteUI = require(CLASS_PATH .. "qte_weapon_sf").new(qteId, view, panel)
  elseif qteId == 2 then
    qteUI = require(CLASS_PATH .. "qte_weapon_tdl").new(qteId, view, panel)
  elseif qteId == 3 then
    qteUI = require(CLASS_PATH .. "qte_weapon_tdl").new(qteId, view, panel)
  elseif qteId == 4 or qteId == 5 or qteId == 6 then
    qteUI = require(CLASS_PATH .. "qte_parkour_jump").new(qteId, view, panel)
  elseif qteId == 7 then
    qteUI = require(CLASS_PATH .. "qte_parkour_shadow_dash").new(qteId, view, panel)
  else
    logError("weaponType not find processFunc is nil")
  end
  if qteUI == nil then
    logError("qteUI is nil")
    return 0
  end
  qteUI.uuid_ = Mgr.GetUuid()
  qteTab.funcId = qteRow.functionId
  qteTab.ui = qteUI
  qteTab.uuid = qteUI.uuid_
  Mgr.QTEDic[qteTab.uuid] = qteTab
  if Mgr.QTEFunctionDic[qteRow.functionId] == nil then
    Mgr.QTEFunctionDic[qteRow.functionId] = {}
  end
  table.insert(Mgr.QTEFunctionDic[qteRow.functionId], qteTab.uuid)
  return qteTab.uuid
end

function Mgr.CheckExistQte(functionIds)
  for i = 1, #functionIds do
    local funcId = functionIds[i]
    if Mgr.QTEFunctionDic[funcId] ~= nil and #Mgr.QTEFunctionDic[funcId] > 0 then
      return true
    end
  end
  return false
end

function Mgr.CloseQteByFunctionIds(functionIds)
  local removeUuids = {}
  for i = 1, #functionIds do
    local funcId = functionIds[i]
    if Mgr.QTEFunctionDic[funcId] ~= nil then
      for _, v in pairs(Mgr.QTEFunctionDic[funcId]) do
        removeUuids[#removeUuids + 1] = v
      end
    end
    Mgr.QTEFunctionDic[funcId] = nil
  end
  for i = 1, #removeUuids do
    local qteTab = Mgr.QTEDic[removeUuids[i]]
    qteTab.ui:DestroyUI()
  end
end

function Mgr:OnCloseQteByFunctionId(functionId)
  local removeUuids = {}
  if self.QTEFunctionDic[functionId] ~= nil then
    for _, v in pairs(self.QTEFunctionDic[functionId]) do
      local qteTab = self.QTEDic[v]
      if qteTab ~= nil and qteTab.ui.isTrigger_ then
      else
        removeUuids[#removeUuids + 1] = v
      end
    end
  end
  for i = 1, #removeUuids do
    local qteTab = self.QTEDic[removeUuids[i]]
    qteTab.ui:DestroyUI()
  end
end

function Mgr.OnQteClosed(uuid)
  if Mgr.QTEDic[uuid] ~= nil then
    local qteTab = Mgr.QTEDic[uuid]
    if Mgr.QTEFunctionDic[qteTab.funcId] ~= nil then
      local funcTab = Mgr.QTEFunctionDic[qteTab.funcId]
      for i = #funcTab, 1, -1 do
        if funcTab[i] == uuid then
          table.remove(funcTab, i)
          break
        end
      end
    end
    Mgr.QTEDic[uuid] = nil
  end
end

return Mgr
