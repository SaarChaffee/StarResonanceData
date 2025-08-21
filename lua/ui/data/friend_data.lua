local FriendData = class("FriendData")

function FriendData:ctor()
  self:InitData()
end

function FriendData:RefreshBothWayFirned(friendCharId, socialInfo)
  self:SetIsGroup(false)
  self:SetGroupId(socialInfo.groupId)
  self:SetIsTop(socialInfo.top)
  self:SetRemark(socialInfo.remark)
  self:SetCharId(friendCharId)
  if socialInfo.socialData and socialInfo.socialData.basicData then
    self:SetShowId(socialInfo.socialData.basicData.showId)
  end
  self:SetIsRemind(socialInfo.remind)
end

function FriendData:RefreshPlayerSocialData(socialData)
  if socialData and socialData.basicData then
    self:SetPlayerName(socialData.basicData.name)
    self:SetPlayerGender(socialData.basicData.gender)
    self:SetPlayerLevel(socialData.basicData.level)
    self:SetPlayerOffLineTime(socialData.basicData.offlineTime)
    self:SetPlayerPersonalState(socialData.basicData.personalState)
    self:SetPlayerSceneId(socialData.basicData.sceneId)
    self:SetSocialData(socialData)
    local model = Z.ModelManager:GetModelIdByGenderAndSize(socialData.basicData.gender, socialData.basicData.bodySize)
    self:SetPlayerModelId(model)
    self:SetShowId(socialData.basicData.showId)
  end
  if socialData and socialData.avatarInfo then
    self:SetPlayerProfileInfo(socialData.avatarInfo.profile)
    self:SetPlayerAvatorInfo(socialData.avatarInfo)
  end
  if socialData and socialData.communityData then
    self:SetHasCohabitant(socialData.communityData.hasCohabitant)
  end
  self:SetInitInfo(true)
end

function FriendData:RefreshStranger(strangerCharId)
  self:SetIsGroup(false)
  self:SetCharId(strangerCharId)
  self:SetIsOneWayFriend(true)
end

function FriendData:RefreshBlackFriend(blackCharId)
  self:SetIsGroup(false)
  self:SetGroupId(E.FriendGroupType.Shield)
  self:SetCharId(blackCharId)
  self:SetIsBlack(true)
end

function FriendData:RefreshApplication(applicationInfo)
  self:SetCharId(applicationInfo.charId)
  self:SetApplySource(applicationInfo.source)
  self:SetApplyTimeStamp(applicationInfo.timeStamp)
end

function FriendData:InitData()
  self.headId_ = nil
  self.playerName_ = nil
  self.charId_ = nil
  self.isOnLine_ = false
  self.onLineStatus_ = nil
  self.pos_ = nil
  self.lastOnLineTime_ = nil
  self.isGroup_ = false
  self.groupId_ = nil
  self.isGroupShow_ = 1
  self.applySource_ = 0
  self.applyTimeStamp_ = 0
  self.isRemind = false
  self.isOneWayFriend_ = false
  self.isTop_ = false
  self.remark_ = ""
  self.friendShowInfo_ = nil
  self.isSelectOn_ = false
  self.isBlack_ = false
  self.lastMsgRecord_ = nil
  self.gender_ = 0
  self.level_ = 0
  self.profileInfo_ = nil
  self.offLineTime_ = 0
  self.personalState_ = {}
  self.modelId_ = 0
  self.avatorInfo_ = nil
  self.sceneId_ = 0
  self.initInfo_ = false
  self.socialData_ = nil
  self.hasCohabitant_ = false
end

function FriendData:GetIsBlack()
  return self.isBlack_
end

function FriendData:SetIsBlack(value)
  self.isBlack_ = value
end

function FriendData:GetIsSelect()
  return self.isSelectOn_
end

function FriendData:SetIsSelect(value)
  self.isSelectOn_ = value
end

function FriendData:GetPlayerName()
  return self.playerName_
end

function FriendData:SetPlayerName(value)
  self.playerName_ = value
end

function FriendData:GetSocialData()
  return self.socialData_
end

function FriendData:SetSocialData(socialData)
  self.socialData_ = socialData
end

function FriendData:GetPlayerGender()
  return self.gender_
end

function FriendData:SetPlayerGender(value)
  self.gender_ = value
end

function FriendData:GetPlayerLevel()
  return self.level_
end

function FriendData:SetPlayerLevel(value)
  self.level_ = value
end

function FriendData:GetPlayerProfileInfo()
  return self.profileInfo_
end

function FriendData:SetPlayerProfileInfo(value)
  self.profileInfo_ = value
end

function FriendData:GetPlayerOffLineTime()
  return self.offLineTime_
end

function FriendData:SetPlayerOffLineTime(value)
  self.offLineTime_ = value
end

function FriendData:GetPlayerPersonalState()
  return self.personalState_
end

function FriendData:SetPlayerPersonalState(value)
  self.personalState_ = value
end

function FriendData:GetPlayerModelId()
  return self.modelId_
end

function FriendData:SetPlayerModelId(value)
  self.modelId_ = value
end

function FriendData:GetPlayerAvatorInfo()
  return self.avatorInfo_
end

function FriendData:GetPlayerAvatorId()
  if self.avatorInfo_ then
    return self.avatorInfo_.avatarId
  end
  return 1
end

function FriendData:SetPlayerAvatorInfo(value)
  self.avatorInfo_ = value
end

function FriendData:GetPlayerSceneId()
  return self.sceneId_
end

function FriendData:SetPlayerSceneId(value)
  self.sceneId_ = value
end

function FriendData:IsInitInfo()
  return self.initInfo_
end

function FriendData:SetInitInfo(value)
  self.initInfo_ = value
end

function FriendData:SetFriendShowInfo(value)
  self.friendShowInfo_ = value
end

function FriendData:GetFriendShowInfo()
  return self.friendShowInfo_
end

function FriendData:SetRemark(value)
  self.remark_ = value
end

function FriendData:GetRemark()
  return self.remark_
end

function FriendData:SetIsTop(value)
  self.isTop_ = value
end

function FriendData:GetIsTop()
  return self.isTop_
end

function FriendData:GetIsOneWayFriend()
  return self.isOneWayFriend_
end

function FriendData:SetIsOneWayFriend(value)
  self.isOneWayFriend_ = value
end

function FriendData:GetCharId()
  return self.charId_
end

function FriendData:SetCharId(value)
  self.charId_ = value
end

function FriendData:GetShowId()
  return self.showId_
end

function FriendData:SetShowId(value)
  self.showId_ = value
end

function FriendData:GetIsRemind()
  return self.isRemind
end

function FriendData:SetIsRemind(value)
  self.isRemind = value
end

function FriendData:SetIsGroup(value)
  self.isGroup_ = value
end

function FriendData:GetIsGroup()
  return self.isGroup_
end

function FriendData:SetGroupId(value)
  self.groupId_ = value
end

function FriendData:GetGroupId()
  return self.groupId_
end

function FriendData:SetIsGroupShow(value)
  self.isGroupShow_ = value
end

function FriendData:GetIsGroupShow()
  return self.isGroupShow_
end

function FriendData:SetApplySource(value)
  self.applySource_ = value
end

function FriendData:GetApplySource()
  return self.applySource_
end

function FriendData:SetApplyTimeStamp(value)
  self.applyTimeStamp_ = value
end

function FriendData:GetApplyTimeStamp()
  return self.applyTimeStamp_
end

function FriendData:GetHasCohabitant()
  return self.hasCohabitant_
end

function FriendData:SetHasCohabitant(value)
  self.hasCohabitant_ = value
end

return FriendData
