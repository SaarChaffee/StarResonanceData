local EquipRefineVm = {}

function EquipRefineVm.OpenRefinePopup(partId)
  Z.UIMgr:OpenView("equip_vocational_refining_popup", {partId = partId})
end

function EquipRefineVm.CloseRefinePopup()
  Z.UIMgr:CloseView("equip_vocational_refining_popup")
end

function EquipRefineVm.InitRefineData()
  local data = Z.DataMgr.Get("equip_config_data")
  local equipRefineMgr = Z.TableMgr.GetTable("EquipRefineTableMgr").GetDatas()
  local tab = {}
  for k, v in pairs(equipRefineMgr) do
    if tab[v.RefineId] == nil then
      tab[v.RefineId] = {}
    end
    tab[v.RefineId][v.RefineLevel] = v
  end
  data.RefineTableData = tab
  local equipRefineBlessingMgr = Z.TableMgr.GetTable("EquipRefineBlessingTableMgr").GetDatas()
  local tab2 = {}
  for _, v in pairs(equipRefineBlessingMgr) do
    for __, v2 in ipairs(v.FitPart) do
      if tab2[v2] == nil then
        tab2[v2] = {}
      end
      tab2[v2][#tab2[v2] + 1] = v.Id
    end
  end
  data.RefineBlessingTableData = tab2
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
            tb.attrName = fightAttrRpw.Name
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
    for levle, value in ipairs(data) do
      local buffIndex = 0
      for k, v in ipairs(value.RefineLevelEffect) do
        if v[1] == E.RemodelInfoType.Attr then
          local desc = fightAttrParseVM.ParseFightAttrTips(v[2], v[3])
          local tb = {
            level = levle,
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
            level = levle,
            condition = value.Condition,
            attrName = buffAttrParseVM.ParseBufferTips(v[2], param)
          }
          tab[#tab + 1] = tb
        elseif value[1] == E.RemodelInfoType.TmpAttr then
          local desc = tempAttrParseVM.ParamTempAttr(value[2], value[3])
          local tb = {
            level = levle,
            condition = value.Condition,
            attrName = desc
          }
          tab[#tab + 1] = tb
        end
      end
    end
  end
  return tab
end

function EquipRefineVm.AsyncRefining(slotId, itemConfigId, itemCount, token)
  local request = {
    slotId = slotId,
    itemConfigId = itemConfigId,
    itemCount = itemCount
  }
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.EquipSlotRefine(request, token)
  if ret.errorCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errorCode)
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
