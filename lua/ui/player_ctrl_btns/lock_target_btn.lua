local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local LockTargetBtn = class("LockTargetBtn", super)

function LockTargetBtn:ctor(key, panel, playerCtrlBtnTemplates)
  self.uiBinder = nil
  super.ctor(self, key, panel, playerCtrlBtnTemplates)
end

function LockTargetBtn:GetUIUnitPath()
  return GetLoadAssetPath(Z.ConstValue.LockTargetRoot)
end

function LockTargetBtn:OnActive()
  self.uiBinder.img_target_icon:SetColor(Color.white)
  self.uiBinder.trans_target:SetScale(1, 1, 1)
  self.uiBinder.Ref.UIComp:SetVisible(true)
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self:AddAsyncClick(self.uiBinder.btn_target, function()
    if self.settingVM_.Get(E.SettingID.LockOpen) then
      Z.LuaBridge.LockTargetOrCancel()
    end
  end)
  self.uiBinder.btn_target.OnLongHoldOnceEvent:AddListener(function()
    if self.settingVM_.Get(E.SettingID.LockOpen) then
      Z.LuaBridge.CancelLockTarget()
    end
  end)
  self:CheckVisible()
  self:OnLockChange()
  Z.EventMgr:Add(Z.ConstValue.LockTargetOpenSettingChange, self.CheckVisible, self)
  Z.EventMgr:Add(Z.ConstValue.LockTargetOperationModeChange, self.CheckVisible, self)
  Z.EventMgr:Add("SkillSlotDataChanged", self.onSkillSlotDataChanged, self)
end

function LockTargetBtn:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.LocalAttr.EIsLock
  }, Z.EntityMgr.PlayerEnt, self.OnLockChange, true)
end

function LockTargetBtn:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.LockTargetOpenSettingChange, self.CheckVisible, self)
  Z.EventMgr:Remove(Z.ConstValue.LockTargetOperationModeChange, self.CheckVisible, self)
end

function LockTargetBtn:OnLockChange()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local isLock = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EIsLock).Value
  if not isLock then
    self.uiBinder.img_target_icon:SetImage("ui/atlas/mainui/skill_btn_locking_02")
  else
    self.uiBinder.img_target_icon:SetImage("ui/atlas/mainui/skill_btn_locking")
  end
end

function LockTargetBtn:OnBuffChange()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local visible = true
  local buffItemList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  if buffItemList then
    buffItemList = buffItemList.Value
    for i = 0, buffItemList.count - 1 do
      local data = buffItemList[i]
      if data and data.BuffBaseId == 681701 then
        visible = false
        break
      end
    end
  end
  self.uiBinder.Ref.UIComp:SetVisible(visible)
end

function LockTargetBtn:CheckVisible()
  local isOpen = self.settingVM_.Get(E.SettingID.LockOpen)
  if not isOpen then
    self.uiBinder.trans_target:SetScale(1.0E-4, 1.0E-4)
    local player = Z.EntityMgr.PlayerEnt
    if player:GetLuaAttr(Z.LocalAttr.EIsLock).Value and player:GetLuaAttr(Z.PbAttrEnum("AttrTargetId")).Value > 0 then
      Z.LuaBridge.LockTargetOrCancel()
    end
  elseif isOpen then
    self.uiBinder.trans_target:SetScale(1, 1, 1)
  end
end

function LockTargetBtn:onSkillSlotDataChanged()
  local isAllSkillHide = false
  for _, value in pairs(E.SkillSlot) do
    local cache = self.playerCtrlBtnTemplates_.slotUIUnitCache_[value]
    if cache and cache.uiBinder and cache.uiBinder.Ref.UIComp.IsVisible then
      isAllSkillHide = true
      break
    end
  end
  self.uiBinder.Ref.UIComp:SetVisible(isAllSkillHide)
end

return LockTargetBtn
