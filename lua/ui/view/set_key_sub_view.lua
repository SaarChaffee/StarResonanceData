local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_key_subView = class("Set_key_subView", super)
local rewiredElementIdentifiers = require("utility/rewired_element_identifiers")
local keyLoopItem = require("ui.component.setting.setting_key_loop_item")
local attrDetailsPrefabPath_ = "ui/prefabs/set/set_item_input_tpl"

function Set_key_subView:ctor(parent)
  self.parent_ = parent
  self.uiBinder = nil
  super.ctor(self, "set_key_sub", "set/set_key_sub", UI.ECacheLv.None)
  self.keyVM_ = Z.VMMgr.GetVM("setting_key")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.keyItems_ = {}
end

function Set_key_subView:OnActive()
  self.uiBinder.set_key_sub:SetSizeDelta(0, 0)
  self.keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  self:createKeyMapList()
  self.isAllowChange_ = false
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
  self:AddClick(self.uiBinder.btn_reset, function()
    self:onClickReset()
  end)
  self:refreshModifier(1, self.uiBinder.dpd_gamepad_1, self.uiBinder.img_icon_arrow_1, self.uiBinder.img_icon_down_1)
  self:refreshModifier(2, self.uiBinder.dpd_gamepad_2, self.uiBinder.img_icon_arrow_2, self.uiBinder.img_icon_down_2)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_arrow_1, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_down_1, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_arrow_2, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_down_2, false)
end

function Set_key_subView:onDeviceChange()
  self:refreshModifier(1, self.uiBinder.dpd_gamepad_1, self.uiBinder.img_icon_arrow_1, self.uiBinder.img_icon_down_1)
  self:refreshModifier(2, self.uiBinder.dpd_gamepad_2, self.uiBinder.img_icon_arrow_2, self.uiBinder.img_icon_down_2)
end

function Set_key_subView:createKeyMapList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setDataList()
  end)()
end

function Set_key_subView:refreshModifier(modifierIndex, dpd, img_arrow, img_arrow_down)
  local modifierList = Z.InputMgr:GetGamePadModifiers(modifierIndex - 1)
  local options = {}
  for i = 0, modifierList.Count - 1 do
    local modifierId = rewiredElementIdentifiers.GetGamePadModifierByElementId(modifierList[i])
    local keyId = rewiredElementIdentifiers.GetGamePadKeyIdByElementId(modifierId, Z.InputMgr.GamepadType)
    if keyId ~= nil then
      local desc = ""
      local contrastRow = Z.TableMgr.GetTable("SetKeyboardContrastTableMgr").GetRow(keyId)
      if contrastRow then
        if contrastRow.ShowType == 1 then
          desc = string.zconcat("<sprite name=\"", contrastRow.Keyboard, "\">")
        else
          desc = contrastRow.Keyboard
        end
      end
      table.insert(options, desc)
    end
  end
  dpd:ClearAll()
  dpd:AddListener(function(index)
    Z.InputMgr:ChangeGamePadModifier(modifierIndex - 1, modifierList[index])
    Z.EventMgr:Dispatch(Z.ConstValue.Device.DeviceTypeChange)
  end, true)
  dpd:AddOnClickListener(function(index)
    self.uiBinder.Ref:SetVisible(img_arrow, false)
    self.uiBinder.Ref:SetVisible(img_arrow_down, true)
  end)
  dpd:AddHideListener(function(index)
    self.uiBinder.Ref:SetVisible(img_arrow, true)
    self.uiBinder.Ref:SetVisible(img_arrow_down, false)
  end)
  dpd:AddOptions(options)
end

function Set_key_subView:setDataList()
  self:clearAllKeyUnits()
  local list = self.keyVM_.GetShowKeyCtxList()
  for i, settingKeyCtx in ipairs(list) do
    local name = string.format("key_%d", i)
    local unit = self:AsyncLoadUiUnit(attrDetailsPrefabPath_, name, self.uiBinder.cont_set_key.node_content)
    local item = keyLoopItem.new()
    table.insert(self.keyItems_, item)
    item:Init(self, settingKeyCtx, unit)
  end
end

function Set_key_subView:clearAllKeyUnits()
  self.ConflictActionIds = nil
  for _, item in ipairs(self.keyItems_) do
    item:UnInit()
  end
  self:ClearAllUnits()
  self.keyItems_ = {}
end

function Set_key_subView:OnDeActive()
  self:clearAllKeyUnits()
  Z.InputMgr:CloseInputMapperListening()
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceChange, self)
end

function Set_key_subView:onClickReset()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("SettingKeyConfirmReset"), function()
    self.keyVM_.ResetKeySetting()
    self:createKeyMapList()
    Z.EventMgr:Dispatch(Z.ConstValue.KeySettingReset)
    Z.TipsVM.ShowTipsLang(1000203)
  end)
end

function Set_key_subView:RefreshAllItem()
  self:createKeyMapList()
end

return Set_key_subView
