local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_handle_key_subView = class("Set_handle_key_subView", super)
local unitPath = "ui/prefabs/set/set_handle_key_tpl"

function Set_handle_key_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_handle_key_sub", "set/set_handle_key_sub", UI.ECacheLv.None)
  self.keyTbl_ = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  self.settingKeyVm_ = Z.VMMgr.GetVM("setting_key")
end

function Set_handle_key_subView:OnActive()
  self.uiBinder.set_basic_sub:SetSizeDelta(0, 0)
  self:initComp()
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.OnRefresh, self)
end

function Set_handle_key_subView:initComp()
  self.ps5Comps_ = {
    [1] = self.uiBinder.lab_touch,
    [2] = self.uiBinder.lab_key_left_1,
    [3] = self.uiBinder.node_ps5
  }
  self.xboxComps_ = {
    [1] = self.uiBinder.lab_key_left_xbox,
    [2] = self.uiBinder.node_xbox
  }
  self.unitParent_ = self.uiBinder.layoutRect
end

function Set_handle_key_subView:OnDeActive()
  Z.EventMgr:RemoveObjAll(self)
end

function Set_handle_key_subView:OnRefresh()
  self.gamepadType_ = Z.InputMgr.GamepadType
  self:refreshUI(self.gamepadType_)
end

function Set_handle_key_subView:refreshUI(gamepadType)
  if gamepadType == Panda.ZInput.EGamepadType.PS5 then
    self:refreshPS5View()
  else
    self:refreshXboxView()
  end
  self:refreshcomboItems()
end

function Set_handle_key_subView:refreshPS5View()
  self:enableComps(self.xboxComps_, false)
  self:enableComps(self.ps5Comps_, true)
  self.uiBinder.rimg_handle:SetImage("ui/textures/set/set_handle_ps")
end

function Set_handle_key_subView:refreshXboxView()
  self:enableComps(self.ps5Comps_, false)
  self:enableComps(self.xboxComps_, true)
  self.uiBinder.rimg_handle:SetImage("ui/textures/set/set_handle_xbox")
end

function Set_handle_key_subView:enableComps(comps, enable)
  for _, comp in pairs(comps) do
    self.uiBinder.Ref:SetVisible(comp, enable)
  end
end

function Set_handle_key_subView:refreshcomboItems()
  local settingKeyVm = Z.VMMgr.GetVM("setting_key")
  local keyIds = settingKeyVm:GetDisplayGamepadActionKeyIds()
  self:ClearAllUnits()
  Z.CoroUtil.create_coro_xpcall(function()
    for _, keyId in ipairs(keyIds) do
      self:loadItem(keyId)
    end
  end, function(err)
    Z.LogError("Set_handle_key_subView:refreshcomboItems error: ", err)
  end)()
end

function Set_handle_key_subView:loadItem(keyId)
  if keyId == nil then
    return
  end
  local row = self.keyTbl_.GetRow(keyId)
  if row == nil then
    return
  end
  local item = self:AsyncLoadUiUnit(unitPath, keyId, self.unitParent_)
  if item == nil then
    return
  end
  self:refreshItem(row, item)
end

function Set_handle_key_subView:refreshItem(row, itemUnit)
  local name = row.SetDes
  local keyDesc = self.settingKeyVm_.GetGamepadDesc(row, self.gamepadType_)
  itemUnit.labName:SetText(name)
  itemUnit.labKeyDesc:SetText(keyDesc)
  itemUnit.layout_element.minWidth = itemUnit.labKeyDesc.preferredWidth
end

return Set_handle_key_subView
