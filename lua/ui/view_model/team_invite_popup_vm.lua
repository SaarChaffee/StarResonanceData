local openInviteView = function()
  Z.UIMgr:OpenView("team_invite_popup")
end
local closeInviteView = function()
  Z.UIMgr:CloseView("team_invite_popup")
end
local nearPlayerSort = function(nearList)
  table.sort(nearList, function(a, b)
    local ent_1 = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), a)
    local ent_2 = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), b)
    local teamId_1 = ent_1:GetLuaAttr(Z.PbAttrEnum("AttrTeamId")).Value
    local teamId_2 = ent_2:GetLuaAttr(Z.PbAttrEnum("AttrTeamId")).Value
    if teamId_1 < teamId_2 then
      return a
    elseif teamId_1 == teamId_2 then
      local seasonLv_1 = ent_1:GetLuaAttr(Z.PbAttrEnum("AttrSeasonLv")).Value
      local seasonLv_2 = ent_2:GetLuaAttr(Z.PbAttrEnum("AttrSeasonLv")).Value
      if seasonLv_1 > seasonLv_2 then
        return a
      elseif seasonLv_1 == seasonLv_2 then
        local uid_1 = ent_1:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
        local uid_2 = ent_2:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
        if uid_1 > uid_2 then
          return a
        end
      end
    end
  end)
  return nearList
end
local getNearPlayerList = function()
  local nearList = {}
  if Z.EntityMgr.CharIdList then
    for i = 0, Z.EntityMgr.CharIdList.Count - 1 do
      local entId = Z.EntityMgr.CharIdList[i]
      if entId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
        table.insert(nearList, entId)
      end
    end
    nearList = nearPlayerSort(nearList)
  end
  return nearList
end
local ret = {
  OpenInviteView = openInviteView,
  CloseInviteView = closeInviteView,
  GetNearPlayerList = getNearPlayerList
}
return ret
