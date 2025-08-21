local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_option_windowView = class("Talk_option_windowView", super)
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local inputKeyDescComp = require("input.input_key_desc_comp")

function Talk_option_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talk_option_window")
  self.optionVM_ = Z.VMMgr.GetVM("talk_option")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Talk_option_windowView:OnActive()
  self.optionNum_ = 0
  self.selectOption_ = 1
  Z.CoroUtil.create_coro_xpcall(function()
    local itemPath = Z.IsPCUI and Z.ConstValue.NpcTalk.PCAddress or Z.ConstValue.NpcTalk.MobileAddress
    local path = GetLoadAssetPath(itemPath)
    for i, optionData in ipairs(self.viewData.optionData) do
      local unit = self:AsyncLoadUiUnit(path, string.zconcat("option", i), self.uiBinder.layout_options)
      if unit then
        self:initOption(unit, optionData, i)
      end
    end
    if next(self.viewData.optionData) then
      self.optionNum_ = #self.viewData.optionData
    end
    Z.EventMgr:Dispatch("HideTalkArrowUI")
  end)()
end

function Talk_option_windowView:OnDeActive()
  self.inputKeyDescComp_:UnInit()
  Z.EventMgr:Dispatch("HideTalkArrowUI")
  self.IsResponseInput = true
end

function Talk_option_windowView:initOption(unit, optionData, index)
  local holderParam = {}
  Z.Placeholder.SetMePlaceholder(holderParam)
  local content = Z.Placeholder.Placeholder(optionData.Content, holderParam)
  itemHelper.InitInteractionItem(unit, content, optionData.iconPath)
  itemHelper.AddCommonListener(unit)
  if Z.IsPCUI then
    self.inputKeyDescComp_:Init(1, unit.cont_key_icon)
    itemHelper.SetSelectState(unit, index == 1)
    itemHelper.IsShowContKyeIcon(unit, index == 1)
  end
  self:AddAsyncClick(unit.btn_interaction, function()
    Z.AudioMgr:Play("sys_general_interact")
    optionData.Func()
  end)
end

function Talk_option_windowView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.IsResponseInput = false
    Z.Delay(0.1, self.cancelSource:CreateToken())
    self.IsResponseInput = true
  end)()
end

function Talk_option_windowView:OnTriggerInputAction(inputActionEventData)
  if not Z.IsPCUI then
    return
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.NavigateInteraction and Z.PlayerInputController:IsGamepadComboValidForAction(inputActionEventData) then
    self:handleNavigateInteraction(inputActionEventData)
  end
  if inputActionEventData.actionId == Z.RewiredActionsConst.Interact then
    self:handleUISubmit(inputActionEventData)
  end
end

function Talk_option_windowView:handleNavigateInteraction(inputActionEventData)
  if self.optionNum_ < 2 then
    return
  end
  local axis = 0
  if inputActionEventData.eventType == Z.InputActionEventType.ButtonJustPressed and Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    axis = -1
  elseif inputActionEventData.eventType == Z.InputActionEventType.AxisActiveOrJustInactive then
    axis = inputActionEventData:GetAxis()
  end
  local absAxis = math.abs(axis)
  if absAxis < Z.Global.ChatMessageWindowSensitivityPC then
    return
  end
  if 0 < axis then
    self.selectOption_ = self.selectOption_ - 1
  elseif axis < 0 then
    self.selectOption_ = self.selectOption_ + 1
  end
  if self.selectOption_ < 1 then
    self.selectOption_ = self.optionNum_
  elseif self.selectOption_ > self.optionNum_ then
    self.selectOption_ = 1
  end
  for i = 1, self.optionNum_ do
    local name = "option" .. i
    local unit = self.units[name]
    if unit then
      itemHelper.SetSelectState(unit, i == self.selectOption_)
      itemHelper.IsShowContKyeIcon(unit, i == self.selectOption_)
    end
  end
end

function Talk_option_windowView:handleUISubmit(inputActionEventData)
  if self.optionNum_ <= 0 then
    return
  end
  local option = self.viewData.optionData[self.selectOption_]
  if option then
    Z.AudioMgr:Play("sys_general_interact")
    option.Func()
  end
end

return Talk_option_windowView
