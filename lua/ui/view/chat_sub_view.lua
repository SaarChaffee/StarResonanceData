local channelIdMax = 9999
local channelBtnPath = "ui/prefabs/chat/chat_up_btn_tpl"
local UI = Z.UI
local loopScrollRect_ = require("ui/component/loopscrollrect")
local chat_channel_tab = require("ui.component.chat.chat_channel_tab")
local chat_input_boxView = require("ui.view.chat_input_box_view")
local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")
local super = require("ui.ui_subview_base")
local Chat_subView = class("Chat_subView", super)
E.EChatRightChannelBtnFunctionId = {
  EExpand = 102128,
  EPop = 102129,
  ESetting = 102130,
  ERotate = 102131
}

function Chat_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_sub", "chat/chat_sub", UI.ECacheLv.None)
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  self.chat_input_box_view_ = chat_input_boxView.new()
end

function Chat_subView:OnActive()
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.chatVm_ = Z.VMMgr.GetVM("chat_main")
  self.socialVm_ = Z.VMMgr.GetVM("socialcontact_main")
  self:startAnimatedShow()
  self:onInitData()
  self:onInitProp()
  self:BindEvents()
  Z.CoroUtil.create_coro_xpcall(function()
    self.chatVm_.asyncInitWorldChatChannelId()
  end)()
end

function Chat_subView:OnDeActive()
  self:UnBindEvents()
  self:setInputBox(false)
  self:setMsg(false)
  self:stopTimer()
  self.channelScrollRect_:ClearCells()
end

function Chat_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.BubbleMsg, self.OnChatBubble, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.GetRecord, self.refreshEmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.RefreshChatViewEmptyState, self.refreshEmptyState, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.RefreshChatChannel, self.refreshChatChannel, self)
end

function Chat_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.BubbleMsg, self.OnChatBubble, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.GetRecord, self.refreshEmptyState, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.RefreshChatViewEmptyState, self.refreshEmptyState, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.RefreshChatChannel, self.refreshChatChannel, self)
end

function Chat_subView:OnRefresh()
  local channelId = self.chatData_:GetChannelId()
  local channelIdx = self.chatData_:GetChannelIdxWithId(channelId)
  self.channelScrollRect_:SetSelected(channelIdx)
end

function Chat_subView:onInitData()
  self.timerList_ = {
    [E.ChatChannelType.EChannelWorld] = {},
    [E.ChatChannelType.EChannelScene] = {},
    [E.ChatChannelType.EChannelTeam] = {},
    [E.ChatChannelType.EChannelUnion] = {},
    [E.ChatChannelType.EComprehensive] = {}
  }
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:setInputBox(true)
  self:setMsg(true)
  self.channelScrollRect_ = loopScrollRect_.new(self.uiBinder.loopscroll_tab_list, self, chat_channel_tab)
  self.chatTips_ = nil
  self.editStr_ = ""
  self.isEdit_ = false
  self.rightChannelBtnList_ = {}
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_black, false)
  self:refreshChatChannel()
end

function Chat_subView:refreshChatChannel()
  local channelConfig = self.chatData_:GetChannelList()
  local channelId = self.chatData_:GetChannelId()
  local channelIdx = self.chatData_:GetChannelIdxWithId(channelId)
  self.channelScrollRect_:SetData(channelConfig)
  self.channelScrollRect_:SetSelected(channelIdx)
end

function Chat_subView:onInitProp()
  self.uiBinder.presscheck_editpress:StopCheck()
  if self.chatData_:GetScaleStatus() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_second, false)
    self.uiBinder.node_main_view_container:SetOffsetMin(-136, 0)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_second, true)
    self.uiBinder.node_main_view_container:SetOffsetMin(0, 0)
  end
  self:AddClick(self.uiBinder.btn_edit, function()
    self:onEditClickBtn()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:onKeyBoardOKClickBtn()
  end)
  self:AddClick(self.uiBinder.btn_del, function()
    self:onKeyBoardDelClickBtn()
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self.socialVm_.CloseSocialContactView()
  end)
  self:EventAddAsyncListener(self.uiBinder.presscheck_editpress.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.presscheck_editpress:StopCheck()
      self.isEdit_ = false
      self:onRefreshGroupTxt()
    end
  end, nil, nil)
  for i = 0, 9 do
    self:AddClick(self.uiBinder["btn_" .. i], function()
      local editeChannelId = self.editStr_ .. tostring(i)
      if tonumber(editeChannelId) > channelIdMax then
        return
      end
      self.editStr_ = editeChannelId
      self.uiBinder.input_channel.text = self.editStr_
    end)
  end
end

function Chat_subView:onMiniClickBtn()
  local channelId = self.chatData_:GetChannelId()
  if channelId ~= E.ChatChannelType.ESystem then
    self.chatVm_.OpenMiniChat(channelId)
    self.socialVm_.CloseSocialContactView()
  end
end

function Chat_subView:onSettingClickBtn()
  Z.UIMgr:OpenView("chat_setting_popup")
end

function Chat_subView:refreshRightChannelBtn(channelId)
  self:clearRightChannelBtn()
  local configData = self.chatData_:GetConfigData(channelId)
  if not (configData and configData.ChannelFunc and configData.ChannelFunc) or #configData.ChannelFunc == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local funcTable = Z.TableMgr.GetTable("FunctionTableMgr")
    for i = #configData.ChannelFunc, 1, -1 do
      local functionId = configData.ChannelFunc[i]
      local functionData = funcTable.GetRow(tonumber(functionId))
      if functionData and functionData.OnOff == 0 then
        local item = self:AsyncLoadUiUnit(channelBtnPath, functionId, self.uiBinder.node_up_icon)
        if item then
          item.img_icon:SetImage(functionData.Icon)
          self:rightChannelBtnAddFunc(functionId, item)
        end
        self.rightChannelBtnList_[#self.rightChannelBtnList_ + 1] = functionId
      end
    end
  end)()
end

function Chat_subView:rightChannelBtnAddFunc(functionId, item)
  functionId = tonumber(functionId)
  if functionId == E.EChatRightChannelBtnFunctionId.EExpand then
    if self.chatData_:GetScaleStatus() then
      item.img_icon_ref:SetScale(-1, 1)
    else
      item.img_icon_ref:SetScale(1, 1)
    end
    self:AddClick(item.btn_chat, function()
      if self.chatData_:GetScaleStatus() then
        self.chatData_:SetScaleStatus(false)
        self.uiBinder.node_main_view_container:SetOffsetMin(0, 0)
        self.uiBinder.anim_main_view:Restart(Z.DOTweenAnimType.Tween_0)
        item.img_icon_ref:SetScale(1, 1)
      else
        self.chatData_:SetScaleStatus(true)
        self.uiBinder.node_main_view_container:SetOffsetMin(-136, 0)
        self.uiBinder.anim_main_view:Restart(Z.DOTweenAnimType.Tween_1)
        item.img_icon_ref:SetScale(-1, 1)
      end
    end)
  elseif functionId == E.EChatRightChannelBtnFunctionId.EPop then
    self:AddClick(item.btn_chat, function()
      self:onMiniClickBtn()
    end)
  elseif functionId == E.EChatRightChannelBtnFunctionId.ESetting then
    self:AddClick(item.btn_chat, function()
      self:onSettingClickBtn()
    end)
  elseif functionId == E.EChatRightChannelBtnFunctionId.ERotate then
    self:AddClick(item.btn_chat, function()
      Z.TipsVM.ShowTipsLang(100102)
    end)
  end
end

function Chat_subView:clearRightChannelBtn()
  if self.rightChannelBtnList_ and table.zcount(self.rightChannelBtnList_) > 0 then
    for _, name in pairs(self.rightChannelBtnList_) do
      self:RemoveUiUnit(name)
    end
    self.rightChannelBtnList_ = {}
  end
end

function Chat_subView:onKeyBoardOKClickBtn()
  self.chatVm_.AsyncChannelGroupSwitch(tonumber(self.editStr_), self.cancelSource:CreateToken())
  self.uiBinder.presscheck_editpress:StopCheck()
  self.isEdit_ = false
  self:onRefreshGroupTxt()
end

function Chat_subView:onKeyBoardDelClickBtn()
  local len = string.zlen(self.editStr_)
  self.editStr_ = string.zcut(self.editStr_, len - 1)
  self.uiBinder.input_channel.text = self.editStr_
end

function Chat_subView:onEditClickBtn()
  if self.isEdit_ == true then
    self.uiBinder.presscheck_editpress:StopCheck()
    self.isEdit_ = false
    self:onRefreshGroupTxt()
    return
  end
  self.isEdit_ = true
  self.uiBinder.presscheck_editpress:StartCheck()
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_channel, true)
  self.editStr_ = ""
  self.uiBinder.input_channel.text = ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_small_keyboard, true)
end

function Chat_subView:onRefreshChannelName()
  if self.chatData_:GetChannelId() == E.ChatChannelType.EChannelWorld then
    self:onRefreshGroupTxt()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.input_channel, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_edit, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_small_keyboard, false)
    self:refreshWorldChannelState()
  end
  self.uiBinder.lab_current.text = self.chatData_:GetChannelName(self.chatData_:GetChannelId())
end

function Chat_subView:onRefreshGroupTxt()
  self.uiBinder.Ref:SetVisible(self.uiBinder.input_channel, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_edit, true)
  self.editStr_ = ""
  self.uiBinder.input_channel.text = self.chatData_:GetShowWorldGroupChannel() or ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_small_keyboard, false)
  self:refreshWorldChannelState()
end

function Chat_subView:refreshWorldChannelState()
  if self.chatData_:GetChannelId() ~= E.ChatChannelType.EChannelWorld then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_world_channel_state, false)
    return
  end
  local curNum = self.chatData_:GetWorldNum()
  local curMaxNum = self.chatData_:GetWorldMaxNum()
  if curMaxNum == 0 then
    return
  end
  local numPre = curNum / curMaxNum * 100
  if numPre >= Z.Global.ChatWorldGreenNum[1] and numPre <= Z.Global.ChatWorldGreenNum[2] then
    self.uiBinder.img_world_channel_state:SetColorByHex("#74d782")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_green"), E.TextStyleTag.ChannelGuild)
  elseif numPre >= Z.Global.ChatWorldOrangeNum[1] and numPre <= Z.Global.ChatWorldOrangeNum[2] then
    self.uiBinder.img_world_channel_state:SetColorByHex("#ffc777")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_orange"), E.TextStyleTag.ChannelFriend)
  else
    self.uiBinder.img_world_channel_state:SetColorByHex("#ff9777")
    self.uiBinder.lab_world_channel_state.text = Z.RichTextHelper.ApplyStyleTag(Lang("world_channel_state_red"), E.TextStyleTag.ChannelSystem)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_world_channel_state, true)
end

function Chat_subView:onInitCd()
  for k, v in pairs(self.chatData_:GetChatCDList()) do
    self:onRefreshCD(k)
  end
end

function Chat_subView:onRefreshCD(channelId)
  for k, v in pairs(self.timerList_) do
    if channelId == k then
      self:refreshTimer(v.timer, channelId)
    end
  end
end

function Chat_subView:refreshTimer(timer, channelId)
  local cdTime = self.chatData_:GetChatCD(channelId)
  if 0 < cdTime then
    local tmpTime = cdTime
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
    local func = function()
      tmpTime = tmpTime - 1
      self.chatVm_.SetChatCD(channelId, tmpTime)
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
    end
    local delta = 1
    local funcFinish = function()
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
    end
    if timer then
      self.timerMgr:StopTimer(timer)
    else
      timer = self.timerMgr:StartTimer(func, delta, cdTime, nil, funcFinish)
    end
  end
end

function Chat_subView:stopTimer()
  for k, v in pairs(self.timerList_) do
    if v.timer then
      self.timerMgr:StopTimer(v.timer)
    end
  end
end

function Chat_subView:setInputBox(isShowInput)
  if isShowInput then
    local inputViewData = {}
    inputViewData.parentView = self
    inputViewData.windowType = E.ChatWindow.Main
    inputViewData.showInputBg = false
    inputViewData.isShowVoice = true
    
    function inputViewData.onEmojiViewChange(isShowEmoji)
      self:onEmojiViewShow(isShowEmoji)
    end
    
    self.chat_input_box_view_:Active(inputViewData, self.uiBinder.node_bottom_container, self.uiBinder)
  elseif self.chat_input_box_view_ then
    self.chat_input_box_view_:DeActive()
  end
end

function Chat_subView:setInputBoxVisible(isShowInput)
  if isShowInput then
    if self.chat_input_box_view_ then
      self.chat_input_box_view_:SetVisible(true)
      self.chat_input_box_view_:RefreshChatDraft(true)
    else
      self:setInputBox(true)
    end
  elseif self.chat_input_box_view_ then
    self.chat_input_box_view_:SetVisible(false)
  end
end

function Chat_subView:onEmojiViewShow(isShowEmoji)
  if isShowEmoji then
    self.uiBinder.node_dialogue_parent:SetOffsetMin(1, 475)
  else
    self.uiBinder.node_dialogue_parent:SetOffsetMin(1, 117)
  end
  if self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:ResetListView()
    self.chat_dialogue_tpl_view_:OnMsgRefreshFromEnd()
  end
  self:setInputBoxVisible(not isShowEmoji)
end

function Chat_subView:setMsg(isShow)
  if isShow then
    local chatDialogueViewData = {}
    chatDialogueViewData.parentView = self
    chatDialogueViewData.windowType = E.ChatWindow.Main
    self.chat_dialogue_tpl_view_:Active(chatDialogueViewData, self.uiBinder.node_dialogue_parent, self.uiBinder)
  elseif self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
    self.chat_dialogue_tpl_view_ = nil
  end
end

function Chat_subView:SwitchChannel(Id)
  if not self.uiBinder then
    return
  end
  self.chatData_:SetChannelId(Id)
  self:onRefreshChannelName()
  self:refreshRightChannelBtn(Id)
  self:refreshEmptyState()
  if Id == E.ChatChannelType.EChannelUnion then
    self.chatVm_.CheckChatChannelUnionTips()
  end
  if Id == E.ChatChannelType.ESystem then
    self.uiBinder.node_dialogue_parent:SetOffsetMin(1, 50)
  else
    self.uiBinder.node_dialogue_parent:SetOffsetMin(1, 117)
  end
  if self.chat_dialogue_tpl_view_ and self.chat_dialogue_tpl_view_.IsActive and self.chat_dialogue_tpl_view_.IsLoaded then
    self.chat_dialogue_tpl_view_:SwitchChannelId(Id)
  end
  if self.chat_input_box_view_ and self.chat_input_box_view_.IsActive and self.chat_input_box_view_.IsLoaded then
    self.chat_input_box_view_:SwitchChannelId(Id)
  end
end

function Chat_subView:OnChatBubble(chatMsgData)
  if Z.ChatMsgHelper.GetChannelId(chatMsgData) == E.ChatChannelType.EChannelPrivate then
    return
  end
  if Z.ChatMsgHelper.GetChannelId(chatMsgData) ~= self.chatData_:GetChannelId() then
    return
  end
  self:refreshEmptyState()
end

function Chat_subView:refreshEmptyState()
  local queue = self.chatData_:GetChannelQueueByChannelId(self.chatData_:GetChannelId(), nil, true)
  if not queue then
    return
  end
  local showEmpty = table.zcount(queue) == 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_black, showEmpty)
end

function Chat_subView:startAnimatedShow()
  if self.viewData.isFirstOpen then
    self.uiBinder.anim_main_view:Restart(Z.DOTweenAnimType.Open)
  end
end

return Chat_subView
