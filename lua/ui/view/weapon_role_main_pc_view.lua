local UI = Z.UI
local super = require("ui.ui_view_base")
local Weapon_role_main_pcView = class("Weapon_role_main_pcView", super)
local RightSubType = {
  PlayerInfo = 1,
  Skill = 2,
  Equip = 3,
  Mod = 4
}
local RightSubLua = {
  [RightSubType.PlayerInfo] = "ui/view/weapon_role_main_player_sub_pc_view",
  [RightSubType.Skill] = "ui/view/weapon_role_main_skill_sub_view",
  [RightSubType.Equip] = "ui/view/weapon_role_main_equip_sub_pc_view",
  [RightSubType.Mod] = "ui/view/weapon_role_main_mod_sub_view"
}
local HelpSysIds = {
  [RightSubType.PlayerInfo] = 30062,
  [RightSubType.Equip] = 30013,
  [RightSubType.Skill] = 400101,
  [RightSubType.Mod] = 400003
}

function Weapon_role_main_pcView:ctor()
  self.uiBinder = nil
  super.ctor(self, "weapon_role_main_pc")
end

function Weapon_role_main_pcView:OnActive()
  Z.AudioMgr:Play("UI_Event_CharacterAttributes_Open")
  self:onStartAnimShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.helpsysVm_ = Z.VMMgr.GetVM("helpsys")
  self.weaponVm_.SwitchEntityShow(false)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.weaponVm_.CloseWeaponRoleView()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVm_.OpenFullScreenTipsView(HelpSysIds[self.curSubType_])
  end)
  self.btnGroups_ = {
    [RightSubType.PlayerInfo] = {
      btnOn = self.uiBinder.btn_information_on,
      btnOff = self.uiBinder.btn_information_off,
      off_uibinder = self.uiBinder.information_off_uibinder,
      functionId = E.FunctionID.RoleInfo,
      iconPath = "ui/atlas/item/c_tab_icon/com_icon_tab_02"
    },
    [RightSubType.Skill] = {
      btnOn = self.uiBinder.btn_skill_on,
      btnOff = self.uiBinder.btn_skill_off,
      off_uibinder = self.uiBinder.skill_off_uibinder,
      functionId = E.FunctionID.WeaponSkill,
      iconPath = "ui/atlas/item/c_tab_icon/com_icon_tab_119"
    },
    [RightSubType.Equip] = {
      btnOn = self.uiBinder.btn_equip_on,
      btnOff = self.uiBinder.btn_equip_off,
      off_uibinder = self.uiBinder.equip_off_uibinder,
      functionId = E.FunctionID.EquipChange,
      iconPath = "ui/atlas/item/c_tab_icon/com_icon_tab_01"
    },
    [RightSubType.Mod] = {
      btnOn = self.uiBinder.btn_mod_on,
      btnOff = self.uiBinder.btn_mod_off,
      off_uibinder = self.uiBinder.mod_off_uibinder,
      functionId = E.FunctionID.Mod,
      iconPath = "ui/atlas/item/c_tab_icon/com_icon_tab_62"
    }
  }
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  for index, value in ipairs(self.btnGroups_) do
    self.uiBinder.Ref:SetVisible(value.btnOn, false)
    self.uiBinder.Ref:SetVisible(value.btnOff, true)
    local isUnlock = self.funcVm_.FuncIsOn(value.functionId, true)
    value.btnOff.IsDisabled = not isUnlock
    value.off_uibinder.Ref:SetVisible(value.off_uibinder.img_lock, not isUnlock)
    if value.functionId ~= E.FunctionID.RoleInfo then
      Z.RedPointMgr.LoadRedDotItem(value.functionId, self, value.btnOn.transform)
      Z.RedPointMgr.LoadRedDotItem(value.functionId, self, value.btnOff.transform)
    end
    self:AddAsyncClick(value.btnOff, function()
      self:openRightSubView(index)
      Z.AudioMgr:Play("UI_Event_CharacterAttributes_Switch")
    end)
  end
  self.subViews_ = {}
  if self.viewData and self.viewData.selectType then
    self.curSubType_ = self.viewData.selectType
  else
    self.curSubType_ = RightSubType.PlayerInfo
  end
  self:openRightSubView(self.curSubType_)
  self:bindEvent()
end

function Weapon_role_main_pcView:onRidingChange()
  self.weaponVm_.CloseWeaponRoleView()
end

function Weapon_role_main_pcView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.onRidingChange, self)
end

function Weapon_role_main_pcView:GetCacheData()
  local viewData = {}
  viewData.selectType = self.curSubType_
  return viewData
end

function Weapon_role_main_pcView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.weaponVm_.SwitchEntityShow(true)
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self:unLoadRedDotItem()
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.UpdateRiding, self.onRidingChange, self)
end

function Weapon_role_main_pcView:OnRefresh()
  self:loadRedDotItem()
end

function Weapon_role_main_pcView:openRightSubView(type)
  local isUnlock = self.funcVm_.FuncIsOn(self.btnGroups_[type].functionId)
  if not isUnlock then
    return
  end
  self.uiBinder.Ref:SetVisible(self.btnGroups_[self.curSubType_].btnOn, false)
  self.uiBinder.Ref:SetVisible(self.btnGroups_[self.curSubType_].btnOff, true)
  self.curSubType_ = type
  if self.subViews_[self.curSubType_] == nil then
    self.subViews_[self.curSubType_] = require(RightSubLua[self.curSubType_]).new(self)
  end
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  self.curSubView_ = self.subViews_[self.curSubType_]
  self.curSubView_:Active(nil, self.uiBinder.node_sub)
  self.uiBinder.Ref:SetVisible(self.btnGroups_[type].btnOn, true)
  self.uiBinder.Ref:SetVisible(self.btnGroups_[type].btnOff, false)
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig({
    self.btnGroups_[type].functionId
  })
  self.uiBinder.img_icon:SetImage(self.btnGroups_[type].iconPath)
end

function Weapon_role_main_pcView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponRolePlayerPc, self, self.btnGroups_[RightSubType.PlayerInfo].btnOn.transform)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WeaponRolePlayerPc, self, self.btnGroups_[RightSubType.PlayerInfo].btnOff.transform)
end

function Weapon_role_main_pcView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.WeaponRolePlayerPc, self)
end

function Weapon_role_main_pcView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Weapon_role_main_pcView
