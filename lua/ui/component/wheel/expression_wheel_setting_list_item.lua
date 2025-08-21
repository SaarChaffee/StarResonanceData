local ExpressWheelSettingListItem = class("ExpressWheelSettingListItem")
local type2PathTable_ = {
  [E.ExpressionSettingType.QuickMessage] = "expression_shortcut_item",
  [E.ExpressionSettingType.Transporter] = "expression_shortcut_location",
  [E.ExpressionSettingType.UseItem] = "expression_shortcut_item_use",
  [E.ExpressionSettingType.Emoji] = "expression_emoji_item",
  [E.ExpressionSettingType.AllAction] = "expression_emoji_item"
}
local type2CellSizeTable_ = {
  NotPC = {
    [E.ExpressionSettingType.QuickMessage] = {x = 410, y = 66},
    [E.ExpressionSettingType.Transporter] = {x = 410, y = 66},
    [E.ExpressionSettingType.UseItem] = {x = 136, y = 136},
    [E.ExpressionSettingType.Emoji] = {x = 136, y = 136},
    [E.ExpressionSettingType.AllAction] = {x = 136, y = 136}
  },
  PC = {
    [E.ExpressionSettingType.QuickMessage] = {x = 190, y = 50},
    [E.ExpressionSettingType.Transporter] = {x = 190, y = 66},
    [E.ExpressionSettingType.UseItem] = {x = 84, y = 84},
    [E.ExpressionSettingType.Emoji] = {x = 84, y = 84},
    [E.ExpressionSettingType.AllAction] = {x = 84, y = 84}
  }
}

function ExpressWheelSettingListItem:ctor(parent)
  self.view_ = parent
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
end

function ExpressWheelSettingListItem:Init(uiBinder)
  self.uiBinder = uiBinder
  self.wheelData_ = Z.DataMgr.Get("wheel_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function ExpressWheelSettingListItem:RefreshSelf(data)
  self.data_ = data
  self.uiBinder.lab_title.text = data.title
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, self.data_.displayType == E.DisplayExpressionType.FishingAction)
  self.uiBinder.btn_jump:AddListener(function()
    if Z.IsPCUI then
      local socialVM = Z.VMMgr.GetVM("socialcontact_main")
      socialVM.OpenChatView(true, nil, 5)
    else
      self.expressionVM_.CloseExpressionWheelSettingView()
      self.expressionVM_.OpenExpressionView({firstOpenIndex = 6})
    end
  end)
  self:refreshItems()
end

function ExpressWheelSettingListItem:UnInit()
  if self.unitNames then
    for k, v in pairs(self.unitNames) do
      self.view_:RemoveUiUnit(k)
    end
  end
end

function ExpressWheelSettingListItem:refreshItems()
  local prefabPath = self.uiBinder.pbc:GetString(type2PathTable_[self.data_.type])
  if Z.IsPCUI then
    self.uiBinder.layout_grid:SetItemCellSize(type2CellSizeTable_.PC[self.data_.type].x, type2CellSizeTable_.PC[self.data_.type].y)
  else
    self.uiBinder.layout_grid:SetItemCellSize(type2CellSizeTable_.NotPC[self.data_.type].x, type2CellSizeTable_.NotPC[self.data_.type].y)
  end
  if #self.data_.itemList > 0 then
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.unitNames = {}
    for k, v in ipairs(self.data_.itemList) do
      local data = v
      local name = tostring(data.type) .. "_" .. tostring(data.id)
      local uiBinder = self.view_:AsyncLoadUiUnit(prefabPath, name, self.uiBinder.layout_content, self.view_.cancelSource:CreateToken())
      self.unitNames[name] = uiBinder
      uiBinder.Ref:SetVisible(uiBinder.img_on, false)
      if data.type == E.ExpressionSettingType.QuickMessage then
        local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
        if slotData then
          uiBinder.lab_content.text = slotData.Text
        end
      elseif data.type == E.ExpressionSettingType.Emoji then
        local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
        uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
        uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
        uiBinder.rimg_emoji:SetImageWithCallback(string.zconcat(Z.ConstValue.Emoji.EmojiPath, slotData.Res), function()
          if not uiBinder then
            return
          end
          uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, true)
        end)
        uiBinder.Ref:SetVisible(uiBinder.img_special_emoji, slotData.ShowCornerMark and slotData.ShowCornerMark > 0)
        uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
      elseif data.type == E.ExpressionSettingType.UseItem then
        local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
        if slotData then
          uiBinder.img_item_quality:SetImage(Z.ConstValue.Item.SquareItemQualityPath .. slotData.Quality)
          uiBinder.rimg_item_icon:SetImage(self.itemsVm_.GetItemIcon(data.id))
          local curHave = self.itemsVm_.GetItemTotalCount(data.id)
          uiBinder.lab_item_count.text = curHave
        end
      elseif data.type == E.ExpressionSettingType.Transporter then
        local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
        if slotData then
          uiBinder.lab_info.text = slotData.Name
          local sceneTagTableRow = Z.TableMgr.GetRow("SceneTagTableMgr", slotData.SceneTag)
          if sceneTagTableRow then
            uiBinder.img_transproter:SetImage(sceneTagTableRow.Icon1)
          end
        end
      else
        local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
        
        function uiBinder.clickItemFunc(trans, name)
          self.expressionVM_.OpenTipsActionNamePopup(trans, name)
        end
        
        uiBinder.img_emoji:SetImage(slotData.tableData.Icon)
        uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
        uiBinder.Ref:SetVisible(uiBinder.img_emoji, true)
        uiBinder.Ref:SetVisible(uiBinder.img_special_emoji, false)
        uiBinder.Ref:SetVisible(uiBinder.node_action_corner, true)
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
      self:bindItemClick(uiBinder, data)
    end
  end)()
end

function ExpressWheelSettingListItem:bindItemClick(uiBinder, data)
  uiBinder.btn:RemoveAllListeners()
  uiBinder.btn:AddListener(function()
    self:onItemClick(uiBinder, data)
  end)
  if Z.IsPCUI then
    function uiBinder.btn.OnNodeStateIntChange(state)
      if uiBinder.clickItemFunc then
        if state == E.NodeState.Highlighted then
          local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
          
          uiBinder.clickItemFunc(uiBinder.Trans, slotData.tableData.Name)
        else
          self.expressionVM_.CloseTipsActionNamePopup()
        end
      end
    end
  end
  uiBinder.event_trigger.onBeginDrag:AddListener(function()
    self:OnItemBeginDrag(uiBinder, data)
  end)
  uiBinder.event_trigger.onDrag:AddListener(function(go, pointerData)
    self:OnItemDrag(uiBinder, data, pointerData)
  end)
  uiBinder.event_trigger.onEndDrag:AddListener(function()
    self:OnItemEndDrag(uiBinder, data)
  end)
end

function ExpressWheelSettingListItem:OnItemBeginDrag(uiBinder, data)
  self.view_:SetIsDraging(data)
end

function ExpressWheelSettingListItem:OnItemDrag(uiBinder, data, pointerData)
  local trans_ = self.view_.uiBinder.copy_item_trans.Trans
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(trans_, pointerData.position, nil)
  local posX, posY = trans_:GetAnchorPosition(nil, nil)
  posX = posX + uiPos.x
  posY = posY + uiPos.y
  trans_:SetAnchorPosition(posX, posY)
  self.view_:SetDragState()
end

function ExpressWheelSettingListItem:OnItemEndDrag(uiBinder, data)
  self.view_:EndDraging(data)
  self.view_:SetIsDraging(nil)
end

function ExpressWheelSettingListItem:onItemClick(uiBinder, data)
  if uiBinder.clickItemFunc then
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    uiBinder.clickItemFunc(uiBinder.Trans, slotData.tableData.Name)
  end
  self.view_:SetItemClick(data)
end

function ExpressWheelSettingListItem:ResetAllSelect()
  for k, v in pairs(self.unitNames) do
    v.Ref:SetVisible(v.img_on, false)
  end
end

return ExpressWheelSettingListItem
