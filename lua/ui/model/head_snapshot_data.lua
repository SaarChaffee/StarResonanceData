local super = require("ui.model.data_base")
local Snapshot = class("Snapshot", super)

function Snapshot:ctor()
  super.ctor(self)
  self.IsInstancePlayerEnt = false
  self.LastGetHeadTime = {}
  self.LastGetHalfTime = {}
  self.HeadData = {}
  self.HalfData = {}
  self.UploadIntervalTime = 60
  self.ExplicitHash = 0
  self.IsSwitchScene = false
  self.SelfSocialData = nil
  self.SnapType = {
    [E.PictureType.EProfileSnapShot] = "snapshot",
    [E.PictureType.EProfileHalfBody] = "halflength"
  }
  self.PictureIdDic = {}
  self.NowGetHeadTimeByCharId = {}
  self.cachePlayerHeadSocialData_ = {}
  self.LoadPlayerHeadData = {}
  self.RefreshPlayerHeadData = {}
  self.IsRefreshPlayerHeadData = false
  local socialVM = Z.VMMgr.GetVM("social")
  self.PlayerHeadMask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
  self.PlayerHeadMask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAvatar, self.PlayerHeadMask)
  self.PlayerHeadMask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, self.PlayerHeadMask)
  self.TimeCheckCount = 10
  self.allPlayerHeadDataCount_ = 100
end

function Snapshot:Init()
  self.IsStartCountdown = true
  self.IsOpenSnapshot = nil
  self.PlayerInfo = {headId = -1, halfId = -1}
  self.CancelSource = Z.CancelSource.Rent()
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.clearCacheSocialDataByCharId, self)
end

function Snapshot:UnInit()
  self.CancelSource:Recycle()
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.clearCacheSocialDataByCharId, self)
end

function Snapshot:Clear()
  self:clearData()
end

function Snapshot:OnReconnect()
  self:clearData()
end

function Snapshot:clearData()
  self.CancelSource:CancelAll()
  self.cachePlayerHeadSocialData_ = {}
  self.LoadPlayerHeadData = {}
  self.RefreshPlayerHeadData = {}
  self.IsRefreshPlayerHeadData = false
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.LoadPlayerHead)
end

function Snapshot:clearCacheSocialDataByCharId()
  for i = #self.cachePlayerHeadSocialData_, 1, -1 do
    if self.cachePlayerHeadSocialData_[i].charId == Z.ContainerMgr.CharSerialize.charBase.charId then
      table.remove(self.cachePlayerHeadSocialData_, i)
      return
    end
  end
end

function Snapshot:CheckPlayerHeadInLoadingList(charId, callBackFunc)
  for i = 1, #self.LoadPlayerHeadData do
    if self.LoadPlayerHeadData[i].charId == charId then
      table.insert(self.LoadPlayerHeadData[i].callBackList, callBackFunc)
      return true
    end
  end
  return false
end

function Snapshot:CheckPlayerHeadIsLoading(charId, callBackFunc)
  for i = 1, #self.RefreshPlayerHeadData do
    if self.RefreshPlayerHeadData[i].charId == charId then
      table.insert(self.RefreshPlayerHeadData[i].callBackList, callBackFunc)
      return true
    end
  end
  return false
end

function Snapshot:AddPlayerHeadSocialData(charId, socialData)
  local playerSocialData = {charId = charId, data = socialData}
  table.insert(self.cachePlayerHeadSocialData_, playerSocialData)
  if table.zcount(self.cachePlayerHeadSocialData_) > self.allPlayerHeadDataCount_ then
    table.remove(self.cachePlayerHeadSocialData_, 1)
  end
end

function Snapshot:GetPlayerHeadSocialData(charId)
  for i = #self.cachePlayerHeadSocialData_, 1, -1 do
    if self.cachePlayerHeadSocialData_[i].charId == charId then
      local value = table.remove(self.cachePlayerHeadSocialData_, i)
      table.insert(self.cachePlayerHeadSocialData_, value)
      return value.data
    end
  end
end

function Snapshot:SetHeadDataInfo(charId, headId, version)
  self.HeadData[charId] = {textureId = headId, version = version}
end

function Snapshot:GetHeadDataInfo(charId)
  if self.HeadData[charId] then
    return self.HeadData[charId]
  end
  return nil
end

function Snapshot:SetHalfDataInfo(charId, id, version)
  self.HalfData[charId] = {textureId = id, version = version}
end

function Snapshot:GetHalfDataInfo(charId)
  if self.HalfData[charId] then
    return self.HalfData[charId]
  end
  return nil
end

function Snapshot:SetTime(time)
  self.UploadIntervalTime = time
end

function Snapshot:GetTime()
  return self.UploadIntervalTime
end

function Snapshot:SetHeadTime(charId, time)
  self.LastGetHeadTime[charId] = time or 0
end

function Snapshot:SetHalfTime(charId, time)
  self.LastGetHalfTime[charId] = time
end

function Snapshot:GetLastGetHeadTime(charId)
  if self.LastGetHeadTime[charId] then
    return self.LastGetHeadTime[charId]
  end
  return 0
end

function Snapshot:GetLastGetHalfTime(charId)
  if self.LastGetHalfTime[charId] then
    return self.LastGetHalfTime[charId]
  end
  return 0
end

function Snapshot:ChangeState(state)
  self.IsChange = state
end

function Snapshot:SetIsSwitchScence(state)
  self.IsSwitchScene = state
end

function Snapshot:SetSelfSocialData(socialData)
  self.SelfSocialData = socialData
end

function Snapshot:GetSelfSocialData()
  return self.SelfSocialData
end

return Snapshot
