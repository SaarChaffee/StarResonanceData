local UI = Z.UI
local super = require("ui.ui_view_base")
local Expression_fast_window_pcView = class("Expression_fast_window_pcView", super)
local wheelCount = 8

function Expression_fast_window_pcView:ctor()
  self.uiBinder = nil
  super.ctor(self, "expression_fast_window_pc")
  self.wheelData_ = Z.DataMgr.Get("wheel_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Expression_fast_window_pcView:OnActive()
  Z.AudioMgr:Play("UI_Menu_Wheel_Open")
  Z.ZInputMapModeMgr:ChangeInputMode(Panda.ZInput.EInputMode.Expression)
  self.curSelectIndex_ = 0
  self.curWheelPage = self.wheelData_:GetWheelPage()
  self:initWheelList()
  self:initWheelRoulette()
  self:bindBtnClick()
  self:addExpressionAction()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(138)[1]
  self.uiBinder.lab_setting_key.text = Lang("ExpressionWheelSettingKey", {val = keyCodeDesc})
  keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(139)[1]
  self.uiBinder.lab_switch_key.text = Lang("ExpressionWheelSwitchKey", {val = keyCodeDesc})
end

function Expression_fast_window_pcView:addExpressionAction()
  function self.onOpenExpressionAction_(inputActionEventData)
    local expressionVM = Z.VMMgr.GetVM("expression")
    
    expressionVM.OpenExpressionWheelSettingView()
  end
  
  function self.onUIVertical_(inputActionEventData)
    local axis = inputActionEventData:GetAxis()
    if 0 < axis then
      self.curWheelPage = self.curWheelPage - 1 < 1 and 3 or self.curWheelPage - 1
      self.wheelData_:SetWheelPage(self.curWheelPage)
      self:initWheelList()
    elseif axis < 0 then
      self.curWheelPage = self.curWheelPage + 1 > 3 and 1 or self.curWheelPage + 1
      self.wheelData_:SetWheelPage(self.curWheelPage)
      self:initWheelList()
    end
  end
  
  function self.onCloseExpressionAction_(inputActionEventData)
    local expressionVM = Z.VMMgr.GetVM("expression")
    expressionVM.CloseExpressionFastWindow()
  end
  
  Z.FuncInputActionComp:SetActionCallback(Z.RewiredActionsConst.ExpressionFast, function()
  end)
end

function Expression_fast_window_pcView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.actionId == Z.RewiredActionsConst.ExpressionSetting then
    self.onOpenExpressionAction_()
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.ExpressionPageSwitch then
    self.onUIVertical_(inputActionEventData)
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.ExpressionFast then
    self.onCloseExpressionAction_()
  end
end

function Expression_fast_window_pcView:removeExpressionAction()
  Z.FuncInputActionComp:SetActionCallback(Z.RewiredActionsConst.ExpressionFast, nil)
end

function Expression_fast_window_pcView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.expressionVm_.CloseExpressionFastWindow()
  end)
  self:AddAsyncClick(self.uiBinder.btn_use, function()
    self:asyncCheckSelect()
    self.wheelData_:SetWheelSlotClicked(true)
    self.expressionVm_.CloseExpressionFastWindow()
  end)
end

function Expression_fast_window_pcView:OnDeActive()
  self:removeExpressionAction()
  self.uiBinder.roulette:SwitchCheck(false)
  if not self.wheelData_:GetWheelSlotClicked() then
    Z.CoroUtil.create_coro_xpcall(function()
      self:asyncCheckSelect()
    end)()
  end
  self.wheelData_:SetWheelSlotClicked(false)
  self.curSelectIndex_ = 0
  Z.ZInputMapModeMgr:ChangeInputMode(Z.ZInputMapModeMgr.GamePlayDefaultMode)
end

function Expression_fast_window_pcView:initWheelList()
  self.uiBinder.lab_info.text = self.curWheelPage
  local list = self.wheelData_:GetWheelList(self.curWheelPage)
  for i = 1, wheelCount do
    if not list[i] or list[i].type == 0 then
      self:setEmojiEmpty(i)
    else
      self:setEmojiData(i, list[i])
    end
  end
end

function Expression_fast_window_pcView:initWheelRoulette()
  if self.viewData then
    return
  end
  self.uiBinder.roulette:SwitchCheck(true)
  self.uiBinder.roulette:AddSelectAreaChangedListener(function(index)
    if not self.uiBinder then
      return
    end
    index = index + 1
    if self.curSelectIndex_ then
      self:setEmojiSelectState(self.curSelectIndex_, false)
    end
    self.curSelectIndex_ = index
    self:setEmojiSelectState(index, true)
  end)
end

function Expression_fast_window_pcView:asyncCheckSelect()
  self.expressionVm_.QuickUseExpression(self.curSelectIndex_)
end

function Expression_fast_window_pcView:setEmojiEmpty(index)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
  uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
  uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
  uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
end

function Expression_fast_window_pcView:setEmojiData(index, data)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
  uiBinder.Ref:SetVisible(uiBinder.img_line_img, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_lab, false)
  if data.type == E.ExpressionSettingType.QuickMessage then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, true)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.img_lab_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_transproter, false)
    uiBinder.Ref:SetVisible(uiBinder.img_line_lab, true)
    uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.lab_info.text = slotData.Text
    end
  elseif data.type == E.ExpressionSettingType.Emoji then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
    uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
    uiBinder.rimg_emoji:SetImageWithCallback(string.zconcat(Z.ConstValue.Emoji.EmojiPath, slotData.Res), function()
      if not uiBinder then
        return
      end
      uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, true)
    end)
  elseif data.type == E.ExpressionSettingType.UseItem then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, true)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
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
    uiBinder.Ref:SetVisible(uiBinder.node_transproter, true)
    uiBinder.Ref:SetVisible(uiBinder.img_line_lab, true)
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
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
    uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
    uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    
    function uiBinder.clickItemFunc(trans)
      self.expressionVm_.OpenTipsActionNamePopup(trans, slotData.tableData.Name)
    end
    
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

function Expression_fast_window_pcView:setEmojiSelectState(index, isSelect)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
  if not uiBinder then
    return
  end
  if uiBinder.clickItemFunc then
    if isSelect then
      uiBinder.clickItemFunc(uiBinder.Trans)
    else
      self.expressionVm_.CloseTipsActionNamePopup()
    end
  end
  uiBinder.Ref:SetVisible(uiBinder.img_frame_select, isSelect)
  uiBinder.Ref:SetVisible(uiBinder.img_lab_select, isSelect)
end

function Expression_fast_window_pcView:OnRefresh()
end

return Expression_fast_window_pcView
