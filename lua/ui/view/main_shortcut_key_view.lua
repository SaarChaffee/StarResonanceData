local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_shortcut_keyView = class("Main_shortcut_keyView", super)
local newKeyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function Main_shortcut_keyView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "main_shortcut_key", "main/main_shortcut_key", UI.ECacheLv.None)
end

function Main_shortcut_keyView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.keyUnitNameList_ = {}
  self.nameKeyUnitDict_ = {}
  self.setKeyboardTableMgr_ = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  self:initKeyHint()
  self:bindEvent()
end

function Main_shortcut_keyView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.IgnoreFlagChanged, self.keyHintUIFresh, self)
  Z.EventMgr:Add(Z.ConstValue.KeyHintOpenChange, self.initKeyHint, self)
end

function Main_shortcut_keyView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.IgnoreFlagChanged)
  Z.EventMgr:Remove(Z.ConstValue.KeyHintOpenChange)
  self:removeKeyUnit()
end

function Main_shortcut_keyView:OnRefresh()
end

function Main_shortcut_keyView:initKeyHint()
  self:removeKeyUnit()
  local mainuiVM = Z.VMMgr.GetVM("mainui")
  if not mainuiVM.IsShowKeyHint() then
    return
  end
  if not (self.viewData and self.viewData.isShowShortcut) or not self.viewData.keyList then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, keyId in ipairs(self.viewData.keyList) do
      if 0 < keyId then
        local row = self.setKeyboardTableMgr_.GetRow(keyId)
        if row then
          local name = "KeyHint" .. keyId
          table.insert(self.keyUnitNameList_, name)
          local unit = self:AsyncLoadUiUnit(GetLoadAssetPath("KeyHintAssetPath"), name, self.uiBinder.layout_key_operate)
          if unit then
            self.nameKeyUnitDict_[name] = unit
            unit.Ref.UIComp:SetVisible(true)
            unit.lab_key_desc.text = row.SetDes
            newKeyIconHelper.InitKeyIcon(unit, unit.com_icon_key, keyId)
          end
        end
      end
    end
    self:keyHintUIFresh()
  end)()
end

function Main_shortcut_keyView:keyHintUIFresh()
  if self.nameKeyUnitDict_[E.PCKeyHint.Jump] then
    self.nameKeyUnitDict_[E.PCKeyHint.Jump].Ref.UIComp:SetVisible(not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump))
  end
  if self.nameKeyUnitDict_[E.PCKeyHint.Dash] then
    self.nameKeyUnitDict_[E.PCKeyHint.Dash].Ref.UIComp:SetVisible(not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Rush))
  end
  if self.nameKeyUnitDict_[E.PCKeyHint.LockTarget] then
    local settingIsOn = Z.VMMgr.GetVM("setting").Get(E.SettingID.LockOpen)
    local lockInputMask = Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.LockTarget)
    self.nameKeyUnitDict_[E.PCKeyHint.LockTarget].Ref.UIComp:SetVisible(settingIsOn and not lockInputMask)
  end
end

function Main_shortcut_keyView:removeKeyUnit()
  for _, name in ipairs(self.keyUnitNameList_) do
    self:RemoveUiUnit(name)
  end
  self.keyUnitNameList_ = {}
  self.nameKeyUnitDict_ = {}
end

return Main_shortcut_keyView
