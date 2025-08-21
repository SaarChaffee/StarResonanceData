local EquipRefineVm = {}

function EquipRefineVm.OpenRefinePopup(partId)
  Z.UIMgr:OpenView("equip_vocational_refining_popup", {partId = partId})
end

function EquipRefineVm.CloseRefinePopup()
  Z.UIMgr:CloseView("equip_vocational_refining_popup")
end

function EquipRefineVm.InitRefineData()
  local data = Z.DataMgr.Get("equip_config_data")
  data:InitRefineData()
end

function EquipRefineVm.GetCurRefineIdByPart(part, professionId)
  if not professionId then
    return
  end
  local equipPartRow = Z.TableMgr.GetRow("EquipPartTableMgr", part)
  if not equipPartRow then
    return
  end
  for k, v in ipairs(equipPartRow.RefineId) do
    if v[1] == professionId then
      return v[2]
    end
  end
end

function EquipRefineVm.GetBasicAttrInfo(part, nowLevel, professionId)
  local curRefineId = EquipRefineVm.GetCurRefineIdByPart(part, professionId)
  if not curRefineId then
    return
  end
  local tab = {}
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local data = equipCfgData.RefineTableData[curRefineId]
  if data then
    local refineRow
    if nowLevel == 0 then
      refineRow = data[1]
    else
      refineRow = data[nowLevel]
    end
    local nextRefineRow = data[nowLevel + 1]
    if refineRow then
      local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
      for k, v in pairs(refineRow.RefineEffect) do
        if v[1] == E.RemodelInfoType.Attr then
          local tb = {}
          local fightAttrRpw = fightAttrParseVm.GetFightAttrTableRow(v[2])
          if fightAttrRpw then
            tb.attrName = fightAttrRpw.OfficialName
          end
          tb.nowValue = nowLevel == 0 and 0 or v[3]
          local isHaveNextLevel = nextRefineRow ~= nil and nextRefineRow.RefineEffect[k] ~= nil
          if isHaveNextLevel then
            tb.nextValue = nextRefineRow.RefineEffect[k][3]
          end
          tab[#tab + 1] = tb
        end
      end
    end
  end
  return tab
end

function EquipRefineVm.GetRefineLevelEffect(part, professionId)
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local curRefineId = EquipRefineVm.GetCurRefineIdByPart(part, professionId)
  if not curRefineId then
    return
  end
  local fightAttrParseVM = Z.VMMgr.GetVM("fight_attr_parse")
  local tempAttrParseVM = Z.VMMgr.GetVM("temp_attr_parse")
  local tab = {}
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local data = equipCfgData.RefineTableData[curRefineId]
  if data then
    for level, value in ipairs(data) do
      if Z.ConditionHelper.CheckCondition(value.ShowCondition) then
        local buffIndex = 0
        for k, v in ipairs(value.RefineLevelEffect) do
          if v[1] == E.RemodelInfoType.Attr then
            local desc = fightAttrParseVM.ParseFightAttrTips(v[2], v[3])
            local tb = {
              level = level,
              condition = value.Condition,
              attrName = desc
            }
            tab[#tab + 1] = tb
          elseif v[1] == E.RemodelInfoType.Buff then
            buffIndex = buffIndex + 1
            local param = {}
            local paramArray = value.BuffPar[buffIndex]
            if paramArray then
              for paramIndex, paramValue in ipairs(paramArray) do
                param[paramIndex] = {paramValue}
              end
            end
            local tb = {
              level = level,
              condition = value.Condition,
              attrName = buffAttrParseVM.ParseBufferTips(v[2], param)
            }
            tab[#tab + 1] = tb
          elseif value[1] == E.RemodelInfoType.TmpAttr then
            local desc = tempAttrParseVM.ParamTempAttr(value[2], value[3])
            local tb = {
              level = level,
              condition = value.Condition,
              attrName = desc
            }
            tab[#tab + 1] = tb
          end
        end
      end
    end
  end
  return tab
end

function EquipRefineVm.AsyncRefining(slotId, itemCostList, token)
  local request = {slotId = slotId, itemCostList = itemCostList}
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.EquipSlotRefine(request, token)
  local refineData = Z.DataMgr.Get("equip_refine_data")
  refineData.CurSelBlessingData = {}
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
  if ret.success then
    Z.EventMgr:Dispatch(Z.ConstValue.Equip.RefinePartSuccess, slotId)
  end
  return ret.success
end

function EquipRefineVm.GetRefinePartRedName(part)
  return "equip_refine_part" .. part
end

function EquipRefineVm.GetRefineItemRedName(uuid)
  return "refineItemRed" .. uuid
end

return EquipRefineVm
