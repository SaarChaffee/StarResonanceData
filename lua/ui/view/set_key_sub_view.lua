local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_key_subView = class("Set_key_subView", super)
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
  local isKeyHintOpen = self.settingVM_.Get(E.SettingID.KeyHint)
  self.uiBinder.cont_set_show.cont_hint_open.cont_switch.switch.IsOn = isKeyHintOpen
  self.isAllowChange_ = false
  self.uiBinder.cont_set_show.cont_hint_open.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.KeyHint, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.KeyHintOpenChange, isOn)
  end)
  self:AddClick(self.uiBinder.btn_reset, function()
    self:onClickReset()
  end)
end

function Set_key_subView:createKeyMapList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setDataList()
  end)()
end

function Set_key_subView:setDataList()
  self:clearAllKeyUnits()
  for i, keyboardTableRow in ipairs(self.keyVM_.GetShowKeyList()) do
    if keyboardTableRow == nil then
      logError("[Setting] keyboardTableRow is nil")
    end
    local name = string.format("key_%d", i)
    local unit = self:AsyncLoadUiUnit(attrDetailsPrefabPath_, name, self.uiBinder.cont_set_key.node_content)
    local item = keyLoopItem.new()
    table.insert(self.keyItems_, item)
    item:Init(self, keyboardTableRow, unit)
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
end

function Set_key_subView:onClickReset()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("SettingKeyConfirmReset"), function()
    self.keyVM_.ResetKeySetting()
    self:createKeyMapList()
    Z.EventMgr:Dispatch(Z.ConstValue.KeySettingReset)
    Z.DialogViewDataMgr:CloseDialogView()
    Z.TipsVM.ShowTipsLang(1000203)
  end)
end

function Set_key_subView:RefreshAllItem()
  if self.ConflictActionIds ~= nil and self.ConflictActionIds.Count > 0 then
    for i = 0, self.ConflictActionIds.Count - 1 do
      local actionId = self.ConflictActionIds[i]
      self.keyVM_.ReBindActionByActionId(actionId)
    end
  end
  self:createKeyMapList()
end

function Set_key_subView:OnRefresh()
end

return Set_key_subView
