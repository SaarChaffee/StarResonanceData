local UI = Z.UI
local super = require("ui.ui_view_base")
local Expression_fast_windowView = class("Expression_fast_windowView", super)
local wheelCount = 8

function Expression_fast_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "expression_fast_window")
  self.wheelData_ = Z.DataMgr.Get("wheel_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Expression_fast_windowView:OnActive()
  Z.AudioMgr:Play("UI_Menu_Wheel_Open")
  self.curSelectIndex_ = 0
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.UIInteract, true, Panda.ZGame.EIgnoreMaskSource.EUIView)
  self.curWheelPage = self.wheelData_:GetWheelPage()
  self:initWheelList()
  self:initWheelRoulette()
  self:bindBtnClick()
end

function Expression_fast_windowView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_switch, function()
    self:OnBtnSwitchClick()
  end)
  self:AddClick(self.uiBinder.btn_set, function()
    self:onBtnSetClick()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.expressionVm_.CloseExpressionFastWindow()
  end)
  self:AddAsyncClick(self.uiBinder.btn_use, function()
    self:asyncCheckSelect()
  end)
end

function Expression_fast_windowView:OnBtnSwitchClick()
  self.curWheelPage = self.curWheelPage + 1 > 3 and 1 or self.curWheelPage + 1
  self.wheelData_:SetWheelPage(self.curWheelPage)
  self:initWheelList()
end

function Expression_fast_windowView:onBtnSetClick()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ChatExpressionFast)
  if not isOn then
    return
  end
  self.expressionVm_.OpenExpressionWheelSettingView()
  self.expressionVm_.CloseExpressionFastWindow()
end

function Expression_fast_windowView:OnDeActive()
  Z.IgnoreMgr:SetInputIgnore(Panda.ZGame.EInputMask.UIInteract, false, Panda.ZGame.EIgnoreMaskSource.EUIView)
  self.uiBinder.roulette:SwitchCheck(false)
end

function Expression_fast_windowView:initWheelList()
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

function Expression_fast_windowView:initWheelRoulette()
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

function Expression_fast_windowView:asyncCheckSelect()
  self.expressionVm_.QuickUseExpression(self.curSelectIndex_)
  self.expressionVm_.CloseExpressionFastWindow()
end

function Expression_fast_windowView:setEmojiEmpty(index)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
  uiBinder.Ref:SetVisible(uiBinder.img_line_img, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_img, false)
  uiBinder.Ref:SetVisible(uiBinder.img_line_lab, true)
  uiBinder.Ref:SetVisible(uiBinder.img_line_on_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
  uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
  uiBinder.Ref:SetVisible(uiBinder.img_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.rimg_emoji, false)
  uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
  uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
  uiBinder.Ref:SetVisible(uiBinder.node_action_corner, false)
end

function Expression_fast_windowView:setEmojiData(index, data)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
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
    uiBinder.Ref:SetVisible(uiBinder.node_transproter, false)
    local slotData = self.wheelData_:GetDataByTypeAndId(data.type, data.id)
    if slotData then
      uiBinder.lab_info.text = slotData.Text
    end
  elseif data.type == E.ExpressionSettingType.Emoji then
    uiBinder.Ref:SetVisible(uiBinder.node_lab, false)
    uiBinder.Ref:SetVisible(uiBinder.node_emoji, true)
    uiBinder.Ref:SetVisible(uiBinder.img_frame_select, false)
    uiBinder.Ref:SetVisible(uiBinder.node_item_square, false)
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

function Expression_fast_windowView:setEmojiSelectState(index, isSelect)
  if index <= 0 or index > wheelCount then
    return
  end
  local uiBinder = self.uiBinder[string.zconcat("node_setting", index)]
  if not uiBinder then
    return
  end
  uiBinder.Ref:SetVisible(uiBinder.img_frame_select, isSelect)
  uiBinder.Ref:SetVisible(uiBinder.img_lab_select, isSelect)
end

return Expression_fast_windowView
