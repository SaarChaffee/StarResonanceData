local super = require("ui.model.data_base")
local ChatSettingData = class("ChatSettingData", super)

function ChatSettingData:ctor()
  super.ctor(self)
end

function ChatSettingData:Init()
  self:Clear()
end

function ChatSettingData:UnInit()
  self:Clear()
end

function ChatSettingData:Clear()
  self.chatList_ = {}
  self.bulletList_ = {}
  self.synthesisList_ = {}
  self.fontSize_ = 24
  self.alpha_ = 1
  self.bulletSpeed_ = 0
  self.chatMessageLevel_ = {}
  self.settingTableData_ = nil
  self.isInit_ = false
end

function ChatSettingData:InitChatSetting()
  if not self.isInit_ then
    self.isInit_ = true
  else
    return
  end
  self:initChatList()
  self:initBullet()
  self:initSynthesis()
  self:initAlpha()
  self:initFontSize()
  self:initBulletSpeed()
  self:initMessageLevel()
  self:initMainChatPCViewAutoHideData()
  self:initFriendApply()
  self:initReceivePrivateChat()
  self:initTeamApply()
  self:initCarpoolApply()
  self:initInteractiveApply()
end

function ChatSettingData:OnLanguageChange()
  self.settingTableData_ = nil
end

function ChatSettingData:GetSettingData(systemID)
  if not self.settingTableData_ then
    self.settingTableData_ = Z.TableMgr.GetTable("SettingsTableMgr").GetDatas()
  end
  for _, v in pairs(self.settingTableData_) do
    if v.SystemId == systemID then
      return v
    end
  end
end

function ChatSettingData:GetAllChatList()
  return self.chatList_
end

function ChatSettingData:GetChatList(ChannelID)
  return self.chatList_[ChannelID]
end

function ChatSettingData:SetChatList(ChannelID, isShow)
  self.chatList_[ChannelID] = isShow
  local key = string.zconcat("BKL_SHOW_CHANNEL", Z.ContainerMgr.CharSerialize.charBase.charId, ChannelID)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, isShow)
end

function ChatSettingData:initChatList()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local data
    local key = string.zconcat("BKL_SHOW_CHANNEL", Z.ContainerMgr.CharSerialize.charBase.charId, table.Id)
    if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
      data = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key)
    else
      local config = self:GetSettingData(table.FunctionId)
      local value = string.split(config.Value, "=")
      data = tonumber(value[1]) == 1
    end
    self.chatList_[table.Id] = data
  end
  local data = true
  local key = string.zconcat("BKL_SHOW_CHANNEL", Z.ContainerMgr.CharSerialize.charBase.charId, E.ChatChannelType.EChannelPrivate)
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
    data = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key)
  end
  self.chatList_[E.ChatChannelType.EChannelPrivate] = data
end

function ChatSettingData:GetBullet(ChannelID)
  return self.bulletList_[ChannelID]
end

function ChatSettingData:SetBullet(ChannelID, isShow)
  self.bulletList_[ChannelID] = isShow
  local key = string.zconcat("BKL_SHOW_BULLET", ChannelID)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, isShow)
end

function ChatSettingData:initBullet()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local data
    local key = string.zconcat("BKL_SHOW_BULLET", table.Id)
    if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
      data = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key)
    else
      local config = self:GetSettingData(table.FunctionId)
      local value = string.split(config.Value, "=")
      data = tonumber(value[3]) == 1
    end
    self.bulletList_[table.Id] = data
  end
end

function ChatSettingData:GetSynthesisList()
  return self.synthesisList_
end

function ChatSettingData:GetSynthesis(ChannelID)
  return self.synthesisList_[ChannelID]
end

function ChatSettingData:SetSynthesis(ChannelID, isShow)
  local key = string.zconcat("BKL_SHOW_SYNTHESIS", ChannelID)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, key, isShow)
  self.synthesisList_[ChannelID] = isShow
end

function ChatSettingData:initSynthesis()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local key = string.zconcat("BKL_SHOW_SYNTHESIS", table.Id)
    if not Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
      local config = self:GetSettingData(102101)
      local value = string.split(config.Value, "=")
      local array = string.split(value[4], ",")
      self:SetSynthesis(table.Id, false)
      for _, v in pairs(array) do
        if table.Id == tonumber(v) then
          self:SetSynthesis(table.Id, true)
        end
      end
    else
      local isShow = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, key)
      self.synthesisList_[table.Id] = isShow
    end
  end
end

function ChatSettingData:SetAlpha(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_SHOW_ALPHA", value)
  self.alpha_ = value
end

function ChatSettingData:GetAlpha()
  return self.alpha_
end

function ChatSettingData:initAlpha()
  local data
  local key = "BKL_SHOW_ALPHA"
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
    data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, key)
  else
    local config = self:GetSettingData(102197)
    local value = string.split(config.Value, "=")
    local array = string.split(value[2], ",")
    data = tonumber(array[3])
  end
  self.alpha_ = data
end

function ChatSettingData:SetFontSize(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_SHOW_FONTSIZE", value)
  self.fontSize_ = value
end

function ChatSettingData:GetFontSize()
  return self.fontSize_
end

function ChatSettingData:initFontSize()
  local key = "BKL_SHOW_FONTSIZE"
  local data
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
    data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, key)
  else
    local config = self:GetSettingData(102197)
    local value = string.split(config.Value, "=")
    local array = string.split(value[1], ",")
    data = tonumber(array[3])
  end
  self.fontSize_ = data
end

function ChatSettingData:SetBulletSpeed(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_SHOW_BULLETSPEED", value)
  self.bulletSpeed_ = value
end

function ChatSettingData:GetBulletSpeed()
  return self.bulletSpeed_
end

function ChatSettingData:initBulletSpeed()
  local data
  local key = "BKL_SHOW_BULLETSPEED"
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
    data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, key)
  else
    local config = self:GetSettingData(102197)
    local value = string.split(config.Value, "=")
    local array = string.split(value[3], "=")
    data = tonumber(array[1])
  end
  self.bulletSpeed_ = data
end

function ChatSettingData:SetMessageLevelLimit(channelId, value)
  local key = string.zconcat("BKL_SHOW_MESSAGELEVELLIMIT", channelId)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, key, value)
  self.chatMessageLevel_[channelId] = value
end

function ChatSettingData:GetMessageLevel(channelId)
  return self.chatMessageLevel_[channelId]
end

function ChatSettingData:initMessageLevel()
  self.chatMessageLevel_ = {}
  local config = Z.TableMgr.GetTable("SettingsTableMgr").GetDatas()
  local systemID = 102198
  for i = E.ChatChannelType.EChannelWorld, E.ChatChannelType.EChannelPrivate do
    local key = string.zconcat("BKL_SHOW_MESSAGELEVELLIMIT", i)
    local data = 1
    if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, key) then
      data = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, key)
    else
      for _, v in pairs(config) do
        if v.SystemId == systemID then
          data = v.Value
          break
        end
      end
    end
    self.chatMessageLevel_[i] = data
  end
end

function ChatSettingData:initMainChatPCViewAutoHideData()
  self.mainChatPCViewAutoHide_ = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Device, "BKL_MainChatPCViewAutoHide", true)
  self.mainChatPCViewAutoHideTime_ = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "BKL_MainChatPCViewAutoHideTime", 60)
  self.mainChatBubbleLink_ = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Device, "BKL_MainChatBubbleLink", Z.IsPCUI)
end

function ChatSettingData:GetMainChatPCViewAutoHide()
  return self.mainChatPCViewAutoHide_
end

function ChatSettingData:SetMainChatPCViewAutoHide(isAutoHide)
  self.mainChatPCViewAutoHide_ = isAutoHide
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Device, "BKL_MainChatPCViewAutoHide", isAutoHide)
end

function ChatSettingData:GetMainChatPCViewAutoHideTime()
  return self.mainChatPCViewAutoHideTime_
end

function ChatSettingData:SetMainChatPCViewAutoHideTime(time)
  self.mainChatPCViewAutoHideTime_ = time
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Device, "BKL_MainChatPCViewAutoHideTime", time)
end

function ChatSettingData:GetMainChatBubbleLink()
  return self.mainChatBubbleLink_
end

function ChatSettingData:SetMainChatBubbleLink(isLinkRaycast)
  self.mainChatBubbleLink_ = isLinkRaycast
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Device, "BKL_MainChatBubbleLink", isLinkRaycast)
end

function ChatSettingData:SetFriendApply(value)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "BKL_FriendApply", value)
  self.friendApply_ = value
end

function ChatSettingData:GetFriendApply()
  return self.friendApply_
end

function ChatSettingData:initFriendApply()
  self.friendApply_ = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "BKL_FriendApply", true)
end

function ChatSettingData:SetReceivePrivateChat(value)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "BKL_ReceivePrivateChat", value)
  self.receivePrivateChat_ = value
end

function ChatSettingData:GetReceivePrivateChat()
  return self.receivePrivateChat_
end

function ChatSettingData:initReceivePrivateChat()
  self.receivePrivateChat_ = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "BKL_ReceivePrivateChat", true)
end

function ChatSettingData:SetTeamApply(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_TeamApply", value)
  self.teamApply_ = value
end

function ChatSettingData:GetTeamApply()
  return self.teamApply_
end

function ChatSettingData:initTeamApply()
  self.teamApply_ = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_TeamApply", 0)
end

function ChatSettingData:SetCarpoolApply(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_CarpoolApply", value)
  self.carpoolApply_ = value
end

function ChatSettingData:GetCarpoolApply()
  return self.carpoolApply_
end

function ChatSettingData:initCarpoolApply()
  self.carpoolApply_ = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_CarpoolApply", 0)
end

function ChatSettingData:SetInteractiveApply(value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, "BKL_InteractiveApply", value)
  self.interactiveApply_ = value
end

function ChatSettingData:GetInteractiveApply()
  return self.interactiveApply_
end

function ChatSettingData:initInteractiveApply()
  self.interactiveApply_ = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, "BKL_InteractiveApply", 0)
end

return ChatSettingData
