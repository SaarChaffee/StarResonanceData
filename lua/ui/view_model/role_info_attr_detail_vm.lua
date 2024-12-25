local openRoleAttrDetailView = function()
  Z.UIMgr:OpenView("role_info_attr_detail")
end
local closeRoleAttrDetailView = function()
  Z.UIMgr:CloseView("role_info_attr_detail")
end
local getAllShowAttr = function()
  local tableSkillVm = Z.VMMgr.GetVM("talent_skill")
  local professionId = Z.VMMgr.GetVM("profession").GetCurProfession()
  local bdType = tableSkillVm.CheckCurTalentBDType()
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  local dynamicShowAttr = {}
  for _, value in ipairs(professionRow.AttackShow) do
    if value[1] == bdType then
      dynamicShowAttr[value[2]] = true
    end
  end
  for _, value in ipairs(professionRow.StrOrIntOrDexShow) do
    if value[1] == bdType then
      dynamicShowAttr[value[2]] = true
    end
  end
  local attrs = {}
  local profileattr = Z.TableMgr.GetTable("ProfileAttrTableMgr").GetDatas()
  for _, value in pairs(profileattr) do
    if math.floor(value.Type / 100) == 2 then
      local type = value.Type % 200
      if attrs[type] == nil then
        attrs[type] = {}
      end
      table.insert(attrs[type], value)
    end
  end
  for _, value in pairs(attrs) do
    table.sort(value, function(a, b)
      return a.Id < b.Id
    end)
  end
  return attrs
end
local getRoleMainAttr = function()
  local tableSkillVm = Z.VMMgr.GetVM("talent_skill")
  local professionId = Z.VMMgr.GetVM("profession").GetCurProfession()
  local bdType = tableSkillVm.CheckCurTalentBDType()
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  local dynamicShowAttr = {}
  for _, value in ipairs(professionRow.AttackShow) do
    if value[1] == bdType then
      dynamicShowAttr[value[2]] = true
    end
  end
  for _, value in ipairs(professionRow.StrOrIntOrDexShow) do
    if value[1] == bdType then
      dynamicShowAttr[value[2]] = true
    end
  end
  local attrs = {}
  local profileattr = Z.TableMgr.GetTable("ProfileAttrTableMgr").GetDatas()
  for _, value in pairs(profileattr) do
    if math.floor(value.Type / 100) == 1 then
      table.insert(attrs, value)
    end
    if value.Type == 0 and dynamicShowAttr[value.AttrId] then
      table.insert(attrs, value)
    end
  end
  table.sort(attrs, function(a, b)
    return a.Id < b.Id
  end)
  return attrs
end
local ret = {
  CloseRoleAttrDetailView = closeRoleAttrDetailView,
  OpenRoleAttrDetailView = openRoleAttrDetailView,
  GetAllShowAttr = getAllShowAttr,
  GetRoleMainAttr = getRoleMainAttr
}
return ret
