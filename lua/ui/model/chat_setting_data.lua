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
end

function ChatSettingData:initChatList()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local data
    local key = string.zconcat("BKL_SHOW_CHANNEL", table.Id)
    if Z.LocalUserDataMgr.Contains(key) then
      data = Z.LocalUserDataMgr.GetBool(key)
    else
      local config = self:GetSettingData(table.FunctionId)
      local value = string.split(config.Value, "=")
      data = tonumber(value[1]) == 1
    end
    self.chatList_[table.Id] = data
  end
end

function ChatSettingData:GetBullet(ChannelID)
  return self.bulletList_[ChannelID]
end

function ChatSettingData:SetBullet(ChannelID, isShow)
  self.bulletList_[ChannelID] = isShow
  local key = string.zconcat("BKL_SHOW_BULLET", ChannelID)
  Z.LocalUserDataMgr.SetBool(key, isShow)
end

function ChatSettingData:initBullet()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local data
    local key = string.zconcat("BKL_SHOW_BULLET", table.Id)
    if Z.LocalUserDataMgr.Contains(key) then
      data = Z.LocalUserDataMgr.GetBool(key)
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
  Z.LocalUserDataMgr.SetBool(key, isShow)
  self.synthesisList_[ChannelID] = isShow
end

function ChatSettingData:initSynthesis()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  for _, table in pairs(channelTables) do
    local key = string.zconcat("BKL_SHOW_SYNTHESIS", table.Id)
    if not Z.LocalUserDataMgr.Contains(key) then
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
      local isShow = Z.LocalUserDataMgr.GetBool(key)
      self.synthesisList_[table.Id] = isShow
    end
  end
end

function ChatSettingData:SetAlpha(value)
  Z.LocalUserDataMgr.SetInt("BKL_SHOW_ALPHA", value)
  self.alpha_ = value
end

function ChatSettingData:GetAlpha()
  return self.alpha_
end

function ChatSettingData:initAlpha()
  local data
  local key = "BKL_SHOW_ALPHA"
  if Z.LocalUserDataMgr.Contains(key) then
    data = Z.LocalUserDataMgr.GetInt(key)
  else
    local config = self:GetSettingData(102197)
    local value = string.split(config.Value, "=")
    local array = string.split(value[2], ",")
    data = tonumber(array[3])
  end
  self.alpha_ = data
end

function ChatSettingData:SetFontSize(value)
  Z.LocalUserDataMgr.SetInt("BKL_SHOW_FONTSIZE", value)
  self.fontSize_ = value
end

function ChatSettingData:GetFontSize()
  return self.fontSize_
end

function ChatSettingData:initFontSize()
  local key = "BKL_SHOW_FONTSIZE"
  local data
  if Z.LocalUserDataMgr.Contains(key) then
    data = Z.LocalUserDataMgr.GetInt(key)
  else
    local config = self:GetSettingData(102197)
    local value = string.split(config.Value, "=")
    local array = string.split(value[1], ",")
    data = tonumber(array[3])
  end
  self.fontSize_ = data
end

function ChatSettingData:SetBulletSpeed(value)
  Z.LocalUserDataMgr.SetInt("BKL_SHOW_BULLETSPEED", value)
  self.bulletSpeed_ = value
end

function ChatSettingData:GetBulletSpeed()
  return self.bulletSpeed_
end

function ChatSettingData:initBulletSpeed()
  local data
  local key = "BKL_SHOW_BULLETSPEED"
  if Z.LocalUserDataMgr.Contains(key) then
    data = Z.LocalUserDataMgr.GetInt(key)
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
  Z.LocalUserDataMgr.SetInt(key, value)
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
    if Z.LocalUserDataMgr.Contains(key) then
      data = Z.LocalUserDataMgr.GetInt(key)
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

return ChatSettingData
