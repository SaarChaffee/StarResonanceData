local ChemistryVM = {}

function ChemistryVM.OpenChemistryMainView(cameraId, isHouseCast)
  Z.UIMgr:OpenView("chemistry_main", {
    camID = tonumber(cameraId),
    slowCam = true,
    isHouseCast = isHouseCast
  })
end

function ChemistryVM.CloseChemistryMainView()
  Z.UIMgr:CloseView("chemistry_main")
end

function ChemistryVM.GetBuffDesById(id)
  local cookCuisineTableRow = Z.TableMgr.GetTable("CookCuisineTableMgr").GetRow(id, true)
  if cookCuisineTableRow == nil then
    return ""
  end
  local buffAttrParseVM = Z.VMMgr.GetVM("buff_attr_parse")
  local param = {}
  local des = ""
  for k, buffPars in ipairs(cookCuisineTableRow.BuffPar) do
    for index, buffPar in ipairs(buffPars) do
      param[index] = {buffPar}
    end
    des = des .. buffAttrParseVM.ParseBufferTips(cookCuisineTableRow.Description, param) .. "\n"
  end
  return des
end

return ChemistryVM
