local EquipVM = {}

function EquipVM.CheckEquipProfession(equipId, profession)
  if profession == nil or profession == 0 then
    profession = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  end
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", equipId, true)
  if equipRow == nil or equipRow.EquipProfession == nil or #equipRow.EquipProfession < 1 then
    return true
  end
  for _, value in ipairs(equipRow.EquipProfession) do
    if value == profession then
      return true
    end
  end
  return false
end

return EquipVM
