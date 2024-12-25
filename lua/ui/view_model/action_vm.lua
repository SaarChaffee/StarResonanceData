local ActionVM = {}

function ActionVM:PlayAction(model, actionInfo)
  if not model or not actionInfo then
    return
  end
  if not actionInfo.actionName and actionInfo.actionId then
    local actionRow = Z.TableMgr.GetTable("ActionTableMgr").GetRow(actionInfo.actionId, true)
    if actionRow then
      actionInfo.actionName = actionRow.ActionEffect
    end
  end
  if not actionInfo.actionName then
    return
  end
  if actionInfo.isPlayStart > 0 or 0 < actionInfo.isPlayMiddle or 0 < actionInfo.isPlayEnd then
    local clipNames = ZUtil.Pool.Collections.ZList_string.Rent()
    if actionInfo.isPlayStart > 0 then
      clipNames:Add(actionInfo.actionName .. "_start")
    end
    if 0 < actionInfo.isPlayMiddle then
      clipNames:Add(actionInfo.actionName .. "_loop")
    end
    if 0 < actionInfo.isPlayEnd then
      clipNames:Add(actionInfo.actionName .. "_end")
    end
    model:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(clipNames))
    clipNames:Recycle()
  else
    model:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(actionInfo.actionName))
  end
end

function ActionVM:InitModelActionInfo(actionInfoTable, maleConfig, femaleConfig)
  local fashionShowAction = {}
  local faceData = Z.DataMgr.Get("face_data")
  if faceData:GetPlayerGender() == Z.PbEnum("EGender", "GenderMale") then
    fashionShowAction = maleConfig
  else
    fashionShowAction = femaleConfig
  end
  for _, actionData in ipairs(fashionShowAction) do
    local keyId = actionData[1]
    local actionId = actionData[2]
    if keyId and actionId then
      local actionPlayInfo = {}
      actionPlayInfo.actionId = actionId
      if 3 <= #actionData then
        actionPlayInfo.isPlayStart = actionData[3]
      else
        actionPlayInfo.isPlayStart = 0
      end
      if 4 <= #actionData then
        actionPlayInfo.isPlayMiddle = actionData[4]
      else
        actionPlayInfo.isPlayMiddle = 0
      end
      if 5 <= #actionData then
        actionPlayInfo.isPlayEnd = actionData[5]
      else
        actionPlayInfo.isPlayEnd = 0
      end
      actionInfoTable[keyId] = actionPlayInfo
    end
  end
end

function ActionVM:GetActionInfo(actionInfo)
  if #actionInfo == 0 then
    return
  end
  local actionPlayInfo = {}
  local actionId = actionInfo[1]
  actionPlayInfo.actionId = actionId
  if 2 < #actionInfo then
    actionPlayInfo.isPlayStart = actionInfo[2]
  else
    actionPlayInfo.isPlayStart = 0
  end
  if 3 < #actionInfo then
    actionPlayInfo.isPlayMiddle = actionInfo[3]
  else
    actionPlayInfo.isPlayMiddle = 0
  end
  if 4 < #actionInfo then
    actionPlayInfo.isPlayEnd = actionInfo[4]
  else
    actionPlayInfo.isPlayEnd = 0
  end
  return actionPlayInfo
end

return ActionVM
