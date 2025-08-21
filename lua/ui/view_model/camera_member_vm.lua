local CameraMemberVM = {}
local EntChar = Z.PbEnum("EEntityType", "EntChar")
local cjson = require("cjson")

function CameraMemberVM:GetPeopleNearby(type)
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  local unionData = Z.DataMgr.Get("union_data")
  local teamData = Z.DataMgr.Get("team_data")
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local nearbyData = Z.EntityMgr.CharEntIdList
  if not nearbyData then
    return {}
  end
  local playerList = {}
  if type == E.CameraCharacterRelationship.Union then
    local unionMemberList = unionData.MemberDict
    if unionMemberList == nil then
      return playerList
    end
    for k, v in pairs(unionMemberList) do
      for i = 0, nearbyData.Count - 1 do
        local entId = nearbyData[i]
        local charId = v.socialData.basicData.charID
        if charId == entId and charId ~= Z.ContainerMgr.CharSerialize.charId then
          table.insert(playerList, v.socialData)
        end
      end
    end
  elseif type == E.CameraCharacterRelationship.Team then
    local teamList = teamData.TeamInfo.members
    if not teamList or 0 >= table.zcount(teamList) then
      return playerList
    end
    for k, v in pairs(teamList) do
      for i = 0, nearbyData.Count - 1 do
        local entId = nearbyData[i]
        if v.charId == entId and v.charId ~= Z.ContainerMgr.CharSerialize.charId then
          table.insert(playerList, v.socialData)
        end
      end
    end
  elseif type == E.CameraCharacterRelationship.Friend then
    local friendList = friendMainData:GetFriendCharList()
    for k, v in pairs(friendList) do
      for i = 0, nearbyData.Count - 1 do
        local entId = nearbyData[i]
        if v == entId then
          local friendData = friendMainData:GetFriendDataByCharId(v)
          if friendData then
            table.insert(playerList, friendData:GetSocialData())
          end
        end
      end
    end
  end
  if 0 >= table.zcount(playerList) then
    return playerList
  end
  for i = #playerList, 1, -1 do
    if table.zcontains(cameraMemberData.MemberCharIdList, playerList[i].basicData.charID) then
      table.remove(playerList, i)
    end
  end
  return playerList
end

function CameraMemberVM:CheckMemberIsNearby(charId)
  local entity = self:GetMemberEntity(charId)
  if not entity then
    return false
  end
  return true
end

function CameraMemberVM:AddMemberToList(charId, socialData, isSelf)
  if not socialData then
    return
  end
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local limit = Z.IsPCUI and Z.Global.PhotographTeamMemberLimit[1] or Z.Global.PhotographTeamMemberLimit[2]
  if limit <= table.zcount(cameraMemberData.MemberListData) then
    return
  end
  local entity = self:GetMemberEntity(charId)
  cameraMemberData:SetMemberListData(charId, socialData, isSelf)
  if entity and not isSelf then
    self:CreateModel(entity, charId)
  end
  if isSelf then
    cameraMemberData.MemberListData[charId].baseData.model = Z.EntityMgr.PlayerEnt.Model
  end
end

function CameraMemberVM:UpdateMemberListData(charId, socialData, loopIndex)
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local memberData = cameraMemberData:GetMemberDataByCharId(charId)
  if not memberData then
    return
  end
  cameraMemberData:UpdateMemberListData(charId, socialData)
  local entity = self:GetMemberEntity(charId)
  if entity then
    self:CreateModel(entity, charId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.CameraMember.CameraMemberDataUpdate, loopIndex, charId)
end

function CameraMemberVM:CreateModel(entity, charID)
  if not entity then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
    local cloneModel = Z.ZAnimActionPlayMgr:CloneModelForPhoto(entity)
    local actionId = cloneModel:GetLuaAttrActionInfoActionId()
    actionId = math.floor(actionId)
    cameraMemberData.MemberListData[charID].baseData.model = cloneModel
    cameraMemberData.MemberListData[charID].actionData.actionId = actionId
  end)()
end

function CameraMemberVM:GetMemberEntity(charId)
  local entityVM = Z.VMMgr.GetVM("entity")
  local uuid = entityVM.EntIdToUuid(charId, EntChar)
  local entity = Z.EntityMgr:GetEntity(uuid)
  return entity
end

function CameraMemberVM:SaveMemberListData()
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local cameraMemberInfo = cameraMemberData.MemberCharIdList
  local info = cjson.encode(cameraMemberInfo)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.CameraMemberListInfo, info)
  Z.LocalUserDataMgr.Save()
end

function CameraMemberVM:GetLocalMemberListData()
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.CameraMemberListInfo) then
    local info = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.CameraMemberListInfo)
    local tempInfo = cjson.decode(info)
    if table.zcount(tempInfo) == 0 then
      return nil
    end
    local charZList = ZUtil.Pool.Collections.ZList_long.Rent()
    for key, value in pairs(tempInfo) do
      value = math.floor(value)
      charZList:Add(value)
    end
    Z.LuaDataMgr:InitCameraMemberCharIdCache(charZList)
    ZUtil.Pool.Collections.ZList_long.Return(charZList)
    return tempInfo
  else
    return nil
  end
end

function CameraMemberVM:AssembledLookAtMemberData()
  local cameraData = Z.DataMgr.Get("camerasys_data")
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local memberTempData = {}
  if cameraData.IsControlEveryOne then
    memberTempData = cameraMemberData.MemberListData
  else
    local data = cameraMemberData:GetSelectMemberData()
    table.insert(memberTempData, data)
  end
  return memberTempData
end

function CameraMemberVM:ExitCameraView()
  self:SaveMemberListData()
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  cameraMemberData:ClearMemberModel()
  cameraMemberData.MemberListData = {}
end

function CameraMemberVM:SetDisbandTeam(isOn)
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  cameraMemberData.IsDisbandTeam = isOn
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "CameraDisbandTeam", isOn)
  Z.LocalUserDataMgr.Save()
end

return CameraMemberVM
