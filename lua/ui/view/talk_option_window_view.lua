local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_option_windowView = class("Talk_option_windowView", super)
local itemHelper = require("ui.component.interaction.interaction_item_helper")
local KeyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function Talk_option_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talk_option_window")
  self.optionVM_ = Z.VMMgr.GetVM("talk_option")
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
  self:registerInputAction()
end

function Talk_option_windowView:OnDeActive()
  Z.EventMgr:Dispatch("HideTalkArrowUI")
  if Z.IsPCUI then
    Z.InputMgr:RemoveInputEventDelegate(self.onUIVertical_, Z.InputActionEventType.AxisActiveOrJustInactive, Z.RewiredActionsConst.Zoom)
    Z.InputMgr:RemoveInputEventDelegate(self.onUISubmit_, Z.InputActionEventType.ButtonPressedForTimeJustReleased, Z.RewiredActionsConst.Interact)
  end
end

function Talk_option_windowView:registerInputAction()
  if not Z.IsPCUI then
    return
  end
  
  function self.onUIVertical_(inputActionEventData)
    if self.optionNum_ < 2 then
      return
    end
    local axis = inputActionEventData:GetAxis()
    if 0 < axis then
      self.selectOption_ = self.selectOption_ - 1
    elseif axis < 0 then
      self.selectOption_ = self.selectOption_ + 1
    end
    self.selectOption_ = Mathf.Clamp(self.selectOption_, 1, self.optionNum_)
    for i = 1, self.optionNum_ do
      local name = "option" .. i
      local unit = self.units[name]
      if unit then
        itemHelper.SetSelectState(unit, i == self.selectOption_)
        itemHelper.IsShowContKyeIcon(unit, i == self.selectOption_)
      end
    end
  end
  
  function self.onUISubmit_(inputActionEventData)
    if self.optionNum_ <= 0 then
      return
    end
    local option = self.viewData.optionData[self.selectOption_]
    if option then
      option.Func()
    end
  end
  
  Z.InputMgr:AddInputEventDelegate(self.onUIVertical_, Z.InputActionEventType.AxisActiveOrJustInactive, Z.RewiredActionsConst.Zoom)
  Z.InputMgr:AddInputEventDelegate(self.onUISubmit_, Z.InputActionEventType.ButtonPressedForTimeJustReleased, Z.RewiredActionsConst.Interact, 0, 0.2)
end

function Talk_option_windowView:initOption(unit, optionData, index)
  local holderParam = {}
  Z.Placeholder.SetMePlaceholder(holderParam)
  local content = Z.Placeholder.Placeholder(optionData.Content, holderParam)
  itemHelper.InitInteractionItem(unit, content, optionData.iconPath)
  itemHelper.AddCommonListener(unit)
  if Z.IsPCUI then
    KeyIconHelper.InitKeyIcon(self, unit.cont_key_icon, 1)
    itemHelper.SetSelectState(unit, index == 1)
    itemHelper.IsShowContKyeIcon(unit, index == 1)
  end
  self:AddAsyncClick(unit.btn_interaction, function()
    Z.AudioMgr:Play("sys_general_interact")
    optionData.Func()
  end)
end

function Talk_option_windowView:OnRefresh()
end

return Talk_option_windowView
