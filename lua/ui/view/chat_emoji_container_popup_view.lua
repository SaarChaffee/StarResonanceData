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
local chat_quick_message_item = require("ui.component.emoji.chat_quick_message_item")

function Chat_emoji_container_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_emoji_container_popup")
end

function Chat_emoji_container_popupView:OnActive()
  self.commonVM_ = Z.VMMgr.GetVM("common")
  if not self.viewData or not self.viewData.isHideChatInputBox then
    self.chat_input_boxView_ = chat_input_boxView.new()
  end
  self.emojiCount_ = 63
  self:startAnimatedShow()
  self.funcList_ = loop_grid_view.new(self, self.uiBinder.node_func_list, chat_func_item, "chat_emoji_func_toggle_tpl", true)
  self.funcList_:Init({})
  self.tabList_ = loop_list_view.new(self, self.uiBinder.node_tab_list, chat_tab_item, "chat_emoji_tab_tpl_new", true)
  self.tabList_:Init({})
  self.gridList_ = loop_grid_view.new(self, self.uiBinder.node_grid_content)
  self.gridList_:SetGetItemClassFunc(function(data)
    if self.curFuncType_ == E.ChatFuncType.Emoji then
      if self.curGroupId_ == 1 then
        return chat_rich_item
      else
        return chat_emoji_item
      end
    elseif self.curFuncType_ == E.ChatFuncType.Backpack then
      return chat_backpack_item
    elseif self.curFuncType_ == E.ChatFuncType.Record then
      return chat_record_item
    elseif self.curFuncType_ == E.ChatFuncType.QuickMessage then
      return chat_quick_message_item
    end
  end)
  self.gridList_:SetGetPrefabNameFunc(function(data)
    local prefabName = "chat_emoji_standard_item_tpl"
    if self.curFuncType_ == E.ChatFuncType.Emoji then
      if self.curGroupId_ == 1 then
        prefabName = "chat_emoji_standard_item_tpl"
      else
        prefabName = "chat_emoji_small_item_tpl"
      end
    elseif self.curFuncType_ == E.ChatFuncType.Backpack then
      prefabName = "com_item_long_1"
    elseif self.curFuncType_ == E.ChatFuncType.Record then
      prefabName = "chat_emoji_standard_item_tpl"
    elseif self.curFuncType_ == E.ChatFuncType.QuickMessage then
      prefabName = "chat_shortcut_tpl"
    end
    if Z.IsPCUI then
      prefabName = string.zconcat(prefabName, "_pc")
    end
    return prefabName
  end)
  self.gridList_:Init({})
  self.loopList_ = loop_list_view.new(self, self.uiBinder.node_list_content, chat_record_item, "chat_record_tpl", true)
  self.loopList_:Init({})
  self:setInputBox(true)
  self:onInitData()
  self:onInitFunc()
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatHistoryRefresh, self.refreshContent, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.ClearItemShare, self.clearItemShare, self)
  self:refreshFirstFunc()
end

function Chat_emoji_container_popupView:OnDeActive()
  self.funcList_:UnInit()
  self.tabList_:UnInit()
  self.gridList_:UnInit()
  self.loopList_:UnInit()
  self:setInputBox(false)
  if self.viewData and self.viewData.parentView and self.viewData.parentView.OnEmojiViewClose then
    self.viewData.parentView:OnEmojiViewClose()
  end
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
    for _, data in ipairs(Z.Global.ChatStickersSort) do
      local info = string.zsplit(data, "=")
      if info[2] ~= nil and info[2] ~= "" then
        list[#list + 1] = {
          id = tonumber(info[1]),
          raw_icon = string.zconcat(Z.ConstValue.Emoji.EmojiPath, info[2]),
          showSpecial = info[3] or 0,
          emoji = true
        }
      end
    end
    self.tabList_:RefreshListView(list, false)
    self.tabList_:ClearAllSelect()
    self.tabList_:SetSelected(1)
  elseif funcType == E.ChatFuncType.Record then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_list_content, true)
    self:refreshContent(true)
  elseif funcType == E.ChatFuncType.QuickMessage then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_list_content, false)
    self.uiBinder.node_grid_ref:SetOffsetMin(20, 20)
    self.uiBinder.node_grid_ref:SetOffsetMax(0, -20)
    local width = self.uiBinder.node_grid_ref.rect.width
    local count = math.floor(width / 362)
    self.gridList_:SetGridFixedGroupCount(Z.GridFixedType.ColumnCountFixed, count)
    local itemHeight = Z.IsPCUI and 32 or 52
    self.gridList_:SetItemSize(Vector2.New(362, itemHeight))
    self.gridList_:SetItemPadding(Vector2.New(18, 18))
    local list = self.chatData_:GetGroupSpriteByType(E.EChatStickersType.EQuickMessage)
    self.gridList_:RefreshListView(list, false)
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
      local itemWidth = Z.IsPCUI and 64 or 146
      local itemHeight = Z.IsPCUI and 64 or 189
      local count = math.floor(width / (itemWidth + 6))
      self.gridList_:SetGridFixedGroupCount(Z.GridFixedType.ColumnCountFixed, count)
      self.gridList_:SetItemSize(Vector2.New(itemWidth, itemHeight))
      self.gridList_:SetItemPadding(Vector2.New(6, 6))
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab, false)
      self.uiBinder.node_grid_ref:SetOffsetMin(20, 20)
      self.uiBinder.node_grid_ref:SetOffsetMax(-20, -20)
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
      self.uiBinder.node_grid_ref:SetOffsetMin(20, 20)
      self.uiBinder.node_grid_ref:SetOffsetMax(0, -70)
      self.tabList_:RefreshListView(list, false)
      self.tabList_:ClearAllSelect()
      self.tabList_:SetSelected(1)
    end
  elseif funcType == E.ChatFuncType.LocalPosition then
    self.viewData.parentView:InputLocalPosition()
    if self.chat_input_boxView_ then
      self.chat_input_boxView_:RefreshChatDraft()
    end
  end
end

function Chat_emoji_container_popupView:OnPointerClickSelectFuncTab(funcType, funcId)
  if funcType == E.ChatFuncType.LocalPosition then
    self.viewData.parentView:InputLocalPosition()
    if self.chat_input_boxView_ then
      self.chat_input_boxView_:RefreshChatDraft()
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
  data.filterTags = {}
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
  if Z.IsPCUI then
    self.uiBinder.node_grid_ref:SetOffsetMin(14, 10)
    self.uiBinder.node_grid_ref:SetOffsetMax(-14, -46)
  else
    self.uiBinder.node_grid_ref:SetOffsetMin(20, 20)
    self.uiBinder.node_grid_ref:SetOffsetMax(0, -76)
  end
  self.gridList_:SetItemPadding(Vector2.New(6, 6))
  self.curGroupId_ = groupId
  local contentList = {}
  local width = self.uiBinder.node_grid_ref.rect.width
  local count = 1
  if self.curFuncType_ == E.ChatFuncType.Emoji then
    if self.curGroupId_ == 1 then
      local itemSize = Z.IsPCUI and 64 or 80
      self.gridList_:SetItemSize(Vector2.New(itemSize, itemSize))
      count = math.floor(width / (itemSize + 6))
    else
      local itemSize = Z.IsPCUI and 64 or 132
      self.gridList_:SetItemSize(Vector2.New(itemSize, itemSize))
      count = math.floor(width / (itemSize + 6))
    end
    contentList = self:getEmojiList(groupId)
  elseif self.curFuncType_ == E.ChatFuncType.Backpack then
    local itemWidth = Z.IsPCUI and 64 or 138
    local itemHeight = Z.IsPCUI and 64 or 180
    self.gridList_:SetItemSize(Vector2.New(itemWidth, itemHeight))
    count = math.floor(width / (itemWidth + 6))
    local backpackId = self:getBackpackTypeByFuncId(self.curFunctionId_)
    contentList = self:getItemListByBackpackType(backpackId, tag)
  end
  self.gridList_:SetGridFixedGroupCount(Z.GridFixedType.ColumnCountFixed, count)
  self.gridList_:ClearAllSelect()
  self.gridList_:RefreshListView(contentList, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_grid_content, 0 < table.zcount(contentList))
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, table.zcount(contentList) == 0)
end

function Chat_emoji_container_popupView:OnSelectBackpackItem(item)
  self.viewData.parentView:InputItem(item)
  if self.chat_input_boxView_ then
    self.chat_input_boxView_:RefreshChatDraft()
  end
end

function Chat_emoji_container_popupView:setInputBox(isShow)
  if self.viewData.isHideChatInputBox then
    return
  end
  if isShow then
    local inputViewData = {
      parentView = self,
      windowType = self.viewData.windowType,
      channelId = self.viewData.channelId,
      charId = self.viewData.charId,
      showInputBg = true,
      isEmojiInput = true
    }
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
  if self.uiBinder.btn_popup_close then
    self:AddClick(self.uiBinder.btn_popup_close, function()
      self.viewData.parentView:DelMsg()
      if self.chat_input_boxView_ then
        self.chat_input_boxView_:RefreshChatDraft()
      end
      self:RefreshBackSpaceBtn()
      self:RefreshParentInput()
    end)
  end
  self.uiBinder.presscheck_tipspress:StartCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck_tipspress.ContainGoEvent, function(isContain)
    if not isContain then
      self.uiBinder.presscheck_tipspress:StopCheck()
      Z.UIMgr:CloseView("chat_emoji_container_popup")
    end
  end, nil, nil)
end

function Chat_emoji_container_popupView:RefreshParentInput()
  self.viewData.parentView:RefreshChatDraft(true)
end

function Chat_emoji_container_popupView:refreshContent(selectTab)
  if not selectTab and self.curFuncType_ ~= E.ChatFuncType.Record then
    return
  end
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

function Chat_emoji_container_popupView:clearItemShare()
  self.gridList_:ClearAllSelect()
end

local sortFunc = function(left, right)
  local chatMainVM = Z.VMMgr.GetVM("chat_main")
  local leftUnlock = true
  if left.UnlockItem > 0 then
    leftUnlock = chatMainVM.GetChatEmojiUnlock(left.Id)
  end
  local rightUnlock = true
  if right.UnlockItem > 0 then
    rightUnlock = chatMainVM.GetChatEmojiUnlock(right.Id)
  end
  if leftUnlock then
    if rightUnlock then
      return left.Id < right.Id
    else
      return true
    end
  elseif rightUnlock then
    return false
  else
    return left.Id < right.Id
  end
  return left.Id < right.Id
end

function Chat_emoji_container_popupView:getEmojiList(groupId)
  if groupId == 1 then
    if not self.richList_ then
      self.richList_ = {}
      for i = 1, self.emojiCount_ do
        table.insert(self.richList_, string.format("<sprite=%s>", i))
      end
    end
    return self.richList_
  else
    local list = self.chatData_:GetGroupSprite(groupId)
    table.sort(list, sortFunc)
    return list
  end
end

function Chat_emoji_container_popupView:InputEmoji(data)
  self.viewData.parentView:InputEmoji(data, false)
  if self.chat_input_boxView_ then
    self.chat_input_boxView_:RefreshChatDraft()
  end
end

function Chat_emoji_container_popupView:SendMessage(msg, chitChatMsgType, configId)
  Z.CoroUtil.create_coro_xpcall(function()
    self.chatMainVm_.AsyncSendMessage(self.viewData.channelId, self.viewData.charId, msg, chitChatMsgType, configId, self.cancelSource:CreateToken())
  end)()
end

function Chat_emoji_container_popupView:RefreshBackSpaceBtn()
  if not (self.chatData_ and self.uiBinder) or not self.uiBinder.node_backspace then
    return
  end
  local chatDraft = self.chatData_:GetChatDraft(self.viewData.channelId, self.viewData.windowType, self.viewData.charId)
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
  self.commonVM_.CommonDotweenPlay(self.uiBinder.anim_emoji_container, Z.DOTweenAnimType.Close, function()
    self:Hide()
  end)
end

return Chat_emoji_container_popupView
