local BuffVM = {}

function BuffVM.IsBanFunc(funcId)
  local entityId = Z.EntityMgr.PlayerUuid
  if entityId == nil then
    return true
  end
  local buffMgr = Z.BuffMgr
  local entityBuffData = buffMgr:GetEntityBuffData(entityId)
  if entityBuffData == nil then
    return false
  end
  local buffData = Z.DataMgr.Get("buff_data")
  local buffBanFuncMap = buffData:GetBuffBanFuncMap()
  local buffItems = entityBuffData:GetBuffDatas()
  if buffItems == nil then
    return false
  end
  for buffId, _ in pairs(buffItems) do
    local isBand = BuffVM.checkIsBandFuncByBuffId(buffId, funcId, buffBanFuncMap)
    if isBand then
      return true, buffId
    end
  end
  return false
end

function BuffVM.checkIsBandFuncByBuffId(buffId, funcId, buffBanFuncMap)
  if buffId == nil then
    return false
  end
  local buffIdMapfuncIds = buffBanFuncMap.BuffIdMapFuncIds[buffId]
  local isHasFuncId = BuffVM.checkHasFuncId(buffIdMapfuncIds, funcId)
  if isHasFuncId then
    return true
  end
  return BuffVM.checkIsBandFuncByBuffType(buffId, funcId, buffBanFuncMap)
end

function BuffVM.checkIsBandFuncByBuffType(buffId, funcId, buffBanFuncMap)
  if buffId == 0 then
    return false
  end
  local buffTableMgr = Z.TableMgr.GetTable("BuffTableMgr")
  local buffTableRow = buffTableMgr.GetRow(buffId)
  if buffTableRow == nil then
    return false
  end
  local buffAbilityTypeMapfuncIds = buffBanFuncMap.BuffAbilityTypeMapFuncIds[buffTableRow.BuffAbilityType]
  local isHasFuncId = BuffVM.checkHasFuncId(buffAbilityTypeMapfuncIds, funcId)
  return isHasFuncId
end

function BuffVM.checkHasFuncId(funcIds, funcId)
  if funcIds == nil then
    return false
  end
  for _, value in ipairs(funcIds) do
    if value == funcId then
      return true
    end
  end
  return false
end

function BuffVM:AddBanFuncsByBuff(buffId, funcIds)
  local buffData = Z.DataMgr.Get("buff_data")
  buffData:AddBanFuncsByBuffId(buffId, funcIds)
end

function BuffVM:RemoveBanFuncsByBuffId(buffId, funcIds)
  local buffData = Z.DataMgr.Get("buff_data")
  buffData:RemoveBanFuncsByBuffId(buffId, funcIds)
end

local sortFunc = function(left, right)
  if left.BuffPriority == right.BuffPriority then
    return left.CreateTime < right.CreateTime
  else
    return left.BuffPriority > right.BuffPriority
  end
end

function BuffVM.initBuffData(buffConfig, buff)
  local buffTime = 0
  if buffConfig and buffConfig.DestroyParam[1] then
    buffTime = buffConfig.DestroyParam[1][2] or 0
  end
  local buffData = {
    Layer = buff.Layer,
    Level = buff.Level,
    BuffUuid = buff.BuffUuid,
    BuffPriority = buffConfig.BuffPriority,
    Icon = buffConfig.Icon,
    Name = buffConfig.Name,
    BuffType = buffConfig.BuffType,
    Desc = buffConfig.Desc,
    CreateTime = Z.NumTools.GetPreciseDecimal(buff.CreateTime / 1000, 1),
    DurationTime = Z.NumTools.GetPreciseDecimal(buff.Duration / 1000, 1),
    BuffTime = buffTime
  }
  return buffData
end

function BuffVM.GetEntityBuffList(entity, showBuffCount, showPriority)
  if entity == nil then
    return
  end
  local buffDataList = entity:GetLuaAttr(Z.LocalAttr.EShowBuffList).Value
  if not buffDataList then
    return
  end
  local showBuffList = {}
  local buffCount = 0
  local deBuffCount = 0
  for i = 0, buffDataList.count - 1 do
    local buff = buffDataList[i]
    if showPriority < buff.Priority then
      local buffConfig = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffDataList[i].BuffBaseId)
      local buffData = BuffVM.initBuffData(buffConfig, buffDataList[i])
      if buffData.BuffType == E.EBuffType.Debuff then
        if showBuffCount > deBuffCount then
          deBuffCount = deBuffCount + 1
          table.insert(showBuffList, deBuffCount, buffData)
        end
      elseif showBuffCount > buffCount then
        buffCount = buffCount + 1
        table.insert(showBuffList, deBuffCount + buffCount, buffData)
      end
    end
  end
  return showBuffList
end

return BuffVM
