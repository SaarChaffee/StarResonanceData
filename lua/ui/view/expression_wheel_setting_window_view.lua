local UI = Z.UI
local super = require("ui.ui_view_base")
local Expression_wheel_setting_windowView = class("Expression_wheel_setting_windowView", super)
local loop_list_view = require("ui.component.loop_list_view")
local expression_setting_item = require("ui.component.wheel.expression_setting_item")
local ExpressWheelSettingListItem = require("ui.component.wheel.expression_wheel_setting_list_item")

function Expression_wheel_setting_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "expression_wheel_setting_window")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.wheelData_ = Z.DataMgr.Get("wheel_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Expression_wheel_setting_windowView:OnActive()
  self.curWheelPage = self.wheelData_:GetWheelPage()
  self.expressionVm_.CloseExpressionFastWindow()
  self.tabListView_ = loop_list_view.new(self, self.uiBinder.node_list, expression_setting_item, "expression_setting_item")
  self.tabListView_:Init({})
  local tabList = self:GetTabTableData()
  self.tabListView_:RefreshListView(tabList, false)
  self.tabListView_:ClearAllSelect()
  self.tabListView_:SetSelected(1)
  self:initWheelList()
  self:bindBtnClick()
  local curToggle = self.uiBinder.node_expression[string.zconcat("tog_", self.curWheelPage)]
  if curToggle then
    curToggle.isOn = true
  end
end

function Expression_wheel_setting_windowView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.expressionVm_.CloseExpressionWheelSettingView()
  end)
  for i = 1, 3 do
    local toggle = self.uiBinder.node_expression[string.zconcat("tog_", i)]
    toggle:AddListener(function(isOn)
      if isOn then
        self.curWheelPage = i
      end
      self:initWheelList()
    end)
  end
  for i = 1, self.wheelData_.WheelCount do
    local uiBinder = self.uiBinder.node_expression[string.zconcat("node_setting", i)]
    self:AddClick(uiBinder.btn_emoji_delete, function()
      self:removeEmoji(i)
    end)
    self:AddClick(uiBinder.btn_lab_delete, function()
      self:removeEmoji(i)
    end)
    self:AddClick(uiBinder.btn_emoji_send, function()
      self:setEmojiData(i, self.curSettingData)
      self.expressionVm_.SetExpressionTargetFinish()
      self:SetItemClick(nil)
    end)
    self:AddClick(uiBinder.btn_lab_send, function()
      self:setEmojiData(i, self.curSettingData)
      self.expressionVm_.SetExpressionTargetFinish()
      self:SetItemClick(nil)
    end)
  end
end

function Expression_wheel_setting_windowView:OnDeActive()
  self.tabListView_:UnInit()
  self:ClearAllUnits()
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_item_trans.Trans, false)
end

function Expression_wheel_setting_windowView:initWheelList()
  self.uiBinder.node_expression.lab_info.text = self.curWheelPage
  local list = self.wheelData_:GetWheelList(self.curWheelPage)
  for i = 1, self.wheelData_.WheelCount do
    if not list[i] or list[i].type == 0 then
      self:setEmojiEmpty(i)
    else
      self:setEmojiData(i, list[i])
    end
  end
  self.uiBinder.node_expression.roulette:SwitchCheck(false)
end

function Expression_wheel_setting_windowView:removeEmoji(index)
  local list = self.wheelData_:GetWheelList(self.curWheelPage)
  list[index] = {type = 0, id = 0}
  self.wheelData_:SetWheelList(self.curWheelPage, list)
  self:setEmojiEmpty(index)
end

function Expression_wheel_setting_windowView:setEmojiData(index, data)
  if index <= 0 or index > self.wheelData_.WheelCount or data == nil then
    return
  end
  if not self.hasDataTable then
    self.hasDataTable = {}
  end
  self.hasDataTable[index] = true
  local list = self.wheelData_:GetWheelList(self.curWheelPage)
  list[index] = data
  self.wheelData_:SetWheelList(self.curWheelPage, list)
  local uiBinder = self.uiBinder.node_expression[string.zconcat("node_setting", index)]
  uiBinder.Ref:SetVisible(uiBinder.img_line_img, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_img, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_lab, true)
  uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
  if data.type == E.ExpressionSettingType.QuickMessage then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, true)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.img_lab_select, false)
    uiBinder.Ref:SetVisible(uiBinder.btn_lab_delete, true)
    uiBinder.Ref:SetVisible(uiBinder.node_transproter, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.lab_info.text = slotData.Text
    end
  elseif data.type == E.ExpressionSettingType.Emoji then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.btn_emoji_delete, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
    if slotData then
      uiBinder.rimg_emoji:SetImageWithCallback(string.zconcat(Z.ConstValue.Emoji.EmojiPath, slotData.Res), function()
        if not uiBinder then
          return
        end
        uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, true)
      end)
    end
  elseif data.type == E.ExpressionSettingType.UseItem then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.btn_emoji_delete, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, true)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.img_item_quality:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. slotData.Quality)
      uiBinder.rimg_item_icon:SetImage(self.itemsVm_.GetItemIcon(data.id))
      local curHave = self.itemsVm_.GetItemTotalCount(data.id)
      uiBinder.lab_item_count.text = curHave
    end
  elseif data.type == E.ExpressionSettingType.Transporter then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, true)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.img_lab_select, false)
    uiBinder.Ref:SetVisible(uiBinder.btn_lab_delete, true)
    uiBinder.Ref:SetVisible(uiBinder.node_transproter, true)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.lab_info.text = slotData.Name
      local sceneTagTableRow = Z.TableMgr.GetRow("SceneTagTableMgr", slotData.SceneTag)
      if sceneTagTableRow then
        uiBinder.img_transproter:SetImage(sceneTagTableRow.Icon1)
      end
    end
  else
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.btn_emoji_delete, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.Ref:SetVisible(uiBinder.node_action_corner, true)
      uiBinder.img_emoji:SetImage(slotData.tableData.Icon)
      uiBinder.Ref:SetVisible(uiBinder.img_emoji, true)
      if slotData.tableData.Type == E.ExpressionType.Action then
        local cornerMark = slotData.tableData.CornerMark
        for i = 1, 3 do
          uiBinder.Ref:SetVisible(uiBinder["img_emoji_corner_" .. i], i == cornerMark)
        end
      else
        for i = 1, 3 do
          uiBinder.Ref:SetVisible(uiBinder["img_emoji_corner_" .. i], false)
        end
      end
    end
  end
end

function Expression_wheel_setting_windowView:setEmojiEmpty(index)
  if index <= 0 or index > self.wheelData_.WheelCount then
    return
  end
  if not self.hasDataTable then
    self.hasDataTable = {}
  end
  self.hasDataTable[index] = false
  local uiBinder = self.uiBinder.node_expression[string.zconcat("node_setting", index)]
  uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_img, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_lab, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
  uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.btn_emoji_delete, false)
  uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
  uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
  uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
end

function Expression_wheel_setting_windowView:GetTabTableData()
  local imagePathPre = self.uiBinder.prefabCache:GetString("expressionTogPath")
  local data = {}
  for _, v in ipairs(Z.Global.UiWheelTabsShow) do
    local tempTab = {}
    tempTab.icon = string.zconcat(imagePathPre, v[1])
    tempTab.type = tonumber(v[2])
    data[#data + 1] = tempTab
  end
  return data
end

function Expression_wheel_setting_windowView:OnSelectEmojiTab(data)
  self:SetItemClick(nil)
  self.type_ = data.type
  local itemList = {}
  local showList = {}
  if self.type_ == E.ExpressionSettingType.Emoji then
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    itemList = chatMainData:GetGroupSpriteByType(E.EChatStickersType.EHeadPicture)
    local chatMainVM = Z.VMMgr.GetVM("chat_main")
    local idList = {}
    for i = 1, #itemList do
      if chatMainVM.GetChatEmojiUnlockByTableRow(itemList[i]) then
        idList[#idList + 1] = {
          type = self.type_,
          id = itemList[i].Id
        }
      end
    end
    showList[#showList + 1] = {
      type = self.type_,
      title = Lang("ExpressionSettingEmojiTitle"),
      itemList = idList
    }
  elseif self.type_ == E.ExpressionSettingType.QuickMessage then
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    itemList = chatMainData:GetGroupSpriteByType(E.EChatStickersType.EQuickMessage)
    local idList = {}
    for i = 1, #itemList do
      idList[#idList + 1] = {
        type = self.type_,
        id = itemList[i].Id
      }
    end
    showList[#showList + 1] = {
      type = self.type_,
      title = Lang("ExpressionSettingQuickMessageTitle"),
      itemList = idList
    }
  elseif self.type_ == E.ExpressionSettingType.Transporter then
    local mapData = Z.DataMgr.Get("map_data")
    for k, v in pairs(Z.Global.ChatWheelTransferList) do
      local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(v)
      if sceneTable ~= nil then
        itemList = mapData:GetSceneUnlockedTransporter(v)
        local idList = {}
        for i = 1, #itemList do
          idList[#idList + 1] = {
            type = self.type_,
            id = itemList[i].Id
          }
        end
        if table.zcount(itemList) > 0 then
          showList[#showList + 1] = {
            type = self.type_,
            title = sceneTable.Name,
            itemList = idList
          }
        end
      end
    end
  elseif self.type_ == E.ExpressionSettingType.UseItem then
    local itemsVM = Z.VMMgr.GetVM("items")
    itemList = itemsVM.GetAllQuickUseItemWithCount()
    local idList = {}
    for i = 1, #itemList do
      idList[#idList + 1] = {
        type = self.type_,
        id = itemList[i].Id
      }
    end
    showList[#showList + 1] = {
      type = self.type_,
      title = Lang("ExpressionSettingUseItemTitle"),
      itemList = idList
    }
  elseif self.type_ == E.ExpressionSettingType.AllAction then
    self:GetActionList(E.DisplayExpressionType.CommonAction, showList, Lang("ExpressionSettingActionTitle" .. E.DisplayExpressionType.CommonAction))
    self:GetActionList(E.DisplayExpressionType.LoopAction, showList, Lang("ExpressionSettingActionTitle" .. E.DisplayExpressionType.LoopAction))
    self:GetActionList(E.DisplayExpressionType.MultAction, showList, Lang("ExpressionSettingActionTitle" .. E.DisplayExpressionType.MultAction))
    self:GetActionList(E.DisplayExpressionType.FishingAction, showList, Lang("ExpressionSettingActionTitle" .. E.DisplayExpressionType.FishingAction))
  end
  self.uiBinder.lab_title.text = Lang("ExpressionSettingTitle" .. self.type_)
  local prefabPath = self.uiBinder.prefabCache:GetString("expression_setting_item_tpl")
  if self.unitNames then
    for k, v in pairs(self.unitNames) do
      v:UnInit()
      self:RemoveUiUnit(k)
    end
    self.unitNames = nil
  end
  Z.CoroUtil.create_coro_xpcall(function()
    if self.unitNames == nil then
      self.unitNames = {}
    end
    for k, v in pairs(showList) do
      local unitName = "expression_setting_item_tpl_" .. self.type_ .. "_" .. k
      local uiBinder = self:AsyncLoadUiUnit(prefabPath, unitName, self.uiBinder.node_setting_root, self.cancelSource:CreateToken())
      local expressWheelSettingListItem = ExpressWheelSettingListItem.new(self)
      expressWheelSettingListItem:Init(uiBinder)
      expressWheelSettingListItem:RefreshSelf(v)
      self.unitNames[unitName] = expressWheelSettingListItem
    end
  end)()
end

function Expression_wheel_setting_windowView:GetActionList(displayType, showList, title)
  local itemList = self.expressionVm_.GetExpressionShowDataByType(displayType, false)
  local idList = {}
  for j = 1, #itemList do
    idList[#idList + 1] = {
      type = self.type_,
      id = itemList[j].tableData.Id
    }
  end
  if table.zcount(itemList) > 0 then
    showList[#showList + 1] = {
      type = self.type_,
      title = title,
      itemList = idList,
      displayType = displayType
    }
  end
end

function Expression_wheel_setting_windowView:SetItemClick(data)
  if not self.unitNames then
    return
  end
  for k, v in pairs(self.unitNames) do
    v:ResetAllSelect()
    if data ~= nil then
      local itemName = tostring(data.type) .. "_" .. tostring(data.id)
      if table.zcontainsKey(v.unitNames, itemName) then
        v.unitNames[itemName].Ref:SetVisible(v.unitNames[itemName].img_on, true)
      end
    end
  end
  self.curSettingData = data
  self:setSettingState(data ~= nil)
end

function Expression_wheel_setting_windowView:SetDragState()
  local minDisSlotId = self:GetCurDragingSlotId()
  for i = 1, self.wheelData_.WheelCount do
    local uiBinder = self.uiBinder.node_expression[string.zconcat("node_setting", i)]
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, minDisSlotId == i)
    uiBinder.Ref:SetVisible(uiBinder.img_lab_select, minDisSlotId == i)
  end
end

function Expression_wheel_setting_windowView:SetIsDraging(data)
  for k, v in pairs(self.unitNames) do
    v:ResetAllSelect()
    if data ~= nil then
      local itemName = tostring(data.type) .. "_" .. tostring(data.id)
      if table.zcontainsKey(v.unitNames, itemName) then
        v.unitNames[itemName].Ref:SetVisible(v.unitNames[itemName].img_on, true)
      end
    end
  end
  self.curSettingData = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.mask, data ~= nil)
  self.uiBinder.Ref:SetVisible(self.uiBinder.copy_item_trans.Trans, data ~= nil)
  self.uiBinder.copy_item_trans.Ref:SetVisible(self.uiBinder.copy_item_trans.expression_shortcut_item.Trans, false)
  self.uiBinder.copy_item_trans.Ref:SetVisible(self.uiBinder.copy_item_trans.expression_emoji_item.Trans, false)
  self.uiBinder.copy_item_trans.Ref:SetVisible(self.uiBinder.copy_item_trans.expression_shortcut_item_use.Trans, false)
  self.uiBinder.copy_item_trans.Ref:SetVisible(self.uiBinder.copy_item_trans.expression_shortcut_location.Trans, false)
  if data ~= nil then
    if data.type == E.ExpressionSettingType.QuickMessage then
      local uiBinder = self.uiBinder.copy_item_trans.expression_shortcut_item
      self.uiBinder.copy_item_trans.Ref:SetVisible(uiBinder.Trans, true)
      local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
      if slotData then
        uiBinder.lab_content.text = slotData.Text
      end
    elseif data.type == E.ExpressionSettingType.Emoji then
      local uiBinder = self.uiBinder.copy_item_trans.expression_emoji_item
      self.uiBinder.copy_item_trans.Ref:SetVisible(uiBinder.Trans, true)
      local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
      uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
      uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
      if slotData then
        uiBinder.rimg_emoji:SetImageWithCallback(string.zconcat(Z.ConstValue.Emoji.EmojiPath, slotData.Res), function()
          if not uiBinder then
            return
          end
          uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, true)
        end)
      end
    elseif data.type == E.ExpressionSettingType.UseItem then
      local uiBinder = self.uiBinder.copy_item_trans.expression_shortcut_item_use
      self.uiBinder.copy_item_trans.Ref:SetVisible(uiBinder.Trans, true)
      local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
      if slotData then
        uiBinder.img_item_quality:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. slotData.Quality)
        uiBinder.rimg_item_icon:SetImage(self.itemsVm_.GetItemIcon(data.id))
        local curHave = self.itemsVm_.GetItemTotalCount(data.id)
        uiBinder.lab_item_count.text = curHave
      end
    elseif data.type == E.ExpressionSettingType.Transporter then
      local uiBinder = self.uiBinder.copy_item_trans.expression_shortcut_location
      self.uiBinder.copy_item_trans.Ref:SetVisible(uiBinder.Trans, true)
      local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
      if slotData then
        uiBinder.lab_info.text = slotData.Name
        local sceneTagTableRow = Z.TableMgr.GetRow("SceneTagTableMgr", slotData.SceneTag)
        if sceneTagTableRow then
          uiBinder.img_transproter:SetImage(sceneTagTableRow.Icon1)
        end
      end
    else
      local uiBinder = self.uiBinder.copy_item_trans.expression_emoji_item
      self.uiBinder.copy_item_trans.Ref:SetVisible(uiBinder.Trans, true)
      local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
      uiBinder.img_emoji:SetImage(slotData.tableData.Icon)
      uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
      uiBinder.Ref:SetVisible(uiBinder.img_emoji, true)
      if slotData.tableData.Type == E.ExpressionType.Action then
        local cornerMark = slotData.tableData.CornerMark
        for i = 1, 3 do
          uiBinder.Ref:SetVisible(uiBinder["img_emoji_corner_" .. i], i == cornerMark)
        end
      else
        for i = 1, 3 do
          uiBinder.Ref:SetVisible(uiBinder["img_emoji_corner_" .. i], false)
        end
      end
    end
  end
end

function Expression_wheel_setting_windowView:EndDraging(data)
  local minDisSlotId = self:GetCurDragingSlotId()
  self:setEmojiData(minDisSlotId, data)
  self.expressionVm_.SetExpressionTargetFinish()
end

function Expression_wheel_setting_windowView:GetCurDragingSlotId()
  local minDis = 110
  local minDisSlotId = -1
  for i = 1, self.wheelData_.WheelCount do
    local uiBinderTrans = self.uiBinder.node_expression[string.zconcat("drag_point", i)]
    if uiBinderTrans then
      local distance = Panda.LuaAsyncBridge.GetScreenDistance(uiBinderTrans.position, self.uiBinder.copy_item_trans.Trans.position)
      if minDis > distance then
        minDis = distance
        minDisSlotId = i
      end
    end
  end
  return minDisSlotId
end

function Expression_wheel_setting_windowView:setSettingState(isSetting)
  for i = 1, self.wheelData_.WheelCount do
    local uiBinder = self.uiBinder.node_expression[string.zconcat("node_setting", i)]
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, isSetting)
    uiBinder.Ref:SetVisible(uiBinder.img_lab_select, isSetting)
    uiBinder.Ref:SetVisible(uiBinder.btn_emoji_delete, not isSetting and self.hasDataTable and self.hasDataTable[i])
    uiBinder.Ref:SetVisible(uiBinder.btn_lab_delete, not isSetting and self.hasDataTable and self.hasDataTable[i])
  end
end

return Expression_wheel_setting_windowView
