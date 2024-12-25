local super = require("ui.ui_view_base")
local Chat_emoji_container_popupView = class("Chat_emoji_container_popupView", super)
local chat_input_boxView = require("ui.view.chat_input_box_view")
local loop_grid_view = require("ui.component.loop_grid_view")
local loop_list_view = require("ui.component.loop_list_view")
local chat_func_item = require("ui.component.emoji.chat_func_item")
local chat_tab_item = require("ui.component.emoji.chat_tab_item")
local chat_emoji_item = require("ui.component.emoji.chat_emoji_item")
local chat_backpack_item = require("ui.component.emoji.chat_backpack_item")
local chat_rich_item = require("ui.component.emoji.chat_rich_item")
local chat_record_item = require("ui.component.emoji.chat_record_item")
E.EChantStickType = {
  EStandardEmoji = 1,
  EEmoji = 2,
  EPicture = 3
}
local emojiPath = "ui/atlas/chat/emoji/"

function Chat_emoji_container_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_emoji_container_popup")
  self.chat_input_boxView_ = chat_input_boxView.new()
  self.emojiCount_ = 63
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Chat_emoji_container_popupView:OnActive()
  self.funcList_ = loop_grid_view.new(self, self.uiBinder.node_func_list, chat_func_item, "chat_emoji_func_toggle_tpl")
  self.funcList_:Init({})
  self.tabList_ = loop_list_view.new(self, self.uiBinder.node_tab_list, chat_tab_item, "chat_emoji_tab_tpl_new")
  self.tabList_:Init({})
  self.gridList_ = loop_grid_view.new(self, self.uiBinder.node_grid_content)
  self.gridList_:SetGetItemClassFunc(function(data)
    if self.curFuncType_ == E.ChatFuncType.Emoji then
      if self.curGroupId_ == E.EChantStickType.EStandardEmoji then
        return chat_rich_item
      else
        return chat_emoji_item
      end
    elseif self.curFuncType_ == E.ChatFuncType.Backpack then
      return chat_backpack_item
    elseif self.curFuncType_ == E.ChatFuncType.Record then
      return chat_record_item
    end
  end)
  self.gridList_:SetGetPrefabNameFunc(function(data)
    if self.curFuncType_ == E.ChatFuncType.Emoji then
      if self.curGroupId_ == 1 then
        return "chat_emoji_standard_item_tpl"
      else
        return "chat_emoji_small_item_tpl"
      end
    elseif self.curFuncType_ == E.ChatFuncType.Backpack then
      return "com_item_long_1"
    elseif self.curFuncType_ == E.ChatFuncType.Record then
      return "chat_emoji_standard_item_tpl"
    end
  end)
  self.gridList_:Init({})
  self.loopList_ = loop_list_view.new(self, self.uiBinder.node_list_content, chat_record_item, "chat_record_tpl")
  self.loopList_:Init({})
  self:startAnimatedShow()
  self:setInputBox(true)
  self:onInitData()
  self:onInitFunc()
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatHistoryRefresh, self.refreshHistory, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.ClearItemShare, self.clearItemShare, self)
  self:refreshFirstFunc()
  self:RegisterInputActions()
end

function Chat_emoji_container_popupView:OnDeActive()
  self.funcList_:UnInit()
  self.tabList_:UnInit()
  self.gridList_:UnInit()
  self.loopList_:UnInit()
  self:UnRegisterInputActions()
  self:setInputBox(false)
  if self.viewData and self.viewData.parentView then
    self.viewData.parentView:OnEmojiViewClose()
  end
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatHistoryRefresh, self.refreshHistory, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.ClearItemShare, self.clearItemShare, self)
end

function Chat_emoji_container_popupView:OnRefresh()
  self:RefreshBackSpaceBtn()
end

function Chat_emoji_container_popupView:refreshFirstFunc()
  local data = Z.TableMgr.GetTable("FunctionTableMgr")
  local switchVm = Z.VMMgr.GetVM("switch")
  local list = {}
  for i = 1, #Z.Global.ChatEnterFunction do
    local funcData = Z.Global.ChatEnterFunction[i]
    for j = 2, #funcData do
      local funcId = funcData[j]
      local funcRow = data.GetRow(funcId)
      local isOpen = switchVm.CheckFuncSwitch(funcId)
      if funcRow ~= nil and isOpen then
        table.insert(list, {
          funcType = funcData[1],
          funcRow = funcRow
        })
      end
    end
  end
  self.funcList_:RefreshListView(list, false)
  self.funcList_:SelectIndex(0)
end

function Chat_emoji_container_popupView:OnSelectFuncTab(funcType, funcId)
  self.curFuncType_ = funcType
  self.curFunctionId_ = funcId
  if funcType == E.ChatFuncType.Emoji then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_list_content, false)
    local list = {}
    for groupId, iconName in pairs(Z.Global.ChatStickersSort) do
      list[#list + 1] = {
        id = groupId,
        icon = string.zconcat(emojiPath, iconName)
      }
    end
    self.tabList_:RefreshListView(list, false)
    self.tabList_:ClearAllSelect()
    self.tabList_:SetSelected(1)
  elseif funcType == E.ChatFuncType.Record then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_list_content, true)
    self:refreshHistory()
  elseif funcType == E.ChatFuncType.Backpack then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_list_content, false)
    local backpackId = self:getBackpackTypeByFuncId(funcId)
    if not backpackId then
      return
    end
    local itemPackageData = Z.TableMgr.GetTable("ItemPackageTableMgr").GetRow(backpackId)
    if not itemPackageData then
      return
    end
    if table.zcount(itemPackageData.Classify) == 0 then
      local contentList = self:getItemListByBackpackType(backpackId, -1)
      local width = self.uiBinder.node_grid_ref.rect.width
      local count = math.floor(width / 146)
      self.gridList_:SetGridFixedGroupCount(Z.GridFixedType.ColumnCountFixed, count)
      self.gridList_:SetItemSize(Vector2.New(146, 189))
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, false)
      self.uiBinder.node_grid_ref:SetOffsetMin(0, 20)
      self.uiBinder.node_grid_ref:SetOffsetMax(0, -20)
      self.gridList_:ClearAllSelect()
      self.gridList_:RefreshListView(contentList, false)
    else
      local list = {}
      local backpackVm = Z.VMMgr.GetVM("backpack")
      local tabList = backpackVm.GetSecondClassSortData(backpackId)
      for i = 1, #tabList do
        table.insert(list, {
          id = tonumber(tabList[i][1]),
          icon = string.zconcat(self:GetBackpackItemIconPath(), tabList[i][4]),
          name = tabList[i][3],
          tag = tonumber(tabList[i][2])
        })
      end
      list[1].id = 1
      list[1].icon = "ui/atlas/bag/secondclass/bag_icon_all"
      list[1].name = Lang("All")
      list[1].tag = -1
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, true)
      self.uiBinder.node_grid_ref:SetOffsetMin(0, 20)
      self.uiBinder.node_grid_ref:SetOffsetMax(0, -70)
      self.tabList_:RefreshListView(list, false)
      self.tabList_:ClearAllSelect()
      self.tabList_:SetSelected(1)
    end
  end
end

function Chat_emoji_container_popupView:GetBackpackItemIconPath()
  local path = ""
  local backpackId = self:getBackpackTypeByFuncId(self.curFunctionId_)
  if backpackId == E.BackPackItemPackageType.Item then
    path = "ui/atlas/bag/secondclass/"
  elseif backpackId == E.BackPackItemPackageType.Equip then
    path = "ui/atlas/bag/equip_bag/"
  elseif backpackId == E.BackPackItemPackageType.Mod then
    path = "ui/atlas/bag/mod_bag/"
  elseif backpackId == E.BackPackItemPackageType.ResonanceSkill then
    path = "ui/atlas/bag/resonance_skill_bag/"
  end
  return path
end

function Chat_emoji_container_popupView:getBackpackTypeByFuncId(funcId)
  for _, data in pairs(Z.Global.ChatItemPackageId) do
    if data[1] == funcId then
      return data[2]
    end
  end
end

function Chat_emoji_container_popupView:getFilterData(tag)
  local data = {}
  data.filterMask = E.ItemFilterType.ItemType + E.ItemFilterType.ItemRare
  data.itemType = tag
  data.filterTgas = {}
  return data
end

function Chat_emoji_container_popupView:getItemListByBackpackType(backpackId, tag)
  local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
  local itemSortData = itemSortFactoryVm.GetSortData(backpackId)
  local itemFilterData = self:getFilterData(tag)
  local sortFunc = itemSortFactoryVm.GetItemSortFunc(backpackId, itemSortData)
  local itemFilterFactoryVM = Z.VMMgr.GetVM("item_filter_factory")
  local filterFuncs = itemFilterFactoryVM.GetBackpackItemFilterFunc(itemFilterData)
  local itemsVm = Z.VMMgr.GetVM("items")
  local contentList = itemsVm.GetItemIds(backpackId, filterFuncs, sortFunc)
  return contentList
end

function Chat_emoji_container_popupView:OnSelectSecondTab(groupId, tag)
  self.curGroupId_ = groupId
  local contentList = {}
  local width = self.uiBinder.node_grid_ref.rect.width
  local count = 1
  if self.curFuncType_ == E.ChatFuncType.Emoji then
    if self.curGroupId_ == 1 then
      self.gridList_:SetItemSize(Vector2.New(80, 80))
      count = math.floor(width / 80)
    else
      self.gridList_:SetItemSize(Vector2.New(132, 132))
      count = math.floor(width / 132)
    end
    contentList = self:getEmojiList(groupId)
  elseif self.curFuncType_ == E.ChatFuncType.Backpack then
    self.gridList_:SetItemSize(Vector2.New(146, 189))
    count = math.floor(width / 146)
    local backpackId = self:getBackpackTypeByFuncId(self.curFunctionId_)
    contentList = self:getItemListByBackpackType(backpackId, tag)
  end
  self.uiBinder.node_grid_ref:SetOffsetMin(20, 20)
  self.uiBinder.node_grid_ref:SetOffsetMax(0, -76)
  self.gridList_:SetGridFixedGroupCount(Z.GridFixedType.ColumnCountFixed, count)
  self.gridList_:ClearAllSelect()
  self.gridList_:RefreshListView(contentList, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, 0 < table.zcount(contentList))
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, table.zcount(contentList) == 0)
end

function Chat_emoji_container_popupView:OnSelectBackpackItem(item)
  self.chat_input_boxView_:InputItem(item)
end

function Chat_emoji_container_popupView:setInputBox(isShow)
  if isShow then
    local inputViewData = {}
    inputViewData.parentView = self
    inputViewData.windowType = self.viewData.windowType
    inputViewData.channelId = self.viewData.channelId
    inputViewData.showInputBg = true
    inputViewData.isEmojiInput = true
    self.chat_input_boxView_:Active(inputViewData, self.uiBinder.node_chat_input)
  elseif self.chat_input_boxView_ then
    self.chat_input_boxView_:DeActive()
  end
end

function Chat_emoji_container_popupView:onInitData()
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.curFunctionId_ = -1
  self.curFuncType_ = nil
end

function Chat_emoji_container_popupView:onInitFunc()
  self:AddClick(self.uiBinder.btn_popup_close, function()
    self.chat_input_boxView_:DelMsg()
    self:RefreshBackSpaceBtn()
    self:RefreshParentInput()
  end)
  self.uiBinder.presscheck_tipspress:StartCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck_tipspress.ContainGoEvent, function(isContain)
    if isContain then
      self.uiBinder.presscheck_tipspress:StopCheck()
      Z.UIMgr:CloseView("chat_emoji_container_popup")
    end
  end, nil, nil)
end

function Chat_emoji_container_popupView:RefreshParentInput()
  self.viewData.parentView:RefreshChatDraft(true)
end

function Chat_emoji_container_popupView:refreshHistory()
  if self.curFuncType_ == E.ChatFuncType.Record then
    local list = {}
    local recordList = self.chatData_:GetMsgHistory()
    for i = 1, #recordList do
      table.insert(list, {
        content = recordList[i],
        width = self.uiBinder.node_list_ref.rect.width
      })
    end
    self.loopList_:RefreshListView(list, false)
  end
end

function Chat_emoji_container_popupView:clearItemShare()
  self.gridList_:ClearAllSelect()
end

function Chat_emoji_container_popupView:getEmojiList(groupId)
  if groupId == E.EChantStickType.EStandardEmoji then
    if not self.richList_ then
      self.richList_ = {}
      for i = 1, self.emojiCount_ do
        table.insert(self.richList_, string.format("<sprite=%s>", i))
      end
    end
    return self.richList_
  else
    return self.chatData_:GetGroupSprite(groupId)
  end
end

function Chat_emoji_container_popupView:InputEmoji(data)
  self.chat_input_boxView_:InputEmoji(data, false)
end

function Chat_emoji_container_popupView:SendMessage(msg, chitChatMsgType, configId)
  Z.CoroUtil.create_coro_xpcall(function()
    self.chatMainVm_.AsyncSendMessage(self.viewData.channelId, msg, chitChatMsgType, configId, self.cancelSource:CreateToken())
  end)()
end

function Chat_emoji_container_popupView:RefreshBackSpaceBtn()
  if not self.chatData_ or not self.uiBinder then
    return
  end
  local chatDraft = self.chatData_:GetChatDraft(self.viewData.channelId, self.viewData.windowType)
  if not (chatDraft and chatDraft.msg) or chatDraft.msg == "" then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_backspace, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_backspace, true)
  end
end

function Chat_emoji_container_popupView:startAnimatedShow()
  self.uiBinder.anim_emoji_container:Restart(Z.DOTweenAnimType.Open)
end

function Chat_emoji_container_popupView:startAnimatedHide()
  self.uiBinder.anim_emoji_container:Restart(Z.DOTweenAnimType.Close)
end

function Chat_emoji_container_popupView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Chat)
end

function Chat_emoji_container_popupView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Chat)
end

return Chat_emoji_container_popupView
