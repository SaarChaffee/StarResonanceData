local super = require("ui.model.data_base")
local CameraMemberData = class("CameraMemberData", super)

function CameraMemberData:ctor()
  super.ctor(self)
  self.MemberListData = {}
  self.MemberCharIdList = {}
  self.memberModelList_ = {}
  self.IsDisbandTeam = false
  self.selectCharId_ = 0
end

function CameraMemberData:Init()
  self:CheckDisbandTeam()
end

function CameraMemberData:UnInit()
end

function CameraMemberData:CheckDisbandTeam()
  local isDisbandTeam = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "CameraDisbandTeam", false)
  self.IsDisbandTeam = isDisbandTeam
  if self.IsDisbandTeam then
    self:ClearCameraMemberCharIdCache()
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Character, Z.ConstValue.PlayerPrefsKey.CameraMemberListInfo)
    return
  end
end

function CameraMemberData:Clear()
  self:ClearMemberModel()
  self.MemberListData = {}
  self.MemberCharIdList = {}
  self.selectCharId_ = 0
  self:CheckDisbandTeam()
end

function CameraMemberData:GetMemberDataByCharId(charId)
  return self.MemberListData[charId]
end

function CameraMemberData:GetSelectMemberCharId()
  return self.selectCharId_
end

function CameraMemberData:SetSelectMemberCharId(charId)
  self.selectCharId_ = charId
end

function CameraMemberData:GetSelectMemberData()
  if self.selectCharId_ == 0 then
    self.selectCharId_ = Z.ContainerMgr.CharSerialize.charId
  end
  return self:GetMemberDataByCharId(self.selectCharId_)
end

function CameraMemberData:SetMemberListData(charId, socialData, isSelf)
  local data = self:InitMemberData(charId, socialData, isSelf)
  self.MemberListData[charId] = data
  if not table.zcontains(self.MemberCharIdList, charId) and not isSelf then
    table.insert(self.MemberCharIdList, charId)
    Z.LuaDataMgr:UpdateCameraMemberCharIdCache(charId, true)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.CameraMember.CameraMemberListUpdate)
end

function CameraMemberData:UpdateMemberListData(charId, socialData)
  self:ReleaseMemberModelByCharId(charId)
  local data = self:InitMemberData(charId, socialData)
  self.MemberListData[charId] = data
end

function CameraMemberData:AssemblyMemberListData(isShowRefreshBtn)
  local tempTable = {}
  for k, v in pairs(self.MemberListData) do
    v.charId = math.floor(v.charId)
    if v.charId == Z.ContainerMgr.CharSerialize.charId then
      table.insert(tempTable, 1, {info = v, isShowRefreshBtn = isShowRefreshBtn})
    else
      table.insert(tempTable, {info = v, isShowRefreshBtn = isShowRefreshBtn})
    end
  end
  return tempTable
end

function CameraMemberData:RemoveMemberListData(charId)
  for i = #self.MemberCharIdList, 1, -1 do
    if self.MemberCharIdList[i] == charId then
      table.remove(self.MemberCharIdList, i)
    end
  end
  Z.LuaDataMgr:UpdateCameraMemberCharIdCache(charId, false)
  self:ReleaseMemberModelByCharId(charId)
  self.MemberListData[charId] = nil
  Z.EventMgr:Dispatch(Z.ConstValue.CameraMember.CameraMemberListUpdate)
end

function CameraMemberData:InitMemberData(charId, data, isSelf)
  local cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  local entity = cameraMemberVM_:GetMemberEntity(charId)
  local isActionState = false
  if entity then
    local stateId = entity:GetLuaLocalAttrState()
    isActionState = stateId == Z.PbEnum("EActorState", "ActorStateAction")
  end
  local memberInfo = {}
  memberInfo.charId = charId
  memberInfo.baseData = {
    isActionState = isActionState,
    isNearby = true,
    isSelf = isSelf,
    model = nil
  }
  memberInfo.lookAtData = {
    headCurPos = Vector3.zero,
    eyesCurPos = Vector3.zero,
    headMode = E.CameraPlayerLookAtType.Default,
    eyesMode = E.CameraPlayerLookAtType.Default
  }
  memberInfo.actionData = {actionId = 0, actionPauseTime = 0}
  memberInfo.socialData = data
  return memberInfo
end

function CameraMemberData:ClearCameraMemberCharIdCache()
  Z.LuaDataMgr:ClearCameraMemberCharIdCache()
  self.MemberCharIdList = {}
end

function CameraMemberData:GetMemberModel(charId)
  return self.memberModelList_[charId]
end

function CameraMemberData:SetMemberModel(charId, model)
  self.memberModelList_[charId] = model
end

function CameraMemberData:ReleaseMemberModelByCharId(charId)
  if self.MemberListData[charId] and self.MemberListData[charId].baseData.model then
    Z.ZAnimActionPlayMgr:RecyclePhotoModel(self.MemberListData[charId].baseData.model)
    self.MemberListData[charId].baseData.model = nil
  end
end

function CameraMemberData:ClearMemberModel()
  for k, v in pairs(self.MemberListData) do
    if v and v.baseData.model and not v.baseData.isSelf then
      Z.ZAnimActionPlayMgr:RecyclePhotoModel(v.baseData.model)
    end
  end
end

return CameraMemberData
