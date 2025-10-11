local UI = Z.UI
local super = require("ui.ui_view_base")
local loop_list_view = require("ui.component.loop_list_view")
local loopGridView = require("ui.component.loop_grid_view")
local chat_setting_tab = require("ui.component.chat.chat_setting_tab")
local chatSettingItem = require("ui.component.chat.chat_setting_item")
local chatChannelFilterItem = require("ui.component.chat.chat_channel_filter_item")
local Chat_setting_popupView = class("Chat_setting_popupView", super)

function Chat_setting_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_setting_popup")
end

function Chat_setting_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:initVMData()
  self:initTabList()
  self:initMainChat()
  self:initDanmu()
  self:initFilter()
  self:initPrivacy()
  self.chatTabloop_:SetSelected(1)
end

function Chat_setting_popupView:OnDeActive()
  self:clearTabList()
  self:clearMainChat()
  self:clearDanmu()
  self:clearFilter()
  self:clearPrivacy()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
end

function Chat_setting_popupView:initVMData()
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.chatSettingVm_ = Z.VMMgr.GetVM("chat_setting")
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.channelList_ = self.chatData_:GetChannelList()
  self.tabList_ = {
    [1] = {
      name = Lang("MainUIChatWindow"),
      node = self.uiBinder.node_main,
      tabFunc = self.selectLeftTab,
      contentFunc = self.refreshMainChat
    },
    [2] = {
      name = Lang("BarrageSettings"),
      node = self.uiBinder.node_danmu,
      tabFunc = self.selectLeftTab,
      contentFunc = self.refreshDanmu
    },
    [3] = {
      name = Lang("FilterSettings"),
      node = self.uiBinder.node_filter,
      tabFunc = self.selectLeftTab,
      contentFunc = self.refreshFilter
    },
    [4] = {
      name = Lang("PrivacySettings"),
      node = self.uiBinder.node_privacy,
      tabFunc = self.selectLeftTab,
      contentFunc = self.refreshPrivacy
    }
  }
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_main, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_danmu, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_filter, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_privacy, false)
end

function Chat_setting_popupView:OnSelectTab(data)
  if data and data.tabFunc then
    data.tabFunc(self, data)
  end
end

function Chat_setting_popupView:selectLeftTab(data)
  if self.curContent_ then
    self.uiBinder.Ref:SetVisible(self.curContent_, false)
  end
  self.curContent_ = data.node
  self.uiBinder.Ref:SetVisible(self.curContent_, true)
  if data and data.contentFunc then
    data.contentFunc(self)
  end
end

function Chat_setting_popupView:initTabList()
  self.chatTabloop_ = loop_list_view.new(self, self.uiBinder.loop_tab, chat_setting_tab, "chat_set_tab_tpl")
  local tabList = {}
  local isOn1 = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ChatSettingChannelShow, true)
  if isOn1 then
    tabList[#tabList + 1] = self.tabList_[1]
  end
  local isOn2 = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ChatSettingBarrageShow, true)
  if isOn2 then
    tabList[#tabList + 1] = self.tabList_[2]
  end
  local isOn3 = self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.ChatSettingFilter, true)
  if isOn3 then
    tabList[#tabList + 1] = self.tabList_[3]
  end
  tabList[#tabList + 1] = self.tabList_[4]
  self.chatTabloop_:Init(tabList)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("chat_setting_popup")
  end)
end

function Chat_setting_popupView:clearTabList()
  self.chatTabloop_:UnInit()
end

function Chat_setting_popupView:initMainChat()
  self.mainChatChannelLoop_ = loopGridView.new(self, self.uiBinder.loop_channel, chatSettingItem, "chat_set_tpl")
  local dataList = {}
  for _, config in pairs(self.channelList_) do
    local data = self.chatSettingData_:GetSettingData(config.FunctionId)
    local value = string.split(data.Value, "=")
    local isShowSetting = tonumber(value[1]) == -1
    if not isShowSetting then
      dataList[#dataList + 1] = {
        configId = config.Id,
        configName = config.ChannelName,
        funcIndex = 1
      }
    end
  end
  dataList[#dataList + 1] = {
    configId = E.ChatChannelType.EChannelPrivate,
    configName = Lang("ChatPrivate"),
    funcIndex = 1
  }
  self.mainChatChannelLoop_:Init(dataList)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_isHide, Z.IsPCUI)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bottom, Z.IsPCUI)
  self.uiBinder.node_auto_hide:SetHeight(Z.IsPCUI and 333 or 200)
  local channel_key_pad = require("ui.view.cont_num_keyboard_view")
  self.channelKeyPad_ = channel_key_pad.new(self)
  self.uiBinder.tog_isHide:AddListener(function(isOn)
    self.chatSettingData_:SetMainChatPCViewAutoHide(isOn)
    self.changeAutoHideParam_ = true
  end)
  self.uiBinder.tog_link:AddListener(function(isOn)
    self.chatSettingData_:SetMainChatBubbleLink(isOn)
  end)
  self.uiBinder.btn_hide_time:AddListener(function()
    self.channelKeyPad_:Active({
      min = 1,
      max = 300,
      scale = 0.7,
      onInputOk = function(num)
        self:InputNum(num)
      end,
      onKeyPadClose = function()
        self.uiBinder.lab_hide_time.text = self.chatSettingData_:GetMainChatPCViewAutoHideTime()
      end
    }, self.uiBinder.node_num)
  end)
end

function Chat_setting_popupView:refreshMainChat()
  self.uiBinder.tog_isHide.isOn = self.chatSettingData_:GetMainChatPCViewAutoHide()
  self.uiBinder.lab_hide_time.text = self.chatSettingData_:GetMainChatPCViewAutoHideTime()
  self.uiBinder.tog_link.isOn = self.chatSettingData_:GetMainChatBubbleLink()
end

function Chat_setting_popupView:InputNum(num)
  self.chatSettingData_:SetMainChatPCViewAutoHideTime(num)
  self.uiBinder.lab_hide_time.text = num
  self.changeAutoHideParam_ = true
end

function Chat_setting_popupView:clearMainChat()
  self.mainChatChannelLoop_:UnInit()
  self.uiBinder.tog_isHide:RemoveAllListeners()
  self.uiBinder.tog_link:RemoveAllListeners()
  if self.changeAutoHideParam_ then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.MainChatAutoHideParamChange)
  end
end

function Chat_setting_popupView:initDanmu()
  self.danmuChannelLoop_ = loopGridView.new(self, self.uiBinder.loop_danmu, chatSettingItem, "chat_set_tpl")
  local dataList = {}
  for _, config in pairs(self.channelList_) do
    local data = self.chatSettingData_:GetSettingData(config.FunctionId)
    local value = string.split(data.Value, "=")
    local isShowSetting = tonumber(value[1]) == -1
    if not isShowSetting then
      dataList[#dataList + 1] = {
        configId = config.Id,
        configName = config.ChannelName,
        funcIndex = 2
      }
    end
  end
  self.danmuChannelLoop_:Init(dataList)
  local config = self.chatSettingData_:GetSettingData(102197)
  local value = string.split(config.Value, "=")
  local array = string.split(value[1], ",")
  self.maxSize_ = math.modf(array[2])
  self.minSize_ = math.modf(array[1])
  self.uiBinder.silder_font:AddListener(function()
    local font = self.minSize_ + math.floor((self.maxSize_ - self.minSize_) * self.uiBinder.silder_font.value)
    self.uiBinder.lab_font.text = tostring(font)
    self.chatSettingData_:SetFontSize(font)
  end)
  self.uiBinder.slider_alpha:AddListener(function()
    local alpha = math.floor(self.uiBinder.slider_alpha.value * 100)
    self.uiBinder.lab_alpha.text = string.format("%s", alpha) .. "%"
    self.chatSettingData_:SetAlpha(math.floor(alpha))
  end)
  self.uiBinder.tog_slow.isOn = false
  self.uiBinder.tog_moderate.isOn = false
  self.uiBinder.tog_fast.isOn = false
  self.uiBinder.tog_slow.group = self.uiBinder.togs_group
  self.uiBinder.tog_moderate.group = self.uiBinder.togs_group
  self.uiBinder.tog_fast.group = self.uiBinder.togs_group
  self.uiBinder.tog_slow:AddListener(function(isOn)
    if isOn then
      self.chatSettingData_:SetBulletSpeed(E.BulletSpeed.low)
    end
  end)
  self.uiBinder.tog_moderate:AddListener(function(isOn)
    if isOn then
      self.chatSettingData_:SetBulletSpeed(E.BulletSpeed.mid)
    end
  end)
  self.uiBinder.tog_fast:AddListener(function(isOn)
    if isOn then
      self.chatSettingData_:SetBulletSpeed(E.BulletSpeed.high)
    end
  end)
end

function Chat_setting_popupView:refreshDanmu()
  local fontSize = math.modf(self.chatSettingData_:GetFontSize())
  self.uiBinder.silder_font.value = (fontSize - self.minSize_) / (self.maxSize_ - self.minSize_)
  self.uiBinder.lab_font.text = tostring(fontSize)
  local alpha = self.chatSettingData_:GetAlpha()
  self.uiBinder.slider_alpha.value = alpha / 100
  self.uiBinder.lab_alpha.text = string.format("%s", math.floor(alpha)) .. "%"
  local bulletSpeed = self.chatSettingData_:GetBulletSpeed()
  if bulletSpeed == E.BulletSpeed.low then
    self.uiBinder.tog_slow.isOn = true
  elseif bulletSpeed == E.BulletSpeed.mid then
    self.uiBinder.tog_moderate.isOn = true
  else
    self.uiBinder.tog_fast.isOn = true
  end
end

function Chat_setting_popupView:clearDanmu()
  self.danmuChannelLoop_:UnInit()
  self.uiBinder.silder_font:RemoveAllListeners()
  self.uiBinder.slider_alpha:RemoveAllListeners()
  self.uiBinder.tog_slow.group = nil
  self.uiBinder.tog_moderate.group = nil
  self.uiBinder.tog_fast.group = nil
  self.uiBinder.tog_slow:RemoveAllListeners()
  self.uiBinder.tog_moderate:RemoveAllListeners()
  self.uiBinder.tog_fast:RemoveAllListeners()
end

function Chat_setting_popupView:initFilter()
  self:initPlayerLevelMinMax()
  self.uiBinder.slider_level_limit:AddListener(function()
    local levelLimit = self.playerLevelMin_ + math.floor((self.playerLevelMax_ - self.playerLevelMin_) * self.uiBinder.slider_level_limit.value)
    self.uiBinder.lab_level_limit.text = levelLimit
    self.chatSettingData_:SetMessageLevelLimit(self.selectChannelId_, levelLimit)
  end)
  local filterTabList = {}
  local channelFilter = {}
  for i = 1, #self.channelList_ do
    if self.channelList_[i].Id ~= E.ChatChannelType.ESystem then
      filterTabList[#filterTabList + 1] = {
        name = self.channelList_[i].ChannelName,
        configId = self.channelList_[i].Id,
        tabFunc = self.selectFilterChannel
      }
    end
    if self.channelList_[i].Id ~= E.ChatChannelType.EComprehensive then
      channelFilter[#channelFilter + 1] = {
        configName = self.channelList_[i].ChannelName,
        configId = self.channelList_[i].Id
      }
    end
  end
  self.chatSettingFilterTabLoop_ = loop_list_view.new(self, self.uiBinder.loop_filter, chat_setting_tab, "chat_set_channel_tpl")
  self.chatSettingFilterTabLoop_:Init(filterTabList)
  self.channelFilterLoop_ = loopGridView.new(self, self.uiBinder.loop_channel_show_filter, chatChannelFilterItem, "chat_set_tpl")
  self.channelFilterLoop_:Init(channelFilter)
end

function Chat_setting_popupView:initPlayerLevelMinMax()
  self.playerLevelMin_ = 1
  self.playerLevelMax_ = 1
  for _, levelData in pairs(self.chatData_:GetPlayerLevelTableData()) do
    if levelData and levelData.Level then
      if self.playerLevelMin_ > levelData.Level then
        self.playerLevelMin_ = levelData.Level
      end
      if self.playerLevelMax_ < levelData.Level then
        self.playerLevelMax_ = levelData.Level
      end
    end
  end
end

function Chat_setting_popupView:refreshFilter()
  self.chatSettingFilterTabLoop_:SetSelected(1)
end

function Chat_setting_popupView:selectFilterChannel(data)
  self.selectChannelId_ = data.configId
  if data.configId == E.ChatChannelType.EComprehensive then
    self:refreshChannelFilter(true)
  else
    self:refreshChannelFilter(false)
    self:refreshChannelMessageLevelLimit()
  end
end

function Chat_setting_popupView:refreshChannelMessageLevelLimit()
  local messageLevelLimit = math.modf(self.chatSettingData_:GetMessageLevel(self.selectChannelId_))
  self.uiBinder.lab_level_limit.text = tostring(messageLevelLimit)
  if self.playerLevelMax_ ~= self.playerLevelMin_ then
    self.uiBinder.slider_level_limit.value = (messageLevelLimit - self.playerLevelMin_) / (self.playerLevelMax_ - self.playerLevelMin_)
  end
end

function Chat_setting_popupView:refreshChannelFilter(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_channel_filter, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_level_limit, not isOn)
end

function Chat_setting_popupView:clearFilter()
  self.chatSettingFilterTabLoop_:UnInit()
  self.channelFilterLoop_:UnInit()
  self.uiBinder.slider_level_limit:RemoveAllListeners()
end

function Chat_setting_popupView:initPrivacy()
  self.choseList_ = {
    Lang("AcceptEveryone"),
    Lang("AcceptFriends"),
    Lang("NotAcceptAnyone")
  }
  self.uiBinder.dpd_team:ClearOptions()
  self.uiBinder.dpd_team:AddOptions(self.choseList_)
  self.uiBinder.dpd_team:AddListener(function(index)
    if 0 <= index then
      self.chatSettingData_:SetTeamApply(index)
    end
  end, true)
  self.uiBinder.dpd_carpool:ClearOptions()
  self.uiBinder.dpd_carpool:AddOptions(self.choseList_)
  self.uiBinder.dpd_carpool:AddListener(function(index)
    if 0 <= index then
      self.chatSettingData_:SetCarpoolApply(index)
    end
  end, true)
  self.uiBinder.dpd_interactive:ClearOptions()
  self.uiBinder.dpd_interactive:AddOptions(self.choseList_)
  self.uiBinder.dpd_interactive:AddListener(function(index)
    if 0 <= index then
      self.chatSettingData_:SetInteractiveApply(index)
    end
  end, true)
  self.uiBinder.switch_friend_apply:AddListener(function(IsOn)
    self.chatSettingData_:SetFriendApply(IsOn)
  end)
  self.uiBinder.switch_private_chat:AddListener(function(IsOn)
    self.chatSettingData_:SetReceivePrivateChat(IsOn)
  end)
end

function Chat_setting_popupView:refreshPrivacy()
  self.uiBinder.switch_friend_apply.IsOn = self.chatSettingData_:GetFriendApply()
  self.uiBinder.switch_private_chat.IsOn = self.chatSettingData_:GetReceivePrivateChat()
  self.uiBinder.dpd_team.value = self.chatSettingData_:GetTeamApply()
  self.uiBinder.dpd_carpool.value = self.chatSettingData_:GetCarpoolApply()
  self.uiBinder.dpd_interactive.value = self.chatSettingData_:GetInteractiveApply()
end

function Chat_setting_popupView:clearPrivacy()
  self.uiBinder.dpd_team:ClearAll()
  self.uiBinder.dpd_carpool:ClearAll()
  self.uiBinder.dpd_interactive:ClearAll()
  self.uiBinder.switch_friend_apply:RemoveAllListeners()
  self.uiBinder.switch_private_chat:RemoveAllListeners()
end

return Chat_setting_popupView
