local UI = Z.UI
local super = require("ui.ui_view_base")
local chat_setting_toggle_itemPath = "ui/prefabs/chat/chat_set_tog_tpl"
local loopScrollRect_ = require("ui/component/loopscrollrect")
local chat_setting_filter_tab = require("ui.component.chat.chat_setting_filter_tab")
local Chat_setting_popupView = class("Chat_setting_popupView", super)

function Chat_setting_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_setting_popup")
end

function Chat_setting_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self:onInitProp()
  self:onInitComp()
  self:onInitData()
end

function Chat_setting_popupView:OnDeActive()
  self.isShowTog_ = false
  self.isBarrageTog_ = false
  self.isFillterTog_ = false
  self:onRefreshBullet(false)
  self:resetBulletStatus()
  self:onRefreshFilter(false)
  self.chatSettingFilterTabLoopScroll_:ClearCells()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
end

function Chat_setting_popupView:OnRefresh()
end

function Chat_setting_popupView:onInitProp()
  self.chatSettingVm_ = Z.VMMgr.GetVM("chat_setting")
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.channelConfig_ = self.chatData_:GetChannelList()
  self.curType_ = E.ChatSettingTagType.Show
  self.isShowTog_ = false
  self.isBarrageTog_ = false
  self.isFillterTog_ = false
  self.isArrow_ = false
  self.selectChannelId_ = 0
  self.playerLevelMin_ = 1
  self.playerLevelMax_ = 1
  self:initPlayerLevelMinMax()
  self.chatSettingFilterTabLoopScroll_ = loopScrollRect_.new(self.uiBinder.loopscroll, self, chat_setting_filter_tab)
  self:initChatMain()
  self:initChatFilter()
  self:initChatBullet()
end

function Chat_setting_popupView:onInitComp()
  self.uiBinder.tog_show_item.group = self.uiBinder.layout_tog
  self.uiBinder.tog_barrage_item.group = self.uiBinder.layout_tog
  self.uiBinder.tog_filter_item.group = self.uiBinder.layout_tog
  self.uiBinder.tog_slow.group = self.uiBinder.togs_group
  self.uiBinder.tog_moderate.group = self.uiBinder.togs_group
  self.uiBinder.tog_fast.group = self.uiBinder.togs_group
  self.uiBinder.tog_show_item:AddListener(function(isOn)
    self:onRefreshChatMain(isOn)
  end)
  self.uiBinder.tog_barrage_item:AddListener(function(isOn)
    self:onRefreshBullet(isOn)
  end)
  self.uiBinder.tog_filter_item:AddListener(function(isOn)
    self:onRefreshFilter(isOn)
  end)
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
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("chat_setting_popup")
  end)
  self:onRefreshChatMain(false)
  self:onRefreshBullet(false)
  self:onRefreshFilter(false)
  if self.viewData and self.viewData.goToTab == E.ChatSetTab.MsgFilter then
    self.uiBinder.tog_filter_item.isOn = true
    self:onRefreshFilter(true)
  else
    self.uiBinder.tog_show_item.isOn = true
    self:onRefreshChatMain(true)
  end
end

function Chat_setting_popupView:onInitData()
  self.fontSize_ = math.modf(self.chatSettingData_:GetFontSize())
  local config = self.chatSettingData_:GetSettingData(102197)
  local value = string.split(config.Value, "=")
  local array = string.split(value[1], ",")
  self.maxSize_ = math.modf(array[2])
  self.minSize_ = math.modf(array[1])
  self.uiBinder.img_silder_font_danmu.value = (self.fontSize_ - self.minSize_) / (self.maxSize_ - self.minSize_)
  self.uiBinder.lab_font_danmu.text = tostring(self.fontSize_)
  self.uiBinder.img_silder_font_danmu:AddListener(function()
    local font = self.minSize_ + math.floor((self.maxSize_ - self.minSize_) * self.uiBinder.img_silder_font_danmu.value)
    self.uiBinder.lab_font_danmu.text = tostring(font)
    self.chatSettingData_:SetFontSize(font)
  end)
  self.alpha_ = self.chatSettingData_:GetAlpha()
  self.uiBinder.img_silder_alpha.value = self.alpha_ / 100
  self.uiBinder.lab_alpha.text = string.format("%s", math.floor(self.alpha_)) .. "%"
  self.uiBinder.img_silder_alpha:AddListener(function()
    local alpha = math.floor(self.uiBinder.img_silder_alpha.value * 100)
    self.uiBinder.lab_alpha.text = string.format("%s", alpha) .. "%"
    self.chatSettingData_:SetAlpha(math.floor(alpha))
  end)
end

function Chat_setting_popupView:onRefreshChatMain(isOn)
  if isOn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_channel_show, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_channel_show, false)
  end
end

function Chat_setting_popupView:initChatMain()
  if self.isShowTog_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, config in pairs(self.channelConfig_) do
      local data = self.chatSettingData_:GetSettingData(config.FunctionId)
      local value = string.split(data.Value, "=")
      local isShow = tonumber(value[1]) == -1
      if not isShow then
        local unitName = string.zconcat(config.Id, "show_tog")
        local isShow = self.chatSettingData_:GetChatList(config.Id)
        local click = function(isOn)
          self.chatSettingVm_.SetChannel(config.Id, isOn)
        end
        self:asyncLoadSettingToggle(unitName, self.uiBinder.togs_channel, isShow, config.ChannelName, click)
      end
    end
    self.isShowTog_ = true
  end)()
end

function Chat_setting_popupView:asyncLoadSettingToggle(unitName, unitRoot, isOn, togContext, func)
  local item = self:AsyncLoadUiUnit(chat_setting_toggle_itemPath, unitName, unitRoot)
  item.tog_item:RemoveAllListeners()
  item.tog_item:SetIsOnWithoutCallBack(isOn)
  item.lab_title.text = togContext
  item.tog_item:AddListener(func)
end

function Chat_setting_popupView:onRefreshBullet(isOn)
  if isOn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_danmu, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_danmu, false)
  end
end

function Chat_setting_popupView:initChatBullet()
  if self.isBarrageTog_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, config in pairs(self.channelConfig_) do
      local unitName = string.zconcat(config.ChannelName, "bullet")
      local isShow = self.chatSettingData_:GetBullet(config.Id)
      local click = function(isOn)
        self.chatSettingVm_.SetBullet(config.Id, isOn)
      end
      self:asyncLoadSettingToggle(unitName, self.uiBinder.layout_danmu, isShow, config.ChannelName, click)
    end
    self.isBarrageTog_ = true
  end)()
  self:resetBulletStatus()
end

function Chat_setting_popupView:resetBulletStatus()
  local bulletSpeed = self.chatSettingData_:GetBulletSpeed()
  if bulletSpeed == E.BulletSpeed.low then
    self.uiBinder.tog_slow.isOn = true
  elseif bulletSpeed == E.BulletSpeed.mid then
    self.uiBinder.tog_moderate.isOn = true
  else
    self.uiBinder.tog_fast.isOn = true
  end
end

function Chat_setting_popupView:onRefreshFilter(isOn)
  if isOn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info_filter, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_info_filter, false)
  end
end

function Chat_setting_popupView:initChatFilter()
  if self.isFillterTog_ then
    return
  end
  self:initFilterTab()
  Z.CoroUtil.create_coro_xpcall(function()
    for _, config in pairs(self.channelConfig_) do
      if config.Id ~= 100 then
        local unitName = string.zconcat(config.ChannelName, "show_synthesis")
        local isShow = self.chatSettingData_:GetSynthesis(config.Id)
        local click = function(isOn)
          self.chatSettingData_:SetSynthesis(config.Id, isOn)
          local chatMainVm = Z.VMMgr.GetVM("chat_main")
          chatMainVm.UpdateComprehensiveRecord()
          Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
        end
        self:asyncLoadSettingToggle(unitName, self.uiBinder.layout_info_show, isShow, config.ChannelName, click)
      end
    end
    self.isFillterTog_ = true
  end)()
end

function Chat_setting_popupView:initFilterTab()
  local config = self.chatData_:GetChannelList()
  self.filterTabList_ = {}
  if config then
    for i = 1, table.zcount(config) do
      if config[i].Id ~= E.ChatChannelType.ESystem then
        local filterTab = {}
        filterTab.filterConfigId_ = config[i].Id
        filterTab.filterName_ = config[i].ChannelName
        self.filterTabList_[#self.filterTabList_ + 1] = filterTab
        if self.selectChannelId_ == 0 then
          self.selectChannelId_ = config[i].Id
        end
      end
    end
  end
  self.chatSettingFilterTabLoopScroll_:RefreshData(self.filterTabList_)
  self.chatSettingFilterTabLoopScroll_:SetSelected(0)
end

function Chat_setting_popupView:GetSelectChannelId()
  return self.selectChannelId_
end

function Chat_setting_popupView:GetFilterTabParent()
  if not self.uiBinder then
    return
  end
  return self.uiBinder.node_filter_content
end

function Chat_setting_popupView:initPlayerLevelMinMax()
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

function Chat_setting_popupView:refreshChannelMessageLevelLimit()
  local messageLevelLimit = math.modf(self.chatSettingData_:GetMessageLevel(self.selectChannelId_))
  self.uiBinder.lab_font_level.text = tostring(messageLevelLimit)
  if self.playerLevelMax_ ~= self.playerLevelMin_ then
    self.uiBinder.img_silder_font_level.value = (messageLevelLimit - self.playerLevelMin_) / (self.playerLevelMax_ - self.playerLevelMin_)
  end
  self.uiBinder.img_silder_font_level:AddListener(function()
    local levelLimit = self.playerLevelMin_ + math.floor((self.playerLevelMax_ - self.playerLevelMin_) * self.uiBinder.img_silder_font_level.value)
    self.uiBinder.lab_font_level.text = levelLimit
    self.chatSettingData_:SetMessageLevelLimit(self.selectChannelId_, levelLimit)
  end)
end

function Chat_setting_popupView:RefreshChannel(filterConfigId)
  self.selectChannelId_ = filterConfigId
  if filterConfigId == E.ChatChannelType.EComprehensive then
    self:refreshChannelFilter(true)
  else
    self:refreshChannelFilter(false)
    self:refreshChannelMessageLevelLimit()
  end
end

function Chat_setting_popupView:refreshChannelFilter(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_title2_1, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_title2_2, not isOn)
end

return Chat_setting_popupView
