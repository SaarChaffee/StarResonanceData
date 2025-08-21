local checkTalentStage = function(talentStageId, filerArray)
  for _, v in ipairs(filerArray) do
    if v == talentStageId then
      return true
    end
  end
  return false
end
local allAttrValueSort = function(attrArray)
  table.sort(attrArray, function(a, b)
    if a.needAccess and not b.needAccess then
      return true
    elseif not a.needAccess and b.needAccess then
      return false
    end
    return a.attrId < b.attrId
  end)
end
local getAccessResultDes = function(attrArray, contrastDict)
  local res = 0
  local count = 0
  local des = ""
  for _, data in pairs(attrArray) do
    if contrastDict[data.attrId] ~= nil and data.needAccess then
      local tmp = 0
      if data.curValue ~= 0 then
        tmp = data.curValue / data.referenceValue * contrastDict[data.attrId].AssessWeight
      end
      res = res + tmp
      count = count + contrastDict[data.attrId].AssessWeight
    end
  end
  res = res / count * 100
  local caData = Z.DataMgr.Get("capability_assessment_data")
  local assessResultCfgs = caData:GetAssessResultCfgs()
  for _, v in pairs(assessResultCfgs) do
    if res >= v.AssessId[1] and res < v.AssessId[2] then
      des = v.TalentStageId
    end
  end
  return des
end
local setAllAttrCurVal = function(attrNameArray, attrArray)
  local valueArray = Z.LuaBridge.GetAllAttrValueByName(attrNameArray)
  for index, data in ipairs(attrArray) do
    data.curValue = tonumber(valueArray[index - 1])
  end
end
local getcontrastDict = function(id)
  local contrastDict = {}
  local talentSkillVM = Z.VMMgr.GetVM("talent_skill")
  local talentStageId = talentSkillVM.GetCurProfessionTalentStage()
  local caData = Z.DataMgr.Get("capability_assessment_data")
  local assessTableCfgs = caData:GetAssessCfgs()
  for _, v in pairs(assessTableCfgs) do
    if v.AssessId == id and checkTalentStage(talentStageId, v.TalentStageId) then
      local attrCfg = Z.TableMgr.GetTable("FightAttrTableMgr").GetRow(v.FightAttrId)
      if attrCfg and contrastDict[attrCfg.Id] == nil then
        contrastDict[attrCfg.Id] = v
      end
    end
  end
  return contrastDict
end
local getAllAttrValue = function(id)
  local attrIdArray = {}
  local attrArray = {}
  local contrastDict = getcontrastDict(id)
  local caData = Z.DataMgr.Get("capability_assessment_data")
  local fightAttrTableCfgs = caData:GetFightAttrCfgs()
  for _, attrCfg in pairs(fightAttrTableCfgs) do
    if attrCfg and attrCfg.IsAssess then
      local caData = {
        attrName = attrCfg.OfficialName,
        referenceValue = contrastDict[attrCfg.Id] and contrastDict[attrCfg.Id].FightAttrVal or -1,
        icon = attrCfg.Icon,
        needAccess = contrastDict[attrCfg.Id] ~= nil and contrastDict[attrCfg.Id].FightAttrVal ~= 0,
        attrId = attrCfg.Id
      }
      table.insert(attrArray, caData)
      table.insert(attrIdArray, attrCfg.Id)
    end
  end
  setAllAttrCurVal(attrIdArray, attrArray)
  local accessResultDes = getAccessResultDes(attrArray, contrastDict)
  allAttrValueSort(attrArray)
  return attrArray, accessResultDes
end
local ret = {GetAllAttrValue = getAllAttrValue}
return ret
