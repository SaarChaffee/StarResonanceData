local super = require("ui.model.data_base")
local TeamData = class("TeamData", super)

function TeamData:ctor()
  super.ctor(self)
  self:Clear()
end

function TeamData:Clear()
  self.TeamInfo = {}
  self.TeamInfo.baseInfo = {}
  self.TeamInfo.members = {}
  self.teamSimpleTime_ = {
    hallTeamListRefresh = 0,
    nearbyTeamListRefresh = 0,
    oneKeyJoin = 0,
    applyCaptain = 0
  }
  self.blockVoiceDIc_ = {}
  self.teamApplyStatus_ = {}
  self.teamInviteStatus_ = {}
  self.leaveAndApplyTeam_ = nil
  self.leaveAndReplyTeam_ = nil
  self.applyList = {}
  self.lasterLeaderId = 0
  self.VoiceRoomName = ""
  self.DungeonPrepareBeginTime = 0
  self.IsDungeonPrepareIng = false
  self.IsOpenMic = false
  self.DungeonPrepareCheckInfo = {}
  self.IsNeedCurProfession = false
  self.NeedMreMemberCount = 0
  self.teamInviteCd_ = {}
end

function TeamData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:InitCfgData()
end

function TeamData:InitCfgData()
  self.TeamTargetTableDatas = Z.TableMgr.GetTable("TeamTargetTableMgr").GetDatas()
end

function TeamData:OnLanguageChange()
  self:InitCfgData()
end

function TeamData:UnInit()
  self.CancelSource:Recycle()
end

function TeamData:setAttrETeammateList()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local teammateList = ZUtil.Pool.Collections.ZList_int.Rent()
  for _, member in pairs(self.TeamInfo.members) do
    teammateList:Add(member.charId)
  end
  Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.ETeammateList, teammateList)
  teammateList:Recycle()
end

function TeamData:SetTeamInfo(baseInfo, members)
  self.TeamInfo.baseInfo = baseInfo
  self.TeamInfo.members = members
  self:setAttrETeammateList()
end

function TeamData:SetTeamMember(charId, member)
  if self.TeamInfo.members[charId] and member then
    member.micState = self.TeamInfo.members[charId].micState
    member.speakState = self.TeamInfo.members[charId].speakState
  end
  self.TeamInfo.members[charId] = member
  self:setAttrETeammateList()
end

function TeamData:SetSocialData(charId, socialData)
  if self.TeamInfo.members[charId] then
    self.TeamInfo.members[charId].socialData = socialData
  end
end

function TeamData:GetMemberVoiceId(charId)
  if self.TeamInfo.members[charId] then
    return self.TeamInfo.members[charId].voiceId
  end
  return 0
end

function TeamData:SetMemberVoiceId(charId, voiceId)
  if self.TeamInfo.members[charId] then
    self.TeamInfo.members[charId].voiceId = voiceId
  end
end

function TeamData:SetTeamMemberSceneGuide(charId, sceneGuid)
  if self.TeamInfo.members[charId] then
    self.TeamInfo.members[charId].socialData.basicData.sceneGuid = sceneGuid
  end
end

function TeamData:SetTeamBaseInfo(baseInfo)
  self.TeamInfo.baseInfo = baseInfo
end

function TeamData:SetTeamMembers(members)
  self.TeamInfo.members = members
  self:setAttrETeammateList()
end

function TeamData:SetApplyList(charId)
  self.applyList[charId] = true
end

function TeamData:RemoveApplyList(charId)
  self.applyList[charId] = nil
end

function TeamData:RefeshApplyList(applyList)
  self.applyList = {}
  for k, v in pairs(applyList) do
    self.applyList[v.charId] = true
  end
end

function TeamData:GetApplyCount()
  return table.zcount(self.applyList)
end

function TeamData:ClearApply()
  self.applyList = {}
end

function TeamData:SetLeaderId(leaderId)
  self.lasterLeaderId = leaderId
end

function TeamData:GetLastLeaderId()
  return self.lasterLeaderId
end

function TeamData:SetTeamSimpleTime(data, key)
  if key then
    self.teamSimpleTime_[key] = data
    return
  end
  self.teamSimpleTime_ = data
end

function TeamData:GetTeamSimpleTime(key)
  if key then
    return self.teamSimpleTime_[key]
  end
  return self.teamSimpleTime_
end

function TeamData:SetTeamApplyStatus(teamId, status)
  self.teamApplyStatus_[teamId] = status
end

function TeamData:GetTeamApplyStatus(teamId)
  if teamId then
    return self.teamApplyStatus_[teamId]
  end
  return self.teamApplyStatus_
end

function TeamData:SetTeamInviteStatus(charId, status)
  self.teamInviteStatus_[charId] = status
end

function TeamData:GetTeamInviteStatus(charId)
  if charId then
    return self.teamInviteStatus_[charId]
  end
  return self.teamInviteStatus_
end

function TeamData:SetLeaveAndApplyTeam(teamList)
  self.leaveAndApplyTeam_ = teamList
end

function TeamData:GetLeaveAndApplyTeam()
  return self.leaveAndApplyTeam_
end

function TeamData:SetLeaveAndReplyTeam(teamList)
  self.leaveAndReplyTeam_ = teamList
end

function TeamData:GetLeaveAndReplyTeam()
  return self.leaveAndReplyTeam_
end

function TeamData:SetBlockVoiceState(charId, isBlock)
  self.blockVoiceDIc_[charId] = isBlock
end

function TeamData:GetBlockVoiceState(charId)
  return self.blockVoiceDIc_[charId]
end

function TeamData:SetInviteCd(charId)
  self.teamInviteCd_[charId] = Z.TimeTools.Now() / 1000
end

function TeamData:GetInviteCd(charId)
  return self.teamInviteCd_[charId] or 0
end

function TeamData:GetLeaderLevel()
  if self.TeamInfo == nil or self.TeamInfo.members == nil or self.TeamInfo.baseInfo == nil then
    return 0
  end
  for k, v in pairs(self.TeamInfo.members) do
    if v.charId == self.TeamInfo.baseInfo.leaderId and v.socialData and v.socialData.basicData then
      return v.socialData.basicData.level
    end
  end
  return 0
end

function TeamData:GetTeamMaxMember()
  if self.TeamInfo == nil or self.TeamInfo.members == nil or self.TeamInfo.baseInfo == nil then
    return 0
  end
  return self.TeamInfo.baseInfo.teamMemberType == E.ETeamMemberType.Five and Z.Global.TeamMaxNum or 20
end

return TeamData
